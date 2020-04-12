require "nokogiri"

class ResourceMapSaxDocument < Nokogiri::XML::SAX::Document

  attr_reader :references, :resources, :actions, :version, :default_action

  def initialize(args = {})
    reset
  end

  def start_element(name, attrs = [])
    #puts "<#{name}: #{attrs.map {|x| x.inspect}.join(', ')}>"

    case name
    when "resourcemap"
      attrs_h = attrs.to_h
      @version = attrs_h["version"]
    when "reference"
      attrs_h = attrs.to_h
      @references[attrs_h["id"]] = attrs_h["src"]
    when "resource"
      attrs_h = attrs.to_h
      @resources[attrs_h["id"]] = attrs_h["name"]
    when "actions"
      @default_action = attrs.to_h["default"]
    when "action"
      @actions << attrs.to_h
    end
  end

  def reset
    @version = ""
    @default_action = ""

    @references = {}
    @resources = {}
    @actions = []
  end
end
