module UMPTG

  require_relative("object")

  class Issue < UMPTG::Object

    attr_reader :name
    attr_accessor :actions, :content

    def initialize(name:, content: nil)
      super(
            name: name,
            content: (content || "")
          )

      @name = name
      @content = content
      @actions = []
    end

    def process(options: nil)
      actions.each {|a| a.process(@content, options: options) }
    end
  end
end
