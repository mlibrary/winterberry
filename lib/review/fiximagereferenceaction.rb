module UMPTG::Review

  class FixImageReferenceAction < NormalizeAction
    def process(args = {})
      super(args)

      entry_name = @properties[:name]
      reference_node = @properties[:reference_node]
      epub = @properties[:epub]

      src = reference_node['src']
      bname = File.basename(src)
      img_entry = epub.entries.select {|e| File.basename(e.name) == bname }
      img_dir = Pathname.new(File.dirname(img_entry.first.name)).relative_path_from(File.dirname(entry_name))
      img_path = File.join(img_dir, File.basename(img_entry.first.name))

      if src == img_path
        @status = Action.COMPLETED
        return
      end

      reference_node['src'] = img_path
      add_info_msg("updated reference #{src} to #{img_path}")
      @status = NormalizeAction.NORMALIZED
    end
  end
end

