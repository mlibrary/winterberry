#!/usr/bin/env ruby
# frozen_string_literal: true

# Script given a list of ISBNs, it generates a CSV
# of ISBN,NOID,DOI[,identifier]
csv_file = ARGV[0]
isbn_list = ARGV[1..-1]

=begin
puts "ISBN,NOID,DOI,ID"
isbn_list.each do |isbn|
  monograph_list = Monograph.where(isbn_numeric: [isbn])
  if monograph_list.empty?
    puts "#{isbn},,,"
  else
    monograph = monograph_list.first
    if monograph.identifier.empty?
      puts "#{isbn},#{monograph.id},https://doi.org/#{monograph.doi},"
    else
      puts "#{isbn},#{monograph.id},https://doi.org/#{monograph.doi},#{monograph.identifier.first}"
    end
  end
end
=end

#csv_file = File.join(File.dirname(__FILE__), "isbn_noid_doi_id.csv")
#csv_file = Tempfile.new(["isbn_noid_doi_id", ".csv"]).path
File.open(csv_file, "w") do |fp|
  fp.puts "ISBN,NOID,DOI,ID"
  isbn_list.each do |isbn|
    monograph_list = Monograph.where(isbn_numeric: [isbn])
    if monograph_list.empty?
      fp.puts "#{isbn},,,"
    else
      monograph = monograph_list.first
      if monograph.identifier.empty?
        fp.puts "\"#{isbn}\",\"#{monograph.id}\",\"https://doi.org/#{monograph.doi}\","
      else
        fp.puts "\"#{isbn}\",\"#{monograph.id}\",\"https://doi.org/#{monograph.doi}\",\"#{monograph.identifier.first}\""
      end
    end
  end
end
