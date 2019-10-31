# HEB EPUB Generation
This document provides the details for the generation of HEB EPUB books, including both fixed and flowable layout books.

The root directory location for the HEB EPUB books is the following:

<a name="rootdir">**ROOTDIR**</a> = **tang.umdl.umich.edu:/quod-prep/prep/a/acls/hebepub**

This location contains the following directories:

* <a name="fixepub_dir">**fixepub**</a> - directory contains the fixed layout book specifics. See [Layouts](#layouts) for more information.
* <a name="flowepub_dir">**flowepub**</a> - directory contains the flowable layout book specifics. See [Layouts](#layouts) for more information.
* <a name="resources_dir">**resources**</a> - directory contains the source for resources used for generating a EPUB. See section [Resources](#resources) for more information.
* <a name="implementation_dir">**target**</a> - directory contains the files used to automate the generation process. See section [Implementation](#implementation) for more information.  

# Table of Contents
1. [Table of Contents](#table-of-contents)
2. [Layouts](#layouts)
3. [Resources](#resources)
4. [HEB Book Source Structure](#heb-book-source-structure)
5. [Process Invocation](#process-invocation)
    1. [Process 1 - Convert Page Scans (fixepub only)](#process-1---convert-page-scans-(fixepub-only))
    2. [Process 2 - Generate EPUB Archive](#process-2---generate-epub-archive)
        1. [Step 2.1 - Copy DLXS XML Source](#step-2.1---copy-dlxs-xml-source)
        2. [Step 2.2 - Copy Resource Files](#step-2.2---copy-resource-files)
        3. [Step 2.3 - Copy Font Files (flowepub only)](#step-2.3---copy-font-files-(flowepub-only))
        4. [Step 2.4 - Copy Stylesheet Files](#step-2.4---copy-stylesheet-files)
        5. [Step 2.5 - Determine Book Assets](#step-2.5---determine-book-assets)
        6. [Step 2.6 - Generate TEI XML File](#step-2.6---generate-tei-xml-file)
        7. [Step 2.7 - Copy Book Cover Image(s)](#step-2.7---copy-book-cover-image(s))
        8. [Step 2.8 - Determine Image Dimensions (fixepub only)](#step-2.8---determine-image-dimensions-(fixepub-only))
        9. [Step 2.9 - Generate EPUB Structure](#step-2.9---generate-epub-structure)
        10. [Step 2.10 - Copy Image Files / Determine Image Dimensions (flowepub only)](#step-2.10---copy-image-files-/-determine-image-dimensions-(flowepub-only))
        11. [Step 2.11 - Zip EPUB Structure](#step-2.11---zip-epub-structure)
    3. [Process 3 - EPUB Structure Validation](#process-3---epub-structure-validation)
    4. [Process 4 - Generate Fulcrum Monograph Bundle Archive](#process-4---generate-fulcrum-monograph-bundle-archive)
        1. [Step 4.1 - Generate Monograph Metadata CSV](#step-4.1---generate-monograph-metadata-csv)
        2. [Step 4.2 - Determine Media Assets](#step-4.2---determine-media-assets)
        3. [Step 4.3 - Zip Monograph Bundle](#step-4.3---zip-monograph-bundle)
    5. [Process 5 - Add Asset Links](#process-5---add-asset-links)
    6. [Process 6 - Clobber Source Files](#process-6---clobber-source-files)
6. [Implementation](#implementation)

# Layouts

The process for generating a HEB EPUB archive differs based on the layout of the book. Currently, each layout has its own directory within the [ROOTDIR](#rootdir) location where the book source resides and any specific resources needed to generate the book. Below are the contents found within a layout directory:

* **books** - this directory contains the books for the specified layout. Within this directory, each book has a directory with the book HEB ID as the name. See section [HEB Book Source Structure](#heb-book-source-structure) for more information.

* **dlxs** - this directory contains the original source DLXS XML files. For [flowepub](#flowepub_dir), the contents is the list of XML files with the HEB ID as the name.  

For [fixepub](#fixepub_dir), this is a link to the directory **tang.umdl.umich.edu:/n1/obj/h/e/b** and the contents consists of a list of directories, one for each HEB book, with the name being the book HEB ID. Each book directory contains the source DLXS XML file and all original page scans.

# Resources

The resources directory contains the source for the following information used for generating a HEB EPUB:

* **aclsdb** - directory containing information provided by ACLS for HEB books. This information includes:
    * <a name="copyholder">**copyholder**</a> - if a HEB book has copyright information, then this directory contains a HTML file with the name of the book HEB ID that consists of a table listing the copyright holder organizations and a URL contact for each.
    * <a name="related_title">**related_title**</a> - if a HEB book has related titles, then this directory contains a HTML file with the name of the book HEB ID that consists of a table listing the related titles.
    * <a name="reviews">**reviews**</a> - if a HEB book has reviews, then this directory contains a HTML file with the name of the book HEB ID that consists of a table listing the reviews.
    * <a name="series">**series**</a> - if a HEB book has series designations, then this directory contains a HTML file with the name of the book HEB ID that consists of a table listing the designations.
    * <a name="subject">**subject**</a> - if a HEB book has subject designations, then this directory contains a HTML file with the name of the book HEB ID that consists of a table listing the subjects.
* <a name="assets">**assets**</a> - directory containing all assets for all HEB books, including cover image, audio, video, and PDF files.  

    **NOTE**: this directory is a link to the following directory: **tang.umdl.umich.edu:/n1/web/a/acls/images**
* <a name="asset_links">**asset_links**</a> - if a HEB book currently has a Fulcrum monograph page with assets listed on the Media tab, then this directory contains a CSV file with the name of the book HEB ID that contains the information for each book asset.
* <a name="marc">**marc**</a> - if a HEB book has a MARC record, then this directory contains a XML file representation of the record. The file name is the first 5 digits of the HEB ID.

# HEB Book Source Structure
The EPUB source for a HEB book can be found in a directory at the following path:

[ROOTDIR](#rootdir)/_layout_/_hebxxxxx.xxxx.xxx_

where _layout_ is either [fixepub](#fixepub_dir) or [flowepub](#flowepub_dir) and _hebxxxxx.xxxx.xxx_ is the HEB ID assigned to the book. For example, the source for the fixed layout book with ID **heb04015.0001.001** can be found in the following directory:

[ROOTDIR](#rootdir)**/fixepub/heb04015.0001.001**

The source directory for the HEB book with the ID _hebxxxxx.xxxx.xxx_ has the following layout:

* <a name="epub_dir">**epub**</a> - directory containing the unzipped EPUB book structure, including:
    * **mimetype**
    * **META-INF/{container,metadata}.xml**
    * <a name="metainfsrc_dir">**META-INF/src**</a> - this directory contains the source XML files used to generate this EPUB, including the original DLXS and TEI XML. The allows for the book source to be contained within the EPUB archive itself. Below is a list of the expected contents:
        * <a name="heb_dlxs_xml">**hebxxxxx.xxxx.xxx_dlxs.xml**</a> - DLXS XML source for the book.
        * <a name="heb_dlxs_org_xml">**hebxxxxx.xxxx.xxx_dlxs_org.xml**</a> - original DLXS XML source for the book. This is present only if it required modification before being processed.
        * <a name="heb_tei_xml">**hebxxxxx.xxxx.xxx_tei.xml**</a> - TEI XML source generated by transformation of the DLXS XML source. This file is used to generate the EPUB archive.
        * <a name="assets_html">**assets.html**</a> - HTML table referenced by the TEI XML file that lists all assets associated with this book, including cover images, book images, audio, video, PDFs, etc. For each asset, a column exists indicating the following concerning each asset:
            * full path.
            * mime-type.
            * whether it should be included in the EPUB archive.
            * whether it should be listed in the monograph Media tab.
            * whether it is a cover image.
            * whether is a hi-resolution version of the image (determined by the -lg suffix on the file name).
            * width in pixels, if asset is an image.
            * height in pixels, if asset is an image.
            * title if asset has previously been uploaded to Fulcrum. Generated from the contents of [asset_links](#asset_links).
            * NOID if asset has previously been uploaded to Fulcrum. Generated from the contents of [asset_links](#asset_links).
            * URL link to asset page, if asset has previously been uploaded to Fulcrum. Generated from the contents of [asset_links](#asset_links).
            * embed code markup if asset has previously been uploaded to Fulcrum.
            
              **NOTE**: for fixed layout books, the page scans are not included in this list.
        * <a name="copyholder_html">**copyholder.html**</a> - copy of [copyholder](#copyholder).
        * <a name="fonts_html">**fonts.html**</a> - HTML table referenced by the TEI XML file that lists all fonts to be included within the EPUB archive.
        * <a name="images_html">**images.html**</a> - HTML table referenced by the TEI XML file that lists all images referenced by the book. For each image, a column exists indicating the format, width, and height. Useful for setting the viewport metadata within a fixed layout page scan HTML file.
        * <a name="marc_xml">**marc.xml**</a> - copy of [marc](#marc).
        * <a name="related_html">**related.html**</a> - copy of [related_title](#related_title). If not empty, then this file is uploaded to Fulcrum and used as the contents to the monograph page Related Titles tab.
        * <a name="reviews_html">**reviews.html**</a> - copy of [reviews](#reviews). If not empty, then this file is uploaded to Fulcrum and used as the contents to the monograph page Reviews tab.
        * <a name="series_html">**series.html**</a> - copy of [series](#series).
        * <a name="stylesheets_html">**stylesheets.html**</a> - HTML table referenced by the TEI XML file that lists all CSS stylesheets to be included within the EPUB archive.
        * <a name="subject_html">**subject.html**</a> - copy of [subject](#subject).
    * <a name="oebps_dir">**OEBPS**</a> - contains the book content.
        * <a name="fonts_dir">**fonts**</a> - directory containing the book font files listed in the [fonts.html](#fonts_html) file. This directory is present only for [flowepub](#flowepub_dir).
        * <a name="images_dir">**images**</a> - directory containing the images listed in the [images.html](#images_html) file. The book cover images reside here. For the fixed layout books, the page scan images reside here. For [flowepub](#flowepub_dir), all images referenced by the [hebxxxxx.xxxx.xxx_tei.xml](#heb_tei_xml) file reside here.
        * <a name="styles_dir">**styles**</a> - directory containing the CSS stylesheet files listed in the [stylesheets.html](#stylesheets_html) file.
        * <a name="xhtml_dir">**xhtml**</a> - directory containing the HTML/XHTML files for this book.
        * **content_{fixed_ocr,fixed_scan,flow}.opf** - EPUB package file. For [fixepub](#fixepub_dir), there exists two files, one for the page scan rendition (**content_fixed_scan.opf**) and the second for the text OCR rendition (**content_fixed_ocr.opf**). For [flowepub](#flowepub_dir), there is one file (**content_flow.opf**).
        * **toc_{fixed_ocr,fixed_scan, flow}.xhtml** - EPUB TOC files. For [fixepub](#fixepub_dir), there exists two files, one for the page scan rendition (**toc_fixed_scan.xthml**) and the second for the text OCR rendition (**toc_fixed_ocr.xhtml**). For [flowepub](#flowepub_dir), there is one file (**toc_flow.xhtml**).
        * **page_list_{fixed_ocr,fixed_scan,flow}.xhtml** - EPUB page list files. For [fixepub](#fixepub_dir), there exists two files, one for the page scan rendition (**pagelist_fixed_scan.xhtml**) and the second for the text OCR rendition (**pagelist_fixed_ocr.xhtml**). For [flowepub](#flowepub_dir), there is one file (**pagelist_flow.xhtml**).
        * **chapter_list_{fixed_ocr,fixed_scan,flow}.xhtml** - EPUB chapter list files. For [fixepub](#fixepub_dir), there exists two files, one for the page scan rendition (**chapterlist_fixed_scan.xthml**) and the second for the text OCR rendition (**chapterlist_fixed_ocr.xhtml**). For [flowepub](#flowepub_dir), there is one file (**chapterlist_flow.xhtml**).
* <a name="heb_epub">**hebxxxxx.xxxx.xxx.epub**</a> - archive of the [epub](#epub_dir) directory described above.
* <a name="heb_metadata_csv">**hebxxxxx.xxxx.xxx_metadata.csv**</a> - CSV file the contains the metadata for this book, including the monograph information, asset information, [reviews.html](#reviews_html), [related.html](#related_html), and the cover image.
* <a name="heb_zip">**hebxxxxx.xxxx.xxx.zip**</a> - zip file that can be used as a Fulcrum bundle for upload to create a new monograph. The following may be included:
    * [hebxxxxx.xxxx.xxx_metadata.csv](#heb_metadata_csv)
    * **hebxxxxx.xxxx.xxx-lg.jpg** - book cover image.
    * [hebxxxxx.xxxx.xxx.epub](#heb_epub)
    * [related.html](#related_html) - if not empty.
    * [reviews.html](#reviews_html) - if not empty.
    * Media assets - the book media assets listed in the [assets.html](#assets_html) file.
* <a name="epubcheck_xml">**epubcheck.xml**</a> - may exists as a result of an invocation of the check production. Contains the output from **epubcheck** validation.

# Process Invocation

The command for invoking any process is the ruby script [hebepub](#hebepub) found within the [ROOTDIR](#rootdir)**/winterberry/script** directory. The syntax for this command is:

  ````
  hebepub production [hebDir…]
  ````
* _production_
    * _bundle_ - generates a [Fulcrum Monograph Bundle Archive](#process-4---generate-fulcrum-monograph-bundle-archive).
    * _check_ - performs [EPUB Structure Validation](#process-3---epub-structure-validation).
    * _clobber_ - removes HEB source directory files thus allowing it to be re-generated. See [Clobber Source Files](#process-6---clobber-source-files).
    * _convert_ - for fixepub, converts original HEB source page scan files from TIF/JP2 to PNG.
    * _epub_ - generates the [HEB EPUB Archive](#process-2---generate-epub-archive).
*   _hebDir_ - path to 1 or more HEB EPUB source directories. If no directory is specified, then the current directory is assumed. If the specified directory does not exist, then a directory will be created.
  
This script sets required environment variables and traverses the list of specified HEB source directories, invoking a Rake task specified by the production parameter on each. See [rakefile](#rakefile) for the details.

Below are example invocations:

1. For the XML title **hebxxxxx.xxxx.xxx**, the following commands will generate the book EPUB archive file:  

   ````
   cd /quod-prep/prep/a/acls/hebepub
   target/bin/hebepub epub flowepub/books/hebxxxxx.xxxx.xxx  
   ````
   The resulting EPUB archive file is stored at 
   **flowepub/books/hebxxxxx.xxxx.xxx/hebxxxxx.xxxx.xxx.epub**.  

2. For the backlist title **hebxxxxx.xxxx.xxx**, the following commands will generate the book Fulcrum bundle file:  

   ````
   cd /quod-prep/prep/a/acls/hebepub
   target/bin/hebepub bundle  fixepub/books/hebxxxxx.xxxx.xxx  
   ````
   The resulting bundle file is stored at  
   **fixepub/books/hebxxxxx.xxxx.xxx/hebxxxxx.xxxx.xxx.zip**.  

3. The following commands will rebuild the bundle file for backlist title **hebxxxxx.xxxx.xxx**:  

    ````
    cd /quod-prep/prep/a/acls/hebepub
    target/bin/hebepub clobber fixepub/books/hebxxxxx.xxxx.xxx  
    target/bin/hebepub bundle  fixepub/books/hebxxxxx.xxxx.xxx  
    ```` 

4. The following commands will invoke **epubcheck** on the specified EPUB source directory:  

    ````
    cd /quod-prep/prep/a/acls/hebepub  
    target/bin/hebepub check fixepub/books/hebxxxxx.xxxx.xxx  
    ````
    
    The output from epubcheck is stored in the file  
    **fixepub/books/hebxxxxx.xxxx.xxx/[epubcheck.xml](#epubcheck_xml)**

5. The following commands will convert page scan TIF images to PNG for backlist title **hebxxxxx.xxxx.xxx**:  

    ````
    cd /quod-prep/prep/a/acls/hebepub
    target/bin/hebepub convert fixepub/books/hebxxxxx.xxxx.xxx  
    ````
    
    The new PNG files are stored in the directory:  
    **fixepub/books/hebxxxxx.xxxx.xxx/epub/OEBPS/images**

The following sections describe the steps necessary to perform the HEB EPUB processes.

## Process 1 - Convert Page Scans (fixepub only)

For [fixepub](#fixepub_dir) books, original page scan files for the book are expected to reside in the following directory:

[ROOTDIR](#rootdir)**/fixepub/dlxs/hebxxxxx.xxxx.xxx**

where **hebxxxxx.xxxx.xxx** is the HEB ID assigned to the book. The file format is expected to be either TIF or JP2. The EPUB specification does not support TIF, so it is necessary to convert the original scans to PNG.

The conversion can be done by invoking the following commands:

    cd /quod-prep/prep/a/acls/hebepub
    target/bin/hebepub convert layout/hebxxxxx.xxxx.xxx

   The new PNG files are stored in the [images](#images_dir) directory within the **hebxxxxx.xxxx.xxx** source directory.

## Process 2 - Generate EPUB Archive

Below are the process steps necessary to generate the HEB book EPUB archive. The following commands can be used to invoke this process and generate a HEB EPUB for the book with the ID **hebxxxxx.xxxx.xxx**:

    cd /quod-prep/prep/a/acls/hebepub  
    target/bin/hebepub epub layout/hebxxxxx.xxxx.xxx  

### Step 2.1 - Copy DLXS XML Source

The book DLXS XML source is expected to be found at the path listed in the table below and copied to path [hebxxxxx.xxxx.xxx_dlxs.xml](#heb_dlxs_xml).

<table class="wrapped" style="margin-left: 30.0px;"><colgroup><col> <col></colgroup> 

<tbody style="margin-left: 30.0px;">
<tr style="margin-left: 30.0px;">
<td style="margin-left: 30.0px;">

**Layout**
</td>
<td style="margin-left: 30.0px;">

**Source Path**
</td>
</tr>

<tr style="margin-left: 30.0px;">

<td style="margin-left: 30.0px;">

[fixepub](#fixepub)
</td>

<td style="margin-left: 30.0px;">

[ROOTDIR](#rootdir)**/fixepub/dlxs/hebxxxxx.xxxx.xxx/hebxxxxx.xxxx.xxx.xml**
</td>
</tr>
<tr style="margin-left: 30.0px;">

<td style="margin-left: 30.0px;">

[flowepub](#flowepub)
</td>
<td style="margin-left: 30.0px;">

[ROOTDIR](#rootdir)**/flowepub/dlxs/hebxxxxx.xxxx.xxx.xml**
</td>
</tr>
</tbody>
</table>

### Step 2.2 - Copy Resource Files

The following resources are copied from their source paths into the [METAINFSRC](#metainfsrc_dir) directory and referenced by the [hebxxxxx.xxxx.xxx_tei.xml](#heb_tei_xml) file:

<table class="wrapped" style="margin-left: 30.0px;"><colgroup><col style="width: 154.0px;"> <col style="width: 447.0px;"></colgroup> 

<tbody style="margin-left: 30.0px;">

<tr style="margin-left: 30.0px;">

<th style="margin-left: 30.0px;">

**Resource**
</th>
<td style="margin-left: 30.0px;">

**Source Paths**
</td>
</tr>
<tr style="margin-left: 30.0px;">

<th style="margin-left: 30.0px;">

[marc.xml](#marc_xml)
</th>
<td style="margin-left: 30.0px;">

[ROOTDIR](#rootdir)**/resources/marc/hebxxxxx.xml**
</td>
</tr>
<tr style="margin-left: 30.0px;">
<th style="margin-left: 30.0px;">

[copyholder.html](#copyholder_html)
</th>
<td style="margin-left: 30.0px;">

[ROOTDIR](#rootdir)**/resources/aclsdb/copyholder/hebxxxxx.xxxx.xxx.xml**
</td>
</tr>
<tr style="margin-left: 30.0px;">
<th style="margin-left: 30.0px;">

[related.html](#related_html)
</th>
<td style="margin-left: 30.0px;">

[ROOTDIR](#rootdir)**/resources/aclsdb/related_title/hebxxxxx.xxxx.xxx.xml**
</td>
</tr>
<tr style="margin-left: 30.0px;">
<th style="margin-left: 30.0px;">

[reviews.html](#reviews_html)
</th>
<td style="margin-left: 30.0px;">

[ROOTDIR](#rootdir)**/resources/aclsdb/reviews/hebxxxxx.xxxx.xxx.xml**
</td>
</tr>
<tr style="margin-left: 30.0px;">
<th style="margin-left: 30.0px;">

[series.html](#series_html)
</th>
<td style="margin-left: 30.0px;">

[ROOTDIR](#rootdir)**/resources/aclsdb/series/hebxxxxx.xxxx.xxx.xml**
</td>
</tr>
<tr style="margin-left: 30.0px;">
<th style="margin-left: 30.0px;">

[subject.html](#subject_html)
</th>
<td style="margin-left: 30.0px;">

[ROOTDIR](#rootdir)**/resources/aclsdb/subject/hebxxxxx.xxxx.xxx.xml**
</td>
</tr>
</tbody>
</table>

### Step 2.3 - Copy Font Files (flowepub only)

The font files are found in the directory

[ROOTDIR](#rootdir)**/flowepub/fonts**

and copied into the [fonts](#fonts_dir) directory. The [fonts.html](#fonts_html) file is generated during this step. For [fixepub](#fixepub_dir), currently there are no fonts to include. So, this file is empty.

### Step 2.4 - Copy Stylesheet Files

The CSS stylesheet file(s) are found in the directory

[ROOTDIR](#rootdir)**/layout/styles**

where _layout_ is either [fixepub](#fixepub_dir) or [flowepub](#flowepub_dir) and are copied into the [styles](#styles_dir) directory. The [stylesheets.html](#stylesheets_html) file is generated during this step.

### Step 2.5 - Determine Book Assets

Assets include book cover image/audio/video/PDF/etc files. These files use the book HEB ID as the prefix for the filename and are expected to reside in the directory:

[ROOTDIR](#rootdir)**/resources/assets**

No files are copied during this step. The [assets.html](#assets_html) file is generated.

### Step 2.6 - Generate TEI XML File

Transform the DLXS XML file [hebxxxxx.xxxx.xxx_dlxs.xml](#heb_dlxs_xml) to the TEI XML file [hebxxxxx.xxxx.xxx_tei.xml](#heb_tei_xml) using the XSLT stylesheet [hebdlxs2tei.xsl](#hebdlxs2tei_xsl).

### Step 2.7 - Copy Book Cover Image(s)

The cover image(s) are located at the path:

[ROOTDIR](#rootdir)**/resources/assets/hebxxxxx.xxxx.xxx.jpg**
[ROOTDIR](#rootdir)**/resources/assets/hebxxxxx.xxxx.xxx-lg.jpg** (higher resolution, may not be present)

and copied in the [images](#images_dir) directory.

### Step 2.8 - Determine Image Dimensions (fixepub only)

For [fixepub](#fixepub_dir) only, all images found in the [images](#images_dir) directory, including cover images and page scan image files (see [Process 1](#process-1---convert-page-scans-(fixepub-only)) are used as input for generating the [images.html](#images_html) file.

### Step 2.9 - Generate EPUB Structure

The TEI XML file [hebxxxxx.xxxx.xxx_tei.xml](#heb_tei_xml) contains references to the resources ([marc.xml](#marc_xml), [copyholder.html](#copyholder_html), [related.html](#related_html), [reviews.html](#reviews_html), [series.html](#series_html), [subject.html](#subject_html)), fonts ([fonts.html](#fonts_html)), CSS stylesheets ([stylesheets.html](#stylesheets_html)), and book assets ([assets.html](#assets_html)). It is used as the input to a XSLT transformation to produce the EPUB book content found in the [OEBPS](#oebps_dir) directory. The XSLT stylesheets [hebtei2fixepub.xsl](#hebtei2fixepub_xsl) ([fixepub](#fixepub_dir)) and [hebtei2flowepub.xsl](#hebtei2flowepub_xsl) ([flowepub](#flowepub_dir)) are used for the transformation.

### Step 2.10 - Copy Image Files / Determine Image Dimensions (flowepub only)

For [flowepub](#flowepub_dir) only, all images referenced by the TEI XML file [hebxxxxx.xxxx.xxx_tei.xml](#heb_tei_xml) are copied to the [images](#images_dir) directory. Then all images found in the [images](#images_dir) directory, including cover images, are used as input for generating the [images.html](#images_html) file.

### Step 2.11 - Zip EPUB Structure

The [hebxxxxx.xxxx.xxx.epub](#heb_epub) file is generated by zipping the contents of the [epub](#epub_dir) directory.

## Process 3 - EPUB Structure Validation

Any HEB EPUB directory can be validated by invoking the following commands:

    cd /quod-prep/prep/a/acls/hebepub
    target/bin/hebepub check layout/books/hebxxxxx.xxxx.xxx

where _layout_ is either [fixepub](#fixepub_dir) or [flowepub](#flowepub_dir). The results can be found in the file

[ROOTDIR](#rootdir)/_layout_/books/hebxxxxx.xxxx.xxx/[epubcheck.xml](#epubcheck_xml)

## Process 4 - Generate Fulcrum Monograph Bundle Archive

To create a new monograph for a HEB EPUB, the [hebxxxxx.xxxx.xxx.zip](#heb_zip) may be generated by invoking the following commands:

    cd /quod-prep/prep/a/acls/hebepub
    target/bin/hebepub bundle layout/hebxxxxx.xxxx.xxx

where _layout_ is either [fixepub](#fixepub_dir) or [flowepub](#flowepub_dir). Below are the process steps for generating the bundle. This process may invoke [Process 2](#process-2---generate-epub-archive) if the [hebxxxxx.xxxx.xxx.epub](#heb_epub) has not been previously generated.

### Step 4.1 - Generate Monograph Metadata CSV

The TEI XML file [hebxxxxx.xxxx.xxx_tei.xml](#heb_tei_xml) is used as the input to a XSLT transformation to produce the monograph metadata file [hebxxxxx.xxxx.xxx_metadata.csv](heb_metadata_csv). The XSLT stylesheet [hebtei2meta.xsl](#hebtei2meta_xsl) is used for the transformation.

### Step 4.2 - Determine Media Assets

The [assets.html](#assets_html) file is used to determine the assets that are to be uploaded to Fulcrum and listed on the monograph Media tab.

### Step 4.3 - Zip Monograph Bundle

The [hebxxxxx.xxxx.xxx.zip](#heb_zip) can be generated as the necessary files have been generated.

## Process 5 - Add Asset Links

Links to existing Fulcrum Media asset pages may be added to an EPUB by performing the following steps:

1. Download the asset CSV file from the Fulcrum monograph page.
2. Rename the CSV using HEB ID, **hebxxxxx.xxxx.xxx.csv**, and store it in the [ROOTDIR](#rootdir)**/resources/asset_links** directory.
3. Invoke the commands in the section [Generate EPUB Archive](#process-2---generate-epub-archive) to regenerate the EPUB archive.
4. Replace or re-version the EPUB archive file asset on the Fulcrum monograph page.

## Process 6 - Clobber Source Files

To re-generate either a HEB EPUB or Fulcrum bundle, invoke the following commands:

    cd /quod-prep/prep/a/acls/hebepub
    target/bin/hebepub clobber layout/hebxxxxx.xxxx.xxx

This removes the necessary files to allow the HEB book source directory to be rebuilt from scratch. This removes all files except the following:

* [hebxxxxx.xxxx.xxx_dlxs.xml](#heb_dlxs_xml) - this file may have been modified by hand to generate this book. So this file is not removed.
* [hebxxxxx.xxxx.xxx_dlxs_org.xml](#heb_dlxs_org_xml) - if present, to preserve the original DLXS XML source.

For [fixepub](#fixepub_dir), the above files are not removed and also the following is not removed:

* [images](#images_dir) directory. Since often the original TIF files have been converted to PNG and this process can be time consuming, the page scans are not removed.

# Implementation

Below is a description of the [ROOTDIR](#rootdir)**/target** directory and the files contained within:

* **bin** - contains bash shell script for invoking the genertion process.
  * <a name="hebepub">_hebepub_</a> - script for invoking the epub/bundle generation process. The script iterates over the list specified HEB directories and invokes a series of **rake** tasks on each. It also sets a few environment specific variables (development or production) used by the **rake** tasks. See the script for more information.
* **layouts** - contains files specific to a layout.
    * **fixepub** - contains files specific to the fixed page layout.
        * **styles** - directory containing the CSS stylesheets to be included in the [styles](#styles_dir) directory of a HEB EPUB archive.
    * **flowepub** - contains files specific to the flowable page layout.
        * **fonts** - directory containing the fonts to be included in the [fonts](#fonts_dir) directory of a HEB EPUB archive.
        * **styles** - directory containing the CSS stylesheets to be included in the [styles](#styles_dir) directory of a HEB EPUB archive.
* **lib** - contains files to support the above described scripts.
  * **jars** - directory contains the following Java jar files:
      * **epubcheck-jar-with-dependencies.jar** - epubcheck jar file from w3c/epubcheck GitHub. provides support for the _[hebepub](#hebepub) check_ production.
      * **hebimg-jar-with-dependencies.jar** - provides support for the _[hebepub](#hebepub) convert_ production. Includes support for image formats except jp2.
      * **hebimgjp2-jar-with-dependencies.jar** - provides support for the _[hebepub](#hebepub) convert_ production. Support for image formats except tif.
      * **hebxslt-jar-with-dependencies.jar** - provides support for the _[hebepub](#hebepub) epub | bundle_ productions. Invokes a XSLT 3.0 processor.
  * **rake** - directory contains the following Ruby and Rake task files:
      * <a name="rakefile">**rakefile**</a> - top level Rake task file that implements the process productions described in section [Process Invocation](#process-invocation).
      * **acls.rake** - Rake task file imported by [rakefile](#rakefile) that implements the dependencies for the ACLS provided files, including [copyholder.html](#copyholder_html), [related.html](#related_html), [reviews.html](#reviews_html), [series.html](#series_html), and [subject.html](#subject_html).
      * **assets.rake** - Rake task file imported by [rakefile](#rakefile) that implements the dependencies for the [assets.html](#assets_html) file.
      * **fonts.rake** - Rake task file imported by [rakefile](#rakefile) that implements the dependencies for the [fonts.html](#fonts_html) file.
      * **Gemfile** - Gem file listed required gems.
      * **styles.rake** - Rake task file imported by [rakefile](#rakefile) that implements the dependencies for the [stylesheets.html](#stylesheets_html) file.
      * **common.rb** - sets the value of path variables that are shared by the rest of the Ruby and Rake task files, such paths to the EPUB source files and the target directory files.
      * **AssetListener.rb** - Ruby class file implementing a listener used during parsing of the [assets.html](#assets_html) and [links.html](#links_html) files.
      * **EmptyListener.rb** - Ruby class file implementing a listener used for parsing [related.html](#related_html) and [reviews.html](#reviews_html) to determine if they are empty. If so, these files are not included in the Fulcrum bundle [hebxxxxx.xxxx.xxx.zip](#heb_zip).
  * **xsl** - directory contains the following XSLT files:
      * <a name="hebdlxs2tei_xsl">**hebdlxs2tei.xsl**</a> - transforms DLXS XML file [hebxxxxx.xxxx.xxx_dlxs.xml](#heb_dlxs_xml) to TEI XML file [hebxxxxx.xxxx.xxx_tei.xml](#heb_tei_xml). See process [Step 2.6 - Generate TEI XML File](#step-2.6---generate-tei-xml-file).
      * <a name="hebtei2fixepub_xsl">**hebtei2fixepub.xsl**</a> - transforms TEI XML file[hebxxxxx.xxxx.xxx_tei.xml](#heb_tei_xml) to fixed layout [HEB Book Source Structure](#heb-book-source-structure). See process [Step 2.9 - Generate EPUB Structure](#step-2.9---generate-epub-structure).
      * <a name="hebtei2flowepub_xsl">**hebtei2flowepub.xsl**</a> - transforms TEI XML file[hebxxxxx.xxxx.xxx_tei.xml](#heb_tei_xml) to flowable layout [HEB Book Source Structure](#heb-book-source-structure). See process [Step 2.9 - Generate EPUB Structure](#step-2.9---generate-epub-structure).
      * <a name="hebtei2meta_xsl">**hebtei2meta.xsl**</a> - transforms TEI XML file[hebxxxxx.xxxx.xxx_tei.xml](#heb_tei_xml) to the Fulcrum monograph metadata CSV file [hebxxxxx.xxxx.xxx_metadata.csv](#heb_metadata_csv).
      * <a name="heblib_xsl">**heblib.xsl**</a> - shared XSL file that sets constants used by the above XSLT files.
      * <a name="heblibtei_xsl">**heblibtei.xsl**</a> - shared XSL file that sets variables used by the XSLT files [hebtei2fixepub.xsl](#hebtei2fixepub_xsl), [hebtei2flowepub.xsl](#hebtei2flowepub_xsl), and [hebtei2meta.xsl](#hebtei2meta_xsl).
      * <a name="hebtei2epub_xsl">**hebtei2epub.xsl**</a> - shared XSL file that sets variables and defines templates used by the XSLT files [hebtei2fixepub.xsl](#hebtei2fixepub_xsl), [hebtei2flowepub.xsl](#hebtei2flowepub_xsl).