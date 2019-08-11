<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:html="http://www.w3.org/1999/xhtml"
                exclude-result-prefixes="xs html"
                version="2.0">

    <xsl:output method="xml" indent="yes"/>

    <xsl:variable name="HTML_URL" select="'http://www.w3.org/1999/xhtml'"/>
    <xsl:variable name="OPS_URL" select="'http://www.idpf.org/2007/ops'"/>

    <xsl:variable name="DOC_TITLE"
                  select="/*[local-name()='ncx']/*[local-name()='docTitle']/*[local-name()='text']"/>

    <xsl:template match="/">
        <xsl:apply-templates/>
    </xsl:template>

    <xsl:template match="*[local-name()='navPoint']/@id">
        <xsl:choose>
            <xsl:when test="matches(., '^[0-9]')">
                <xsl:attribute name="id" select="concat('nav',.)"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:attribute name="id" select="."/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="*[local-name()='pageTarget']/@id">
        <xsl:choose>
            <xsl:when test="matches(., '^[0-9]')">
                <xsl:attribute name="id" select="concat('page',.)"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:attribute name="id" select="."/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="*[local-name()='content']/@src">
        <xsl:variable name="src">
            <xsl:choose>
                <xsl:when test="not(starts-with(.,'http:')) and not(contains(.,'www.')) and contains(.,'.html')">
                    <xsl:value-of select="replace(.,'\.html','.xhtml')"/>
                </xsl:when>
                <xsl:when test="not(starts-with(.,'http:')) and not(contains(.,'www.')) and contains(.,'.htm')">
                    <xsl:value-of select="replace(.,'\.htm','.xhtml')"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="."/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:attribute name="src" select="$src"/>
    </xsl:template>

    <xsl:template match="*|@*|processing-instruction()|comment()">
        <xsl:copy>
            <xsl:apply-templates select="*|@*|text()|processing-instruction()|comment()"/>
        </xsl:copy>
    </xsl:template>

</xsl:stylesheet>