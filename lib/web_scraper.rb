require 'open-uri'
require 'nokogiri'

class WebScraper
  class ConfigurationError < RuntimeError
    def message
      'resource, base, properties and key should be defined'
    end
  end

  class ResourceDefentitionError < RuntimeError
    def message
      'resource should be a string'
    end
  end

  class BaseDefentitionError < RuntimeError
    def message
      'base should be a selector (:css|:xpath => String)'
    end
  end

  class PropertyDefentitionError < RuntimeError
    def message
      'property is a name (with type optionally) ' +
      'and a selector (:css|:xpath => String)'
    end
  end

  class KeyDefentitionError < RuntimeError
    def message
      'key should be a name of a defined property'
    end
  end

  class << self
    def all
      raise ConfigurationError unless valid?

      @all ||= Nokogiri::HTML(open(_resource))
               .send(*_base).map { |node| new(node) }
    end

    def count
      all.size
    end

    def expire
      @all = nil
    end

    def find(key)
      all.find { |e| e.send(_key) == key }
    end

    def resource(_resource)
      raise ResourceDefentitionError unless _resource.is_a? String

      @_resource = _resource
    end

    attr_reader :_resource

    def base(_base)
      raise BaseDefentitionError unless valid_selector? _base

      @_base = _base.to_a.flatten
    end

    attr_reader :_base

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

    def key(_key)
      raise KeyDefentitionError unless properties.keys.include? _key

      @_key = _key
    end

    attr_reader :_key

    def valid?
      _resource && _base && _key
    end

    def valid_selector?(selector)
      (selector.is_a? Hash) &&
      (selector.size == 1) &&
      ([:css, :xpath].include? selector.keys.first) &&
      (selector.values.first.is_a? String)
    end

    def valid_info?(info)
      (info.is_a? Hash) &&
      (info.size == 1) &&
      (info.keys.first.is_a? Symbol) &&
      ([:string, :integer, :float, :node].include? info.values.first)
    end

    private :new
  end

  def initialize(node)
    @node = node
  end

  attr_reader :node

  def css(*args)
    node.css(*args)
  end

  def xpath(*args)
    node.xpath(*args)
  end

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

