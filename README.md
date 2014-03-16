# Web Scraper

Web Scraper is a library to build APIs by scraping static sites and use data as models.

### Installation

    gem install web_scraper

    require 'web_scraper'

### Usage

**Example**

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

### TODO

* write documentation in code
* add overview in readme
* write tests

**Author (Speransky Danil):**
[Personal Page](http://dsperansky.info) |
[LinkedIn](http://ru.linkedin.com/in/speranskydanil/en) |
[GitHub](https://github.com/speranskydanil?tab=repositories) |
[StackOverflow](http://stackoverflow.com/users/1550807/speransky-danil)

