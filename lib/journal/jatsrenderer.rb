module UMPTG::Journal
  require 'redcarpet'

  class JATSRenderer < Redcarpet::Render::Base

    def normal_text(text)
      return text
    end

    def block_code(code, language)
      puts "block_code: encountered code:#{code},language:#{language}"
    end

    def codespan(code)
      block_code(code, nil)
    end

    def header(title, level)
      puts "header: encountered title:#{title},level:#{level}"
    end

    def double_emphasis(text)
      puts "double_emphasis: encountered text:#{text}"
    end

    def emphasis(text)
      puts "emphasis: encountered text:#{text}"
      return "<italic>#{text}</italic>"
    end

    def linebreak
      puts "linebreak:"
    end

    def link(link, title, content)
      puts "link: encountered link:#{link},title:#{title},content:#{content}"
      return link
    end

    def autolink(link, link_type)
      puts "autolink: encountered link:#{link},link_type:#{link_type}"
      return "<ext-link ext-link-type=\"uri\" xlink:type=\"simple\" xlink:href=\"#{link}\">#{link}</ext-link>"
    end

    def paragraph(text)
      puts "paragraph: encountered text:#{text}"
      return text
    end

    def list(content, list_type)
      puts "list: encountered content:#{content},list_type:#{list_type}"
    end

    def list_item(content, list_type)
      puts "list_item: encountered content:#{content},list_type:#{list_type}"
    end
  end
end
