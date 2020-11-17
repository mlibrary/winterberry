# Module for performing EPUB processing.
module UMPTG::EPUB
  require_relative File.join('processors', 'object')
  require_relative File.join('processors', 'marker')
  require_relative File.join('processors', 'imageprocessor')
  require_relative File.join('processors', 'newgencontainerselector')
  require_relative File.join('processors', 'newgenimageprocessor')
  require_relative File.join('processors', 'specimageprocessor')
  require_relative File.join('processors', 'markerselector')
  require_relative File.join('processors', 'markerprocessor')


  @@VENDOR_PROCESSORS = [ 'newgen', 'default' ]

  def self.vendor_processor(vendor)
    case vendor
    when "newgen"
      return UMPTG::EPUB::Processors::NewgenImageProcessor.new
    else
      return UMPTG::EPUB::Processors::SpecImageProcessor.new
    end
    return nil
  end
end
