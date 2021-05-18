module UMPTG
  require_relative 'object'

  class Message < UMPTG::Object
    @@INFO = 1
    @@WARNING = 2
    @@ERROR = 3
    @@FATAL = 4

    attr_accessor :level, :text

    def initialize(args = {})
      super(args)
      @level = @properties.key?(:level) ? @properties[:level] : @@INFO
      @text = @properties.key?(:text) ? @properties[:text] : ""
    end

    def to_s
      return "#{@level}: #{@text}"
    end

    def self.INFO
      return @@INFO
    end

    def self.WARNING
      return @@WARNING
    end

    def self.ERROR
      return @@ERROR
    end

    def self.FATAL
      return @@FATAL
    end
  end
end
