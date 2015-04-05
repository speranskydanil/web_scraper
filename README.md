# Web Scraper

Web Scraper is a library to build APIs by scraping static sites and use data as models.

## Installation

    gem install web_scraper

    require 'web_scraper'

## Usage

**Example**

```ruby
require 'web_scraper'

class Article < WebScraper
  resource 'http://hbswk.hbs.edu/topics/it.html'

  base css: '.tile-medium'

  property :title,       xpath: './/h4/a/text()'
  property :date,        xpath: './/li[1]/text()'
  property :category,    xpath: './/li[2]/a/text()'
  property :description, xpath: './/p/text()'

  key :title
end

puts "#{Article.count} articles were found"
puts

articles = Article.all

articles.each do |article|
  header = article.title
  puts header
  puts '=' * header.length
  puts

  subheader = "#{article.date} #{article.category}"
  puts subheader
  puts '-' * subheader.length
  puts

  puts article.description
  puts
end

article =  Article.find('Tech Investment the Wise Way')

puts article.description
```

**Output**

    Optimal Auction Design and Equilibrium Selection in Sponsored Search Auctions
    =============================================================================

    14 Jan 2010 Working Papers
    --------------------------

    Reserve prices may have an important impact on search advertising marketplaces. But the effect of reserve prices can be opaque, particularly because it is not always straightforward to compare "before" and "after" conditions. HBS professor Benjamin G. Edelman and Yahoo's Michael Schwarz use a pair of mathematical models to predict responses to reserve prices and understand which advertisers end up paying more.

    The IT Leader’s Hero Quest
    ==========================

    11 May 2009 Research & Ideas
    ----------------------------

    Think you could be CIO? Jim Barton is a savvy manager but an IT newbie when he's promoted into the hot seat as chief information officer in , a novel by HBS professors  and  and coauthor . Can Barton navigate his strange new world quickly enough? Q&A with the authors, and book excerpt.

## Reference

**WebScraper.all**  
*Loads html page, detects appropriate blocks,  
wraps them in objects.  
The result will be cached.*

    articles = Article.all

**WebScraper.count**  
*Returns number of objects found.*

    puts "#{Article.count} articles were found"

**WebScraper.reset**  
*Resets cache of the html data.*

    Article.reset

**WebScraper.find(key)**  
*Finds first object with required key.*

    article = Article.find('Tech Investment the Wise Way')

**WebScraper.resource(_resource)**  
*Defines resource -- url of the html page.*

    class Article < WebScraper
      ...
      resource 'http://hbswk.hbs.edu/topics/it.html'
      ...
    end

**WebScraper.base(_base)**  
*Defines base -- selector which determines blocks of content.  
You can use css or xpath selectors.*

    class Article < WebScraper
      ...
      base css: '.tile-medium'
      ...
    end

**WebScraper.property(*args)**  
*Defines property -- name (and type optionally) and selector.  
You can use css or xpath selectors.  
Types determine returning values.  
Available types (default is string): string, integer, float, node.  
The node option means nokogiri node.*

    class Article < WebScraper
      ...
      property :title,           xpath: './/h4/a/text()'
      property  views: :integer, xpath: './/h4/span/text()'
      ...
    end

**WebScraper.key(_key)**  
*Defines key -- property which will be used in find method.*

    class Article < WebScraper
      ...
      key :title
      ...
    end

**WebScraper#css(*args)**  
*Allows you to use nokogiri css method directly on your object.  
It proxies it to nokogiri node.*

**WebScraper#xpath(*args)**  
*Allows you to use nokogiri xpath method directly on your object.  
It proxies it to nokogiri node.*

**WebScraper#property**  
**WebScraper#method_missing(name, *args, &block)**  
*Returns appropriate value for property if found.  
Converts it to the defined type.*

    puts article.description

**Author (Speransky Danil):**
[Personal Page](http://dsperansky.info) |
[LinkedIn](http://ru.linkedin.com/in/speranskydanil/en) |
[GitHub](https://github.com/speranskydanil?tab=repositories) |
[StackOverflow](http://stackoverflow.com/users/1550807/speransky-danil)

