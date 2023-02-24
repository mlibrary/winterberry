module UMPTG::Journal

  require 'nokogiri'

  class JATSResourceProcessor < UMPTG::Object
    attr_reader :logger

    JATS_DOCTYPE = <<-JDT
<!DOCTYPE article
  PUBLIC "-//NLM//DTD JATS (Z39.96) Journal Publishing DTD v1.2 20190208//EN" "http://jats.nlm.nih.gov/publishing/1.2/JATS-journalpublishing1-mathml3.dtd">
JDT

    JOURNAL_ID_XPATH = <<-JIXPATH
    //*[
    local-name()='front'
    ]/*[
    local-name()='journal-meta'
    ]/*[
    local-name()='journal-id'
    and @journal-id-type='publisher'
    ]
    JIXPATH

    FULCRUM_RESOURCE_XPATH_OLD = <<-FRXPATH_OLD
    //*[
    @specific-use='umptg_fulcrum_resource_link'
    ]
    FRXPATH_OLD

    FULCRUM_RESOURCE_XPATH = <<-FRXPATH
    //*[
    local-name()='graphic'
    and @*[local-name()='href']
    ]
    FRXPATH

    LINK_HREF_MARKUP = "%s/downloads/%s?file=embed_css"

    def initialize(args = {})
      super(args)

      @logger = @properties[:logger]
      if @logger.nil?
        @logger = UMPTG::Logger.create(logger_fp: STDOUT)
      end

      @service = nil
    end

    def resource_ref_node_list(args = {})
      jats_doc = args2doc(args)
      return nil if jats_doc.nil?
      return jats_doc.xpath(FULCRUM_RESOURCE_XPATH)
    end

    def resource_ref_name_list(args = {})
      node_list = resource_ref_node_list(args)
      name_list = []
      node_list.each {|n| name_list << n['xlink:href']}
      return name_list
    end

    def process(args = {})
      # The resource manifest is required.
      manifest = args[:manifest]
      if manifest.nil?
        @logger.error("no manifest provided.")
        return nil
      end

      # Construct the JATS XML doc
      jats_doc = args2doc(args)
      return nil if jats_doc.nil?

      # See if a resource map has been specified.
      resource_map = args[:resource_map]

      # Have a JATS doc. Process it.
      resource_ref_list = jats_doc.xpath(FULCRUM_RESOURCE_XPATH)
      @logger.info("found #{resource_ref_list.count} resource references")

      if resource_ref_list.count > 0
        resource_ref_list.each do |ref_node|
          fig_node = ref_node.xpath("ancestor-or-self::*[local-name()='fig'][1]").first
          if fig_node.nil?
            @logger.warn("no figure container for link #{ref_node['xlink:href']}.")
            next
          end

          href = ref_node['xlink:href']
          fileset = nil
          unless resource_map.nil?
            resource = resource_map.reference_resource(href)
            unless resource.nil?
              @logger.info("mapped #{href} to #{resource.name}.")
              fileset = manifest.fileset(resource.name)
              if fileset['noid'].empty?
                @logger.warn("no fileset found for #{resource.name}.")
              end
            end
          end
          fileset = manifest.fileset(href) if fileset.nil?

          if fileset['noid'].empty?
            @logger.warn("no fileset for href #{href}. Skipping.")
            next
          end
          @logger.info("found fileset #{fileset['file_name']}.")

          embed_markup = fileset['embed_code']
          unless embed_markup.nil? or embed_markup.empty?
            embed_doc = Nokogiri::XML::DocumentFragment.parse(embed_markup)
            iframe_node = embed_doc.xpath("descendant-or-self::*[local-name()='iframe']").first
            embed_link = iframe_node['src']
          end

          link_uri = URI(embed_link)
          link_scheme_host = link_uri.scheme + "://" + link_uri.host

          href = fileset['link'][12..-3]
          title = fileset['title']
          title = "" if title.nil?
          caption = fileset['caption']
          caption = "" if caption.nil?
          doi = fileset['doi']
          doi = "" if doi.nil?
          doi_noprefix = doi.delete_prefix("https://doi.org/")
          embed_code = fileset['embed_code']
          noid = fileset['noid']

          css_link = sprintf(LINK_HREF_MARKUP, link_scheme_host, noid)

          media_element = jats_doc.document.create_element("media")
          fig_node.previous = media_element
          fig_node.remove

          #media_element['xlink:href'] = sprintf("%s/embed?hdl=2027%sfulcrum.%s", link_scheme_host, "%2F", noid)
          media_element['xlink:href'] = embed_link
          media_element['mimetype'] = fileset['resource_type']
          media_element['mime-subtype'] = File.extname(fileset['file_name'])[1..-1]
          media_element['position'] = 'anchor'
          media_element['specific-use'] = 'online'

          unless title.strip.empty? and caption.strip.empty?
            caption_element = media_element.document.create_element("caption")
            media_element.add_child(caption_element)
            unless title.strip.empty?
              child_element = caption_element.document.create_element("title")
              caption_element.add_child(child_element)
              child_element.content = title
            end
            unless caption.strip.empty?
              child_element = caption_element.document.create_element("p")
              caption_element.add_child(child_element)
              child_element.content = caption
            end
          end
          unless doi.strip.empty?
            child_element = media_element.document.create_element("object-id")
            media_element.add_child(child_element)
            child_element['pub-id-type'] = "doi"
            child_element.content = doi_noprefix
          end

          attrib_element = media_element.document.create_element("attrib")
          media_element.add_child(attrib_element)
          attrib_element['id'] = "umptg_fulcrum_resource_" + noid
          attrib_element['specific-use'] = "umptg_fulcrum_resource"

          unless doi.strip.empty?
            child_element = attrib_element.document.create_element("ext-link")
            attrib_element.add_child(child_element)
            child_element['ext-link-type'] = "doi"
            child_element['xlink:href'] = doi_noprefix
          end

          child_element = attrib_element.document.create_element("ext-link")
          attrib_element.add_child(child_element)
          child_element['ext-link-type'] = "uri"
          child_element['specific-use'] = "umptg_fulcrum_resource_link"
          child_element['xlink:href'] = href

          child_element = attrib_element.document.create_element("ext-link")
          attrib_element.add_child(child_element)
          child_element['ext-link-type'] = "uri"
          child_element['specific-use'] = "umptg_fulcrum_resource_css_stylesheet_link"
          child_element['xlink:href'] = css_link

          child_element = attrib_element.document.create_element("ext-link")
          attrib_element.add_child(child_element)
          child_element['ext-link-type'] = "uri"
          child_element['specific-use'] = "umptg_fulcrum_resource_embed_link"
          child_element['xlink:href'] = embed_link

          alt_element = attrib_element.document.create_element("alternatives")
          attrib_element.add_child(alt_element)
          child_element = alt_element.document.create_element("preformat")
          alt_element.add_child(child_element)
          child_element['specific-use'] = "umptg_fulcrum_resource_identifier"
          child_element['position'] = "anchor"
          child_element.content = noid

          unless title.strip.empty?
            child_element = alt_element.document.create_element("preformat")
            alt_element.add_child(child_element)
            child_element['specific-use'] = "umptg_fulcrum_resource_title"
            child_element['position'] = "anchor"
            child_element.content = title
          end
        end
      end
      return jats_doc
    end

    def self.save(jats_doc, dest_path)
      xml_string = jats_doc.root.to_s
      xml_string = xml_string.sub(/xsi:noNamespaceSchemaLocation=\"[^\"]*\"/, '')
      begin
        File.write(
            dest_path,
            UMPTG::XMLUtil.XML_PI + "\n" +
            JATS_DOCTYPE +
            xml_string
            )
      rescue Exception => e
        puts e.message
      end
    end

    private

    def args2doc(args)
      jats_doc = args[:jats_doc]
      if jats_doc.nil?
        # No doc parameter. See if JATS string provided.
        jats_content = args[:jats_content]
        if jats_content.nil? or jats_content.strip.empty?
          # No JATS string. See if JATS file provided.
          jats_file = args[:jats_file]
          if jats_file.nil? or jats_file.strip.empty?
            # No JATS file. Abort.
            @logger.error("either the :jats_doc, :jats_content, or :jats_file parameter must be specified.")
            return nil
          end

          # Have a JATS file. Make sure it exists.
          unless File.exists?(jats_file)
            @logger.error("JATS file #{jats_file} does not exist.")
            return nil
          end

          # Read content
          jats_content = File.read(jats_file)
        end

        # Have content. Construct the JATS doc.
        begin
          jats_doc = Nokogiri::XML(File.open(jats_file))
        rescue StandardError => e
          @logger.error(e.message)
          return nil
        end
      end
      jats_doc.root.add_namespace("xlink", "http://www.w3.org/1999/xlink")
      jats_doc.root.add_namespace("mml", "http://www.w3.org/1998/Math/MathML")
      jats_doc.root['dtd-version'] = "1.2"
      jats_doc.root['xml:lang'] = 'en' unless jats_doc.root.has_attribute?('xml:lang')
      jats_doc.root.remove_attribute('xsi:noNamespaceSchemaLocation')

      return jats_doc
    end
  end
end
