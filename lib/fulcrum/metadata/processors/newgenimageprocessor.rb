module UMPTG::Fulcrum::Metadata::Processors

  # Class processes images found within an EPUB generated by vendor Newgen.
  class NewgenImageProcessor < FigureProcessor
    @@imgselector = nil

    # Select the XML fragments that refer to resources
    # to process and create Actions for each fragment.
    #
    # Arguments:
    #   :name       Content identifier, e.g. EPUB entry name or file name.
    #   :content    Entry XML content
    def action_list(args = {})
      # Figures expected to wrapped within a <div class="figurewrap">.
      # NOTE: not handling case of <img> not wrapped within a figure
      # container as it has not been encountered to date.
      @@imgselector = NewgenContainerSelector.new if @@imgselector.nil?
      args[:selector] = @@imgselector

      alist = super(args)
      alist.each do |action|
        action.process(name: name)
      end
      return alist
    end
  end
end