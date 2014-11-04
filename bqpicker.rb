#!/usr/bin/env ruby

require "pry"
require "slop"

SELF_DIR = File.expand_path("../", __FILE__)
RES_DIR = "#{SELF_DIR}/res"

Dir["#{SELF_DIR}/lib/*.rb"].each { |lib| require_relative lib }

def parse_args(argv)
  opts = Slop.new(strict: true, help: true) do 
    banner "Usage [OPTIONS]"
    on "v", "verbose", "Verbose mode"
    on "f=", "ofname=", "Output file",               default: "#{RES_DIR}/quotes.out.xml"
    on "n=", "num=", "Number of quotes for picking", default: 5
  end
  begin 
    opts.parse!(argv)
  rescue Slop::Error => e
    abort(opts.help)
  end

  opts
end

def display_quotes(quotes)
  quotes.each do |quote|
    QuotesOutput::disp_quote(quote)
  end
end

opts = parse_args(ARGV)
quotes = BashorgQuotesPicker.new.scrape(opts[:num].to_i)

display_quotes(quotes) if opts.verbose?

xml_out_doc = XmlOut::get_xml_doc(quotes, node_name: "quote")
XmlOut::write(xml_out_doc, opts[:ofname])
