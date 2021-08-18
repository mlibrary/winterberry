module UMPTG::Fulcrum::ResourceMap

  require 'nokogiri'
  require 'csv'

  # Class representing a resource map, i.e a
  # mapping of file references to Fulcrum resources.
  # Methods exist for reading/writing maps and searching.
  # Currently, this reads/writes an XML file and writes
  # a CSV, but hopefully the CSV can be deprecated.

  class Map < UMPTG::Object
    @@DEFAULT_VERSION = "1.0"
    @@DEFAULT_ACTION = :embed

    @@XML_RESOURCEMAP = <<-XML_RESOURCEMAP
<?xml version="1.0" encoding="UTF-8"?>
<resourcemap version="%s">
<vendors %s/>
<references>
%s</references>
<resources>
%s</resources>
<actions default="%s">
%s</actions>
</resourcemap>
    XML_RESOURCEMAP

    @@XML_REFERENCE = <<-XREFERENCE
<reference id="%s" src="%s"/>
    XREFERENCE

    @@XML_RESOURCE =  <<-XRESOURCE
<resource id="%s" name="%s"/>
    XRESOURCE

    @@XML_ACTION =    <<-XACTION
<action reference_id="%s" resource_id="%s" type="%s" entry="%s" xpath="%s"/>
    XACTION

    # Headers to use for writing CSV version.
    @@resource_map_file_headers = [ "File Name", "Resource Name", "Resource Action" ]

    @@parser = nil
    @@processor = XMLSaxDocument.new

    attr_reader :actions, :resources
    attr_accessor :default_action, :vendors

    def initialize(args = {})
      super(args)

      # Load the XML document is one is specified
      # either by string or path.
      load(args)

      # Store additional properties for each
      # mapping. These currently are not written,
      # but are necessary for searching.
      #@properties = {}

      # CSV headers, hopefully to be deprecated.
      @csv_headers = []
    end

    def add_reference(args = {})
      name = args[:name]
      id = args[:id]
      id = ResourceMapObject.name_id(name) if id.nil?

      reference = @references[id]
      if reference.nil?
        reference = Reference.new(
                  :id => id,
                  :name => name
                )
        @references[id] = reference
      end
      return reference
    end

    def add_resource(args = {})
      name = args[:name]
      resource_properties = args[:resource_properties]
      id = args.has_key?(:id) ? args[:id] : \
            ResourceMapObject.name_id(name)

      resource = @resources[id]
      if resource.nil?
        resource = Resource.new(
                  :id => id,
                  :name => name
                )
        @resources[id] = resource
      end
      resource.resource_properties = resource_properties
      return resource
    end

    # Add a new map entry, reference => resource.
    def add(args = {})
      name = args[:name]
      reference_id = args[:reference_id]
      reference_name = args[:reference_name]
      resource = args[:resource]
      resource_path = args[:resource_path]
      xpath = args[:xpath]
      type = args[:type]

      reference = add_reference(
            :id => reference_id,
            :name => reference_name
          )

      if resource.nil?
        resource = add_resource(
                name: File.basename(resource_path)
            )
        action = Action.new(
                name: name,
                reference: reference,
                resource: resource,
                type: type.to_sym,
                xpath: xpath
              )
      else
        action = @actions.find {|a| a.reference.id == reference.id and a.resource.id == resource.id }
        if action.nil?
          action = Action.new(
                name: name,
                reference: reference,
                resource: resource,
                type: type.to_sym,
                xpath: xpath
                )
          @actions << action
        else
          action.type = type
        end
      end
    end

    # For a specified resource, return a property map.
    def resource_properties(resource_name)
      action = @actions.find {|a| a.resource.name == resource_name }
      return action.resource.resource_properties unless action.nil?
    end

    # For a specified reference path, return a possible
    # associated resource.
    def reference_resource(reference)
      action = @actions.find {|a| a.reference.name == reference }
      if action.nil?
        ref_base = File.basename(reference, ".*")
        ref_base.downcase! unless ref_base.nil?
        r = @resources.select {|id,resource| File.basename(resource.name, ".*").downcase == ref_base }
        return r.values.first unless r.nil?
      end
      return action.resource unless action.nil?
    end

    # Load an XML resource map file.
    def load(args = {})
      @references = {}
      @resources = {}
      @actions = []
      @vendors = {}
      @@processor.reset

      markup = args[:markup] if args.has_key?(:markup)
      markup = File.read(args[:xml_path]) if args.has_key?(:xml_path)
      #raise "#{__method__}: error, no markup specified" if markup.nil? or markup.empty?

      if markup.nil?
        @version = args.has_key?(:version) ? args[:version] : @@DEFAULT_VERSION
        @default_action = args.has_key?(:default_action) ? args[:default_action] : @@DEFAULT_ACTION
      else
        @@parser = Nokogiri::XML::SAX::Parser.new(@@processor) if @@parser.nil?
        @@parser.parse(markup)

        @version = @@processor.version
        @default_action = @@processor.default_action
        @vendors = @@processor.vendors

        @@processor.references.each do |id, name|
          @references[id] = add_reference(
                      :id => id,
                      :name => name
                    )
        end

        @@processor.resources.each do |id, name|
          @resources[id] = add_resource(
                      :id => id,
                      :name => name
                    )
        end

        @@processor.actions.each do |action_node|
          ref_id = action_node["reference_id"]
          res_id = action_node["resource_id"]
          resource = add_resource(
                  :id => res_id,
                  :name => @@processor.resources[res_id]
                )

          raise "Error: no reference for id #{ref_id}" \
                unless @@processor.references.key?(ref_id)
          add(
              :reference_id => ref_id,
              :reference_name => @@processor.references[ref_id],
              :resource_id => res_id,
              :resource =>  resource,
              :type => action_node["type"].nil? ? "default" : action_node["type"]
            )
        end
      end
    end

    # Save a resource map file, both an XML and
    # CSV versions. Hopefully CSV can be deprecated.
    def save(path, opts = {})
      save_xml(path)
      if opts[:save_csv] == true
        save_csv(path)
      end
    end

    def save_xml(path)
      reference_list = @references.collect do |id,reference|
                sprintf(
                    @@XML_REFERENCE,
                    id,
                    reference.name
                    )
      end
      resource_list = @resources.collect do |id,resource|
                sprintf(
                    @@XML_RESOURCE,
                    id,
                    resource.name
                    )
      end
      action_list = @actions.collect do |action|
                sprintf(
                    @@XML_ACTION,
                    action.reference.id,
                    action.resource.id,
                    action.type,
                    action.name,
                    action.xpath
                    )
      end

      vendors = @vendors.collect do |format,vendor|
                "#{format.to_s}=\"#{vendor.to_s}\" "
      end
      File.open(path, "w") do |f|
        f.printf(
          @@XML_RESOURCEMAP,
          @@DEFAULT_VERSION,
          vendors.join(' '),
          reference_list.join,
          resource_list.join,
          @@DEFAULT_ACTION,
          action_list.join
          )
      end
    end

    # Specify the headers to use for the CSV
    # version. Hopefully deprecated.
    def add_headers(headers)
      @csv_headers = headers
    end

    # Save the CSV version. Hopefully deprecated.
    def save_csv(path)
      resource_map_file = File.join(File.dirname(path), File.basename(path, ".*") + ".csv")

      # Determine the headers to use for the resource info CSV.
      headers = @@resource_map_file_headers + @csv_headers

      # Build the resource map CSV string.
      resource_info_body = CSV.generate(
                :headers => headers,
                :write_headers => true
            ) do |csv|
        @actions.each do |action|
          crow = {}

          # Add the "File Name" and "Resource Name" values.
          crow[@@resource_map_file_headers[0]] = action.reference.name
          crow[@@resource_map_file_headers[1]] = action.resource.name
          crow[@@resource_map_file_headers[2]] = action.type

          # Add values for the other columns, which are
          # the object properties (node attribute and
          # added properties).
          properties = action.resource.resource_properties
          if !properties.nil?
            properties.each do |attr,value|
              crow[attr] = value
            end
          end

          csv << crow
        end
      end

      # Create a CSV object from the CSV string.
      begin
        resource_info_csv = CSV.parse(
                  resource_info_body,
                  :headers => true,
                  :return_headers => false)
       #          :header_converters => lambda { |h| h.downcase.gsub(' ', '_') })
       #          :headers => true, :converters => :all,
      rescue Exception => e
        puts e.message
        return nil
      end

      # Save the resource map CSV file.
      CSV.open(
              resource_map_file,
              "w",
              :write_headers=> true,
              :headers => @@resource_map_file_headers
              #:headers => resource_map.headers
            ) do |csv|
        resource_info_csv.each do |row|
          csv << [
                    row[@@resource_map_file_headers[0]],
                    row[@@resource_map_file_headers[1]],
                    row[@@resource_map_file_headers[2]]
                 ]
          next

          # Debug code that dumps all information.
          new_row = {}
          row.each do |key,value|
            new_row[key] = value
          end
          csv << new_row
        end
      end
    end
  end
end