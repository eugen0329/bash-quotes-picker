#!/usr/bin/env ruby

require "pry"
require "colorize"
require "mechanize"

class Bqpicker
  URL = "http://bashorg.org/"

  def initialize
    @agent = Mechanize.new { |agent| agent.user_agent = 'Custom agent' }
  end

  def makeNode(doc, content, attr)
    node = Nokogiri::XML::Node.new("quote", doc) do |node|
      node.content = content.gsub("\n", "<br />")
      attr.each { |attr,val| node[attr] = val }
    end
    node 
  end


  def scrape
    document =  Nokogiri::XML::Builder.new(:encoding => 'UTF-8') { |xml| xml.root }.doc
    @agent.get(URL).parser.css(".q").each do |q|
      attr, content = getNodeData(q)
      document.root << makeNode(document, content , attr.dup)
      dispQuote(attr, content)
    end
    File.open("./res/quotes.out.xml", "w") { |file| file << document.to_xml }
  end

  private 

  def getNodeData(q)
      attr = {
        head:    q.at_css("a").content, 
        rating:  q.at_css("span").content
      }
      content = getContent(q)
      return attr, content
  end

  def dispQuote(attr, content)
    puts "#{attr[:head]}".blue
    puts "#{content}"
    puts "♥ #{colorizeRating(attr[:rating])}\n\n"
  end

  def getContent(q)
    q.at_css(".quote").css("br").each { |br| br.replace("\n") }
    content = q.at_css(".quote").content
  end

  def colorizeRating(rating)
    color = :default
    rating.to_i > 0 ? color = :green : color = :red
    "#{rating}".colorize(color)
  end
end

Bqpicker.new.scrape
