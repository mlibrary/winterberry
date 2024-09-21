module UMPTG::EPUB

  class RootFiles < Node

    ROOTFILE_XML = <<-XMLTEMP
<rootfile full-path="%s" media-type="application/oebps-package+xml"/>
    XMLTEMP

    def initialize(args = {})
      a = args.clone
      a[:xpath_node] = "//*[local-name()='rootfiles']"
      a[:xpath_children] = "//*[local-name()='rootfiles']/*[local-name()='rootfile' and @media-type='application/oebps-package+xml' and @full-path]"
      super(a)
    end

    def find(args = {})
      entry_name = args[:entry_name]
      raise "invalid entry name" if entry_name.nil? or entry_name.strip.empty?

      return children.select {|r| r['full-path'] == entry_name }
    end

    def add(args = {})
      rfiles = find(args)
      if rfiles.empty?
        a = args.clone
        a[:opf] = true
        entry = @archive_entry.archive.add(a)
        markup = sprintf(ROOTFILE_XML, entry.name)
        rfiles = obj_node.add_child(markup)
        return entry
      end
      return nil
    end
  end
end
