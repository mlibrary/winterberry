<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
        xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
        xmlns:xs="http://www.w3.org/2001/XMLSchema"
        xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
        xmlns:xi="http://www.w3.org/2001/XInclude"
        xmlns:xlink="http://www.w3.org/1999/xlink"
        exclude-result-prefixes="xs xi"
        version="2.0">

    <xsl:param name="output_dir" required="yes"/>

    <xsl:template match="DLPSTEXTCLASS">
        <xsl:variable name="path" select="concat($output_dir,.//IDNO[@TYPE='dlps'],'.xml')"/>
        <xsl:message>path=<xsl:value-of select="$path"/></xsl:message>
        <xsl:result-document href="{$path}" method="xml">
            <xsl:element name="{local-name()}">
                <xsl:apply-templates/>
            </xsl:element>
        </xsl:result-document>
    </xsl:template>

    <xsl:template match="element()">
        <xsl:element name="{local-name()}">
            <xsl:apply-templates select="@*|node()"/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="@*">
        <xsl:attribute name="{local-name()}" select="."/>
    </xsl:template>

    <xsl:template match="text()">
        <xsl:copy>.</xsl:copy>
        <!--
        <xsl:value-of select="." disable-output-escaping="no"/>
        -->
    </xsl:template>

</xsl:stylesheet>