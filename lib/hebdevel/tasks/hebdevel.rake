# This is a rakefile for generating HEB epubs and possibly
# bundles that can be uploaded to Fulcrum.
#
# NOTE: this script requires the following 4 environment
# varibles to be set. See file "paths.rb" for descriptions
# of these variables. It is recommended that the bash
# script "hebepub" be used as it will insure that these
# required variables are set:
#   LAYOUT, HEBDIR, SRCASSETSDIR,
#   SRCTIFSCANROOTDIR, SRCPNGSCANROOTDIR
#
# All books have the following inputs:
#   DLXS source file.
#   Book cover image (optional -lg extension for hi-res)
#   Optional media assets external to the book (pdf, audio, etc.)
#
# For fixed layout epubs (backlist), the input also includes
# book page scans referenced from within the DLXS.
#
# Below are the possible outputs generated:
#   EPUB archive        Use the "epub" production.
#   Fulcrum bundle      Use the "bundle" production to generate
#                       a zip file that contains the
#                           EPUB archive
#                           Metadata CSV file
#                           Book cover image.
#                           Optional media assets.
#
# For details as to how the following files are processed,
# see the associated import:
#   CPHOLDERPATH        acls.rake
#   RELATEDPATH         acls.rake
#   REVIEWSPATH         acls.rake
#   SERIESPATH          acls.rake
#   SUBJECTPATH         acls.rake
#   ASSETSPATH          assets.rake
#   FONTSPATH           fonts.rake
#   STYLESPATH          styles.path

require 'rake/clean'
require 'fileutils'
require 'image_size'
require 'uri'

require_relative "common.rb"

require_relative "asset_list.rb"
require_relative "resources.rb"

require_relative "../../xslt"

Dir.glob("#{TARGETTASKS}/*.rake").each do |r|
  #import r
end

