module UMPTG::Monograph
  class MarkerSelector

    def select_fragment(name, attrs = [])
      return false unless name == 'p'

      pclass = attrs.to_h['class']
      return true if pclass == 'rb' or pclass == 'rbi'
      return false
    end
  end
end
