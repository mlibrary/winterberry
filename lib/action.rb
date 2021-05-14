module UMPTG
  require_relative 'object'

  class Action < Object
    @@PENDING = "Pending"
    @@COMPLETED = "Completed"
    @@FAILED = "Failed"
    @@NO_ACTION = "No action"

    attr_reader :status, :message

    def initialize(args = {})
      super(args)

      @status = Action.PENDING
      @message = ""
    end

    def process(args = {})
      #raise "#{self.class}: method #{__method__} must be implemented."
      @status = @@COMPLETED
    end

    def to_s
      return "#{@status}: #{self.class},#{@message}"
    end

    def self.COMPLETED
      @@COMPLETED
    end

    def self.PENDING
      @@PENDING
    end

    def self.NO_ACTION
      @@NO_ACTION
    end

    def self.FAILED
      @@FAILED
    end
  end
end
