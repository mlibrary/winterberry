<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                exclude-result-prefixes="xs"
                version="2.0">

    <xsl:output method="xml" indent="yes"/>

    <xsl:variable name="IDPF_URL" select="'http://www.idpf.org/2007/opf'"/>
    <xsl:variable name="PURL_DC_URL" select="'http://purl.org/dc/elements/1.1/'"/>
    <xsl:variable name="PURL_DCTERMS_URL" select="'http://purl.org/dc/terms'"/>

    <xsl:variable name="version" select="/*[local-name()='package']/@version"/>

    <xsl:variable name="nav_item"
                  select="/*[local-name()='package']/*[local-name()='manifest']/*[local-name()='item' and contains(concat(' ', @properties, ' '), ' nav ')]"/>

    <xsl:template match="/">
        <xsl:apply-templates/>
    </xsl:template>

    <xsl:template match="/*[local-name()='package']">
        <xsl:element name="{local-name()}" namespace="{$IDPF_URL}">
            <xsl:namespace name="dc" select="$PURL_DC_URL"/>
            <xsl:namespace name="opf" select="$IDPF_URL"/>

            <xsl:apply-templates select="@*"/>
            <xsl:if test="$version != '3.0'">
                <xsl:attribute name="version" select="'3.0'"/>
            </xsl:if>
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="*[local-name()='metadata']">
        <xsl:variable name="modifiedValue" select="./*[local-name()='meta' and @property='dcterms:modified']"/>

        <xsl:element name="{local-name()}" namespace="{namespace-uri()}">
            <xsl:namespace name="dcterms" select="$PURL_DCTERMS_URL"/>

            <xsl:apply-templates select="@*"/>
            <xsl:apply-templates/>

            <xsl:if test="not(exists($modifiedValue))">
                <xsl:variable name="dcterms-modified"
                           select="format-dateTime(current-dateTime(), '[Y0001]-[M01]-[D01]T[H01]:[m01]:[s01]Z')"/>
                <xsl:element name="meta" namespace="{$IDPF_URL}">
                    <xsl:attribute name="property" select="'dcterms:modified'"/>
                    <xsl:value-of select="$dcterms-modified"/>
                </xsl:element>
            </xsl:if>
        </xsl:element>
    </xsl:template>

    <xsl:template match="*[namespace-uri()=xs:anyURI($PURL_DC_URL)]">
        <xsl:element name="{name()}" namespace="{namespace-uri()}">
            <xsl:apply-templates select="@*"/>
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="*[local-name()='item' or local-name()='reference']">
        <!--
        <xsl:variable name="href" select="@href"/>
        -->
        <xsl:variable name="href">
            <xsl:choose>
                <xsl:when test="ends-with(@href,'.html')">
                    <!--
                    <xsl:value-of select="replace(@href,'\.html','.xhtml')"/>
                    -->
                    <xsl:value-of select="concat(substring(@href,1,string-length(@href)-5),'.xhtml')"/>
                </xsl:when>
                <xsl:when test="ends-with(@href,'.htm')">
                    <xsl:value-of select="concat(substring(@href,1,string-length(@href)-4),'.xhtml')"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="@href"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <xsl:element name="{local-name()}" namespace="{$IDPF_URL}">
            <xsl:apply-templates select="@*[name() != 'href']"/>
            <xsl:attribute name="href" select="$href"/>
        </xsl:element>
        <xsl:choose>
            <xsl:when test="not(exists($nav_item)) and local-name()='item' and @media-type='application/x-dtbncx+xml'">
                <xsl:element name="{local-name()}" namespace="{$IDPF_URL}">
                    <xsl:attribute name="id" select="'toc_xhtml'"/>
                    <xsl:attribute name="href" select="'toc_nav.xhtml'"/>
                    <xsl:attribute name="media-type" select="'application/xhtml+xml'"/>
                    <xsl:attribute name="properties" select="'nav'"/>
                </xsl:element>
            </xsl:when>
        </xsl:choose>
   </xsl:template>

    <xsl:template match="*">
        <xsl:element name="{local-name()}" namespace="{$IDPF_URL}">
            <xsl:apply-templates select="@*"/>
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="@*[local-name()='role' or local-name()='file-as']">
        <xsl:message>Skipping <xsl:value-of select="name()"/></xsl:message>
    </xsl:template>

    <xsl:template match="*[local-name()='itemref']/@*[local-name()='linear']">
        <xsl:message>Skipping <xsl:value-of select="name()"/></xsl:message>
    </xsl:template>

    <xsl:template match="@*|processing-instruction()|comment()">
        <xsl:copy>
            <xsl:apply-templates select="@*|text()|processing-instruction()|comment()"/>
        </xsl:copy>
    </xsl:template>

</xsl:stylesheet>