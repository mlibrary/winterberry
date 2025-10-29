module UMPTG::CSS::Pipeline

  class Filter < UMPTG::Object

    attr_reader :actions, :name

    def initialize(args = {})
      a = args.clone

      super(a)

      @name = @properties[:name]
      @actions = []
    end

    def create_actions(args = {})
      a = args.clone
      act = UMPTG::XML::Pipeline::Action.new(a)
      act.add_info_msg("#{name}, found #{a[:css_class]}")
      return [ act ]
    end

    def process_action_results(args = {})
      action_results = args[:action_results]
      @actions = args[:actions]
      logger = args[:logger]

      completed_cnt = warning_cnt = error_cnt = 0
      @actions.each do |a|
        completed_cnt += 1 if a.normalize and a.status == UMPTG::Action.COMPLETED
        a.messages.each {|m| warning_cnt += 1 if m.level == UMPTG::Message.WARNING }
        a.messages.each {|m| error_cnt += 1 if m.level == UMPTG::Message.ERROR }
      end

      logger.info("#{@name}, actions=#{@actions.count}, completed=#{completed_cnt}, warnings=#{warning_cnt}, errors=#{error_cnt}")
    end
  end
end
