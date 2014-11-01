require "mechanize"
require "slop"

require_relative "#{File.expand_path("../", __FILE__)}/quote_output.rb"

class BashorgQuotesPicker
  include QuoteOutput

  URL = "http://bashorg.org/"
  DEFAULT_OPTS = {verbose: false}

  attr_accessor :opts

  def initialize(opts = {})
    @agent = Mechanize.new { |agent| agent.user_agent = 'Custom agent' }
    @opts = DEFAULT_OPTS
    @opts.each_key { |k| @opts[k] = opts[k] if opts.has_key?(k) }
  end

  def scrape(amount = 1)
    page = @agent.get(URL)
    quotes = Nokogiri::XML::Builder.new(:encoding => 'UTF-8') { |xml| xml.root }.doc
    nodeAddingWorkflow = getNodeAddingWorkflow

    while amount > 0
      node_set = page.parser.css(".q").take(amount)
      node_set.each { |q| nodeAddingWorkflow.call(quotes, q) }
      amount -= node_set.count
      page = get_next_page(page)
      break if page.nil?
    end

    quotes
  end

  private 
  
  def getNodeAddingWorkflow
    if @opts[:verbose]
      workflow = lambda do |doc,q|
        attr, content = getNodeData(q)
        doc.root << makeNode(doc, attr, content)
        dispQuote(attr, content)
      end
    else
      workflow = ->(doc, q) { doc.root << makeNode(doc, *getNodeData(q)) }
    end

    workflow
  end

  def getNodeData(q)
      attr = {
        head:    q.at_css("a").content, 
        rating:  q.at_css("span").content
      }
      content = getNodeContent(q)

      return attr, content
  end

  def getNodeContent(q)
    q.at_css(".quote").css("br").each { |br| br.replace("\n") }
    content = q.at_css(".quote").content
  end

  def makeNode(doc, attr, content)
    node = Nokogiri::XML::Node.new("quote", doc) do |node|
      #node.content = content.gsub("\n", "<br />")
      node.content = content
      attr.each { |attr,val| node[attr] = val }
    end
    node 
  end

  def get_next_page(page)
    next_button = page.link_with(:text => /Далее/)
    return nil if next_button.nil?
    #page.replace()
    @agent.click(next_button)
    
  end
end
