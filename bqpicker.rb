#!/usr/bin/env ruby

require "pry"
require "slop"

SELF_DIR = File.expand_path("../", __FILE__)
RES_DIR = "#{SELF_DIR}/res"
require_relative "#{SELF_DIR}/lib/bash_quotes_picker.rb"

opts = Slop.new(strict: true, help: true) do 
  banner "Usage [OPTIONS]"
  on "v", "verbose", "Verbose mode"
  on "f=", "outfile=", "Output file",              default: "#{RES_DIR}/quotes.out.xml"
  on "n=", "num=", "Number of quotes for picking", default: 5
end
begin 
  opts.parse!(ARGV)
rescue Slop::Error => e
  abort(opts.help)
end

quotes = BashorgQuotesPicker.new(opts.to_hash).scrape(opts[:num].to_i)

Dir.mkdir(RES_DIR) unless File.directory?(RES_DIR)
File.open(opts[:outfile], "w") { |file| file << quotes.to_xml }  

