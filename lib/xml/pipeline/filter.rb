module UMPTG::XML::Pipeline
  require_relative("elementselector")

  class Filter < UMPTG::Object

    attr_reader :name, :xpath

    def initialize(args = {})
      unless args.key?(:selector)
        args[:selector] = ElementSelector.new(
                selection_xpath: args[:xpath]
              )
      end

      super(args)

      @name = @properties[:name]
      @xpath = @properties[:xpath]
      @selector = @properties[:selector]
    end

    def run(xml_doc, args = {})
      a = args.clone()
      actions = []
      @selector.references(xml_doc).each do |n|
        a[:reference_node] = n
        act_list = create_actions(a)
        actions += act_list
      end
      return actions
    end

    def create_actions(args = {})
      act = UMPTG::XML::Pipeline::Action.new(args)
      return [ act ]
    end
  end
end
