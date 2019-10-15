# Process epub resources provided by ACLS, including
#   copyholder, related titles, reviews, series, subject
# For each resource, an HTML table is generated that
# is referenced by the epub TEI file when generating
# the epub directory structure or the book metadata csv.

require 'htmlentities'

require_relative "common.rb"

namespace :winterberry do

    task :default => [ :files ]

    task :files => [ CPHOLDERPATH, RELATEDPATH, REVIEWSPATH, SERIESPATH, SUBJECTPATH ]

    # Process copyholder
    file CPHOLDERPATH => [ :environment, METAINFSRCDIR ] do
      heb = Hebid.find_by hebid: HEBID
      if heb == nil
        puts "Error: #{HEBID} record not found."
        return
      end

      coder = HTMLEntities.new
      heading = "<tr><th class=\"copyholder\">Organization/Name</th><th class=\"puburl\">URL</th></tr>"
      body = ""
      heb.copyholders.each do |cp|
        body += "<tr><td class=\"copyholder\">#{coder.encode(cp.copyholder)}</td><td class=\"puburl\">#{cp.url}</td></tr>"
      end
      write_acls(CPHOLDERPATH, "Copyright Holder", heading, body)
    end

    # Process related titles
    file RELATEDPATH => [ :environment, METAINFSRCDIR ] do
      heb = Hebid.find_by hebid: HEBID
      if heb == nil
        puts "Error: #{HEBID} record not found."
        return
      end

      related_title_list = HebidRelatedTitle.where(hebid_id: heb.id)
      if related_title_list == nil
        puts "Warning: #{HEBID} no related titles found"
        return
      end

      coder = HTMLEntities.new
      heading = "<tr><th class=\"related_hebid\">HEB Id</th><th class=\"related_title\">Title</th><th class=\"related_authors\">Authors</th><th class=\"related_pubinfo\">Publication Information</th></tr>"
      body = ""
      related_title_list.each do |cp|
        body += "<tr><td class=\"related_hebid\">#{cp.related_hebid}</td><td class=\"related_title\">#{coder.encode(cp.related_title)}</td><td class=\"related_authors\">#{coder.encode(cp.related_authors)}</td><td class=\"related_pubinfo\">#{coder.encode(cp.related_pubinfo)}</td></tr>"
      end
      write_acls(RELATEDPATH, "Related Titles", heading, body)
    end

    # Process reviews
    file REVIEWSPATH => [ :environment, METAINFSRCDIR ] do
      heb = Hebid.find_by hebid: HEBID
      if heb == nil
        puts "Error: #{HEBID} record not found."
        return
      end

      review_list = HebidReview.where(hebid_id: heb.id)
      if review_list == nil
        puts "Warning: #{HEBID} no reviews found"
        return
      end

      coder = HTMLEntities.new
      heading = "<tr><th class=\"journal_abbrev\">Journal Abbreviation</th><th class=\"review_label\">Label</th><th class=\"review_url\">URL</th></tr>"
      body = ""
      review_list.each do |cp|
        body += "<tr><td class=\"journal_abbrev\">#{coder.encode(cp.journal_abbrev)}</td><td class=\"review_label\">#{coder.encode(cp.review_label)}</td><td class=\"review_url\">#{cp.review_url}</td></tr>"
      end
      write_acls(REVIEWSPATH, "Reviews", heading, body)
    end

    # Process series
    file SERIESPATH => [ :environment, METAINFSRCDIR ] do
      heb = Hebid.find_by hebid: HEBID
      if heb == nil
        puts "Error: #{HEBID} record not found."
        return
      end

      coder = HTMLEntities.new
      heading = "<tr><th class=\"series\">Series</th></tr>"
      body = ""
      heb.series.each do |s|
        body += "<tr><td class=\"series\">#{coder.encode(s.series_title)}</td></tr>"
      end
      write_acls(SERIESPATH, "Series", heading, body)
    end

    # Process subject
    file SUBJECTPATH => [ :environment, METAINFSRCDIR ] do
      heb = Hebid.find_by hebid: HEBID
      if heb == nil
        puts "Error: #{HEBID} record not found."
        return
      end

      coder = HTMLEntities.new
      heading = "<tr><th class=\"subject\">Subject Designation</th></tr>"
      body = ""
      heb.subjects.each do |s|
        body += "<tr><td class=\"subject\">#{coder.encode(s.subject_title)}</td></tr>"
      end
      write_acls(SUBJECTPATH, "Subject Designation", heading, body)
    end

    def write_acls(dest_file, caption, heading, body)
      f_noext = File.basename(dest_file, File.extname(dest_file))
      File.open(dest_file, "w") { |f|
          f.write(sprintf(MARKUP_TBL, "#{HEBID}_#{f_noext}", HEBID, caption, heading, body))
      }
      puts "Created #{File.basename(dest_file)}"
    end
end
