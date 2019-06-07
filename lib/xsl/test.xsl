<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:xi="http://www.w3.org/2001/XInclude"
                xmlns:html="http://www.w3.org/1999/xhtml"
                xmlns:mlibxsl="http://www.mlib.umich.edu/namespace/mlibxsl"
                exclude-result-prefixes="xs xi html mlibxsl"
                version="2.0">

    <xsl:output method="xml" indent="no"/>

    <xsl:param name="resourcePath" required="yes"/>

    <xsl:variable name="resourceDoc" select="document($resourcePath)"/>
    <xsl:variable name="resourceTable" select="$resourceDoc/html:table/html:tbody"/>

    <xsl:template match="/">
        <xsl:apply-templates/>
    </xsl:template>

    <xsl:template match="*[local-name()='p' and (@class='rb_test' or @class='rbi_test')]/comment()">
        <xsl:message>Found rb: <xsl:value-of select="."/></xsl:message>
        <xsl:variable name="content" select="."/>
        <xsl:analyze-string select="$content" regex='file="([^"]+)"'>
            <xsl:matching-substring>
                <xsl:variable name="resPath" select="regex-group(1)"/>
                <xsl:message>Found file: <xsl:value-of select="$resPath"/></xsl:message>
                <xsl:variable name="asset" select="mlibxsl:genAssetReference($resPath)"/>
                <xsl:message>asset: <xsl:value-of select="exists($asset)"/></xsl:message>
                <xsl:variable name="embedMarkup">
                    <xsl:value-of select="$asset/html:td[@class='embed-markup']" disable-output-escaping="yes"/>
                </xsl:variable>

                <xsl:value-of select="$embedMarkup" disable-output-escaping="yes"/>
            </xsl:matching-substring>
        </xsl:analyze-string>
    </xsl:template>

    <xsl:template match="@*|*|processing-instruction()|comment()">
        <xsl:copy>
            <xsl:apply-templates select="*|@*|text()|processing-instruction()|comment()"/>
        </xsl:copy>
    </xsl:template>

    <xsl:function name="mlibxsl:genAssetReference" as="element()*">
        <xsl:param name="ref"/>

        <xsl:variable name="refNode"
                      select="$resourceTable/html:tr[html:td[@class='asset' and string()=$ref] and html:td[@class='media' and lower-case(string())='yes']]"/>
        <xsl:variable name="pngNode"
                      select="$resourceTable/html:tr[html:td[@class='asset' and string()=concat($ref,'.png')] and html:td[@class='media' and lower-case(string())='yes']]"/>
        <xsl:variable name="jpgNode"
                      select="$resourceTable/html:tr[html:td[@class='asset' and string()=concat($ref,'.jpg')] and html:td[@class='media' and lower-case(string())='yes']]"/>
        <xsl:choose>
            <xsl:when test="exists($refNode)">
                <xsl:sequence select="$refNode"/>
            </xsl:when>
            <xsl:when test="exists($pngNode)">
                <xsl:sequence select="$pngNode"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="$jpgNode"/>
            </xsl:otherwise>
        </xsl:choose>

    </xsl:function>

</xsl:stylesheet>