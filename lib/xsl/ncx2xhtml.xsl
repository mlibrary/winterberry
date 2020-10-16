<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:xi="http://www.w3.org/2001/XInclude"
                xmlns:html="http://www.w3.org/1999/xhtml"
                xmlns:epub="http://www.idpf.org/2007/ops"
                xmlns:mlibxsl="http://www.mlib.umich.edu/namespace/mlibxsl"
                exclude-result-prefixes="xs xi html epub mlibxsl"
                version="2.0">

    <xsl:output method="xml" indent="yes"/>

    <xsl:variable name="HTML_URL" select="'http://www.w3.org/1999/xhtml'"/>
    <xsl:variable name="NCX_URL" select="'http://www.daisy.org/z3986/2005/ncx/'"/>
    <xsl:variable name="OPS_URL" select="'http://www.idpf.org/2007/ops'"/>

    <xsl:variable name="DOC_TITLE"
                  select="/*[local-name()='ncx']/*[local-name()='docTitle']/*[local-name()='text']"/>

    <xsl:template match="/">
        <xsl:apply-templates/>
    </xsl:template>

    <xsl:template match="/*[local-name()='ncx']">
        <xsl:element name="html" namespace="{$HTML_URL}">
            <xsl:apply-templates select="./*[local-name()='head']"/>

            <xsl:element name="body" namespace="{$HTML_URL}">
                <xsl:apply-templates select="./*[local-name()!='head']"/>
            </xsl:element>
        </xsl:element>
    </xsl:template>

    <xsl:template match="*[local-name()='head']">
        <xsl:element name="head" namespace="{$HTML_URL}">
            <xsl:element name="title" namespace="{$HTML_URL}">
                <xsl:value-of select="$DOC_TITLE"/>
            </xsl:element>
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="*[local-name()='navMap']">
        <xsl:element name="nav" namespace="{$HTML_URL}">
            <xsl:namespace name="epub" select="$OPS_URL"/>
            <xsl:attribute name="id" select="'toc_nav'"/>
            <xsl:attribute name="epub:type" namespace="{$OPS_URL}" select="'toc'"/>
            <xsl:element name="h1" namespace="{$HTML_URL}">
                <xsl:value-of select="'Table of Contents'"/>
            </xsl:element>
            <xsl:call-template name="generateTocList">
                <xsl:with-param name="tocList" select="./*[local-name()='navPoint']"/>
            </xsl:call-template>
        </xsl:element>
    </xsl:template>

    <!--
    <xsl:template match="*[local-name()='navPoint']">
        <xsl:element name="li" namespace="{$HTML_URL}">
            <xsl:if test="exists(@id)">
                <xsl:attribute name="id" select="@id"/>
            </xsl:if>

            <xsl:variable name="title" select="./*[local-name()='navLabel']/*[local-name()='text']"/>
            <xsl:variable name="href">
                <xsl:choose>
                    <xsl:when test="contains(./*[local-name()='content']/@src,'.html')">
                        <xsl:value-of select="replace(./*[local-name()='content']/@src,'.html','.xhtml')"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="./*[local-name()='content']/@src"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
            <xsl:element name="a" namespace="{$HTML_URL}">
                <xsl:attribute name="href" select="$href"/>
                <xsl:value-of select="$title"/>
            </xsl:element>

            <xsl:call-template name="generateTocList">
                <xsl:with-param name="tocList" select="./*[local-name()='navPoint']"/>
            </xsl:call-template>
        </xsl:element>
    </xsl:template>
    -->

    <xsl:template match="*[local-name()='pageList']">
        <xsl:element name="nav" namespace="{$HTML_URL}">
            <xsl:namespace name="epub" select="$OPS_URL"/>
            <xsl:attribute name="id" select="'pagelist'"/>
            <xsl:attribute name="epub:type" namespace="{$OPS_URL}" select="'page-list'"/>
            <xsl:element name="h1" namespace="{$HTML_URL}">
                <xsl:value-of select="'List of Pages'"/>
            </xsl:element>
            <xsl:call-template name="generateTocList">
                <xsl:with-param name="tocList" select="./*[local-name()='pageTarget']"/>
            </xsl:call-template>
        </xsl:element>
    </xsl:template>

    <xsl:template match="*[local-name()='navPoint' or local-name()='pageTarget']">
        <xsl:variable name="elem" select="."/>

        <xsl:call-template name="insertListItem">
            <xsl:with-param name="elem" select="$elem"/>
        </xsl:call-template>
    </xsl:template>

    <xsl:template match="*[local-name()='docTitle']">
        <!-- Remove this element -->
    </xsl:template>

    <xsl:template match="*[local-name()='docAuthor']">
        <!-- Remove this element -->
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

    <xsl:template match="*">
        <xsl:element name="{local-name()}" namespace="{$HTML_URL}">
            <xsl:apply-templates select="@*"/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="@*|processing-instruction()|comment()">
        <xsl:copy>
            <xsl:apply-templates select="@*|text()|processing-instruction()|comment()"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template name="generateTocList">
        <xsl:param name="tocList"/>

        <xsl:choose>
            <xsl:when test="count($tocList) > 0">
                <xsl:element name="ol" namespace="{$HTML_URL}">
                    <xsl:for-each select="$tocList">
                        <xsl:apply-templates select="."/>
                    </xsl:for-each>
                </xsl:element>
            </xsl:when>
        </xsl:choose>

    </xsl:template>

    <xsl:template name="insertListItem">
        <xsl:param name="elem"/>

        <xsl:element name="li" namespace="{$HTML_URL}">
            <xsl:if test="exists($elem/@id)">
                <!--
                <xsl:attribute name="id" select="$elem/@id"/>
                -->
                <xsl:apply-templates select="$elem/@id"/>
            </xsl:if>

            <xsl:variable name="src" select="$elem/*[local-name()='content']/@src"/>
            <xsl:variable name="title" select="$elem/*[local-name()='navLabel']/*[local-name()='text']"/>
            <xsl:variable name="href">
                <xsl:choose>
                    <xsl:when test="contains($src,'.html')">
                        <xsl:value-of select="replace($src,'\.html','.xhtml')"/>
                    </xsl:when>
                    <xsl:when test="contains($src,'.htm')">
                        <xsl:value-of select="replace($src,'\.htm','.xhtml')"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="$elem/*[local-name()='content']/@src"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
            <xsl:element name="a" namespace="{$HTML_URL}">
                <xsl:attribute name="href" select="$href"/>
                <xsl:value-of select="$title"/>
            </xsl:element>

            <xsl:call-template name="generateTocList">
                <xsl:with-param name="tocList" select="./*[local-name()=local-name($elem)]"/>
            </xsl:call-template>
        </xsl:element>
    </xsl:template>

</xsl:stylesheet>