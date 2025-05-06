module UMPTG::XML::Pipeline
  require_relative("elementselector")

  class Filter < UMPTG::Object

    attr_reader :name, :xpath, :selector

    def initialize(args = {})
      a = args.clone
      unless a.key?(:selector)
        a[:selector] = ElementSelector.new(
                selection_xpath: a[:xpath]
              )
      end

      super(a)

      @name = @properties[:name]
      @selector = @properties[:selector]
      @xpath = @selector.xpath
    end

    def run(xml_doc, args = {})
      a = args.clone()
      a[:name] = @name

      actions = []
      @selector.references(xml_doc).each do |n|
        a[:reference_node] = n
        act_list = create_actions(a)
        actions += act_list
      end
      return actions
    end

    def create_actions(args = {})
      a = args.clone
      act = UMPTG::XML::Pipeline::Action.new(a)
      act.add_info_msg("#{name}, found #{a[:reference_node]}")
      return [ act ]
    end
  end
end
