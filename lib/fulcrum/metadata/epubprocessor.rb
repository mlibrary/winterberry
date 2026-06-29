module UMPTG::Fulcrum::Metadata

  class EPUBProcessor < UMPTG::EPUB::Pipeline::Processor
    def initialize(name, options: {}, logger: nil)
      xhtml_processor = UMPTG::Fulcrum::Metadata::XHTML::Processor(
                "FulcrumResourceMetadataProcessor",
                options: {
                    xhtml_resource_metadata: true
                }
          )
      super(
            name,
            processors: { xhtml_processor: xhtml_processor },
            options: options,
            logger: logger
          )
    end

    def run(epub, fmsl_file, processing_dir, options: {}, logger: nil)
      entry_results = super(
              epub,
              options: options,
              logger: logger
            )

      UMPTG::Fulcrum::Metadata::EPUBProcessor.update_fmsl(entry_results, fmsl_file, processing_dir, logger)
    end

    def self.update_fmsl(entry_actions, fmsl_file, processing_dir, logger)
      fmsl_csv = CSV.parse(
                File.read(fmsl_file),
                :headers => true,
                :return_headers => false
                )

      actions = []
      entry_actions.each do |ea|
        ea.result.issues.each do |issue|
          actions += issue.actions if issue.name == :xhtml_resource_metadata
        end
      end

      logger.info("Updating FMSL #{File.basename(fmsl_file)}.")
      actions.each do |a|
        a.object_list.each do |o|
          fmsl_row = UMPTG::Fulcrum::Metadata::EPUBProcessor.fileset(fmsl_csv, o.resource_name)
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

      # Add new columns to the CSV headers if needed.
      new_fmsl_headers = fmsl_csv.headers
      new_fmsl_headers << "Caption" unless new_fmsl_headers.include?("Caption")
      new_fmsl_headers << "Alternative Text" unless new_fmsl_headers.include?("Alternative Text")

      # Save the updated FMSL in the resource processing directory.
      new_fmsl_file = File.join(processing_dir, File.basename(fmsl_file))
      CSV.open(
              new_fmsl_file,
              "w",
              :write_headers=> true,
              :headers => new_fmsl_headers
            ) do |csv|
        fmsl_csv.each do |fmsl_row|
          new_row = {}
          fmsl_row.each do |key,value|
            new_row[key] = value.strip.force_encoding("UTF-8") unless value.nil?
          end
          csv << new_row
        end
      end
    end

    private

    def self.fileset_ident(fmsl_csv, file_name)
      regex = sprintf("[;]?[ ]*youtube_id:[ ]*(%s)[ ]*[;]?", file_name)
      fileset_row = fmsl_csv.find {|row| !row['Identifier(s)'].nil? and row['Identifier(s)'].match?(regex) }
      fileset_row['File Name'] = file_name unless fileset_row.nil?
      return fileset_row
    end

    def self.fileset(fmsl_csv, file_name)
      unless file_name.nil?
        file_name_base = File.basename(file_name, ".*")
        file_name_base_lc = file_name_base.downcase
        fileset_row = fmsl_csv.find {|row| !row['File Name'].nil? and File.basename(row['File Name'], ".*").downcase == file_name_base_lc }
        if fileset_row.nil?
          file_name_base_lc = file_name_base_lc.gsub(/[ ]+/, '_')
          fileset_row = fmsl_csv.find {|row| !row['File Name'].nil? and File.basename(row['File Name'], ".*").downcase == file_name_base_lc }
        end

        fileset_row = UMPTG::Fulcrum::Metadata::EPUBProcessor.fileset_ident(fmsl_csv, file_name_base) if fileset_row.nil?

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
