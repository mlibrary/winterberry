module UMPTG::XML::Reviewer::Action

  class NormalizeFigureAction < UMPTG::XML::Pipeline::Action::NormalizeAction
    def self.normalize_caption_class(args = {})
      node = args[:caption_node]
      normalize_caption_class = args[:normalize_caption_class]

      if normalize_caption_class
        rm_list = node.classes.select {|c| (" figcap figcap1 figh figh1 fign figatr ").include?(" #{c.downcase} ")}
        rm_list.each {|c| node.remove_class(c)}
      end
      return node
    end
  end
end

