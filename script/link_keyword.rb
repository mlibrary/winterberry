#!/usr/bin/env ruby
# frozen_string_literal: true

require 'optparse'
require 'ostruct'

# Process the script parameters.
options = OpenStruct.new
#options.publisher_dir = Dir.pwd
options.publisher_dir = "s:/Information\ Management/Fulcrum/UMP"
#options.publisher_dir = "c:/Users/tbelc/Documents/winterberry_production/Information\ Management/Fulcrum/UMP/"
options.vendor = "default"
options.fulcrum_host = nil
option_parser = OptionParser.new do |opts|
  opts.banner = "Usage: #{File.basename(__FILE__)} <epub_file> [<epub_file>..]"
  opts.on_tail('-h', '--help', 'Print this help message') do
    puts opts
    exit 0
  end
end
option_parser.parse!(ARGV)
if ARGV.count < 1
  puts option_parser.help
  return
end

# Determine the root directory of the code base.
script_dir = File.expand_path(File.dirname(__FILE__))
root_dir = File.dirname(script_dir)

require_relative File.join(root_dir, 'lib', 'epub')
require_relative File.join(root_dir, 'lib', 'xmlutil')

epub_file_list = ARGV

epub_file_list.each do |epub_file|
  epub_file = File.expand_path(epub_file)
  unless File.file?(epub_file)
    puts "Error: invalid EPUB file #{epub_file}"
    next
  end
  puts "Processing file #{File.basename(epub_file)}"

  # Create the EPUB from the specified file.
  epub = UMPTG::EPUB::Archive.new(:epub_file => epub_file)
  epub.spine.each do |item|
    puts "Processing item #{item.name}"
    STDOUT.flush

    # Create the XML tree.
    content = item.get_input_stream.read
    begin
      doc = Nokogiri::XML(content, nil, 'UTF-8')
    rescue Exception => e
      puts e.message
      next
    end

    xpath = ".//*[local-name()='span' and (@class='tetr' or @class='tetr-i')]"
    node_list = doc.xpath(xpath)
    node_list.each do |node|
      puts "#{node['class']}: #{node.text}"
    end
  end
end
