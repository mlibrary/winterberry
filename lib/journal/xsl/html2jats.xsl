<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
        version="2.0"
        xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
        xmlns:xs="http://www.w3.org/2001/XMLSchema"
        xmlns:xi="http://www.w3.org/2001/XInclude"
        xmlns:xlink="http://www.w3.org/1999/xlink"
        exclude-result-prefixes="xs xi">

    <xsl:output method="xml"
                doctype-public="-//NLM//DTD JATS (Z39.96) Journal Publishing DTD v1.2 20190208//EN"
                doctype-system="http://jats.nlm.nih.gov/publishing/1.2/JATS-journalpublishing1-mathml3.dtd"
                xpath-default-namespace=""
                indent="no"/>
    <xsl:strip-space elements="ext-link title"/>

    <xsl:template match="html">
        <xsl:element name="article">
            <xsl:namespace name="xlink" select="'http://www.w3.org/1999/xlink'"/>
            <xsl:namespace name="mml" select="'http://www.w3.org/1998/Math/MathML'"/>
            <xsl:namespace name="xsi" select="'http://www.w3.org/2001/XMLSchema-instance'"/>

            <xsl:attribute name="article-type" select="'research-article'"/>
            <xsl:attribute name="dtd-version" select="'1.2'"/>

            <xsl:apply-templates select="@*|node()"/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="head">
        <xsl:element name="front">
            <xsl:element name="article-meta">
                <xsl:element name="title-group">
                    <xsl:element name="article-title">
                        <xsl:value-of select="normalize-space(./title)"/>
                    </xsl:element>
                </xsl:element>
                <xsl:apply-templates select="@*|node()[local-name() !='title']"/>
            </xsl:element>
        </xsl:element>
    </xsl:template>

    <xsl:template match="div|section">
        <xsl:element name="sec">
            <xsl:apply-templates select="@*|node()"/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="h1|h2|h3|h4|h5|h6">
        <xsl:element name="title">
            <xsl:apply-templates select="@*|node()"/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="blockquote">
        <xsl:element name="disp-quote">
            <xsl:apply-templates select="@*|node()"/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="dl">
        <xsl:variable name="list" select="./*[local-name()='dt']"/>
        <xsl:if test="count($list)>0">
            <xsl:element name="def-list">
                <xsl:for-each select="$list">
                    <xsl:element name="def-item">
                        <xsl:apply-templates select="."/>
                        <xsl:if test="local-name(following-sibling::*[1]) = 'dd'">
                            <xsl:apply-templates select="following-sibling::*[1]"/>
                        </xsl:if>
                    </xsl:element>
                </xsl:for-each>
            </xsl:element>
        </xsl:if>
    </xsl:template>

    <xsl:template match="dt">
        <xsl:element name="term">
            <xsl:apply-templates select="@*|node()"/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="dd">
        <xsl:element name="def">
            <xsl:apply-templates select="@*|node()"/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="span">
        <xsl:choose>
            <xsl:when test="exists(@*)">
                <xsl:element name="styled-content">
                    <xsl:apply-templates select="@*|node()"/>
                </xsl:element>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates select="@*|node()"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="a">
        <xsl:element name="ext-link">
            <xsl:if test="exists(@href)">
                <xsl:attribute name="xlink:href" select="normalize-space(@href)"/>
            </xsl:if>
            <xsl:if test="exists(@title)">
                <xsl:attribute name="xlink:title" select="normalize-space(@title)"/>
            </xsl:if>
            <xsl:apply-templates select="@*[name()!='href' and name()!='title']|node()"/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="b|em|strong">
        <xsl:element name="bold">
            <xsl:apply-templates select="@*|node()"/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="figure">
        <xsl:element name="fig">
            <xsl:apply-templates select="@*|node()"/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="i">
        <xsl:element name="italic">
            <xsl:apply-templates select="@*|node()"/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="iframe">
        <xsl:element name="media">
            <xsl:attribute name="mimetype" select="'video'"/>
            <xsl:attribute name="xlink:show" select="'embed'"/>
            <xsl:attribute name="xlink:href" select="normalize-space(@src)"/>
            <xsl:element name="caption">
                <xsl:element name="title">
                    <xsl:value-of select="normalize-space(@src)"/>
                </xsl:element>
            </xsl:element>
        </xsl:element>
    </xsl:template>

    <xsl:template match="img">
        <xsl:element name="graphic">
            <xsl:attribute name="xlink:href" select="@src"/>
            <xsl:apply-templates select="@*[name()!='src']|node()"/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="li">
        <xsl:element name="list-item">
            <xsl:apply-templates select="@*"/>

            <xsl:choose>
                <xsl:when test="count(p) = 0">
                    <xsl:element name="p">
                        <xsl:apply-templates select="@*|node()"/>
                    </xsl:element>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates select="@*|node()"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:element>
    </xsl:template>

    <xsl:template match="ol|ul">
        <xsl:element name="list">
            <xsl:choose>
                <xsl:when test="local-name()='ol'">
                    <xsl:attribute name="list-type" select="'order'"/>
                </xsl:when>
                <xsl:when test="local-name()='ul'">
                    <xsl:attribute name="list-type" select="'bullet'"/>
                </xsl:when>
            </xsl:choose>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="pre">
        <xsl:element name="preformat">
            <xsl:apply-templates select="@*|node()"/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="br|hr|meta">
        <!-- Skip -->
    </xsl:template>

    <xsl:template match="element()">
        <xsl:element name="{lower-case(local-name())}">
            <xsl:apply-templates select="@*|node()"/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="html/@lang">
        <xsl:attribute name="xml:lang" select="."/>
    </xsl:template>

    <xsl:template match="@class|html/@dir
            |iframe/@allowfullscreen|iframe/@frameborder|iframe/@height|iframe/@src|iframe/@width
            |img/@alt|img/@height|img/@sizes|img/@srcset|img/@width
            |@rel|@role|@style
            |@*[starts-with(name(.),'aria-')]">
        <!-- Skip -->
    </xsl:template>

    <xsl:template match="@*">
        <xsl:attribute name="{lower-case(local-name())}" select="."/>
    </xsl:template>

    <xsl:template match="text()">
        <xsl:variable name="txt" select="normalize-space(.)"/>
        <xsl:if test="string-length($txt) > 0">
            <xsl:copy>$txt</xsl:copy>
        </xsl:if>
        <!--
        <xsl:copy>.</xsl:copy>
        or
        <xsl:value-of select="." disable-output-escaping="no"/>
        -->
    </xsl:template>

</xsl:stylesheet>