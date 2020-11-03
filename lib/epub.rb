module UMPTG
  require_relative 'fragment'
  require_relative 'xmlutil'
  require_relative 'xslt'
  require_relative File.join('epub', 'rendition')
  require_relative File.join('epub', 'archive')
  require_relative File.join('epub', 'migrator')
end
