#!/usr/bin/env ruby

require "pry"
require "colorize"
require "mechanize"
require "slop"

SELF_DIR = File.expand_path("../", __FILE__)
OUT_FILE_NAME = "#{SELF_DIR}/res/quotes.out.xml"
require_relative "#{SELF_DIR}/lib/bash_quotes_picker.rb"

quotes = BashorgQuotesPicker.new.parseArgs(ARGV).scrape

File.open(OUT_FILE_NAME, "w") { |file| file << quotes.to_xml }  

#begin 
#  opts = Slop.parse(ARGV, strict: true) do
#    on "f=", "outfile=", "Output file", default: "#{SELF_DIR}/res/quotes.out.xml"
#  end
#rescue Slop::Error => e                                                                                                                                          
#  abort(e.message)                                                                                                                                               
#end    
#File.open(opts[:outfile], "w") { |file| file << quotes.to_xml }  

