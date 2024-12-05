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
=begin
      fmsl_csv = CSV.parse(
                File.read(fmsl_file),
                :headers => true,
                :return_headers => false
                )
=end
      fmsl = UMPTG::Fulcrum::Manifest::Document.new(
                  csv_file: fmsl_file,
                  convert_headers: false
              )

      entry_actions.each do |ea|
        ea.action_result.actions.each do |a|
          a.object_list.each do |o|
            fmsl_row = fmsl.fileset(o.resource_name)
            if fmsl_row['file_name'].empty?
              logger.warn("resource #{o.resource_name} not found.")
              next
            end
            #script_logger.info("updating resource #{o.resource_name}.")

=begin
            alt = fmsl_row["Alternative Text"]
            caption = fmsl_row["Caption"]
            resource_name = fmsl_row["File Name"]
=end
            alt = fmsl_row["alternative_text"]
            caption = fmsl_row["caption"]
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
      return fmsl.csv
    end
  end
end
