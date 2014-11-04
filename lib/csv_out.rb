require "fileutils"
require "csv"

class CSV
  def self.write_to_file(csv_string, ofname)
    ofdir = File.expand_path("../", ofname)
    FileUtils.mkdir_p(ofdir) unless File.directory?(ofdir)

    File.open(ofname, "w") { |f| f << csv_string }
  end

  def self.generate_from_hash(data_hash)
    csv_out_string = CSV.generate do |csv|
      csv << data_hash.first.map { |k,_| k.to_s }
      data_hash.each { |elem| csv << elem.map { |_,v| v } }
    end
    
    csv_out_string
  end
end
