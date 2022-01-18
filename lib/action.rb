module UMPTG
  require_relative 'object'
  require_relative 'message'

  class Action < Object
    @@PENDING = "Pending"
    @@COMPLETED = "Completed"
    @@FAILED = "Failed"
    @@NO_ACTION = "No action"

    attr_reader :status, :message, :messages

    def initialize(args = {})
      super(args)

      @status = Action.PENDING
      @messages = []
      @message = ""

      add_info_msg(@properties[:info_message]) if @properties.key?(:info_message)
      add_warning_msg(@properties[:warning_message]) if @properties.key?(:warning_message)
      add_error_msg(@properties[:error_message]) if @properties.key?(:error_message)
      add_fatal_msg(@properties[:fatal_message]) if @properties.key?(:fatal_message)
    end

    def process(args = {})
      #raise "#{self.class}: method #{__method__} must be implemented."
      @status = @@COMPLETED
    end

    def to_s
      if @messages.empty?
        return "#{@status}: #{self.class}"
      else
        m = @messages.join("\n")
        return "#{@status}: #{self.class},#{m}"
      end
    end

    def add_msg(args = {})
      raise "Missing :level parameter" unless args.key?(:level)
      raise "Missing :text parameter" unless args.key?(:text)

      @messages << UMPTG::Message.new(
                level: args[:level],
                text: args[:text]
              )
    end

    def add_info_msg(txt = "")
      add_msg(
          level: UMPTG::Message.INFO,
          text: txt
      )
    end

    def add_warning_msg(txt = "")
      add_msg(
          level: UMPTG::Message.WARNING,
          text: txt
      )
    end

    def add_error_msg(txt = "")
      add_msg(
          level: UMPTG::Message.ERROR,
          text: txt
      )
    end

    def add_fatal_msg(txt = "")
      add_msg(
          level: UMPTG::Message.FATAL,
          text: txt
      )
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
