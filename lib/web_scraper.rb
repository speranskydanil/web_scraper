require 'open-uri'
require 'nokogiri'

##
# WebScraper allows you to describe html structure declaratively,
# get appropriate blocks, and work with them as with ruby objects.
# @example
#  class Article < WebScraper
#    resource 'http://hbswk.hbs.edu/topics/it.html'
#
#    base css: '.tile-medium'
#
#    property :title,       xpath: './/h4/a/text()'
#    property :date,        xpath: './/li[1]/text()'
#    property :category,    xpath: './/li[2]/a/text()'
#    property :description, xpath: './/p/text()'
#
#    key :title
#  end
#
#  puts "#{Article.count} articles were found"
#  puts
#
#  articles = Article.all
#
#  articles.each do |article|
#    header = article.title
#    puts header
#    puts '=' * header.length
#    puts
#
#    subheader = "#{article.date} #{article.category}"
#    puts subheader
#    puts '-' * subheader.length
#    puts
#
#    puts article.description
#    puts
#  end
#
#  article =  Article.find('Tech Investment the Wise Way')
#
#  puts article.description
class WebScraper
  ##
  # The error raises when a user tries to call a class method
  # when not all required attributes were defined.
  class ConfigurationError < RuntimeError
    def message
      'resource, base, properties and key should be defined'
    end
  end

  ##
  # The error raises when a user tries to define resource improperly.
  class ResourceDefentitionError < RuntimeError
    def message
      'resource should be a string'
    end
  end

  ##
  # The error raises when a user tries to define base improperly.
  class BaseDefentitionError < RuntimeError
    def message
      'base should be a selector (:css|:xpath => String)'
    end
  end

  ##
  # The error raises when a user tries to define propery improperly.
  class PropertyDefentitionError < RuntimeError
    def message
      'property is a name (with type optionally) ' +
      'and a selector (:css|:xpath => String)'
    end
  end

  ##
  # The error raises when a user tries to define key improperly.
  class KeyDefentitionError < RuntimeError
    def message
      'key should be a name of a defined property'
    end
  end

  class << self
    ##
    # Loads html page, detects appropriate blocks,
    # wraps them in objects.
    # The result will be cached.
    # @example
    #  articles = Article.all
    def all
      raise ConfigurationError unless valid?

      @all ||= Nokogiri::HTML(open(_resource))
               .send(*_base).map { |node| new(node) }
    end

    ##
    # Returns number of objects found.
    # @example
    #  puts "#{Article.count} articles were found"
    def count
      all.size
    end

    ##
    # Resets cache of the html data.
    # @example
    #  Article.reset
    def reset
      @all = nil
    end

    ##
    # Finds first object with required key.
    # @example
    #  article = Article.find('Tech Investment the Wise Way')
    def find(key)
      all.find { |e| e.send(_key) == key }
    end

    ##
    # Defines resource -- url of the html page.
    # @example
    #  class Article < WebScraper
    #    ...
    #    resource 'http://hbswk.hbs.edu/topics/it.html'
    #    ...
    #  end
    def resource(_resource)
      raise ResourceDefentitionError unless _resource.is_a? String

      @_resource = _resource
    end

    attr_reader :_resource

    ##
    # Defines base -- selector which determines blocks of content.
    # You can use css or xpath selectors.
    # @example
    #  class Article < WebScraper
    #    ...
    #    base css: '.tile-medium'
    #    ...
    #  end
    def base(_base)
      raise BaseDefentitionError unless valid_selector? _base

      @_base = _base.to_a.flatten
    end

    attr_reader :_base

    ##
    # Defines property -- name (and type optionally) and selector.
    # You can use css or xpath selectors.
    # Types determine returning values.
    # Available types (default is string): string, integer, float, node.
    # The node option means nokogiri node.
    # @example
    #  class Article < WebScraper
    #    ...
    #    property :title,           xpath: './/h4/a/text()'
    #    property  views: :integer, xpath: './/h4/span/text()'
    #    ...
    #  end
    def property(*args)
      @properties ||= {}

      exception = PropertyDefentitionError

      case args.length
      when 1
        params = args[0]

        raise exception unless params.is_a? Hash

        info = params.reject { |k| [:css, :xpath].include? k }
        selector = params.select { |k| [:css, :xpath].include? k }
      when 2
        name, selector = args
        info = { name => :string }
      else
        raise exception
      end

      raise exception unless valid_selector? selector
      raise exception unless valid_info? info

      name = info.keys.first
      type = info.values.first
      selector = selector.to_a.flatten

      @properties[name] = { type: type, selector: selector }
    end

    attr_reader :properties

    ##
    # Defines key -- property which will be used in find method.
    # @example
    #  class Article < WebScraper
    #    ...
    #    key :title
    #    ...
    #  end
    def key(_key)
      raise KeyDefentitionError unless properties.keys.include? _key

      @_key = _key
    end

    attr_reader :_key

    ##
    # Checks if all attributes were set.
    def valid?
      _resource && _base && _key
    end

    ##
    # Checks if selector was defined correctly.
    def valid_selector?(selector)
      (selector.is_a? Hash) &&
      (selector.size == 1) &&
      ([:css, :xpath].include? selector.keys.first) &&
      (selector.values.first.is_a? String)
    end

    ##
    # Checks if property information (i.e. name and type) were defined correctly.
    def valid_info?(info)
      (info.is_a? Hash) &&
      (info.size == 1) &&
      (info.keys.first.is_a? Symbol) &&
      ([:string, :integer, :float, :node].include? info.values.first)
    end

    private :new
  end

  ##
  # Sets nokogiri node. It's private method.
  def initialize(node)
    @node = node
  end

  ##
  # Allows you to use nokogiri css method directly on your object.
  # It proxies it to nokogiri node.
  def css(*args)
    @node.css(*args)
  end

  ##
  # Allows you to use nokogiri xpath method directly on your object.
  # It proxies it to nokogiri node.
  def xpath(*args)
    @node.xpath(*args)
  end

  ##
  # Returns appropriate value for property if found.
  # Converts it to the defined type.
  # @example
  #  puts article.description
  def method_missing(name, *args, &block)
    if self.class.properties.key? name
      property = self.class.properties[name]

      type = property[:type]
      value = @node.send(*property[:selector])

      case type
      when :string  then value.text.strip
      when :integer then value.text.to_i
      when :float   then value.text.to_f
      when :node    then value
      end
    else
      super(name, *args, &block)
    end
  end
end

