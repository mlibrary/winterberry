module ManifestOLD

  MONOGRAPH_FILE_NAME = '://:MONOGRAPH://:'

  def self.find_monograph(manifest_csv)
    # Find monograph row.
    monograph_row = manifest_csv.find {|row| row['file_name'] == MONOGRAPH_FILE_NAME }
    if monograph_row == nil
      puts "Error: no CSV monograph row"
      return nil
    end
    return monograph_row
  end

  def self.noid_find_monograph(manifest_csv, noid)
    # Find monograph row using noid.
    monograph_row = manifest_csv.find {|row| row['noid'] == noid }
    if monograph_row == nil
      puts "Error: no monograph row for noid #{noid}"
      return nil
    end
    return monograph_row
  end

  def self.find_ebook_isbn(manifest_csv, noid)
    # Find monograph row.
    monograph_row = noid_find_monograph(manifest_csv, noid)
    if monograph_row == nil
      return nil
    end

    # Determine the ebook ISBN without dashes.
    isbns = monograph_row['isbn(s)']
    if isbns == nil or isbns.empty?
      puts "Error: no isbns found for noid #{noid}"
      return nil
    end

    # Look for OA ISBN first, then the ebook ISBN.
    ebook_isbns = isbns.split(';').select {|isbn|
      isbn.strip.downcase.match('[0-9]+[ ]+\(open access\)')
    }
    if ebook_isbns.empty?
      ebook_isbns = isbns.split(';').select {|isbn|
        isbn.strip.downcase.match('[0-9]+[ ]+\(ebook\)')
      }
    end

    if ebook_isbns.empty?
      puts "Error: no ebook isbn found for noid #{noid}"
      return nil
    end
    puts "Warning: multiple ebook isbns found for noid #{noid}" if ebook_isbns.count > 1

    ebook_isbn = ebook_isbns[0].sub(/\([^\)]*\)/, '').strip.gsub('-', '')
    return ebook_isbn
  end

  def self.find_epub_file_name(manifest_csv)
    epub_row = manifest_csv.find {|row| row['representative_kind'] == 'epub' }
    if epub_row == nil
      puts "Error: no epub row found."
      return nil
    end
    epub_file_name = epub_row['file_name']
    return epub_file_name
  end

  def self.save(manifest_csv, path)
    puts "Saving manifest file #{File.basename(path)}"
    File.open(path, "w") do |f|
      f.write(manifest_csv)
    end
  end

  def self.name_find_fileset(manifest_csv, file_name)
    if file_name != nil
      file_name_base = File.basename(file_name, ".*")
      fileset_row = manifest_csv.find {|row| File.basename(row['file_name'], ".*") == file_name_base }
      return fileset_row unless fileset_row == nil
    end

    return {
              "noid" => "",
              "resource_name" => "",
              "link" => "",
              "embed_code" => ""
           }
  end

  def self.noid_find_fileset(manifest_csv, noid)
    if noid != nil and !noid.empty?
      fileset_row = manifest_csv.find {|row| row['noid'] == noid }
      return fileset_row unless fileset_row == nil
    end

    return {
              "noid" => "",
              "resource_name" => "",
              "link" => "",
              "embed_code" => ""
           }
  end
end