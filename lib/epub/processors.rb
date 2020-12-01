# Module for performing EPUB processing.
module UMPTG::EPUB
  require_relative File.join('processors', 'object')
  require_relative File.join('processors', 'marker')
  require_relative File.join('processors', 'imageprocessor')
  require_relative File.join('processors', 'newgencontainerselector')
  require_relative File.join('processors', 'newgenmarkerselector')
  require_relative File.join('processors', 'newgenimageprocessor')
  require_relative File.join('processors', 'newgenmarkerprocessor')
  require_relative File.join('processors', 'specmarkerselector')
  require_relative File.join('processors', 'specimageprocessor')
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
                image: UMPTG::EPUB::Processors::SpecImageProcessor.new,
                marker: UMPTG::EPUB::Processors::SpecMarkerProcessor.new
             }
    end
    return nil
  end
end
