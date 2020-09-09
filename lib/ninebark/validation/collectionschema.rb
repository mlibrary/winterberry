class CollectionSchema

  require 'nokogiri'

  @@METADATA_XSD_FILE = File.join(__dir__, 'collection.xsd')
  @@METADATA_XSD = nil
  @@SCHEMA = nil

  @@METADATA_YML_FILE = File.join(__dir__, "collection.yml")
  @@FIELD2ENTRY = nil
  @@RESOURCE_TYPES = nil
  @@REPRESENTATIVES = nil
  @@FIELD_HEADERS = nil

  @@MARKUP_COLLECTION = <<-MCOLLECTION
<?xml version="1.0" encoding="UTF-8"?>
<collection xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="collection.xsd">
<monographs>
%s</monographs>
</collection>
MCOLLECTION

  @@MARKUP_MONOGRAPH = <<-MMONOGRAPH
<monograph%s>
%s%s%s</monograph>
MMONOGRAPH

  @@MARKUP_REPRESENTATIVES = <<-MREPRESENTATIVES
<representative_kind>
%s</representative_kind>
MREPRESENTATIVES

  @@MARKUP_RESOURCES = <<-MRESOURCES
<resource_type>
%s</resource_type>
MRESOURCES

  @@MARKUP_OBJECT = <<-MOBJECT
<%s%s>
%s</%s>
MOBJECT

  @@MARKUP_FIELD = <<-MFIELD
<%s>%s</%s>
MFIELD

  def self.validate(args = {})
    case
    when args.key?(:xml_markup)
      xml_doc = Nokogiri::XML(args[:xml_markup])
    when args.key?(:xml_doc)
      xml_doc = args[:xml_doc]
    else
      raise "#{__method__} ERROR: :xml_markup or :xml_doc not specified."
    end

    error_list = CollectionSchema.SCHEMA.validate(xml_doc)
    return error_list
  end

  def self.normalize(name)
    return name.strip.downcase.gsub(/[ \-\/]+/, '_')
  end

  def self.resource?(name)
    CollectionSchema.RESOURCE_TYPES.has_key?(name)
  end

  def self.representative?(name)
    CollectionSchema.REPRESENTATIVES.has_key?(name)
  end

  def self.field(name)
    CollectionSchema.FIELD_MAP[CollectionSchema.normalize(name)]
  end

  def self.field_name(name)
    field = CollectionSchema.FIELD_MAP[CollectionSchema.normalize(name)]
    return field.nil? ? name : field[:field_name]
  end

  def self.header?(name)
    CollectionSchema.FIELD_MAP.has_key?(CollectionSchema.normalize(name))
  end

  def self.headers()
    CollectionSchema.FIELD_HEADERS
  end

  def self.SCHEMA
    @@SCHEMA = Nokogiri::XML::Schema(CollectionSchema.METADATA_XSD) if @@SCHEMA.nil?
    return @@SCHEMA
  end

  def self.METADATA_XSD
    @@METADATA_XSD = File.read(@@METADATA_XSD_FILE) if @@METADATA_XSD.nil?
    return @@METADATA_XSD
  end

  def self.MARKUP_COLLECTION
    return @@MARKUP_COLLECTION
  end

  def self.MARKUP_MONOGRAPH
    return @@MARKUP_MONOGRAPH
  end

  def self.MARKUP_REPRESENTATIVES
    return @@MARKUP_REPRESENTATIVES
  end

  def self.MARKUP_RESOURCES
    return @@MARKUP_RESOURCES
  end

  def self.MARKUP_OBJECT
    return @@MARKUP_OBJECT
  end

  def self.MARKUP_FIELD
    return @@MARKUP_FIELD
  end

  private

  def self.FIELD_MAP
    if @@FIELD2ENTRY.nil?
      @@FIELD2ENTRY = {}
      YAML::load_file(@@METADATA_YML_FILE).each do |entry|
        @@FIELD2ENTRY[CollectionSchema.normalize(entry[:field_name])] = entry
      end
    end
    return @@FIELD2ENTRY
  end

  def self.RESOURCE_TYPES
    if @@RESOURCE_TYPES.nil?
      @@RESOURCE_TYPES = {}
      CollectionSchema.FIELD_MAP['resource_type'][:acceptable_values].each do |resource|
        @@RESOURCE_TYPES[resource['term']] = 1
      end
    end
    return @@RESOURCE_TYPES
  end

  def self.REPRESENTATIVES
    if @@REPRESENTATIVES.nil?
      @@REPRESENTATIVES = {}
      CollectionSchema.FIELD_MAP['representative_kind'][:acceptable_values].each do |rep|
        @@REPRESENTATIVES[rep] = 1
      end
    end
    return @@REPRESENTATIVES
  end

  def self.HEADERS
    if @@FIELD_HEADERS.nil?
      @@FIELD_HEADERS = {}
      CollectionSchema.FIELD_MAP.each do |entry|
        @@FIELD_HEADERS << entry[:field_name]
      end
    end
    return @@REPRESENTATIVES
  end
end
