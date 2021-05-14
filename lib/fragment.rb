module UMPTG
  require 'nokogiri'

  require_relative 'object'
  require_relative File.join('fragment', 'object')
  require_relative File.join('fragment', 'selector')
  require_relative File.join('fragment', 'containerselector')
  require_relative File.join('fragment', 'processor')
  require_relative File.join('fragment', 'xmlsaxdocument')
end
