<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet
        version="1.1"
        xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
        xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
        xmlns:date="http://exslt.org/dates-and-times"
        extension-element-prefixes="date"
>
    <!-- Defined paramters that can be overridden -->
    <xsl:param name="BATCH_ID"/>
    <xsl:param name="TIMESTAMP"/>
    <xsl:param name="BISAC_LIST" select="'temporarily out of stock;on demand;active;not yet published'"/>
    <xsl:param name="EXCLUDE_ISBN" select="''"/>
    <xsl:param name="ENCODING_NAME" select="'utf-8'"/>
    <xsl:param name="ELOQUENCE_VERIFICATION" select="'false'"/>
    <xsl:param name="UMP_URL_PREFIX" select="'https://press.umich.edu/isbn/'"/>
    <xsl:param name="MPS_URL_PREFIX" select="'https://services.publishing.umich.edu/isbn/'"/>
    <xsl:param name="UMP_DEPOSITOR" select="'scpo'"/>
    <xsl:param name="UMP_EMAIL" select="'mpub.xref@gmail.com'"/>
    <xsl:param name="UMP_REGISTRANT" select="'MPublishing'"/>
    <xsl:param name="UMP_PUBLISHER_PLACE" select="'Ann Arbor, MI'"/>
    <xsl:param name="IMPRINTS" select="'lived places publishing;'"/>

    <xsl:output method="xml" encoding="utf-8" omit-xml-declaration="no" indent="yes"/>
    <xsl:strip-space elements="*"/>

    <!-- Current Crossref namespace -->
    <xsl:variable name="NAMESPACE_URL" select="'http://www.crossref.org/doi_resources_schema/5.4.0'"/>
    <xsl:variable name="EXCLUDE_ISBN_LIST" select="concat(';',translate($EXCLUDE_ISBN,' ',''),';')"/>
    <xsl:variable name="FORMAT_BISAC_LIST" select="concat(';',$BISAC_LIST,';')"/>
    <xsl:variable name="FORMAT_IMPRINTS" select="concat(';',$IMPRINTS,';')"/>

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
                        <xsl:value-of select="concat('umpre-backlist-',$BATCH_ID,'-submission')"/>
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
                            <xsl:variable name="pbisac" select="translate(./primaryBISAC, 'ABCDEFGHIJKLMNOPQRSTUVWXYZ', 'abcdefghijklmnopqrstuvwxyz')"/>
                            <xsl:apply-templates select="book[contains($FORMAT_IMPRINTS,translate(./groupentry3,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')) and starts-with(eloquenceVerificationStatus,'Passed') and not(contains($EXCLUDE_ISBN_LIST,printISBN))]"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:apply-templates select="book[contains($FORMAT_IMPRINTS,translate(./groupentry3,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')) and not(contains($EXCLUDE_ISBN_LIST,printISBN))]"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:element>
            </xsl:element>
        </xsl:if>
    </xsl:template>

    <xsl:template match="book">
        <xsl:element name="doi_resources" namespace="{$NAMESPACE_URL}">
            <xsl:element name="doi" namespace="{$NAMESPACE_URL}">
                <xsl:value-of select="./doi"/>
            </xsl:element>
            <xsl:element name="collection" namespace="{$NAMESPACE_URL}">
                <xsl:attribute name="property"><xsl:value-of select="'list-based'"/></xsl:attribute>
                <xsl:element name="item" namespace="{$NAMESPACE_URL}">
                    <xsl:attribute name="label"><xsl:value-of select="'SECONDARY_X'"/></xsl:attribute>
                    <xsl:element name="resource" namespace="{$NAMESPACE_URL}">
                        <xsl:value-of select="./resource"/>
                    </xsl:element>
                </xsl:element>
            </xsl:element>
        </xsl:element>
    </xsl:template>

</xsl:stylesheet>
