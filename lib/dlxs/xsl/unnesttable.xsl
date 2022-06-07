<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
        xmlns:epub="http://www.idpf.org/2007/ops"
        xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
        xmlns:xs="http://www.w3.org/2001/XMLSchema"
        xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
        xmlns:xi="http://www.w3.org/2001/XInclude"
        xmlns:dlxs="http://mlib.umich.edu/namespace/dlxs"
        xmlns:mlibxsl="http://www.mlib.umich.edu/namespace/mlibxsl"
        exclude-result-prefixes="xs xi dlxs mlibxsl"
        version="2.0">

    <xsl:output method="xml"
                indent="no"/>

    <xsl:template match="*[local-name()='table']">
        <xsl:choose>
            <xsl:when test="exists(*[local-name()='caption'])">
                <xsl:element name="section">
                    <xsl:apply-templates select="@*|node()"/>
                </xsl:element>
            </xsl:when>
            <xsl:otherwise>
                <xsl:element name="table">
                    <xsl:element name="tbody">
                        <xsl:for-each select="*[local-name()='tr']">
                            <xsl:element name="{local-name(.)}">
                                <xsl:for-each select="*[local-name()='td']">
                                    <xsl:element name="{local-name(.)}">
                                        <xsl:apply-templates select="@*|node()"/>
                                    </xsl:element>
                                </xsl:for-each>
                            </xsl:element>
                        </xsl:for-each>
                    </xsl:element>
                </xsl:element>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="*[local-name()='table']/*[local-name()='caption']|*[local-name()='td']">
        <xsl:apply-templates select="node()"/>
    </xsl:template>

    <xsl:template match="*[local-name()='tr']">
        <xsl:choose>
            <xsl:when test="exists(*[local-name()='td']/*[local-name()='table'])">
                <xsl:apply-templates select="node()"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:element name="p">
                    <xsl:apply-templates select="@*|node()"/>
                </xsl:element>
            </xsl:otherwise>
        </xsl:choose>
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