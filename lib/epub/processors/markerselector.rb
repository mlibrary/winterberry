module UMPTG::EPUB::Processors

  # Class selects markers found within an EPUB.
  class MarkerSelector < UMPTG::Fragment::Selector
    def select_fragment(name, attrs = [])

      # Select <p class="rb|rbi">
      return false unless name == 'p'

      pclass = attrs.to_h['class']
      return true if pclass == 'rb' or pclass == 'rbi'
      return false
    end
  end
end
