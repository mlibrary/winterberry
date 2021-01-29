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

  # Vendors may produce different markup for resource references.
  # Below is an association of resource/additional resource processors
  # for the default case and vendor specific processors.
  def self.vendor_processor(vendor)
    case vendor
    when "newgen"
      # Newgen processors
      return {
                image: UMPTG::EPUB::Processors::NewgenImageProcessor.new,
                marker: UMPTG::EPUB::Processors::NewgenMarkerProcessor.new
             }
    end

    # Default processors.
    return {
              image: UMPTG::FMetadata::Processors::SpecFigureProcessor.new,
              marker: UMPTG::FMetadata::Processors::SpecMarkerProcessor.new
           }
  end
end
