class ReviewInfo < FragmentInfo
  attr_reader :review_msg_list
  attr_accessor :has_elements

  def initialize(args = {})
    super(args)
    @has_elements = {}
    @review_msg_list = []
  end
end