<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:html="http://www.w3.org/1999/xhtml"
                xmlns:mlibxsl="http://www.mlib.umich.edu/namespace/mlibxsl"
                exclude-result-prefixes="xs html mlibxsl"
                version="2.0">

    <xsl:output method="xml" indent="yes"/>

    <xsl:variable name="HTML_URL" select="'http://www.w3.org/1999/xhtml'"/>

    <xsl:template match="/">
        <xsl:apply-templates/>
    </xsl:template>

    <xsl:template match="@*[name()='href']">
        <xsl:variable name="href" select="mlibxsl:updateHref(.)"/>
        <xsl:message>href:<xsl:value-of select="."/>=><xsl:value-of select="$href"/></xsl:message>
        <xsl:attribute name="href" select="$href"/>
    </xsl:template>

    <xsl:template match="*[local-name()='content']/@src">
        <xsl:variable name="src" select="mlibxsl:updateHref(.)"/>
        <xsl:message>src:<xsl:value-of select="."/>=><xsl:value-of select="$src"/></xsl:message>
        <xsl:attribute name="src" select="$src"/>
    </xsl:template>

    <xsl:template match="*[local-name()='img' and @width='100%']/@width">
        <!-- Remove this value -->
        <xsl:message>Removing attribute <xsl:value-of select="local-name()"/>/@width='100%'.</xsl:message>
    </xsl:template>

    <xsl:template match="*[local-name()='table']">
        <!-- Remove @width, @cellspacing -->
        <!-- Move @cellpadding to @style. Fix @border value -->
        <xsl:element name="table" namespace="{$HTML_URL}">
            <xsl:apply-templates select="@*[name()!='width' and name()!='cellspacing' and name()!='border' and name()!='cellpadding']"/>
            <xsl:if test="@border!='' and @border!='0'">
                <xsl:attribute name="border" select="@border"/>
            </xsl:if>
            <xsl:variable name="style">
                <xsl:choose>
                    <xsl:when test="exists(@style) and exists(@cellpadding)">
                        <xsl:value-of select="concat(@style,';padding:',@cellpadding)"/>
                    </xsl:when>
                    <xsl:when test="exists(@style)">
                        <xsl:value-of select="@style"/>
                    </xsl:when>
                    <xsl:when test="exists(@cellpadding)">
                        <xsl:value-of select="concat('padding:',@cellpadding)"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="''"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
            <xsl:if test="$style !=''">
                <xsl:attribute name="style" select="$style"/>
            </xsl:if>
            <xsl:message>Moving attribute <xsl:value-of select="'cellpadding'"/>=<xsl:value-of select="@cellpadding"/> to @style.</xsl:message>

            <xsl:choose>
                <xsl:when test="exists(*[local-name()='col']) and count(*[local-name()='col']/@*[name()!='width']) > 0">
                    <xsl:element name="colgroup" namespace="{$HTML_URL}">
                        <xsl:apply-templates select="*[local-name()='col']"/>
                    </xsl:element>
                </xsl:when>
            </xsl:choose>
            <xsl:apply-templates select="*[local-name()!='col']|processing-instruction()|comment()"/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="*[local-name()='td']">
        <!-- Move this value to @style -->
        <xsl:variable name="pos" select="position()"/>
        <xsl:variable name="colWidth">
            <xsl:choose>
                <xsl:when test="exists(../preceding-sibling::*[local-name()='tr'])">
                    <xsl:value-of select="''"/>
                </xsl:when>
                <xsl:when test="exists(../..//*[local-name()='col' and position()=$pos]/@width)">
                    <xsl:value-of select="concat('width:',../..//*[local-name()='col' and position()=$pos]/@width)"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="''"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <xsl:variable name="attrValue">
            <xsl:choose>
                <xsl:when test="exists(@valign) and exists(@align)">
                    <xsl:value-of select="concat('vertical-align:',@valign,';text-align:',@align)"/>
                </xsl:when>
                <xsl:when test="exists(@valign)">
                    <xsl:value-of select="concat('vertical-align:',@valign)"/>
                </xsl:when>
                <xsl:when test="exists(@align)">
                    <xsl:value-of select="concat('text-align:',@align)"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="''"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="style">
            <xsl:choose>
                <xsl:when test="exists(@style) and $attrValue !='' and $colWidth !=''">
                    <xsl:value-of select="concat(@style,';',$attrValue,';',$colWidth)"/>
                </xsl:when>
                <xsl:when test="exists(@style) and $attrValue !=''">
                    <xsl:value-of select="concat(@style,';',$attrValue)"/>
                </xsl:when>
                <xsl:when test="exists(@style) and $colWidth !=''">
                    <xsl:value-of select="concat(@style,';',$colWidth)"/>
                </xsl:when>
                <xsl:when test="$attrValue !='' and $colWidth !=''">
                    <xsl:value-of select="concat($attrValue,';',$colWidth)"/>
                </xsl:when>
                <xsl:when test="$attrValue !=''">
                    <xsl:value-of select="$attrValue"/>
                </xsl:when>
                <xsl:when test="$colWidth !=''">
                    <xsl:value-of select="$colWidth"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="''"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:element name="{local-name()}" namespace="{$HTML_URL}">
            <xsl:apply-templates select="@*[name()!='valign' and name()!='align']"/>
            <xsl:if test="$style !=''">
                <xsl:attribute name="style" select="$style"/>
            </xsl:if>
            <xsl:apply-templates select="*|processing-instruction()|comment()"/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="*[local-name()='tr']">
        <!-- Move this value to @style -->
        <xsl:variable name="attrValue">
            <xsl:choose>
                <xsl:when test="exists(@valign) and exists(@align)">
                    <xsl:value-of select="concat('vertical-align:',@valign,';text-align:',@align)"/>
                </xsl:when>
                <xsl:when test="exists(@valign)">
                    <xsl:value-of select="concat('vertical-align:',@valign)"/>
                </xsl:when>
                <xsl:when test="exists(@align)">
                    <xsl:value-of select="concat('text-align:',@align)"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="''"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="style">
            <xsl:choose>
                <xsl:when test="exists(@style) and $attrValue !=''">
                    <xsl:value-of select="concat(@style,';',$attrValue)"/>
                </xsl:when>
                <xsl:when test="$attrValue !=''">
                    <xsl:value-of select="$attrValue"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="''"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:element name="{local-name()}" namespace="{$HTML_URL}">
            <xsl:apply-templates select="@*[name()!='valign' and name()!='align']"/>
            <xsl:if test="$style !=''">
                <xsl:attribute name="style" select="$style"/>
            </xsl:if>
            <xsl:apply-templates select="*|processing-instruction()|comment()"/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="*[local-name()='table']//*[local-name()='col']/@width">
        <xsl:message>Removing attribute <xsl:value-of select="local-name()"/>/@width.</xsl:message>
    </xsl:template>

    <xsl:template match="*[local-name()='small']">
        <xsl:choose>
            <xsl:when test="exists(./*[local-name()='big'])">
                <xsl:for-each select="./*[local-name()='big']">
                    <xsl:value-of select="."/>
                </xsl:for-each>
                <xsl:element name="small" namespace="{$HTML_URL}">
                    <xsl:apply-templates select="./*[local-name()='big']/following-sibling::text()"/>
                </xsl:element>
            </xsl:when>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="*[local-name()='p']//*[local-name()='big']">
        <xsl:value-of select="."/>
    </xsl:template>

    <xsl:template match="*|@*|processing-instruction()|comment()">
        <xsl:copy>
            <xsl:apply-templates select="*|@*|text()|processing-instruction()|comment()"/>
        </xsl:copy>
    </xsl:template>

    <xsl:function name="mlibxsl:updateHref">
        <xsl:param name="href"/>

        <xsl:variable name="newHref">
            <xsl:choose>
                <xsl:when test="not(starts-with($href,'http:')) and not(contains($href,'www.')) and contains($href,'.html')">
                    <xsl:value-of select="replace($href,'.html','.xhtml')"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$href"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:sequence select="$newHref"/>
    </xsl:function>

</xsl:stylesheet>