module UMPTG::EPUB
  class DocumentProcessor
    def self.process(args = {})
      case
      when args.has_key?(:epub_file)
        epub_file = File.expand_path(args[:epub_file])
        raise "Error: invalid EPUB file." unless File.exists?(epub_file)
        epub = nil
      when args.has_key?(:epub)
        epub = args[:epub]
        raise "Error: invalid EPUB." if epub.nil?
      else
        raise "Error: no :epub_file or :epub parameter specified."
      end
      epub = UMPTG::EPUB::Archive.new(:epub_file => epub_file) if epub.nil?

      raise "Error: missing :processors parameter." unless args.has_key?(:processors)
      processors = args[:processors]
      raise "Error: no processors specified." if processors.nil? or processors.empty?

      item2doc = {}
      epub.spine.each do |item|
        puts "Processing file #{item.name}"
        STDOUT.flush

        # Create the XML tree.
        begin
          doc = Nokogiri::XML(item.get_input_stream.read, nil, 'UTF-8')
        rescue Exception => e
          puts e.message
          next
        end

        item2doc[item.name] = doc

        processors.each do |proc|
          proc.process(
                  name: item.name,
                  document: doc
                )
        end
      end

      id2fn = {}
      url_cnt = 0
      processors.first.fn_list.each do |fn_node|
        backlink_list = fn_node.xpath(".//*[@role='doc-backlink']")
        unless backlink_list.empty?
          backlink = backlink_list.first
          id = backlink['id']
          id2fn[id] = fn_node
        end

          url_list = fn_node.xpath(".//*[local-name()='a' and @class='url']")
          url_cnt += url_list.count
=begin
          url_list.each do |url_node|
            class_list = url_node['class'].split(' ')
            class_list << "url-force-wrap"
            url_node['class'] = class_list.join(' ')
          end
=end
      end
      puts "url: #{url_cnt}"

      processors.first.section_fnref.each do |section_node,fnref_node_list|
        title_node_list = section_node.xpath(".//*[local-name()='a' and @class='xref']")

        fnref_node_list.each_with_index do |fnref_node,ndx|
          new_num = ndx + 1
          fnref_node.content = new_num

          href = fnref_node["href"]
          id = href.split("#").last
          fnref_node["href"] = "Nurse-0018.xhtml\##{id}"
          fn_node = id2fn[id]
          backlink_list = fn_node.xpath(".//*[@role='doc-backlink']")
          unless backlink_list.empty?
            backlink = backlink_list.first
            backlink.content = new_num
          end
        end
        puts "Section: fn: #{fnref_node_list.count} #{title_node_list.first.content}"
      end

      epub.spine.each do |item|
        doc = item2doc[item.name]
        epub.add(
              entry_name: item.name,
              entry_content: UMPTG::XMLUtil.doc_to_xml(doc)
          )
      end

      return epub
    end
  end
end
