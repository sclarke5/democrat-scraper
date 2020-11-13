require 'nokogiri'
# require 'pry'
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
  # REMEMBER: css creates array of every element; at_css stops at first match

  # set up Watir/headless
  browser = Watir::Browser.new(:chrome, headless: true)
  browser.goto('http://berniesanders.com/issues')

  # set up Nokogiri
  url = 'https://berniesanders.com/issues'
  data = Nokogiri::HTML(open(url))

  headings = data.css('.accordion-title')
  stripped_headings = []
  headings.map do |h|
    stripped_headings << h.text.strip
    # h.text.gsub("\n", "") && h.text.gsub(" ", "")--keep around in case stripping isn't an option
  end

  open('./bernie.html', 'w') do |f|
    f.puts "<html>"
    f.puts "<link rel='stylesheet' type='text/css' href='style.css'>"
    f.puts "</html>"

    f.puts "<body>"
    f.puts "<h1>#{browser.title}</h1>"
    stripped_headings.each_with_index do |h, i|
      f.puts "<h2>#{h}</h2>"
      sleep 0.5
      browser.div(text: h).click
      sleep 0.5
      paragraph = browser.div(id: "collapse-issue-#{i+1}").text.gsub("Read More", "")
      f.puts "<p>#{paragraph}</p>"
    end 
    f.puts "</body>"
  end
end 

get_issues