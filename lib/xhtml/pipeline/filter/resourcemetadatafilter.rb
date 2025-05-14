module UMPTG::XHTML::Pipeline::Filter

  class ResourceMetadataFilter < UMPTG::XML::Pipeline::Filter

    RESOURCE_XPATH = <<-SXPATH
    //*[
    local-name()='figure' and count(descendant::*[local-name()='figure'])=0
    ] | //*[
    local-name()='img' and count(ancestor::*[local-name()='figure'])=0
    ] | //*[
    @data-fulcrum-embed-filename and local-name()!='figure'
    ]
    SXPATH

    def initialize(args = {})
      args[:name] = :resource_metadata
      args[:xpath] = RESOURCE_XPATH
      super(args)
    end

    def create_actions(args = {})
      a = args.clone

      # Node could be one of the following:
      #   figure
      #   img with no figure parent
      #   span with @data-fulcrum-embed-filename
      reference_node = a[:reference_node]

      action_list = []
      if reference_node.key?("data-fulcrum-embed-filename")
        action = UMPTG::XHTML::Pipeline::Actions::MarkerAction.new(
                             name: args[:name],
                             reference_node: reference_node
                             )
      else
        action = UMPTG::XHTML::Pipeline::Actions::FigureAction.new(
            name: args[:name],
            reference_node: reference_node
            )
      end

      action_list << action
      return action_list
    end

    def process_action_results(args = {})
      action_results = args[:action_results]
      actions = args[:actions]
      logger = args[:logger]
      fmsl_csv = args[:fmsl_csv]

      actions.each do |a|
        a.object_list.each do |o|
          fmsl_row = fileset(fmsl_csv, o.resource_name)
          if fmsl_row.nil?
            logger.warn("resource #{o.resource_name} not found.")
            next
          end
          #script_logger.info("updating resource #{o.resource_name}.")

          alt = fmsl_row["Alternative Text"]
          caption = fmsl_row["Caption"]
          resource_name = o.resource_name
          epub_alt = o.alt_text
          epub_caption = o.caption_text

          logger.info("FMSL alt text matches EPUB alt text for resource \"#{resource_name}\"") \
              unless alt.nil? or alt != epub_alt
          logger.warn("No alt text found within EPUB for resource \"#{resource_name}\".") \
              if epub_alt.nil? or epub_alt.empty?
          logger.warn("Overwriting FMSL alt text with EPUB alt text for resource \"#{resource_name}\"") \
              if !(alt.nil? or alt.empty?) and !(epub_alt.nil? or epub_alt.empty?) and alt != epub_alt
              #unless (alt.nil? or alt.empty?) and !(epub_alt.nil? or epub_alt.empty?)
          logger.info("Updating FMSL alt text with EPUB alt text for resource \"#{resource_name}\"") \
              if (alt.nil? or alt.empty?) and !(epub_alt.nil? or epub_alt.empty?)
          fmsl_row["Alternative Text"] = epub_alt unless epub_alt.nil? or epub_alt.empty?

          logger.info("FMSL caption matches EPUB caption for resource \"#{resource_name}\"") \
              unless caption.nil? or caption != epub_caption
          logger.warn("No caption found within EPUB for resource \"#{resource_name}\".") \
              if epub_caption.nil? or epub_caption.empty?
          logger.warn("Overwriting FMSL caption with EPUB caption for resource \"#{resource_name}\"") \
              if !(caption.nil? or caption.empty?) and !(epub_caption.nil? or epub_caption.empty?) and caption != epub_caption
          logger.info("Updating FMSL caption with EPUB caption for resource \"#{resource_name}\"") \
              if (caption.nil? or caption.empty?) and !(epub_caption.nil? or epub_caption.empty?)
          fmsl_row["Caption"] = epub_caption unless epub_caption.nil? or epub_caption.empty?
        end
      end
    end

    private

    def fileset_ident(fmsl_csv, file_name)
      regex = sprintf("[;]?[ ]*youtube_id:[ ]*(%s)[ ]*[;]?", file_name)
      fileset_row = fmsl_csv.find {|row| !row['Identifier(s)'].nil? and row['Identifier(s)'].match?(regex) }
      fileset_row['File Name'] = file_name unless fileset_row.nil?
      return fileset_row
    end

    def fileset(fmsl_csv, file_name)
      unless file_name.nil?
        file_name_base = File.basename(file_name, ".*")
        file_name_base_lc = file_name_base.downcase
        fileset_row = fmsl_csv.find {|row| !row['File Name'].nil? and File.basename(row['File Name'], ".*").downcase == file_name_base_lc }
        if fileset_row.nil?
          file_name_base_lc = file_name_base_lc.gsub(/[ ]+/, '_')
          fileset_row = fmsl_csv.find {|row| !row['File Name'].nil? and File.basename(row['File Name'], ".*").downcase == file_name_base_lc }
        end

        fileset_row = fileset_ident(fmsl_csv, file_name_base) if fileset_row.nil?

        if fileset_row.nil?
          fn = HTMLEntities.new.decode(file_name)
          fileset_row = fmsl_csv.find {|row| row['External Resource Url'] == fn }
        end
        return fileset_row unless fileset_row.nil?
      end

      return nil
    end
  end
end