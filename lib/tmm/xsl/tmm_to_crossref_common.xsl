<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet
        version="1.1"
        xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
        xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
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

    <xsl:output method="xml" encoding="utf-8" omit-xml-declaration="no" indent="yes"/>
    <xsl:strip-space elements="*"/>

    <xsl:variable name="EXCLUDE_ISBN_LIST" select="concat(';',translate($EXCLUDE_ISBN,' ',''),';')"/>
    <xsl:variable name="FORMAT_BISAC_LIST" select="concat(';',$BISAC_LIST,';')"/>

</xsl:stylesheet>
