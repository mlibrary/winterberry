module UMPTG::EPUB

  require 'zip'

  class Util
    def self.create(args = {})
      raise "Missing directory path" unless args.key?(:directory)
      dirpath = File.expand_path(args[:directory])

      case
      when args.key?(:epub_file)
        epub_file = args[:epub_file]
      else
        epub_file = File.join(File.dirname(dirpath), File.basename(dirpath) + ".epub")
      end

      Zip::OutputStream.open(epub_file) do |zos|
        # Make the mimetype the first item
        mimetype_list = Dir.glob(File.join(dirpath, "mimetype"))
        raise "Error: mimetype file missing" if mimetype_list.empty?

        mimetype_file = mimetype_list.first
        entry_name = mimetype_file.delete_prefix(dirpath + File::SEPARATOR)
        puts "Adding entry #{entry_name}"
        zos.put_next_entry(mimetype_file.delete_prefix(dirpath + File::SEPARATOR), nil, nil, Zip::Entry::STORED)
        zos.write(File.read(mimetype_file, mode: "rb"))

        Dir.glob(File.join(dirpath, "**", "*")).each do |fpath|
          unless File.directory?(fpath) or File.basename(fpath) == 'mimetype'
            entry_name = fpath.delete_prefix(dirpath + File::SEPARATOR)
            puts "Adding entry #{entry_name}"
            zos.put_next_entry(entry_name)
            zos.write(File.read(fpath, mode: "rb"))
          end
        end
      end
    end
  end
end
