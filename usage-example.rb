require './lib/web_scraper'

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

