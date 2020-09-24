module UMPTG::EPUB

  require 'zip'

  class Archive
    attr_reader :epub, :renditions

    @@fragment_processor = nil
    @@fragment_selector = nil

    def initialize(args = {})
      @epub_file = args[:epub_file]
      reset
      load(@epub_file)
    end

    def get_entry(entry)
      item_list = @epub.glob(entry)
      return nil if item_list.nil? or item_list.empty?
      return item_list.first
    end

    def all_items
      load_epub if @epub.nil?
      return @epub.entries
    end

    def reset
      @epub = nil
      @renditions = []
    end

    def to_xhtml(args = {})
      case
      when args.key?(:rendition_label)
        rendition_label = args[:rendition_label]
        r_list = @renditions.select { |r| r.label == rendition_label }
        raise "Error: invalid rendition label #{rendition_label}" if r_list.empty?
        rendition = r_list.first
      when args.key?(:rendition)
        rendition = args[:rendition]
      else
        rendition = renditions.first
      end

      fragment_processor = FragmentProcessor.new if fragment_processor.nil?
      fragment_selector = ContainerSelector.new if fragment_selector.nil?

      lines = [
            "<?xml version=\"1.0\" encoding=\"UTF-8\"?>",
            "<html xmlns=\"http://www.w3.org/1999/xhtml\" xmlns:epub=\"http://www.idpf.org/2007/ops\">",
            "<head></head>",
            "<body>"
          ]
      rendition.spine_items.each do |item|
        path = File.join(File.dirname(item.name), File.basename(item.name, ".*")).gsub(/\//, '_')

        fragment_selector.containers = [ 'body' ]
        fragment_list = fragment_processor.process(
              :content => item.get_input_stream.read,
              :selector => fragment_selector
            )
        if fragment_list.empty?
          puts "Warning: empty body for #{item.name}"
          next
        end

        lines << "<div id=\"#{path}\">" if rendition.text_rendition?
        fragment_list.each do |fragment|
          body_elem = fragment.node

          div_elem_list = body_elem.xpath("./*")
          div_elem_list.each do |div_elem|
            div_elem.remove_attribute('id') if rendition.text_rendition?
            lines << div_elem.to_xhtml
          end
        end
        lines << "</div>" if rendition.text_rendition?
      end
      lines << "</body>"
      lines << "</html>"

      return lines.join
    end

    private

    def load(epub_file)
      if @epub.nil?

        fragment_processor = FragmentProcessor.new
        fragment_selector = ContainerSelector.new

        Zip::File.open(epub_file) do |epub|
          @epub = epub

          containers = epub.glob(File.join("META-INF", "container.xml"))
          next if containers.empty?

          containers.each do |container_entry|
            fragment_selector.containers = [ 'rootfile' ]
            fragment_list = fragment_processor.process(
                  :content => container_entry.get_input_stream.read,
                  :selector => fragment_selector
                )
            if fragment_list.empty?
              puts "Warning: no container found"
              next
            end

            fragment_list.each do |fragment|
              root_elem = fragment.node
              opf_file = root_elem['full-path']
              #opf_item = epub.glob(opf_file).first

              rendition = Rendition.new(
                              archive: epub,
                              rendition_label: root_elem['rendition:label'],
                              opf_file: opf_file
                            )
              renditions << rendition
            end
          end
        end
      end
    end
  end
end
