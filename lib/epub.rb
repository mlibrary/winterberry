require 'nokogiri'

require_relative 'resources'
require_relative 'xslt'

LIBXSL_PATH = File.join(__dir__, 'xsl')

def xform(args)
  srcpath = args[:srcpath]
  destpath = args[:destpath]
  xslpath = args[:xslpath]

  XSLT.transform(
      :xslpath => args[:xslpath],
      :srcpath => args[:srcpath],
      :destpath => args[:destpath]
      )
end

def update_toc(args)
  XSLT.transform(
      :xslpath => File.join(LIBXSL_PATH, "ncx2xhtml.xsl"),
      :srcpath => args[:srcpath],
      :destpath => args[:destpath]
      )
end

def update_ncx(args)
  XSLT.transform(
      :xslpath => File.join(LIBXSL_PATH, "update_ncx.xsl"),
      :srcpath => args[:srcpath],
      :destpath => args[:destpath]
      )
end

def update_opf(args)
  XSLT.transform(
      :xslpath => File.join(LIBXSL_PATH, "update_opf.xsl"),
      :srcpath => args[:srcpath],
      :destpath => args[:destpath]
      )
end

def update_xhtml(args)
  XSLT.transform(
      :xslpath => File.join(LIBXSL_PATH, "update_xhtml.xsl"),
      :srcpath => args[:srcpath],
      :destpath => args[:destpath]
      )
end
