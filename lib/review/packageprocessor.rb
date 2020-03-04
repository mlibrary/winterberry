class PackageProcessor < ReviewProcessor
  @@containers = [ 'package' ]
  @@children = [ 'metadata' ]

  @@metadata_processor = nil

  def process(args = {})
    args[:containers] = @@containers
    args[:children] = @@children

    fragments = super(args)

    @@metadata_processor = PackageMetadataProcessor.new if @@metadata_processor.nil?

    fragments.each do |fragment|
      fragment.has_elements.each do |elem_name, exists|
          fragment.review_msg_list << "Package INFO:  contains <#{elem_name}>." if exists
          fragment.review_msg_list << "Package INFO:  contains no <#{elem_name}>." unless exists
      end

      meta_fragments = @@metadata_processor.process(
                :name => args[:name],
                :content => fragment.node.to_xml
            )
      meta_fragments.each do |meta_frag|
        meta_frag.review_msg_list.each do |msg|
          fragment.review_msg_list << "Package " + msg
        end
      end
    end
    return fragments
  end
end
