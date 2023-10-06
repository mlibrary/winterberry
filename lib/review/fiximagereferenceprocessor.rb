module UMPTG::Review
  class FixImageReferenceProcessor < EntryProcessor

    XPATH = <<-XP
    //*[
    local-name()='body'
    ]//*[
    local-name()='img' and @src
    ]
    XP

    def initialize(args = {})
      args[:selector] = ElementSelector.new(
              selection_xpath: XPATH
            )
      super(args)
    end

    def new_action(args = {})
      a = args.clone
      a[:epub] = @epub

      return [
          FixImageReferenceAction.new(a)
          ]
    end
  end
end
