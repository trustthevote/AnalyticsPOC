module ApplicationHelper
  def dir_archive
    "public/archive"
  end
  def dir_upload
    "public/upload"
  end
  def voter_records_file_name
    path = 'public/records'
    unless File.directory?(path) || FileUtils.mkdir(path)
      raise Exception, "No voter records repository: "+path
    end
    files = Array.new
    Dir.new(path).entries.each { |f| files.push(f) if f =~ /\.csv$/i }
    return "FILE.csv" if files.length < 1
    return files[0].to_s
  end
end
