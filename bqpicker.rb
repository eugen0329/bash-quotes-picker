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
    on "o=", "ofname=", "Output file",               default: "#{RES_DIR}/quotes.out"
    on "n=", "num=", "Number of quotes for picking", default: 5,    as: Integer
    on "-f=", "--outformat=", "Out file format",     default: :xml, as: Symbol
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

def write_in_atom_format(quotes, ofname)
  a = AtomOut.new 

  atom_out_doc = a.make_atom_doc(quotes) do |doc,feed|
    quotes.each do |quote|
      feed << a.make_entry(doc) do |entry|
        entry[:title]   = quote[:head]
        entry[:updated] = quote[:date]
        entry[:link]    = quote[:href]
        entry[:summary] = quote[:content]
      end
    end
  end

  XmlOut.write_to_file(atom_out_doc, ofname)
end

opts = parse_args(ARGV)
if opts.verbose?
  quotes = BashorgQuotesPicker.new.scrape(opts[:num]) { |q| QuotesOutput::disp_quote(q) }
else
  quotes = BashorgQuotesPicker.new.scrape(opts[:num]) 
end

#display_quotes(quotes) if opts.verbose?

case opts[:outformat]
when :xml
  xml_out_doc = XmlOut.make_xml_doc(quotes, node_name: "quote")
  XmlOut.write_to_file(xml_out_doc, opts[:ofname])
when :csv
  csv_out = CSV.generate_from_hash(quotes)
  CSV.write_to_file(csv_out, opts[:ofname])
when :atom
  write_in_atom_format(quotes, opts[:ofname])
end

