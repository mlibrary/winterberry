<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
        xmlns:epub="http://www.idpf.org/2007/ops"
        xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
        xmlns:xs="http://www.w3.org/2001/XMLSchema"
        xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
        xmlns:xi="http://www.w3.org/2001/XInclude"
        xmlns:mlibxsl="http://www.mlib.umich.edu/namespace/mlibxsl"
        exclude-result-prefixes="xs xi mlibxsl"
        version="2.0">

    <xsl:output method="xml"
                indent="no"/>

    <xsl:template match="*[local-name()='table']">
        <xsl:element name="{local-name()}">
            <xsl:apply-templates select="@*"/>
            <xsl:if test="exists(*[local-name()='caption'])">
                <xsl:apply-templates select="*[local-name()='caption']"/>
            </xsl:if>
            <xsl:element name="tbody">
                <xsl:apply-templates select="*[local-name()!='caption']"/>
            </xsl:element>
        </xsl:element>
    </xsl:template>

    <xsl:template match="element()">
        <xsl:element name="{local-name()}">
            <xsl:apply-templates select="@*|node()"/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="@*">
        <xsl:attribute name="{name()}" select="."/>
    </xsl:template>

    <xsl:template match="text()">
        <xsl:copy>.</xsl:copy>
        <!--
        <xsl:value-of select="." disable-output-escaping="no"/>
        -->
    </xsl:template>
</xsl:stylesheet>