module UMPTG::XML::Pipeline
  require_relative("elementselector")

  class Filter < UMPTG::Object

    attr_reader :actions, :name, :xpath, :selector

    def initialize(args = {})
      a = args.clone
      unless a.key?(:selector)
        a[:xpath] = "//*" if a[:xpath].nil?

        a[:selector] = ElementSelector.new(
                selection_xpath: a[:xpath]
              )
      end

      super(a)

      @name = @properties[:name]
      @selector = @properties[:selector]
      @xpath = @selector.xpath
      @actions = []
    end

=begin
    def run(xml_doc, args = {})
      a = args.clone()
      a[:name] = @name

      @selector.references(xml_doc).each do |n|
        a[:reference_node] = n
        actions += create_actions(a)
      end
      return actions
    end
=end

    def create_actions(args = {})
      a = args.clone
      act = UMPTG::XML::Pipeline::Action.new(a)
      act.add_info_msg("#{name}, found #{a[:reference_node]}")
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

  FILTERS = {
        xml_default: UMPTG::XML::Pipeline::Filter
      }

  def self.DefaultFilter(args = {})
    return FILTERS[:xml_default].new(args)
  end

  def self.FILTERS
    return FILTERS
  end

end
