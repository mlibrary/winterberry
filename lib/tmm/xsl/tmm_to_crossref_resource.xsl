<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet
        version="1.1"
        xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
        xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
>
    <xsl:include href="tmm_to_crossref_common.xsl"/>

    <xsl:param name="IMPRINTS" select="'lived places publishing;'"/>
    <xsl:param name="REMOVE_RESOLUTION" select="'true'"/>

    <xsl:variable name="FORMAT_IMPRINTS" select="concat(';',$IMPRINTS,';')"/>
    <xsl:variable name="NAMESPACE_URL" select="'http://www.crossref.org/doi_resources_schema/5.4.0'"/>

    <xsl:template match="root">
        <xsl:if test="normalize-space($BATCH_ID)!='' and normalize-space($TIMESTAMP)!=''">
            <xsl:element name="doi_batch" namespace="{$NAMESPACE_URL}">
                <xsl:attribute name="version">
                    <xsl:value-of select="'5.4.0'"/>
                </xsl:attribute>
                <xsl:attribute name="xsi:schemaLocation">
                    <xsl:value-of select="'http://www.crossref.org/doi_resources_schema/5.4.0 http://www.crossref.org/schemas/doi_resources5.4.0.xsd'"/>
                </xsl:attribute>
                <xsl:element name="head" namespace="{$NAMESPACE_URL}">
                    <xsl:element name="doi_batch_id" namespace="{$NAMESPACE_URL}">
                        <xsl:value-of select="concat('umpre-secondary-',$BATCH_ID,'-submission')"/>
                    </xsl:element>
                    <xsl:element name="depositor" namespace="{$NAMESPACE_URL}">
                        <xsl:element name="depositor_name" namespace="{$NAMESPACE_URL}">
                            <xsl:value-of select="$UMP_DEPOSITOR"/>
                        </xsl:element>
                        <xsl:element name="email_address" namespace="{$NAMESPACE_URL}">
                            <xsl:value-of select="$UMP_EMAIL"/>
                        </xsl:element>
                    </xsl:element>
                </xsl:element>
                <xsl:element name="body" namespace="{$NAMESPACE_URL}">
                    <!-- Strip out titles that have not passed Eloquence verification. -->
                    <xsl:choose>
                        <xsl:when test="$ELOQUENCE_VERIFICATION='true'">
                            <xsl:apply-templates select="book[contains($FORMAT_IMPRINTS,translate(./groupentry3,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')) and starts-with(eloquenceVerificationStatus,'Passed') and not(contains($EXCLUDE_ISBN_LIST,printISBN))]"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <!--
                            <xsl:apply-templates select="book[contains($FORMAT_IMPRINTS,translate(./groupentry3,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')) and not(contains($EXCLUDE_ISBN_LIST,printISBN))]"/>
                            -->
                            <xsl:apply-templates select="book[contains($FORMAT_IMPRINTS,translate(./groupentry3,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz'))]"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:element>
            </xsl:element>
        </xsl:if>
    </xsl:template>

    <xsl:template match="book">
        <xsl:element name="doi_resources" namespace="{$NAMESPACE_URL}">
            <xsl:element name="doi" namespace="{$NAMESPACE_URL}">
                <xsl:value-of select="substring-after(./doi,'https://doi.org/')"/>
            </xsl:element>
            <xsl:element name="collection" namespace="{$NAMESPACE_URL}">
                <xsl:attribute name="property"><xsl:value-of select="'list-based'"/></xsl:attribute>
                <xsl:choose>
                    <xsl:when test="$REMOVE_RESOLUTION='true'">
                        <xsl:attribute name="multi-resolution"><xsl:value-of select="'lock'"/></xsl:attribute>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:for-each select="./resource">
                            <xsl:element name="item" namespace="{$NAMESPACE_URL}">
                                <xsl:attribute name="label"><xsl:value-of select="concat('UMPRE_Fulcrum_',position())"/></xsl:attribute>
                                <xsl:element name="resource" namespace="{$NAMESPACE_URL}">
                                    <xsl:value-of select="."/>
                                </xsl:element>
                            </xsl:element>
                        </xsl:for-each>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:element>
        </xsl:element>
    </xsl:template>

</xsl:stylesheet>
