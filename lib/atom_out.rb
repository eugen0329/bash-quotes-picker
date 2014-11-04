require "nokogiri"

class AtomOut
  DEFAULT_OPTS = {
    encoding: 'UTF-8', 
    feed_xmlns:    "default_feed_xmlns",
    feed_title:    "default_feed_title",
    feed_link:     "default_feed_link",
    feed_updated:  Time.now.strftime("%Y-%m-%dT%H:%M:%SZ"), 
    feed_id:       "default_feed_id", 
  }

  DEFAULT_ENTRY_OPTS = {
    title:    "default_entry_title",
    link:     "default_entry_link",
    id:       "default_entry_id", 
    updated:  Time.now.strftime("%Y-%m-%dT%H:%M:%SZ"), 
    summary:  "default_entry_summary"
  }

  def initialize(args = {})
    @opts = DEFAULT_OPTS
    args.each { |k,v| @opts[k] = v }
    yield(@opts) if block_given?
  end

  def make_atom_doc(data)
    atom_out_doc = get_atom_blank
    yield(atom_out_doc, atom_out_doc.at_css("feed")) if block_given?

    atom_out_doc
  end

  def make_entry(doc, args = {})
    @entry_opts = DEFAULT_ENTRY_OPTS
    args.each { |k,v| @entry_opts[k] = v }

    yield(@entry_opts) if block_given?

    entry = Nokogiri::XML::Node.new("entry", doc) do |entry|
      @entry_opts.each do |opt,val|
        entry <<  Nokogiri::XML::Node.new(opt.to_s, doc) { |t| t.content = val }
      end
    end

    entry
  end

  private

  def get_atom_blank
    Nokogiri::XML::Builder.new(encoding: @opts[:encoding]) do |xml| 
      xml.feed(xmlns: @opts[:feed_xmlns]) {
        xml.title   @opts[:feed_title]
        xml.link    @opts[:feed_link]
        xml.updated @opts[:feed_updated]
        xml.id      @opts[:feed_id]
      }
    end.doc
  end
end
