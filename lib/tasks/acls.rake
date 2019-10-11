# Process epub resources provided by ACLS, including
#   copyholder, related titles, reviews, series, subject
# For each resource, an HTML table is generated that
# is referenced by the epub TEI file when generating
# the epub directory structure or the book metadata csv.

require_relative "common.rb"

namespace :acls do

    # Generate the paths to ACLS resource files.
    ACLSDIR=File.join(RESOURCESDIR, "aclsdb")
    ACLSCPHOLDERPATH=File.join(ACLSDIR, "copyholder", "#{HEBID}.html")
    ACLSRELATEDPATH=File.join(ACLSDIR, "related_title", "#{HEBID}.html")
    ACLSREVIEWSPATH=File.join(ACLSDIR, "reviews", "#{HEBID}.html")
    ACLSSERIESPATH=File.join(ACLSDIR, "series", "#{HEBID}.html")
    ACLSSUBJECTPATH=File.join(ACLSDIR, "subject", "#{HEBID}.html")

    task :default => [ :files ]

    task :files => [ CPHOLDERPATH, RELATEDPATH, REVIEWSPATH, SERIESPATH, SUBJECTPATH ]

    # Process copyholder
    file CPHOLDERPATH => [ :environment, METAINFSRCDIR ] do
        #cpacls(ACLSCPHOLDERPATH, CPHOLDERPATH, "Copyright Holder")

      heb = Hebid.find_by hebid: HEBID
      if heb == nil
        puts "Error: #{HEBID} record not found."
        return
      end

      heading = "<tr><th class=\"copyholder\">Organization/Name</th><th class=\"puburl\">URL</th></tr>"
      body = ""
      heb.copyholders.each do |cp|
        body += "<tr><td class=\"copyholder\">#{cp.copyholder}</td><td class=\"puburl\">#{cp.url}</td></tr>"
      end
      write_acls(CPHOLDERPATH, "Copyright Holder", heading, body)
    end

    # Process related titles
    file RELATEDPATH => [ METAINFSRCDIR ] do
        cpacls(ACLSRELATEDPATH, RELATEDPATH, "Related Titles")
    end

    # Process reviews
    file REVIEWSPATH => [ METAINFSRCDIR ] do
        cpacls(ACLSREVIEWSPATH, REVIEWSPATH, "Reviews")
    end

    # Process series
    file SERIESPATH => [ :environment, METAINFSRCDIR ] do
        #cpacls(ACLSSERIESPATH, SERIESPATH, "Series")

      heb = Hebid.find_by hebid: HEBID
      if heb == nil
        puts "Error: #{HEBID} record not found."
        return
      end

      heading = "<tr><th class=\"series\">Series</th></tr>"
      body = ""
      heb.series.each do |s|
        body += "<tr><td class=\"series\">#{s.series_title}</td></tr>"
      end
      write_acls(SERIESPATH, "Series", heading, body)
    end

    # Process subject
    file SUBJECTPATH => [ :environment, METAINFSRCDIR ] do
        #cpacls(ACLSSUBJECTPATH, SUBJECTPATH, "Subject")

      heb = Hebid.find_by hebid: HEBID
      if heb == nil
        puts "Error: #{HEBID} record not found."
        return
      end

      heading = "<tr><th class=\"subject\">Subject</th></tr>"
      body = ""
      heb.series.each do |s|
        body += "<tr><td class=\"subject\">#{s.subject_title}</td></tr>"
      end
      write_acls(SUBJECTPATH, "Subject", heading, body)
    end

    # Method for copying the resource file. If the resource
    # does not current reside in the epub directory structure,
    # or the current file is out of date with the source, then
    # copy resource into the epub directory structure.
    #
    # If the source resource file does not exist, then create
    # file with an empty HTML table in the epub structure for
    # this resource so when the TEI file is processed during
    # metadata CSV generation, it can determine that the
    # resource should not be used as xhtml file metadata or
    # be included as a media asset.
    def cpacls(srcfile, destfile, caption)
        if File.exists?(srcfile)
            # Source resource file exists, copy it out of date.
            if !File.exists?(destfile) or File.mtime(destfile).to_f > File.mtime(srcfile).to_f
                cp(srcfile, destfile)
            end
        else
            # Generate the empty html table for this file.
            print "Warning: #{srcfile} doesn't exist. Template created.\n"
            f_noext = File.basename(destfile, File.extname(destfile))
            File.open(destfile, "w") { |f|
                f.write(sprintf(MARKUP_TBL_EMPTY, "#{HEBID}_#{f_noext}", HEBID, caption))
            }
        end
    end

    def write_acls(dest_file, caption, heading, body)
      f_noext = File.basename(dest_file, File.extname(dest_file))
      File.open(dest_file, "w") { |f|
          f.write(sprintf(MARKUP_TBL, "#{HEBID}_#{f_noext}", HEBID, caption, heading, body))
      }
      puts "Created #{File.basename(dest_file)}"
    end
end