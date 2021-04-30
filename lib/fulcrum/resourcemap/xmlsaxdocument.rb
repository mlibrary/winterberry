module UMPTG::Fulcrum::ResourceMap

  require "nokogiri"

  class XMLSaxDocument < Nokogiri::XML::SAX::Document

    attr_reader :references, :resources, :actions, \
           :version, :default_action, :vendors, :selectors

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
        @default_action = attrs.to_h["default"].to_sym
      when "action"
        @actions << attrs.to_h
      when "vendors"
        attrs.to_h.each do |format,vendor|
          @vendors[format.to_sym] = vendor.to_sym
        end
      when "xpath"
        attrs_h = attrs.to_h
        @selectors[attrs_h["type"].to_sym] = attrs_h["expression"]
      end
    end

    def reset
      @version = ""
      @default_action = :none

      @references = {}
      @resources = {}
      @actions = []
      @vendors = {
          epub: :default
        }
      @selectors = {}
    end
  end
end
