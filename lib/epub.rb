module UMPTG
  require_relative 'object'
  require_relative 'action'

  require_relative '../lib/fragment'
  require_relative '../lib/xmlutil'
  require_relative '../lib/xslt'

  require_relative File.join('epub', 'entry')
  require_relative File.join('epub', 'rendition')
  require_relative File.join('epub', 'archive')
  require_relative File.join('epub', 'migrator')
  require_relative File.join('epub', 'entryprocessor')
  require_relative File.join('epub', 'processor')
end
