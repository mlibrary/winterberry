module UMPTG::RTF
  require 'ruby-rtf'

  class Document < RubyRTF::Document

    attr_reader :endnotes, :style_table

    def initialize
      super
      @endnotes = []
      @style_table = {}
    end

    def add_style(args = {})
      style_id = args[:style_id]
      style_name = args[:style_name]

      @style_table[style_id] = style_name
    end

    def add_endnote(args = {})
      en = args[:endnote]
      @endnotes << en
    end
  end
end
