module UMPTG::XHTML::Pipeline

  class Processor < UMPTG::XML::Pipeline::Processor

    def initialize(args = {})
      a = args.clone

      if a[:filters].nil?
        a[:filters] = FILTERS
      else
        a[:filters] = a[:filters].merge(FILTERS)
      end

      super(a)
    end

    def process_action_results(args = {})
      action_results = args[:action_results]
      llogger = args[:logger] || @logger

      @filters.each do |f|
        act = []
        action_results.each {|ar| act += ar.actions.select {|a| a.name == f.name } }

        case f.name
        when :xhtml_img_alttext
          cnt = 0
          act.each {|a| a.messages.each {|m| cnt += 1 if m.level == UMPTG::Message.WARNING } }

          act_text_msg = "non-presentation images without alt text:#{cnt}"
          llogger.info(act_text_msg) if cnt == 0
          llogger.warn(act_text_msg) unless cnt == 0
        when :xhtml_extdescr
          llogger.info("extended description references:#{act.count}")
        end
      end
    end
  end
end
