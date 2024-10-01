module UMPTG::Fulcrum::Manifest
  require 'redcarpet'

  class XHTMLRenderer < Redcarpet::Render::XHTML

    def block_code(code, language)
      # Prevents wrapping text with a <p>.
      nil
    end

    def paragraph(text)
      # Format the paragraph text, required with nil above.
      return text
    end
  end
end
