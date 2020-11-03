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
      manifest_processor = PackageManifestProcessor.new

      fragments.each do |fragment|
        pck_version = fragment.node["version"]
        case
        when pck_version.nil?
          fragment.review_msg_list << "Package Warning:  EPUB version not specified."
        when pck_version[0] == '3'
          fragment.review_msg_list << "Package INFO:     EPUB version is 3.x."
        else
          fragment.review_msg_list << "Package Warning:  EPUB version is #{pck_version}."
        end

        fragment.has_elements.each do |elem_name, exists|
            fragment.review_msg_list << "Package INFO:  contains <#{elem_name}>." if exists
            fragment.review_msg_list << "Package INFO:  contains no <#{elem_name}>." unless exists
        end

        fragment_selector.containers = [ 'metadata' ]
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

        fragment_selector.containers = [ 'manifest' ]
        manifest_fragments = manifest_processor.process(
                  :name => args[:name],
                  :content => fragment.node.to_xml,
                  :selector => fragment_selector
              )
        manifest_fragments.each do |man_frag|
          man_frag.review_msg_list.each do |msg|
            fragment.review_msg_list << "Package " + msg
          end
        end
      end
      return fragments
    end
  end
end
