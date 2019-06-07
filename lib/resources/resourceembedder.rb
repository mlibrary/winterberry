require 'nokogiri'

class ResourceEmbedder
  def initialize(p_processor)
    @processor = p_processor
  end

  def get_resource_path(resource_marker_node)
    @processor.get_resource_path(resource_marker_node)
  end

  def get_reference_node(resource_marker_node)
    @processor.get_reference_node(resource_marker_node)
  end

  def create_embed_container(doc)
    @processor.create_embed_container(doc)
  end

  def create_default_container(doc)
    @processor.create_default_container(doc)
  end

  def replace_node(resource_marker_node)
    @processor.replace_node(resource_marker_node)
  end

  def find_reference(resource_marker_node)
    # NOTE: it is possible that a resource may be
    # referenced multiple times in a document. For now,
    # the assumption is that a resource marker will be
    # present at each reference. Also, it is assumed that
    # the marker is the first sibling after the reference
    # markup.
    # Will verify this by confirming that the marker path
    # resides within the reference markup.

    # Get the resource marker path.
    path = get_resource_path(resource_marker_node)
    if path.empty?
      puts "Resource marker has no path (#{resource_marker_node})."
      return
    end

    # Locate the reference markup.
    reference_node = get_reference_node(resource_marker_node)
    if reference_node == nil
      puts "No reference markup found for resource marker (#{resource_marker_node})."
    end
    reference_node
  end

  def find_child_ids(reference_node)
    id_list = reference_node.xpath(".//descendant-or-self::*[@id]")
    if id_list.count < 1
      puts "Found no child ids for (#{reference_node})"
    end
    id_list
  end

  def insert_embed_container(embed_container, resource_marker_node, div = nil)
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

  def insert_embed_markup(resource_marker_node, div = nil)
    embed_container = create_embed_container(resource_marker_node)
    insert_embed_container(embed_container, resource_marker_node, div)
  end

  def replace_media_markup(resource_marker_node)
    embed_container = create_embed_container(resource_marker_node)
    if embed_container
      reference_node = find_reference(resource_marker_node)
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
        insert_embed_container(embed_container, resource_marker_node, div)
      end
    end

    doc
  end

  def embed(resource_marker_node)
    if replace_node(resource_marker_node)
      replace_media_markup(resource_marker_node)
    else
      insert_embed_markup(resource_marker_node)
    end
  end
end

