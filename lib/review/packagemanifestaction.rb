module UMPTG::Review

  #
  class PackageManifestAction < Action
    def process(args = {})
      super(args)

      nav_items = @fragment.node.xpath("./item[translate(@properties, 'ANV', 'anv')='nav']")
      case
      when nav_items.empty?
        @review_msg_list << "Manifest Warning:  no navigation item found."
      when nav_items.count > 1
        @review_msg_list << "Manifest Warning:  multiple navigation items found."
      else
        @review_msg_list << "Manifest INFO:     one navigation item found."
      end

      @status = Action.COMPLETED
    end
  end
end
