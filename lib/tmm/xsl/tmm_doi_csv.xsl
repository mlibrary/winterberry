<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet
        xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
        xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
        xmlns:date="http://exslt.org/dates-and-times"
        xmlns:doc="http://exslt.org/common"
        version="2.0"
        extension-element-prefixes="date doc"
        >
    <xsl:output method="text" encoding="utf-8" omit-xml-declaration="yes" indent="no"/>
    <xsl:strip-space elements="*"/>

    <xsl:variable name="headers" select="distinct-values(//*[local-name()='Details']//*[local-name()='Field']/@Name)"/>

    <xsl:template match="*[local-name()='CrystalReport']">
        <xsl:for-each select="$headers">
            <xsl:choose>
                <xsl:when test="position()=count($headers)">
                    <xsl:value-of select="."/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="concat(.,',')"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
        <xsl:value-of select="codepoints-to-string(10)"/>
        <xsl:apply-templates select="//*[local-name()='Details']"/>
    </xsl:template>

    <xsl:template match="*[local-name()='Details']">
        <xsl:variable name="node" select="."/>
        <xsl:for-each select="$headers">
            <xsl:variable name="field_name" select="."/>
            <xsl:variable name="field_value" select="concat('&quot;',$node//*[local-name()='Field' and @Name=$field_name],'&quot;')"/>
            <xsl:choose>
                <xsl:when test="position()=count($headers)">
                    <xsl:value-of select="$field_value"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="concat($field_value,',')"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
        <xsl:value-of select="codepoints-to-string(10)"/>
    </xsl:template>

    <xsl:template match="text()">
        <!--
        <xsl:copy>.</xsl:copy>
        <xsl:value-of select="." disable-output-escaping="no"/>
        -->
    </xsl:template>

</xsl:stylesheet>
