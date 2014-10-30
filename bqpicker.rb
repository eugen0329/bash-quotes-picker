#!/usr/bin/env ruby

require "pry"
require "colorize"
require "mechanize"

page = Mechanize.new.get("http://bashorg.org/")

page.parser.css('br').each { |br| br.replace("\n") }
page.parser.css('.quote').map(&:text).reject(&:empty?).each do |quote|
  puts "#{quote}" + "\n"*2
end

