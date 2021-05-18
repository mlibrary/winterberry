module UMPTG::Review

  #
  class FigureAction < Action
    def process(args = {})
      super(args)

      # Determine if figure has a caption.
      caption_elem = ""
      @has_elements.each do |elem_name, exists|
        if exists
          #fragment.review_msg_list << "Figure INFO:           has #{elem_name}"
          caption_elem = elem_name if caption_elem.empty?
        end
      end
      add_info_msg("Figure:           has caption (#{caption_elem})") unless caption_elem.empty?
      add_warning_msg("Figure:        has no caption") if caption_elem.empty?
      #@review_msg_list << msg

      # Attach the list XML fragment objects processed to this
      # Action and set it status COMPLETED.
      @status = Action.COMPLETED
    end

    def self.element_xpath(elements = [])
      xpath = elements.collect do |e|
        e.index(":").nil? ? "local-name()=\"#{e}\"" : "name()=\"#{e}\""
      end
      return "#{xpath.join(' or ')}"
    end

    def self.class_xpath(class_values = [])
      xpath = class_values.collect { |cl| "@class=\"#{cl}\"" }
      return "#{xpath.join(' or ')}"
    end
  end
end
