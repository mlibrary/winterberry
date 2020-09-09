class Collection
  def initialize
    @monograph_list = []
    @collection_tree = nil
  end

  def add_monograph(monograph)
    @monograph_list << monograph
  end

  def xml_markup
    monograph_markup_list = []
    @monograph_list.each do |monograph|
      monograph_markup_list << monograph.xml_markup
    end
    sprintf(CollectionSchema.MARKUP_COLLECTION, monograph_markup_list.join)
  end
end
