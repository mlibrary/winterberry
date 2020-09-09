module Validation
  @@BLANK_ROW_FILE_NAME = "***row left intentionally blank***"

  require_relative 'validation/metadata'
  require_relative 'validation/collectionschema'
  require_relative 'validation/fmsl'
  require_relative 'validation/migrator'
  require_relative 'validation/monograph'
  require_relative 'validation/collection'

  def self.BLANK_ROW_FILE_NAME
    return @@BLANK_ROW_FILE_NAME
  end
end
