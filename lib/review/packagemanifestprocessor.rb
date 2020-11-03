module UMPTG::Review
  class PackageManifestProcessor < ReviewProcessor
    def process(args = {})
      fragment_selector = UMPTG::Fragment::ContainerSelector.new
      fragment_selector.containers = [ 'manifest' ]
      args[:selector] = fragment_selector

      fragments = super(args)

      fragments.each do |fragment|
        nav_items = fragment.node.xpath("./item[translate(@properties, 'ANV', 'anv')='nav']")
        case
        when nav_items.empty?
          fragment.review_msg_list << "Manifest Warning:  no navigation item found."
        when nav_items.count > 1
          fragment.review_msg_list << "Manifest Warning:  multiple navigation items found."
        else
          fragment.review_msg_list << "Manifest INFO:     one navigation item found."
        end
      end
      return fragments
    end
  end
end

