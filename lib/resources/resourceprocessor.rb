require 'nokogiri'

class ResourceProcessor
  attr_reader :resource_csv, :resource_locator

  def initialize(params = {})
    @resource_metadata = params[:resource_metadata]
    @resource_locator = params[:resource_locator]
  end

  def get_resource_metadata(resource_path)
    @resource_metadata.find { |row| row['file_name'] == resource_path }
  end

  def get_resource_path(resource_marker_node)
    @resource_locator.get_resource_path(resource_marker_node)
  end

  def get_reference_node(resource_marker_node)
    @resource_locator.get_reference_node(resource_marker_node)
  end

  def replace_node(resource_marker_node)
    @resource_locator.replace_node(resource_marker_node)
  end

  def get_embed_markup(resource_marker_node)
    path = get_resource_path(resource_marker_node)

    metadata = get_resource_metadata(path)
    if metadata == nil
      puts "Warning: no resource found for path #{path}"
      return
    end

    puts "resource found for path #{path}."
    embed_code = get_embed_xml(metadata)
    embed_doc = Nokogiri::XML(embed_code)
    embed_doc.root
  end

  def create_media_container(resource_marker_node)
    embed_markup = get_embed_markup(resource_marker_node)
    if embed_markup != nil
      embed_container = resource_marker_node.document.create_element("div", :class => "enhanced-media-display")
      embed_container.add_child(embed_markup)
      return embed_container
    end
    return nil
  end

  def create_default_container(reference_node)
    default_container = reference_node.document.create_element("div", :class => "default-media-display")
    default_container.add_child(reference_node)
    default_container
  end

  def find_child_ids(reference_node)
    id_list = reference_node.xpath(".//descendant-or-self::*[@id]")
    if id_list.count < 1
      puts "Found no child ids for (#{reference_node})"
    end
    id_list
  end

  def insert_media_container(embed_container, resource_marker_node, div = nil)
    if embed_container != nil
      if div == nil
        resource_marker_node.add_next_sibling(embed_container)
      else
        div.add_child(embed_container)
      end

      # Remove the resource marker
      resource_marker_node.remove
    end
  end

  def insert_media_markup(params = {}, div = nil)
    resource_marker_node = params[:marker]
    embed_container = create_media_container(resource_marker_node)
    insert_media_container(embed_container, resource_marker_node, div)
  end

  def replace_media_markup(params = {})
    resource_marker_node = params[:marker]

    embed_container = create_media_container(resource_marker_node)
    if embed_container
      # NOTE: it is possible that a resource may be
      # referenced multiple times in a document. For now,
      # the assumption is that a resource marker will be
      # present at each reference. Also, it is assumed that
      # the marker is the first sibling after the reference
      # markup.
      # Will verify this by confirming that the marker path
      # resides within the reference markup.

      # Locate the reference markup.
      reference_node = get_reference_node(resource_marker_node)
      if reference_node == nil
        puts "No reference markup found for resource marker (#{resource_marker_node})."
      end

      if reference_node != nil
        doc = reference_node.document

        # Find any IDs in the reference markup to preserve links.
        id_list = find_child_ids(reference_node)
        if id_list.count > 1
         puts "Found multiple IDs for reference (#{reference_node})"
        end

        # Add <div> around default media markup. One for each ID found.
        # If no IDs, add just one.
        div = nil
        id_list.each do |id|
          ch = doc.create_element("div", :id => id.attribute("id"))

          if div == nil
            reference_node.add_next_sibling(ch)
          else
            div.add_child(ch)
          end
          div = ch
        end

        # Remove the IDs from the reference markup
        id_list.each { |id| id.remove_attribute("id") }

        # Should be within inner most <div>.
        # Insert container for default media display.
        default_container = create_default_container(reference_node)
        div.add_child(default_container)

        # Insert resource embed markup
        insert_media_container(embed_container, resource_marker_node, div)
      end
    end

    doc
  end

  def process(params = {})
    resource_marker_node = params[:marker]
    if replace_node(resource_marker_node)
      replace_media_markup(params)
    else
      insert_media_markup(params)
    end
  end
end