namespace :winterberry do

    # Productions
    desc 'Generate Fulcrum bundle.'
    task :bundle => [ BUNDLEPATH ]

    desc 'Generate Fulcrum bundle metadata CSV file.'
    task :csv => [ CSVPATH ]

    desc 'Generate HEB EPUB file.'
    task :epub => [ EPUBPATH ]

    desc 'Generate HEB EPUB files, unzipped.'
    task :epubsrc => [ EPUBSRC ]

    desc 'Generate HEB TEI file.'
    task :tei => [ TEIPATH ]

    desc 'Locate and retrieve HEB book DLXS file.'
    task :dlxs => [ DLXSPATH ]

    desc 'Locate and retrieve HEB book DLXS file.'
    task :assets => [ ASSETSPATH ]

    desc 'Invoke epubcheck on this HEB epub file.'
    task :check => [ EPUBPATH ] do
        sh %{ java -jar "#{CHECKJAR}" -mode exp -o "#{HEBDIR}/epubcheck.xml" "#{HEBDIR}/epub" } do |ok, res|
            if ! ok
                print "epubcheck failed (status = #{res.exitstatus})\n"
            end
        end
    end

    task :test do
        is_empty = is_empty_table(ASSETSPATH)
        puts "is_empty: #{is_empty}"
    end

    desc 'For fixepub, convert TIF/JP2 source to PNG.'
    task :convert => [ IMAGESDIR, METAINFSRCDIR ] do
        if LAYOUT == "fixepub"
            cwd = Dir.pwd
            Dir.chdir(SRCTIFSCANDIR)

            # Convert the TIF files
            file_list = Dir.glob("*.tif")
            if file_list.count > 0
                sh %{ java -jar "#{IMGJAR}" convert png "#{IMAGESDIR}" #{file_list.join(' ')} } do |ok, res|
                    if ! ok
                        print "TIF convert failed (status = #{res.exitstatus})\n"
                    end
                end
            end

            # Convert the JP2 files
            file_list = Dir.glob("*.jp2")
            if file_list.count > 0
                sh %{ java -jar "#{IMGJP2JAR}" convert png "#{IMAGESDIR}" #{file_list.join(' ')} } do |ok, res|
                    if ! ok
                        print "TIF convert failed (status = #{res.exitstatus})\n"
                    end
                end
            end

            # Rename an jp2, replace 'p' prefix with a '0'
            Dir.chdir(IMAGESDIR)
            Dir.glob("p*.png").each do |f|
                f_basename = File.basename(f)
                mv(f, '0' + f_basename[1..-1])
            end

            Dir.chdir(cwd)
        end
    end

    desc 'For fixepub, migrate PNG source.'
    task :migrate => [ OEBPSDIR, METAINFSRCDIR ] do
        if LAYOUT == "fixepub"
            # Copy DLXS file.
            cp(SRCFIXEPUBDLXS, METAINFSRCDIR)
            if File.exist?(SRCFIXEPUBDLXSORG)
                cp(SRCFIXEPUBDLXSORG, METAINFSRCDIR)
            end

            # Move the scans
            #mv(SRCFIXEPUBIMGS, OEBPSDIR)

            # Copy scans.
            image_exp = File.join(SRCFIXEPUBIMGS, "*")
            Dir.glob(image_exp).each do |f|
                f_basename = File.basename(f)
                cp(f, File.join(IMAGESDIR, f_basename))
            end
        end
    end

    # Generate the bundle file
    file BUNDLEPATH => [ EPUBPATH, CSVPATH ] do

        # Remove the bundle file and any media assets
        # if they exist.
        FileUtils.rm(BUNDLEPATH, :force => true)

        # Generate the list of files to include in the bundle.
        file_list = Array.new
        file_list.push(CSVPATH)
        file_list.push(EPUBPATH)

        # Determine the current media assets for this book.
        media_list = get_assets("media")
        file_list.push(media_list)

        # Determine whether related titles or reviews exist.
        if !resource_is_empty?(RELATEDPATH)
            file_list.push(RELATEDPATH)
        end
        if !resource_is_empty?(REVIEWSPATH)
            file_list.push(REVIEWSPATH)
        end

        # Generate the bundle zip file.
        file_list_str = file_list.join(" ")
        print "Generating #{File.basename(BUNDLEPATH)}\n"
        if file_list_str.length > 30000
            # Avoid DOS command line length limitation
            file_list_path = File.join(HEBDIR, "file_list")
            File.open(file_list_path, "w") { |f| f.write(file_list.join("\n")) }

            sh %{ cat "#{file_list_path}" | zip -j -@ "#{BUNDLEPATH}" } do |ok, res|
                if ! ok
                    puts "zip bundle failed (status = #{res.exitstatus})"
                end
            end
            FileUtils.rm(file_list_path)
        else
            sh %{ zip -j "#{BUNDLEPATH}" #{file_list_str} } do |ok, res|
                if ! ok
                    puts "zip bundle failed (status = #{res.exitstatus})"
                end
            end
        end
    end

    # Generate the bundle metadata CSV file from information in the TEI file.
    file CSVPATH => [ METAINFSRCDIR, CPHOLDERPATH, RELATEDPATH,
            REVIEWSPATH, SERIESPATH, SUBJECTPATH, ASSETSPATH, TEIPATH ] do

        if File.exist?(SRCMARCPATH)
            cp(SRCMARCPATH, MARCPATH)
        end

        # Use XSLT to generate the CSV file.
        xslt(METAXSLPATH, TEIPATH)
    end

    # Generate the EPUB archive from the epub directory.
    file EPUBPATH => [ EPUBSRC ] do

        # Remove the current EPUB archive if it exists.
        FileUtils.rm(EPUBPATH, :force => true)

        if LAYOUT == "flowepub"

            # For flowable epubs, remove the any existing images
            # and copy the current images for this book.
            # Don't need size info as it is now in the assets.html file.
            FileUtils.rm(File.join(IMAGESDIR, "*"), :force => true)
            image_list = get_assets("images")
            image_list.each {|item| cp(item, IMAGESDIR) }
        end

        # Generate an updated EPUB archive file.
        print "Generating #{File.basename(EPUBPATH)}\n"

        cwd = Dir.pwd
        Dir.chdir(EPUBDIR)
        file_list = Dir.glob("*")
        sh %{ zip -r "#{EPUBPATH}" #{file_list.join(' ')} } do |ok, res|
            if ! ok
                puts "zip epub failed (status = #{res.exitstatus})"
            end
        end
        Dir.chdir(cwd)
    end

    # Generate the epub directory structure.
    file EPUBSRC => [ EPUBDIR, IMAGESDIR, CPHOLDERPATH, RELATEDPATH, REVIEWSPATH, SERIESPATH, SUBJECTPATH,
                ASSETSPATH, STYLESPATH, FONTSPATH, TEIPATH ] do

        # Remove any TOC, chapter lists, packagae file, and xhtml files.
        FileUtils.rm(MIMETYPE, :force => true)
        FileUtils.rm(File.join(OEBPSDIR, "*.{xhtml,opf}"), :force => true)
        FileUtils.remove_dir(XHTMLDIR, true)

        if File.exist?(SRCMARCPATH) and !File.exist?(MARCPATH)
            cp(SRCMARCPATH, MARCPATH)
        end

        rows = ""
        if LAYOUT == "fixepub"
            # For fixed layout books, copy the page scans
            # and generate the size information for each image
            # in this book. Needed for setting the page scan
            # viewport.
            image_list = get_assets("images")
            image_list.each {|item| cp(item, IMAGESDIR) }

            scan_list = Dir.glob(File.join(IMAGESDIR, "*"))
            scan_list.each { |scan|
                f_basename = File.basename(scan)
                image_size = ImageSize.path(scan)
                width = image_size.width
                height = image_size.height
                format = image_size.format
                rows += sprintf(MARKUP_ROW_SCANS, f_basename, format, width, height)
            }
        end
        File.open(IMAGESPATH, "w") { |f| f.write(sprintf(MARKUP_TBL, "#{HEBID}_scans", HEBID, "Scans", MARKUP_HEADER_SCANS, rows)) }

        # Use XSLT to generate the updated epub structure.
        xslt(LAYOUTXSLPATH, TEIPATH)
    end

    # Generate the source TEI file from the DLXS file.
    file TEIPATH => [ DLXSPATH ] do

        # Use XSLT to generate the TEI file.
        xslt(TEIXSLPATH, DLXSPATH, TEIPATH)
    end

    # Locate and copy the DLXS source file.
    file DLXSPATH => [ METAINFSRCDIR ] do
        cp(SRCDLXSPATH, DLXSPATH, :verbose => true)
        if LAYOUT == "fixepub" and File.exists?(ORGSRCDLXSPATH)
            cp(ORGSRCDLXSPATH, File.join(METAINFSRCDIR, "#{HEBID}_dlxs_org.xml"),
                :verbose=> true)
        end
    end

    # Locate and copy the book MARC record if it exists.
    file MARCPATH => [ METAINFSRCDIR ] do
        cp(SRCMARCPATH, MARCPATH) if File.exists?(SRCMARCPATH)
    end

    # Method for invoking an XSLT process.
    def xslt(xsl_file, xml_file, dest_file = "")
      uri_path = URI(File.dirname(xml_file))
      uri_path.scheme = "file"
      params = {
                  "working-dir" => uri_path.to_s + "/"
               }
      UMPTG::XSLT.transform(
            :xslpath => xsl_file,
            :srcpath => xml_file,
            :destpath => dest_file,
            :parameters => params
            )
    end

    def xsltOLD(xsl_file, xml_file)
        # Use Java XSLT 2.0 processor.
        sh %{ java -jar "#{XSLTJAR}" "#{xsl_file}" "#{xml_file}" } do |ok, res|
            if ! ok
                puts "XSLT failed (status = #{res.exitstatus})"
            end
            FileUtils.rm("result.xml", :force => true)
        end
    end

    # Method parses the ASSETSPATH file and
    # determines whether an asset should be included in the
    # EPUB archive, or be an asset associated with the
    # monograph and listed on the Media tab.
    def get_assets(type)

        # Parse the ASSETSPATH file for generating the list of EPUB
        # included images, or media assets.
        assets_xml = File.new(ASSETSPATH)
        #parsed_assets = AssetListener.new
        #Document.parse_stream(assets_xml, parsed_assets)
        parsed_assets = parsed_assets(ASSETSPATH)

        case type
        when "images"

            # Use the generated list to copy images
            # to the images directory.
            image_list = parsed_assets.get_image_list
            return image_list
        when "media"

            # Use the generated list to copy assets
            # to the media directory.
            media_asset_list = parsed_assets.get_media_list
            return media_asset_list
        end
    end

    def resource_is_empty?(resource_path)
        # Parse the resource_path file to determine if the
        # resource table is empty.
        return is_empty_table?(resource_path)
    end

    # Productions for generating needed directories.
    directory EPUBDIR
    directory IMAGESDIR

    # For fixepub, clobber all files except the DLXS file
    # and the PNG images. The DLXS file may have been
    # modified. The images have been converted/resized
    # and don't want to redo this.
    # For flowepub, clobber all files except the DLXS file.
    CLOBBER.include(MIMETYPE)
    CLOBBER.include(TEIPATH)
    CLOBBER.include(MARCPATH)
    CLOBBER.include(File.join(METAINFSRCDIR, "*.html"))
    CLOBBER.include(File.join(METAINFDIR, "*.xml"))
    CLOBBER.include(EPUBPATH)
    CLOBBER.include(CSVPATH)
    CLOBBER.include(BUNDLEPATH)
    CLOBBER.include(File.join(HEBDIR, "*.{html,xml}"))
    CLOBBER.include(File.join(OEBPSDIR, "*.{xhtml,opf}"))
    CLOBBER.include(XHTMLDIR)
    if LAYOUT == "flowepub"
        # Remove entire OEBPS directory, including images
        CLOBBER.include(OEBPSDIR)
    else
        # Remove all files in OEBPS, except images directory.
        CLOBBER.include(File.join(OEBPSDIR, "*.{xhtml,opf}"))
    end

end
