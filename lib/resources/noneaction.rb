class NoneAction < Action
  def process()
    @status = Action.NO_ACTION
  end
end