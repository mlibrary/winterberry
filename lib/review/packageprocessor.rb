module UMPTG::Review
  class PackageProcessor < ReviewProcessor
    @@children = [ 'metadata' ]

    def process(args = {})
      args[:children] = @@children
      fragment_selector = UMPTG::Fragment::ContainerSelector.new
      fragment_selector.containers = [ 'package' ]
      args[:selector] = fragment_selector

      fragments = super(args)

      metadata_processor = PackageMetadataProcessor.new
      fragment_selector.containers = [ 'metadata' ]

      fragments.each do |fragment|
        fragment.has_elements.each do |elem_name, exists|
            fragment.review_msg_list << "Package INFO:  contains <#{elem_name}>." if exists
            fragment.review_msg_list << "Package INFO:  contains no <#{elem_name}>." unless exists
        end

        meta_fragments = metadata_processor.process(
                  :name => args[:name],
                  :content => fragment.node.to_xml,
                  :selector => fragment_selector
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
end
