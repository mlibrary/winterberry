module UMPTG::Fulcrum::Metadata::Processors

  # Class selects references to additional resources (Markers)
  # found within an EPUB.
  class SpecMarkerSelector < UMPTG::Fragment::Selector
    def select_element(name, attrs = [])
      case name
      when 'p'
        pclass = attrs.to_h['class']
        return true if pclass == 'rb' or pclass == 'rbi'
      when 'figure'
        attrs_h = attrs.to_h
        return true if attrs_h.key?('data-fulcrum-embed-filename') \
                      and !attrs_h['data-fulcrum-embed-filename'].empty?
      end
      return false
=begin
      # Select <p class="rb|rbi">
      return false unless name == 'p'

      pclass = attrs.to_h['class']
      return true if pclass == 'rb' or pclass == 'rbi'
      return false
=end
    end
  end
end
