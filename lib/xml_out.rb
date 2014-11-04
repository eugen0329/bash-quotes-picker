require "nokogiri"
require "fileutils"

class XmlOut
  DEFAULT_OPTS = {encoding: 'UTF-8', node_name: 'node'}

  def self.write_to_file(xml_doc, ofname)
    ofdir = File.expand_path("../", ofname)
    FileUtils.mkdir_p(ofdir) unless File.directory?(ofdir)

    File.open(ofname, "w") { |f| f << xml_doc.to_xml }
  end

  def self.make_xml_doc(data, args = {})
    opts = DEFAULT_OPTS
    args.each { |k,v| opts[k] = v }

    xml_out_doc = Nokogiri::XML::Builder.new(encoding: opts[:encoding]) { |xml| xml.root }.doc

    data.each do |elem|
      xml_out_doc.root << make_node(xml_out_doc, elem, opts[:node_name])
    end
    
    xml_out_doc
  end

  private

  def self.make_node(doc, data, node_name)
    node = Nokogiri::XML::Node.new(node_name, doc) do |node|
      #node.content = content.gsub("\n", "<br />")
      node.content = get_node_content(data)
      data.each { |attr,val| node[attr] = val }
    end
    node 
  end

  def self.get_node_content(data)
    content = ""
    if data.has_key?(:content)
      content = data[:content]
      data.delete(:content)
    end

    content
  end
  #module_function :write, :get_xml_doc, :make_node, :get_node_content
end
