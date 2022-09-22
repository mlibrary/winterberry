module UMPTG::Review

  class RemoveMarkerMediaAction < Action
    def process(args = {})
      super(args)

      reference_node = @properties[:reference_node]
      add_warning_msg("RemoveMarkerMediaAction not implemented.")

      #@status = Action.COMPLETED
    end
  end
end

