module UMPTG::RTF
  class Processor
    def self.process(args = {})
      rtf_content = args[:rtf_content]
      rtf_listener = args[:rtf_listener]

      rtf_parser = UMPTG::RTF::Parser.new
      rtf_document = rtf_parser.parse(rtf_content)

      rtf_document.endnotes.each do |endnote|
        rtf_document = rtf_parser.parse(endnote)

        section = rtf_document.sections.last
        parser_context = section[:parser_context]
        parser_context[:footnote_end] = true
        #parser_context[:outlinelevel] = 0
      end

      event_context = {
                  :rtf_document => rtf_document,
                  :rtf_listener => rtf_listener,
                  :open_paragraph => false,
                  :stack => [],
                  :block_wrapper_cnt => 0,
                  :cur_level => -1,
                  :table => false
                }

      rtf_listener.start_document()
      rtf_document.sections.each do |section|
        puts section
        puts

        process_section(event_context, section)
      end

      self.close_paragraph(event_context)

      cur_level = event_context[:cur_level]
      puts "cur_level=#{cur_level}"
      while cur_level >= 0
        self.end_element(event_context)
        cur_level -= 1
      end

      rtf_listener.end_document()

      return rtf_listener.output
    end

    private

    def self.process_section(event_context, section)
      rtf_listener = event_context[:rtf_listener]

      mods = section[:modifiers]
      parser_context = section[:parser_context]

=begin
      if parser_context[:listtext]
        unless event_context[:inlist]
          parser_context[:startlist] = true
          self.start_element(event_context, section)
          parser_context[:startlist] = false
        end
        event_context[:inlist] = true
        return
      end
=end

      if parser_context.key?(:outlinelevel)
        # Change in document structure.
        self.close_paragraph(event_context)

        # Close any divisions.
        cur_level = event_context[:cur_level]
        level = parser_context[:outlinelevel]
        #puts "cur: #{cur_level}, level: #{level}"
        while level <= cur_level
          self.end_element(event_context)
          cur_level -= 1
        end
        event_context[:cur_level] = level

        # Open new division. Maybe do this later?
        parser_context[:division] = true
        self.start_element(event_context, section)
        parser_context[:division] = false
      end

      if mods[:paragraph]
        # End of a paragraph.
        # If currently in an open para, close it;
        self.close_paragraph(event_context)
        return
      end

      txt = section[:text]
      unless txt.nil? or txt.strip.empty?
        # Found non-empty text. Open a new paragraph
        # if one is not currently open.
        unless event_context[:open_paragraph]
          self.start_element(event_context, section)
          event_context[:open_paragraph] = true
        end

        # Insert the text
        rtf_listener.characters(
                :event_context => event_context,
                :section => section
              )
      end
      if parser_context.key?(:footnote_end)
        # Word doesn't close its footnotes.
        # Currently, not sure where footnotes
        # go. For now, close the paragraph.
        self.close_paragraph(event_context)
      end
    end

    def self.start_element(event_context, section)
      rtf_listener = event_context[:rtf_listener]

      # Inform the application to open a new block.
      rtf_listener.start_element(
                :event_context => event_context,
                :section => section
              )
    end

    def self.end_element(event_context)
      rtf_listener = event_context[:rtf_listener]

      # Inform application to close a block.
      rtf_listener.end_element(:event_context => event_context)
    end

    def self.close_paragraph(event_context)
      if event_context[:open_paragraph]
        # Currently, within an open paragraph.
        # Close it.
        self.end_element(event_context)
        event_context[:open_paragraph] = false
      end
    end
  end
end
