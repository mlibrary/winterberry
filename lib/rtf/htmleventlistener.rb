module UMPTG::RTF
  require 'htmlentities'

  class HTMLEventListener < UMPTG::RTF::EventListener

    @@encoder = nil

    def initialize
      super()
      @para_number = 0
    end

    def start_document(args = {})
      #super(args)

      # Counter for providing numbers for marked paragraphs.
      @para_number = 0

      append_markup("<?xml version=\"1.0\" encoding=\"UTF-8\"?>")
      append_markup("<html xmlns=\"http://www.w3.org/1999/xhtml\">")
      append_markup("<head></head>")
      append_markup("<body>")
    end

    def end_document(args = {})
      #super(args)
      append_markup("</body>")
      append_markup("</html>")
    end

    # Start a new block.
    def start_element(args = {})
      #super(args)

      event_context = args[:event_context]
      section = args[:section]
      parser_context = section[:parser_context]

      # Determine the paragraph for this block.
      style = parser_context[:paragraph_style]

      # If a new division, then open a new section.
      if parser_context[:division]
        event_context[:stack].push("section")
        append_markup("<section class=\"#{style}\">")
        return
      end

=begin
      if parser_context[:startlist]
        event_context[:stack].push("ol")
        append_markup("<ol class=\"#{style}\">")
        return
      end
=end

      rtf_document = event_context[:rtf_document]

      # Determine the style name for this block.
      # The ids may change from document to document,
      # so rely on the names.
      style_name = rtf_document.style_table[style]
      raise "Error: unknown style #{style}" if style_name.nil?
      #puts "#{style}:|#{style_name}|"

      # From the style name, select the block element.
      case style_name
      when "Definition Heading 1", "PdeC Heading 1", "PdeC Heading 2", "PdeC Heading 3"
        # Header element for a division.
        # Determine the current outline level
        outlinelevel = parser_context[:outlinelevel]
        outlinelevel = 0 if outlinelevel.nil? or outlinelevel < 0

        # Select the h[3-?] header element.
        elem_name = "h#{outlinelevel+3}"
      else
        # Not a divisoion. Use a paragraph element.
        elem_name = "p"
      end

      # Push this element on the stack and add its
      # markup to the output string.
      event_context[:stack].push(elem_name)
      append_markup("<#{elem_name} class=\"#{style}\">")
    end

    # Close a block.
    def end_element(args = {})
      #super(args)

      event_context = args[:event_context]

      # Pop element off stack and close the block.
      elem_name = event_context[:stack].pop
      append_markup("</#{elem_name}>")
    end

    # Insert text and possibly inline markup.
    def characters(args = {})
      #super(args)

      event_context = args[:event_context]
      section = args[:section]
      parser_context = section[:parser_context]
      mods = section[:modifiers]

      # Determine the paragraph and character styles
      # for this text. If a character style is present,
      # use it. Otherwise, fall back on the paragraph
      # style.
      para_style = parser_context[:paragraph_style]
      char_style = parser_context[:character_style]
      style = para_style
      if char_style >= 0 and para_style == 0
        style = char_style
      end

      # Determine the style name for this block.
      # The ids may change from document to document,
      # so rely on the names.
      rtf_document = event_context[:rtf_document]
      style_name = rtf_document.style_table[style]
      raise "Error: unknown style #{style}" if style_name.nil?
      puts "#{style}:|#{style_name}|"

      # Determine whether to wrap any inline style markup.
      inline_cnt = 0
      if style_name == "Paragraph Number"
        elem_name = "span"
        event_context[:stack].push(elem_name)
        @para_number += 1
        append_markup("<#{elem_name} id=\"para#{@para_number}\" style=\"#{style}\">")
        inline_cnt += 1
      end
      if style_name == "Frequently Used Term + Term w/ Definition"
        elem_name = "span"
        event_context[:stack].push(elem_name)
        append_markup("<#{elem_name} style=\"#{style}\">")
        inline_cnt += 1
      end
      if style_name == "Historical Character"
        elem_name = "a"
        event_context[:stack].push(elem_name)
        append_markup("<#{elem_name} style=\"#{style}\">")
        inline_cnt += 1
      end
      if mods[:strikethrough]
        elem_name = "s"
        event_context[:stack].push(elem_name)
        append_markup("<#{elem_name}>")
        inline_cnt += 1
      end
      if mods[:subscript]
        elem_name = "sub"
        event_context[:stack].push(elem_name)
        append_markup("<#{elem_name}>")
        inline_cnt += 1
      end
=begin
Don't know why this is being set for footnotes.
      if mods[:superscript]
        elem_name = "sup"
        event_context[:stack].push(elem_name)
        append_markup("<#{elem_name}>")
        inline_cnt += 1
      end
=end
      if mods[:underline]
        elem_name = "u"
        event_context[:stack].push(elem_name)
        append_markup("<#{elem_name}>")
        inline_cnt += 1
      end
      if mods[:bold]
        elem_name = "b"
        event_context[:stack].push(elem_name)
        append_markup("<#{elem_name}>")
        inline_cnt += 1
      end
      if mods[:italic]
        elem_name = "i"
        event_context[:stack].push(elem_name)
        append_markup("<#{elem_name}>")
        inline_cnt += 1
      end

      # Encode any entities.
      @@encoder = HTMLEntities.new if @@encoder.nil?
      txt = @@encoder.encode(section[:text])
      append_text(txt)

      # Close off any inline markup.
      while inline_cnt > 0
        elem_name = event_context[:stack].pop
        append_markup("</#{elem_name}>")
        inline_cnt -=1
      end
    end
  end
end
