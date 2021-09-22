module UMPTG::Fulcrum
  module Shared
    #@@DEFAULT_PUBLISHER_DIR = OS.windows? ? "s:/Information\ Management/Fulcrum" : "/mnt/umptmm"
    @@DEFAULT_DIR = "s:/Information\ Management/Fulcrum"
    @@DEFAULT_PUBLISHER = "UMP"

    require_relative File.join('shared', 'monographdir')
    require_relative File.join('shared', 'monographdirreviewer')

    def self.DEFAULT_PUBLISHER
      return @@DEFAULT_PUBLISHER
    end

    def self.DEFAULT_DIR
      return @@DEFAULT_DIR
    end
  end
end
