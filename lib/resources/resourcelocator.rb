class ResourceLocator
  def find_resources(doc)
    raise NotImplementedError, "not implemented"
  end

  def get_resource_path(resource_marker_node)
    raise NotImplmentedError, "not implemented"
  end

  def get_reference_node(resource_marker_node)
    raise NotImplmentedError, "not implemented"
  end

  def replace_node(resource_marker_node)
    raise NotImplmentedError, "not implemented"
  end
end