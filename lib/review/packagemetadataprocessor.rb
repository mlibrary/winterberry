module UMPTG::Review
  class PackageMetadataProcessor < ReviewProcessor
    @@children = [ 'dc:title', 'dc:creator', 'dc:language', 'dc:rights', 'dc:publisher', 'dc:identifier' ]

    def process(args = {})
      args[:children] = @@children
      fragment_selector = UMPTG::Fragment::ContainerSelector.new
      fragment_selector.containers = [ 'metadata' ]
      args[:selector] = fragment_selector

      fragments = super(args)

      fragments.each do |fragment|
        fragment.has_elements.each do |elem_name, exists|
            fragment.review_msg_list << "Metadata INFO:  contains <#{elem_name}>." if exists
            fragment.review_msg_list << "Metadata INFO:  contains no <#{elem_name}>." unless exists
        end
      end
      return fragments
    end
  end
end

