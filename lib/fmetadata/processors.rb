module UMPTG::FMetadata
  require_relative File.join('processors', 'entryprocessor')
  require_relative File.join('processors', 'figureprocessor')
  require_relative File.join('processors', 'newgencontainerselector')
  require_relative File.join('processors', 'newgenmarkerselector')
  require_relative File.join('processors', 'newgenimageprocessor')
  require_relative File.join('processors', 'newgenmarkerprocessor')
  require_relative File.join('processors', 'specfigureprocessor')
  require_relative File.join('processors', 'specmarkerselector')
  require_relative File.join('processors', 'specmarkerprocessor')

  @@VENDOR_PROCESSORS = [ 'newgen', 'default' ]

  def self.vendor_processor(vendor)
    case vendor
    when "newgen"
      return {
                image: UMPTG::EPUB::Processors::NewgenImageProcessor.new,
                marker: UMPTG::EPUB::Processors::NewgenMarkerProcessor.new
             }
    else
      return {
                image: UMPTG::FMetadata::Processors::SpecFigureProcessor.new,
                marker: UMPTG::FMetadata::Processors::SpecMarkerProcessor.new
             }
    end
    return nil
  end
end
