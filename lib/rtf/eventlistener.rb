module UMPTG::RTF
  class EventListener

    attr_reader :output

    def initialize
      reset()
    end

    def start_document(args = {})
      #puts "#{__method__}: #{args}"
      append_markup("<#{__method__}>")
    end

    def end_document(args = {})
      #puts "#{__method__}: #{args}"
      append_markup("</#{__method__}>")
    end

    def start_element(args = {})
      #puts "#{__method__}: #{args}"
      elem = args[:elem]
      append_markup("<#{__method__} elem=\"#{elem}\">")
    end

    def end_element(args = {})
      #puts "#{__method__}: #{args}"
      elem = args[:elem]
      append_markup("</#{__method__} elem=\"#{elem}\">")
    end

    def characters(args = {})
      section = args[:section]

      txt = section[:text]
      append_text(txt)
    end

    def append_markup(txt)
      append_text(txt)
    end

    def append_text(txt)
      @output += txt
    end

    def reset
      @output = ""
    end
  end
end
