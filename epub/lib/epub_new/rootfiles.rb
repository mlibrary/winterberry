module UMPTG::EPUB

  class RootFiles < Node

    ROOTFILE_XML = <<-XMLTEMP
<rootfile full-path="%s" media-type="application/oebps-package+xml"/>
    XMLTEMP

    def initialize(args = {})
      a = args.clone
      a[:xpath_node] = "//*[local-name()='rootfiles']"
      a[:xpath_items] = "//*[local-name()='rootfiles']/*[local-name()='rootfile' and @media-type='application/oebps-package+xml' and @full-path]"
      super(a)

      @container = args[:container]
    end

    def find(args = {})
      entry_name = args[:entry_name]
      raise "invalid entry name" if entry_name.nil? or entry_name.strip.empty?

      return children.select {|r| r['full-path'] == entry_name }
    end

    def add(args = {})
      a = args.clone
      a[:opf] = true
      entry = @container.aentry.archive.add(a)
      rfiles = find(args)
      if rfiles.empty?
        markup = sprintf(ROOTFILE_XML, entry.name)
        rfiles = obj_node.add_child(markup)
      end
      return rfiles.first
    end
  end
end
