module UMPTG::Resources

  require 'zip'

  class EpubResourceProcessor
    def self.process(args = {})

      epub_file = args[:epub_file]
      default_action_str = args[:default_action_str]
      process_dir = args[:processing_dir]
      resource_metadata = args[:resource_metadata]
      resource_map_file = args[:resource_map_file]
      fulcrum_css_file = args[:fulcrum_css_file]

      # Determine the project directory for storing the modified .xhtml
      # and the OPF files.
      dest_epub_dir = File.join(process_dir, "epub")

      puts "Using resource map file #{File.basename(resource_map_file)}"
      resource_map = UMPTG::ResourceMap::Map.new(
            :xml_path => resource_map_file,
            :default_action => default_action_str
          )

      # Save the resource actions file within a new epub structure
      # for archival purposes.
      epub_src_dir = File.join(dest_epub_dir, "META-INF", "src")
      FileUtils.mkdir_p epub_src_dir
      epub_resource_map_file = File.join(epub_src_dir, File.basename(resource_map_file))
      resource_map.save(epub_resource_map_file,
             :save_csv => true
           )

      reference_processor = UMPTG::Resources::ReferenceProcessor.new
      resource_processor = UMPTG::Resources::ResourceProcessor.new(
                  :resource_map => resource_map,
                  :resource_metadata => resource_metadata,
                  :default_action_str => default_action_str,
                  :reference_processor => reference_processor
                  )

      # Provide the directory path for adding the stylesheet link.
      # Possible option?
      fulcrum_css_name = File.basename(fulcrum_css_file)
      #fulcrum_css_dir = "../Styles"
      fulcrum_dest_css_dir = "./"
      fulcrum_dest_css_file = File.join(fulcrum_dest_css_dir, fulcrum_css_name)

      # Create the EPUB from the specified file.
      epub = UMPTG::EPUB::Archive.new(:epub_file => epub_file)

      rendition = epub.renditions.first
      spine_items = rendition.spine_items

      html_path_update_list = []
      remote_resources_list = []
      spine_items.each do |item|
        puts "Processing file #{item.name}"
        STDOUT.flush

        # Assign the output file name.
        dest_file = File.join(dest_epub_dir, item.name)

        # Create the XML tree.
        content = item.get_input_stream.read
        begin
          doc = Nokogiri::XML(content, nil, 'UTF-8')
        rescue Exception => e
          puts e.message
          next
        end

        # Determine the list of actions completed.
        # The -e flag must be specified for the actions
        # to be completed.
        action_list = resource_processor.process(doc)
        result = action_list.index { |action| action.status == Action.COMPLETED }
        if result

          # At last one action was completed. Remember that this
          # file was updated.
          html_path_update_list << dest_file

          # If resources were embedded, then we need to set the
          # remote-resource property in the OPF file.
          has_remote_resources = action_list.index { |action|
                      action.status == Action.COMPLETED and action.reference_action_def.action_str == "embed"
          }
          if has_remote_resources
            remote_resources_list << dest_file
          end

          # Add the CSS stylesheet link that manages the Fulcrum resource display.
          level = File.dirname(item.name).split(File::SEPARATOR).count
          if level == 1
            XMLUtil.add_css(doc, fulcrum_dest_css_file)
          else
            fpath = (('..' + File::SEPARATOR) * (level-1)) + fulcrum_css_name
            XMLUtil.add_css(doc, fpath)
          end
          puts "Added CSS stylesheet \"#{fulcrum_css_name}\"."

          # Save the modified xhtml file.
          FileUtils.mkdir_p File.dirname(dest_file)
          XMLUtil.save(doc, dest_file)
        end
        puts "\n"
      end

      if html_path_update_list.count > 0
        # xhtml files were modified. Need to update the OPF file.
        opf_item = rendition.opf_item
        opf_content = opf_item.get_input_stream.read unless opf_item.nil?
        if opf_content.nil?
          puts "Error: OPF file not found."
        else
          # Create XML tree for the OPF file.
          begin
            doc = Nokogiri::XML(opf_content, nil, 'UTF-8')
          rescue Exception => e
            puts e.message
            exit
          end

          # Locate the <manifest>.
          manifest_node = doc.xpath("//*[local-name()='manifest']")
          if manifest_node == nil
            puts "No manifest node"
          else
            # Add the manifest entry for the Fulcrum CSS stylesheet.
            # If another CSS stylesheet is present, add it after.
            # Otherwise, add it as last child.
            item_node = doc.create_element(
                    "item",
                    :href => fulcrum_dest_css_file,
                    :id => "fulcrum_default",
                    )
            item_node['media-type'] = "text/css"

            node_list = manifest_node.xpath("./*[local-name()='item' and @media-type='text/css']")
            if node_list == nil
              manifest_node.add_child(item_node)
            else
              node_list.last.add_next_sibling(item_node)
            end

            # Copy the Fulcrum CSS stylesheet into the epub structure.
            FileUtils.cp(fulcrum_css_file, File.join(dest_epub_dir, "OEBPS", fulcrum_dest_css_file))
            #FileUtils.cp(fulcrum_css_file, File.join(dest_epub_dir, "OPS", fulcrum_dest_css_file))
          end

          # Add remote resources to the OPF file.
          puts "Adding remote resources to OPF file #{File.basename(opf_item.name)}"
          remote_resources_list.each do |path|
            path_basename = File.basename(path)
            node_list = doc.xpath("//*[local-name()='manifest']/*[local-name()='item' and contains(@href, '#{path_basename}')]")
            node_list.each do |node|
              if node.has_attribute?("properties")
                node['properties'] += " remote-resources"
              else
                node['properties'] = "remote-resources"
              end
            end
          end

          # Save the OPF file.
          XMLUtil.save(doc, File.join(dest_epub_dir, opf_item.name))
        end
      end

      # Create the new epub. Remove the old one if it exists.
      processed_epub_file = File.join(process_dir, File.basename(epub_file))
      FileUtils.remove_file(processed_epub_file, true)

      # Create the new epub by reading the original one,
      # and replacing the files found in the epub directory.
      Zip::File.open(processed_epub_file, true) do |output_file|

        # Replace existing entries.
        epub.all_items.each do |input_entry|
          if !input_entry.name_is_directory?
            new_entry = File.expand_path(input_entry.name, dest_epub_dir)

            if File.exists?(new_entry)
              puts "Replacing file #{input_entry.name}"
              output_file.get_output_stream(input_entry.name) do |output_entry_stream|
                output_entry_stream.write(File.read(new_entry))
              end
            else
              puts "Using file #{input_entry.name}"
              input_entry.get_input_stream do |input_entry_stream|
                output_file.get_output_stream(input_entry.name) do |output_entry_stream|
                  output_entry_stream.write(input_entry_stream.read)
                end
              end
            end
          end
        end

        # Add any new entries.
        dest_epub_file_list = Dir.glob(File.join(dest_epub_dir, "**", "*"))
        dest_epub_file_list.each do |dest_epub_file|
          dest_epub_file_name = dest_epub_file.delete_prefix(dest_epub_dir + File::SEPARATOR)
          if !epub.epub.find_entry(dest_epub_file_name)
            if File.directory?(dest_epub_file)
              puts "Adding new directory #{dest_epub_file_name}"
              output_file.mkdir(dest_epub_file_name)
            else
              puts "Adding new file #{dest_epub_file_name}"
              output_file.get_output_stream(dest_epub_file_name) do |output_entry_stream|
                output_entry_stream.write(File.read(dest_epub_file))
              end
            end
          end
        end
      end
      return processed_epub_file
    end
  end
end

