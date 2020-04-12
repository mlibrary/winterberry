require 'nokogiri'

# Class representing a resource map, i.e a
# mapping of file references to Fulcrum resources.
# Methods exist for reading/writing maps and searching.
# Currently, this reads/writes an XML file and writes
# a CSV, but hopefully the CSV can be deprecated.

class ResourceMap
  @@DEFAULT_VERSION = "1.0"
  @@DEFAULT_ACTION = "embed"

  # Headers to use for writing CSV version.
  @@resource_map_file_headers = [ "File Name", "Resource Name", "Resource Action" ]

  @@parser = nil
  @@processor = ResourceMapSaxDocument.new

  attr_reader :actions

  def initialize(args = {})
    # Load the XML document is one is specified
    # either by string or path.
    load(args)

    # Store additional properties for each
    # mapping. These currently are not written,
    # but are necessary for searching.
    @properties = {}

    # CSV headers, hopefully to be deprecated.
    @csv_headers = []
  end

  # Add a new map entry, reference => resource.
  def add_action(args = {})
    reference = args[:reference]
    resource_name = args[:resource_name]
    type = args[:type]
    resource_properties = args[:resource_properties]

    ref_id = args.has_key?(:reference_id) ? args[:reference_id] : \
          File.basename(reference).gsub('.', '_')
    res_id = args.has_key?(:resource_id) ? args[:resource_id] : \
          File.basename(resource_name).gsub('.', '_')

    resource = ResourceMapResource.new(
            :resource_name => resource_name,
            :resource_properties => resource_properties
        )
    action = ResourceMapAction.new(
            :reference_id => ref_id,
            :reference => reference,
            :resource_id => res_id,
            :resource => resource,
            :type => type
          )
    @actions << action
  end

  # For a specified resource, return a property map.
  def resource_properties(resource_name)
    action = @actions.find {|a| a.resource_name == resource_name }
    return action.resource_properties unless action.nil?
  end

  def reference_resource_name(reference)
    action = @actions.find {|a| a.reference == reference }
    return action.resource_name unless action.nil?
  end

  # Load an XML resource map file.
  def load(args = {})
    @actions = []

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

      @@processor.actions.each do |action_node|
        ref_id = action_node["reference_id"]
        res_id = action_node["resource_id"]

        add_action(
            :reference_id => ref_id,
            :reference => @@processor.references[ref_id],
            :resource_id => res_id,
            :resource_name =>  @@processor.resources[res_id],
            :type => action_node["type"]
          )
      end
    end
  end

  # Save a resource map file, both an XML and
  # CSV versions. Hopefully CSV can be deprecated.
  def save(path)
    save_xml(path)
    save_csv(path)
  end

  def save_xml(path)
    File.open(path, "w") do |f|
      f.puts("<?xml version=\"1.0\" encoding=\"UTF-8\"?>")
      f.puts("<resourcemap version=\"1.0\">")
      f.puts("<references>")
      @actions.each do |action|
        f.puts("<reference id=\"#{action.reference_id}\" src=\"#{action.reference}\"/>")
      end
      f.puts("</references>")
      f.puts("<resources>")
      @actions.each do |action|
        f.puts("<resource id=\"#{action.resource_id}\" name=\"#{action.resource.name}\"/>")
      end
      f.puts("</resources>")
      f.puts("<actions default=\"#{@default_action}\">")
      @actions.each do |action|
        m = "<action reference_id=\"#{action.reference_id}\""
        m += " resource_id=\"#{action.resource_id}\""
        m += " type=\"#{action.type}\""
        m += "/>"
        f.puts(m)
      end
      f.puts("</actions>")
      f.puts("</resourcemap>")
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
        crow[@@resource_map_file_headers[0]] = action.reference
        crow[@@resource_map_file_headers[1]] = action.resource_name
        crow[@@resource_map_file_headers[2]] = action.type

        # Add values for the other columns, which are
        # the object properties (node attribute and
        # added properties).
        properties = action.resource_properties
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