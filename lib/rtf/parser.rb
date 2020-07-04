module UMPTG::RTF
  require 'ruby-rtf'

  class Parser < RubyRTF::Parser

    @@DEBUG_OUTPUT = false

    attr_reader :endnote_list

    # @param unknown_control_warning_enabled [Boolean] Whether to write unknown control directive warnings to STDERR
    def initialize(unknown_control_warning_enabled: true)
      super(unknown_control_warning_enabled: false)

      @parser_context = {
                :paragraph_style => 0,
                :character_style => -1,
                #:outlinelevel => 0,
                #:listlevel => 0,
                #:listtext => false,
                #:table => false
              }

      @doc = UMPTG::RTF::Document.new

      @endnote_list = []

    end

    # Parses the info group
    #
    # @param src [String] The source document
    # @param current_pos [Integer] The starting position
    # @return [Integer] The new current position
    #
    # @api private
    def parse_info(src, current_pos)

      group = 1

      style_name = []
      style_type = ""
      style_id = 0

      while (true)
        case(src[current_pos])
        when '{' then
          group += 1
          current_pos += 1
        when '\\' then
          ctrl, val, current_pos = parse_control(src, current_pos + 1)
          puts "#{__method__}:ctrl=#{ctrl}" if @@DEBUG_OUTPUT
=begin
          case(ctrl)
          end
=end
        when '}' then
          group -= 1
          break if group == 0
          current_pos += 1
        when ';' then
          current_pos += 1
        #when *["\r", "\n", " "]
        when *["\r", "\n"]
          current_pos += 1
        else
          style_name << src[current_pos]
          current_pos += 1
        end
      end

      current_pos
    end

    # Parses the stylesheet group
    #
    # @param src [String] The source document
    # @param current_pos [Integer] The starting position
    # @return [Integer] The new current position
    #
    # @api private
    def parse_stylesheet(src, current_pos)
      #return super(src, current_pos)

      group = 1

      style_name = []
      style_type = ""
      style_id = 0

      while (true)
        case(src[current_pos])
        when '{' then
          group += 1
          current_pos += 1
        when '\\' then
          ctrl, val, current_pos = parse_control(src, current_pos + 1)

          case(ctrl)
          #when *[:s,:cs,:ds,:ts,:tsrowd] then
          when *[:s,:cs,:ds,:ts] then
            style_type = ctrl
            style_id = val
          end
        when '}' then
          group -= 1
          break if group == 0
          current_pos += 1
        when ';' then
          puts "Style #{style_type} #{style_id} #{style_name.join}" if @@DEBUG_OUTPUT or true
          @doc.add_style(
                    :style_id => style_id,
                    :style_name => style_name.join
                  )
          style_name = []
          style_type = ""
          style_id = -1
          current_pos += 1
        #when *["\r", "\n", " "]
        when *["\r", "\n"]
          current_pos += 1
        else
          style_name << src[current_pos]
          current_pos += 1
        end
      end

      current_pos
    end

    def parse_footnote(src, current_pos)
      start_pos = current_pos

      group = 1
      while (true)
        case(src[current_pos])
        when '{' then
          group += 1
          current_pos += 1
        when '\\' then
          ctrl, val, current_pos = parse_control(src, current_pos + 1)

          case(ctrl)
          when false
          else
            #puts "#{__method__}: found #{ctrl}"
          end
        when '}' then
          group -= 1
          if group == 0
            puts "Done parsing footnote" if @@DEBUG_OUTPUT
            txt = src[start_pos..current_pos]
            @doc.add_endnote(:endnote => "{\\rtf1" + txt)
            #@endnote_list << "{\\rtf1" + txt
            break
          end
          current_pos += 1
        else
          current_pos += 1
        end
        #current_pos += 1
      end

      current_pos
    end

    STOP_CHARS = [' ', '\\', '{', '}', "\r", "\n", ';']

    # Parses a control switch
    #
    # @param src [String] The fragment to parse
    # @param current_pos [Integer] The position in string the control starts at (after the \)
    # @return [String, String|Integer, Integer] The name, optional control value and the new current position
    #
    # @api private
    def parse_control(src, current_pos = 0)
      if src[current_pos] == "~"
        ctrl = "~".to_sym
        val = nil
        return [ctrl, val, current_pos]
      end
      return super(src, current_pos)
    end

    # Handle a given control
    #
    # @param name [Symbol] The control name
    # @param val [Integer|nil] The controls value, or nil if non associated
    # @param src [String] The source document
    # @param current_pos [Integer] The current document position
    # @return [Integer] The new current position
    #
    # @api private
    def handle_control(name, val, src, current_pos)

      case name
      when :deflang
        puts "Found default language #{name.inspect} with #{val} at #{current_pos}." if @@DEBUG_OUTPUT
      when :outlinelevel
        puts "Found #{name.inspect} with #{val} at #{current_pos}." if @@DEBUG_OUTPUT
        @parser_context[:outlinelevel] = val
      when :par
        #puts "Found new para #{name.inspect} with #{val} at #{current_pos}." if @@DEBUG_OUTPUT
      when :pard
        #puts "Found default para #{name.inspect} with #{val} at #{current_pos}." if @@DEBUG_OUTPUT
        @parser_context[:paragraph_style] = 0
        @parser_context[:character_style] = -1
      when :s
        #puts "Found new para style #{name.inspect} with #{val} at #{current_pos}." if @@DEBUG_OUTPUT
        @parser_context[:paragraph_style] = val
      when :cs
        #puts "Found new char style #{name.inspect} with #{val} at #{current_pos}." if @@DEBUG_OUTPUT
        @parser_context[:character_style] = val
      when *[:ds,:ts,:tsrowd] then
        #puts "Found #{name.inspect} with #{val} at #{current_pos}" if @@DEBUG_OUTPUT
      when :listtext
        #puts "Found list text #{name.inspect} with #{val} at #{current_pos}." if @@DEBUG_OUTPUT
        #@parser_context[:listtext] = true
      when :ilvl
        #puts "Found list level #{name.inspect} with #{val} at #{current_pos}." if @@DEBUG_OUTPUT
        #@parser_context[:listlevel] = val
      when :intbl
        #puts "Found table #{name.inspect} with #{val} at #{current_pos}." if @@DEBUG_OUTPUT
        #@parser_context[:table] = true
      when :footnote
        puts "Found #{name.inspect} with #{val} at #{current_pos}." if @@DEBUG_OUTPUT
        current_pos = parse_footnote(src, current_pos)
      when :hex
        #puts "Found hex #{name.inspect} with #{val} at #{current_pos}." if @@DEBUG_OUTPUT
      end
      current_pos = super(name, val, src, current_pos)
      return current_pos
    end

    def force_section!(mods = {}, text =  nil)
      para = @current_section[:modifiers][:paragraph]
      #puts "Section #{@doc.sections.count+1}: para=#{para},level=#{@parser_context[:outlinelevel]},text: #{@current_section[:text]}" if @@DEBUG_OUTPUT

      @current_section[:parser_context] = @parser_context

      new_parser_context = @parser_context.clone
      new_parser_context[:character_style] = -1
      #new_parser_context[:listtext] = false
      #new_parser_context[:listlevel] = 0
      #new_parser_context[:table] = false
      new_parser_context.delete(:outlinelevel)

      @parser_context = new_parser_context

      super(mods, text)
    end
  end
end
