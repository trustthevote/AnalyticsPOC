require 'nokogiri'

def validateFile(file, schema)
  print "File:   "+file+"\n"
  print "Schema: "+schema+"\n"
  # print "1\n"
  unless (schema = readXMLSchema(schema))
    printerrs
  end
  # print "2\n"
  unless (document = readXMLDocument(file))
    printerrs
  end
  # print "3\n"
  errors = schema.validate(document)
  # print "4\n"
  @validate_errs = errors if (errors.length > 0)
end

def readXMLSchema(schema)
  return Nokogiri::XML::Schema(File.read(schema))
rescue => e
  @validate_errs.push("Shouldn't happen, invalid built-in schema. "+e.message)
  return false
end

def readXMLDocument(file)
  document = Nokogiri::XML(File.read(file))
  return document
rescue => e
  @validate_errs.push("Invalid File format: "+e.message)
  return false
end

def printerrs
  print "**PRINT ERRORS**\n"
  @validate_errs.each{|e|print e.to_s+"\n"}
  exit(1)
end

def printHelp
  print "\n**HELP** 1 or 2 args required, both file names\n"
  print "  1st arg holds voterTranscationLog XML data\n"
  print "  2nd optional arg holds voterTranscationLog Schema definition\n"
  print "    when absent, schema assumed to be in ../public/schemas/VTL.xsd\n\n"
end

begin
  @validate_errs = []
  unless ARGV.length > 0
    printHelp
    exit(0)
  end
  file = ARGV.shift
  if file == 'help'
    printHelp
    exit(0)
  end
  if File.exists?(file)
    schema = "../public/schemas/VTL.xsd"
    schema = ARGV.shift if ARGV.length > 0
    unless File.exists?(schema)
      print "**ERROR** non-existent VTL schema file: "+schema.to_s+"\n"
      exit(1)
    end
    validateFile(file, schema)
  else
    print "**ERROR** non-existent VTL XML file: "+file.to_s+"\n"
    exit(1)
  end
  if @validate_errs.length > 0
    @validate_errs.each{|e|print e.to_s+"\n"}
  else
    print "OK\n"
  end
rescue => e
  print "** ERROR ** Fatal Error\n#{e.message}\n"
  @validate_errs.each{|e|print e.to_s+"\n"}
end
