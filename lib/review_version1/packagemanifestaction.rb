module UMPTG::Review

  #
  class PackageManifestAction < Action
    def process(args = {})
      super(args)

      nav_items = @fragment.node.xpath("./item[translate(@properties, 'ANV', 'anv')='nav']")
      case
      when nav_items.empty?
        add_warning_msg("Manifest: no navigation item found.")
      when nav_items.count > 1
        add_warning_msg("Manifest: multiple navigation items found.")
      else
        add_info_msg("Manifest:  one navigation item found.")
      end

      @status = Action.COMPLETED
    end
  end
end
