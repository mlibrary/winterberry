<?xml version="1.0" encoding="utf-8"?>
<xsl:transform xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:date="http://exslt.org/dates-and-times" xmlns:doc="http://exslt.org/common" version="2.0" extension-element-prefixes="date doc">
  <xsl:output method="xml" encoding="utf-8" omit-xml-declaration="no" indent="yes"/>
  <xsl:strip-space elements="*"/>

<xsl:template match="root">


<doi_batch xmlns="http://www.crossref.org/schema/5.3.1" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" version="5.3.1" xsi:schemaLocation="http://www.crossref.org/schema/5.3.1 http://www.crossref.org/schema/deposit/crossref5.3.1.xsd">
  <head >
    <!--
    <doi_batch_id>umpre-backlist-<xsl:value-of select="date:date-time()"/>-submission</doi_batch_id>
    <timestamp><xsl:value-of select="date:year()"/><xsl:value-of select="format-number(date:month-in-year(),'00')"/><xsl:value-of select="format-number(date:day-in-month(),'00')"/><xsl:value-of select="format-number(date:hour-in-day(),'00')"/><xsl:value-of select="format-number(date:minute-in-hour(),'00')"/><xsl:value-of select="format-number(date:second-in-minute(),'00')"/></timestamp>
    -->
    <doi_batch_id>umpre-backlist-<xsl:value-of select="format-dateTime(current-dateTime(),'[Y0001]-[M01]-[D01]T[H01]:[m01]:[s01][Z]')"/>-submission</doi_batch_id>
    <timestamp><xsl:value-of select="concat(format-dateTime(current-dateTime(),'[Y0001][M01][D01][H01][m01][s01]'),'00000')"/></timestamp>
    <depositor>
      <depositor_name>scpo</depositor_name>
      <email_address>mpub.xref@gmail.com</email_address>
    </depositor>
    <registrant>MPublishing</registrant>
  </head>
  <body>
    <xsl:apply-templates select="book"/>
  </body>
</doi_batch>
</xsl:template>

<xsl:template match="book">
  <xsl:element name="book" xmlns="http://www.crossref.org/schema/5.3.1">
    <xsl:attribute name="book_type">monograph</xsl:attribute>
      <book_metadata language="en">
        <xsl:call-template name="contributors"/>
                <xsl:call-template name="titles"/>
        <publication_date>
          <year><xsl:value-of select="pubyear"/></year>
        </publication_date>
        <xsl:apply-templates select="printISBN|eISBN"/>
        <publisher>
          <publisher_name><xsl:value-of select="groupentry3"/></publisher_name>
            <publisher_place>Ann Arbor, MI</publisher_place>
        </publisher>
        <doi_data>
            <xsl:choose>
              <xsl:when test="doi"><doi><xsl:value-of select="substring-after(doi,'https://doi.org/')"/></doi></xsl:when>
              <xsl:otherwise><doi>10.3998/mpub.<xsl:value-of select="workkey"/></doi></xsl:otherwise>
            </xsl:choose>
            <resource><xsl:value-of select="resource"/></resource>
        </doi_data>
      </book_metadata>
    </xsl:element>
</xsl:template>


<xsl:template name="contributors">
  <xsl:if test="node()[starts-with(name(), 'authortype')][text()='Author' or contains(text(), 'Editor') or text()='Editor']">
    <contributors xmlns="http://www.crossref.org/schema/5.3.1">
        <xsl:for-each select="node()[starts-with(name(), 'authortype')]">
          <xsl:variable name="tmmRole">
              <xsl:value-of select="."/>
          </xsl:variable>
          <xsl:if test="$tmmRole='Author' or contains($tmmRole, 'Editor') or $tmmRole='Translator'">
            <xsl:variable name="ordinal">
                <xsl:value-of select="substring-after(name(), 'authortype')"/>
            </xsl:variable>
            <xsl:element name="person_name">
                <xsl:attribute name="sequence">
                  <xsl:choose>
                      <xsl:when test="$ordinal='1'">first</xsl:when>
                      <xsl:otherwise>additional</xsl:otherwise>
                  </xsl:choose>
                </xsl:attribute>
                <xsl:choose>
                    <xsl:when test="$tmmRole='Author' or $tmmRole='Contributor'">
                      <xsl:attribute name="contributor_role">author</xsl:attribute>
                    </xsl:when>
                    <xsl:when test="contains($tmmRole, 'Editor')">
                      <xsl:attribute name="contributor_role">editor</xsl:attribute>
                    </xsl:when>
                    <xsl:when test="$tmmRole='Translator'">
                      <xsl:attribute name="contributor_role">translator</xsl:attribute>
                    </xsl:when>
                </xsl:choose>
                <xsl:apply-templates select="following-sibling::*[contains(name(), concat('authorfirstname' , $ordinal))]"/>
                <xsl:apply-templates select="following-sibling::*[contains(name(), concat('authorlastname' , $ordinal))]"/>
            </xsl:element>
          </xsl:if>
      </xsl:for-each>
    </contributors>
  </xsl:if>
</xsl:template>

<xsl:template match="*[starts-with(name(), 'authorfirstname')][text()]">
    <given_name xmlns="http://www.crossref.org/schema/5.3.1"><xsl:value-of select="substring(.,1,45)"/></given_name>
</xsl:template>

<xsl:template match="*[starts-with(name(), 'authorlastname')][text()]">
    <surname xmlns="http://www.crossref.org/schema/5.3.1"><xsl:value-of select="substring(.,1,45)"/></surname>
</xsl:template>



<xsl:template name='titles'>
  <titles xmlns="http://www.crossref.org/schema/5.3.1">
      <title><xsl:value-of select="titleprefixandtitle"/></title>
      <xsl:apply-templates select="subtitle"/>
  </titles>
</xsl:template>

<xsl:template match="subtitle[text()]">
  <subtitle xmlns="http://www.crossref.org/schema/5.3.1"><xsl:value-of select="."/></subtitle>
</xsl:template>

<xsl:template match="printISBN|eISBN">
  <xsl:element name="isbn" xmlns="http://www.crossref.org/schema/5.3.1">
      <xsl:attribute name="media_type">
        <xsl:choose>
            <xsl:when test="name()='printISBN'">print</xsl:when>
            <xsl:when test="name()='eISBN'">electronic</xsl:when>
        </xsl:choose>
      </xsl:attribute>
      <xsl:value-of select="."/>
  </xsl:element>
</xsl:template>

</xsl:transform>
