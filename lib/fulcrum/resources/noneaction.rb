module UMPTG::Fulcrum::Resources

  # Class that defines no Action necessary.
  class NoneAction < Action
    def process()
      @status = Action.NO_ACTION
    end
  end
end
