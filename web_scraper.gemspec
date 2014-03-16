Gem::Specification.new do |s|
  s.name         = 'web_scraper'
  s.version      = '1.0.1'
  s.licenses     = ['MIT']
  s.authors      = ['Speransky Danil']
  s.summary      = 'Web Scraper is a library to build APIs by scraping static sites and use data as models.'
  s.description  = 'Web Scraper is a library to build APIs by scraping static sites and use data as models.'
  s.email        = 'speranskydanil@gmail.com'
  s.homepage     = 'http://speranskydanil.github.io/web_scraper/'
  s.files        = ['lib/web_scraper.rb']

  s.add_runtime_dependency 'nokogiri'
end

