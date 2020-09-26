module UMPTG::Monograph
  class ImgSelector

    @@containers = [ 'img', 'figure' ]

    def select_fragment(name, attrs = [])
      return @@containers.include?(name)
    end
  end
end
