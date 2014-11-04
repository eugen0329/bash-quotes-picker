require "fileutils"
require "csv"

module CsvOut
  #DEFAULT_OPTS = {}

  def write(csv_string, ofname)
    ofdir = File.expand_path("../", ofname)
    FileUtils.mkdir_p(ofdir) unless File.directory?(ofdir)

    File.open(ofname, "w") { |f| f << csv_string }
  end

  def make_csv_string(data, args = {})
    #opts = DEFAULT_OPTS
    #args.each { |k,v| opts[k] = v }
    csv_out_string = CSV.generate do |csv|
      csv << data.first.map { |k,_| k.to_s }
      data.each { |elem| csv << elem.map { |_,v| v } }
    end
    
    csv_out_string
  end

  module_function :write, :make_csv_string
end
