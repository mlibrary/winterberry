module UMPTG::Fulcrum::Metadata
  require_relative File.join('processors', 'entryprocessor')
  require_relative File.join('processors', 'figureprocessor')
  require_relative File.join('processors', 'apexmarkerselector')
  require_relative File.join('processors', 'apexmarkerprocessor')
  require_relative File.join('processors', 'apexcontainerselector')
  require_relative File.join('processors', 'apexfigureprocessor')
  require_relative File.join('processors', 'newgencontainerselector')
  require_relative File.join('processors', 'newgenmarkerselector')
  require_relative File.join('processors', 'newgenimageprocessor')
  require_relative File.join('processors', 'newgenmarkerprocessor')
  require_relative File.join('processors', 'specfigureprocessor')
  require_relative File.join('processors', 'specmarkerselector')
  require_relative File.join('processors', 'specmarkerprocessor')


  @@VENDOR_PROCESSORS = [ 'apex', 'newgen', 'default' ]

  # Vendors may produce different markup for resource references.
  # Below is an association of resource/additional resource processors
  # for the default case and vendor specific processors.
  def self.vendor_processor(vendor)
    case vendor
    when "apex"
      # Apex processors
      return {
                image: Processors::ApexFigureProcessor.new,
                marker: Processors::ApexMarkerProcessor.new
             }
    when "newgen"
      # Newgen processors
      return {
                image: Processors::NewgenImageProcessor.new,
                marker: Processors::NewgenMarkerProcessor.new
             }
    end

    # Default processors.
    return {
              image: Processors::SpecFigureProcessor.new,
              marker: Processors::SpecMarkerProcessor.new
           }
  end
end
