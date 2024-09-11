module UMPTG::Fulcrum::Metadata

  class Processor < UMPTG::XML::Pipeline::Processor

    def initialize(args = {})
      a = args.clone

      a[:filters] = FILTERS
      a[:options] = {
          resource_metadata: true
        }
      super(a)
    end

    def update_fmsl(args = {})
      fmsl_file = args[:fmsl_file]
      entry_actions = args[:entry_actions]

      fmsl_csv = CSV.parse(
                File.read(fmsl_file),
                :headers => true,
                :return_headers => false
                )

      entry_actions.each do |ea|
        ea.action_result.actions.each do |a|
          a.object_list.each do |o|
            #fmsl_row = monograph_dir.fmsl.fileset(o.resource_name)
            file_name_base = File.basename(o.resource_name, ".*").downcase
            fmsl_row = fmsl_csv.find {|row| !row['File Name'].nil? and File.basename(row['File Name'], ".*").downcase == file_name_base }
            if fmsl_row.nil?
              logger.warn("resource #{o.resource_name} not found.")
              next
            end
            #script_logger.info("updating resource #{o.resource_name}.")

            alt = fmsl_row["Alternative Text"]
            caption = fmsl_row["Caption"]
            resource_name = fmsl_row["File Name"]
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
      return fmsl_csv
    end
  end
end
