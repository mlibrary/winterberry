module UMPTG::Manifest
  @@BLANK_ROW_FILE_NAME = "***row left intentionally blank***"

  require_relative File.join('validation', 'collectionschema')
  require_relative File.join('validation', 'collection')

  def self.BLANK_ROW_FILE_NAME
    return @@BLANK_ROW_FILE_NAME
  end
end
