module Monograph
  require 'nokogiri'
  require 'csv'
  require 'zip'

  require_relative 'fragment'

  require_relative 'monograph/imginfo'
  require_relative 'monograph/imgselector'
  require_relative 'monograph/imgprocessor'
  require_relative 'monograph/markerinfo'
  require_relative 'monograph/markerselector'
  require_relative 'monograph/markerprocessor'
end
