require "mechanize"
require "slop"

require_relative "#{File.expand_path("../", __FILE__)}/quote_output.rb"

class BashorgQuotesPicker
  include QuoteOutput

  URL = "http://bashorg.org/"

  attr_accessor :opts

  def initialize
    @agent = Mechanize.new { |agent| agent.user_agent = 'Custom agent' }
    @opts = Slop.new( strict: true, help: true ) do 
      banner "BashorgQuotesPicker: Usage [OPTIONS]"
      on "v", "verbose", "Verbose mode"
    end
  end
  
  def parseArgs(argv)
    begin 
      @opts.parse!(argv)
    rescue Slop::Error => e
      abort(opts.help)
    end
    self
  end

  def scrape
    document = Nokogiri::XML::Builder.new(:encoding => 'UTF-8') { |xml| xml.root }.doc

    nodeAddingWorkflow = getNodeAddingWorkflow
    @agent.get(URL).parser.css(".q").each do |q|
      nodeAddingWorkflow.call(document, q)
    end

    document
  end

  private 
  
  def getNodeAddingWorkflow
    if @opts.verbose? 
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
end
