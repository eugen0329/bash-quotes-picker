require "mechanize"

class BashorgQuotesPicker
  URL = "http://bashorg.org/"

  attr_accessor :opts

  def initialize()
    @agent = Mechanize.new { |agent| agent.user_agent = 'Custom agent' }
  end

  def scrape(amount = 1)
    page = @agent.get(URL)
    quotes = []

    while amount > 0
      node_set = page.parser.css(".q").take(amount)   
      node_set.each do |q| 
        quotes << parse_node(q)
        yield(quotes.last) if block_given?
      end

      amount -= node_set.count
      page = get_next_page(page)
      break if page.nil?
    end

    quotes
  end

  private 

  def parse_node(q)
      attributes = {
        head:    q.at_css("a").content, 
        rating:  q.at_css("span").content,
        content:  getNodeContent(q)
      }

      attributes
  end

  def getNodeContent(q)
    q.at_css(".quote").css("br").each { |br| br.replace("\n") }
    content = q.at_css(".quote").content
  end

  def get_next_page(page)
    next_button = page.link_with(:text => /Далее/)
    return nil if next_button.nil?

    @agent.click(next_button)
  end
end
