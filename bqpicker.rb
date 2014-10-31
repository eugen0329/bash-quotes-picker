#!/usr/bin/env ruby

require "pry"
require "colorize"
require "mechanize"

class Bqpicker
  URL = "http://bashorg.org/"

  def initialize
    @agent = Mechanize.new { |agent| agent.user_agent = 'Custom agent' }
  end

  def scrape
    @agent.get(URL).parser.css(".q").each do |q|
      q.at_css(".quote").css("br").each { |br| br.replace("\n") }
      puts "#{q.at_css("a").content}".blue
      puts "#{q.at_css(".quote").text}\n"
      puts "♥ #{colorizeVote(q.at_css("span").text.to_i)}\n\n"
    end
  end

  private 

  def colorizeVote(rating)
    color = :default
    rating.to_i > 0 ? color = :green : color = :red
    "#{rating}".colorize(color)
  end
end

Bqpicker.new.scrape
