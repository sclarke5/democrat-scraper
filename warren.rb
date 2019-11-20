require 'nokogiri'
require 'pry'
require 'open-uri'
require 'watir'
require 'chromedriver-helper'

BROWSER_METHODS = %w(element a link i ul li div input table tbody tfoot td tr th form hidden button execute_script h1 h2 h3 h4 h5 h6 select select_list window iframe script file_field span option footer)
PLURAL_BROWSER_METHODS = BROWSER_METHODS.map { |method| method + 's' }

# Define singular and collection browser methods
(BROWSER_METHODS + PLURAL_BROWSER_METHODS).each do |browser_method|
  define_method browser_method do |params = {}|
    browser.send browser_method, params
  end
end

  def get_issues
    browser = Watir::Browser.new(:chrome)
    url = 'http://elizabethwarren.com/plans'
    data = Nokogiri::HTML(open(url))

    browser.goto(url)
    headings = []
    h1s = data.css('h1')
    h1s.each_with_index do |c, i|
      if i > 2
        headings << c
      end
    end


    browser.h1(text: headings[3].text).present?

    open('./warren.html', 'w') do |f|
      f.puts "<html>"
      f.puts "<link rel='stylesheet' type='text/css' href='style.css'>"
      f.puts "</html>"

      f.puts "<body>"
      f.puts "<h1>#{browser.title}</h1>"
      headings.each do |h|
        f.puts "<h2>#{h}</h2>"
        binding.pry
        browser.execute_script('arguments[0].scrollIntoView();', browser.div(text: h.text))
        browser.div(text: h.text).click
        paragraph = browser.div(text: h.text).parent.text
        f.puts "<p>#{paragraph}</p>"
        browser.div(text: h.text).a.click
        binding.pry
      end
      f.puts "</body>"
    end 
  binding.pry  
  end

  def scroll_to(element)
    browser.execute_script('arguments[0].scrollIntoView();', element)
  end

get_issues