class FragmentProcessor
  def initialize(args = {})
    if args.has_key?(:info)
      @info = args[:info]
    else
      @info = self
    end
  end

  def process(args = {})
    if args.has_key?(:file_name)
      file_name = args[:file_name]
      content = File.read(file_name)
    else
      content = args[:content]
    end

    fragments = FragmentBuilder.parse(
              :content => content,
              :info => @info,
              :name => args[:name],
              :selector => args[:selector]
            )
    return fragments
  end

  def new_info(node)
    return FragmentInfo.new(node)
  end
end
