#!/usr/bin/env ruby

require "pry"
require "slop"

SELF_DIR = File.expand_path("../", __FILE__)
RES_DIR = "#{SELF_DIR}/res"
require_relative "#{SELF_DIR}/lib/bash_quotes_picker.rb"

def parse_args(argv)
  opts = Slop.new(strict: true, help: true) do 
    banner "Usage [OPTIONS]"
    on "v", "verbose", "Verbose mode"
    on "f=", "outfile=", "Output file",              default: "#{RES_DIR}/quotes.out.xml"
    on "n=", "num=", "Number of quotes for picking", default: 5
  end
  begin 
    opts.parse!(argv)
  rescue Slop::Error => e
    abort(opts.help)
  end

  opts
end

def write_to_file(filename, doc)
  if File.expand_path(filename).include?(RES_DIR) && ! File.directory?(RES_DIR) 
    Dir.mkdir(RES_DIR) 
  end
  File.open(filename, "w") { |file| file << doc.to_xml }  
end

opts = parse_args(ARGV)
quotes = BashorgQuotesPicker.new(opts.to_hash).scrape(opts[:num].to_i)
write_to_file(opts[:outfile], quotes)



