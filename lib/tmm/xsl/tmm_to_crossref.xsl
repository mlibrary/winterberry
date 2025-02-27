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
    <xsl:param name="MPS_SERVICES_IMPRINTS" select="'a2ru intervals;against the grain, llc;american pancreatic association;amherst college press;bridwell press;disobedience press;faculty reprints;health sciences publishing services;lever press;maize books;michigan publishing services;no imprint;open humanities press;school for environment sustainability;society for cinema and media studies;university of westminster press;'"/>

    <xsl:output method="xml" encoding="utf-8" omit-xml-declaration="no" indent="yes"/>
    <xsl:strip-space elements="*"/>

    <!-- Current Crossref namespace -->
    <xsl:variable name="NAMESPACE_URL" select="'http://www.crossref.org/schema/5.3.1'"/>
    <xsl:variable name="EXCLUDE_ISBN_LIST" select="concat(';',translate($EXCLUDE_ISBN,' ',''),';')"/>
    <xsl:variable name="FORMAT_BISAC_LIST" select="concat(';',$BISAC_LIST,';')"/>
    <xsl:variable name="FORMAT_MPS_SERVICES_IMPRINTS" select="concat(';',$MPS_SERVICES_IMPRINTS,';')"/>

    <xsl:template match="root">
        <xsl:if test="normalize-space($BATCH_ID)!='' and normalize-space($TIMESTAMP)!=''">
            <xsl:element name="doi_batch" namespace="{$NAMESPACE_URL}">
                <xsl:attribute name="version">
                    <xsl:value-of select="'5.3.1'"/>
                </xsl:attribute>
                <xsl:attribute name="xsi:schemaLocation">
                    <xsl:value-of select="'http://www.crossref.org/schema/5.3.1 http://www.crossref.org/schema/deposit/crossref5.3.1.xsd'"/>
                </xsl:attribute>
                <xsl:element name="head" namespace="{$NAMESPACE_URL}">
                    <xsl:element name="doi_batch_id" namespace="{$NAMESPACE_URL}">
                        <!-- XSLT 2.0
                        <xsl:value-of select="concat('umpre-backlist-',format-dateTime(current-dateTime(),'[Y0001]-[M01]-[D01]T[H01]:[m01]:[s01][Z]'),'-submission')"/>
                        -->
                        <!-- XSLT 1.1
                        <xsl:value-of select="concat('umpre-backlist-',date:date-time(),'-submission')"/>
                        -->
                        <xsl:value-of select="concat('umpre-backlist-',$BATCH_ID,'-submission')"/>
                    </xsl:element>
                    <xsl:element name="timestamp" namespace="{$NAMESPACE_URL}">
                        <!-- XSLT 2.0
                        <xsl:value-of select="concat(format-dateTime(current-dateTime(),'[Y0001][M01][D01][H01][m01][s01]'),'00000')"/>
                        -->
                        <!-- XSLT 1.1
                        <xsl:value-of select="concat(date:year(),format-number(date:month-in-year(),'00'),format-number(date:day-in-month(),'00'),format-number(date:hour-in-day(),'00'),format-number(date:minute-in-hour(),'00'),format-number(date:second-in-minute(),'00'),'00000')"/>
                         -->
                        <xsl:value-of select="$TIMESTAMP"/>
                    </xsl:element>
                    <xsl:element name="depositor" namespace="{$NAMESPACE_URL}">
                        <xsl:element name="depositor_name" namespace="{$NAMESPACE_URL}">
                            <xsl:value-of select="$UMP_DEPOSITOR"/>
                        </xsl:element>
                        <xsl:element name="email_address" namespace="{$NAMESPACE_URL}">
                            <xsl:value-of select="$UMP_EMAIL"/>
                        </xsl:element>
                    </xsl:element>
                    <xsl:element name="registrant" namespace="{$NAMESPACE_URL}">
                        <xsl:value-of select="$UMP_REGISTRANT"/>
                    </xsl:element>
                </xsl:element>
                <xsl:element name="body" namespace="{$NAMESPACE_URL}">
                    <!-- Strip out titles that have not passed Eloquence verification. -->
                    <xsl:choose>
                        <xsl:when test="$ELOQUENCE_VERIFICATION='true'">
                            <xsl:apply-templates select="book[starts-with(eloquenceVerificationStatus,'Passed') and not(contains($EXCLUDE_ISBN_LIST,printISBN))]"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:apply-templates select="book[not(contains($EXCLUDE_ISBN_LIST,printISBN)) and (starts-with(resource,'https://www.fulcrum.org/') or starts-with(eloquenceVerificationStatus,'Passed'))]"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:element>
            </xsl:element>
        </xsl:if>
    </xsl:template>

    <xsl:template match="book">
        <xsl:variable name="pbisac" select="translate(./primaryBISAC, 'ABCDEFGHIJKLMNOPQRSTUVWXYZ', 'abcdefghijklmnopqrstuvwxyz')"/>
        <xsl:variable name="sbisac" select="translate(./secondaryBISAC, 'ABCDEFGHIJKLMNOPQRSTUVWXYZ', 'abcdefghijklmnopqrstuvwxyz')"/>
        <xsl:variable name="pbisac_active" select="contains($FORMAT_BISAC_LIST,$pbisac)"/>
        <xsl:variable name="sbisac_active" select="contains($FORMAT_BISAC_LIST,$sbisac)"/>

        <xsl:element name="book" namespace="{$NAMESPACE_URL}">
            <xsl:attribute name="book_type"><xsl:value-of select="'monograph'"/></xsl:attribute>
            <xsl:element name="book_metadata" namespace="{$NAMESPACE_URL}">
                <xsl:attribute name="language"><xsl:value-of select="'en'"/></xsl:attribute>
                <xsl:if test="./*[starts-with(local-name(),'authortype') and (text()='Author' or text()='Editor' or contains(text(),'Editor'))]">
                    <!-- QQQ: Restricted to author and editor. Should all roles be allowed? -->
                    <xsl:element name="contributors" namespace="{$NAMESPACE_URL}">
                        <xsl:apply-templates select="./*[starts-with(local-name(),'authortype') and text()!='Contributor']"/>
                    </xsl:element>
                </xsl:if>
                <xsl:if test="./titleprefixandtitle or ./subittle">
                    <xsl:element name="titles" namespace="{$NAMESPACE_URL}">
                        <xsl:apply-templates select="./*[local-name()='titleprefixandtitle' or local-name()='subtitle']"/>
                    </xsl:element>
                </xsl:if>
                <xsl:apply-templates select="./pubyear"/>
                <!--
                <xsl:apply-templates select="./printISBN|./eISBN"/>
                -->
                <xsl:choose>
                    <xsl:when test="$pbisac_active='true' and ./printISBN">
                        <xsl:apply-templates select="./printISBN"/>
                    </xsl:when>
                    <xsl:when test="$sbisac_active='true' and ./secondaryISBN">
                        <xsl:apply-templates select="./secondaryISBN"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:message>WARNING: bookkey <xsl:value-of select="./bookkey"/> no active ISBN found.</xsl:message>
                        <xsl:apply-templates select="./printISBN"/>
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:apply-templates select="./eISBN"/>
                <xsl:apply-templates select="./groupentry3"/>
                <xsl:element name="doi_data" namespace="{$NAMESPACE_URL}">
                    <xsl:element name="doi" namespace="{$NAMESPACE_URL}">
                        <xsl:choose>
                            <xsl:when test="./doi">
                                <xsl:value-of select="substring-after(./doi,'://doi.org/')"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="concat('10.3998/mpub.',./workkey)"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:element>
                    <xsl:variable name="imprint" select="translate(./groupentry3, 'ABCDEFGHIJKLMNOPQRSTUVWXYZ', 'abcdefghijklmnopqrstuvwxyz')"/>
                    <xsl:variable name="url_prefix">
                        <xsl:choose>
                            <xsl:when test="contains($FORMAT_MPS_SERVICES_IMPRINTS,$imprint)"><xsl:value-of select="$MPS_URL_PREFIX"/></xsl:when>
                            <xsl:otherwise><xsl:value-of select="$UMP_URL_PREFIX"/></xsl:otherwise>
                        </xsl:choose>
                    </xsl:variable>
                    <xsl:variable name="resourceValue">
                        <xsl:choose>
                            <xsl:when test="starts-with(./resource, 'https://www.fulcrum.org/')">
                                <xsl:value-of select="./resource"/>
                            </xsl:when>
                            <xsl:when test="$pbisac_active='true' and ./printISBN">
                                <xsl:value-of select="concat($url_prefix, ./printISBN)"/>
                            </xsl:when>
                            <xsl:when test="$pbisac_active='true' and ./eISBN">
                                <xsl:value-of select="concat($url_prefix, ./eISBN)"/>
                            </xsl:when>
                            <xsl:when test="$sbisac_active='true' and ./secondaryISBN">
                                <xsl:value-of select="concat($url_prefix, ./secondaryISBN)"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:message>WARNING: bookkey <xsl:value-of select="./bookkey"/> no active ISBN found, using current resource.</xsl:message>
                                <xsl:value-of select="./resource"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:variable>
                    <xsl:element name="resource" namespace="{$NAMESPACE_URL}">
                        <xsl:value-of select="$resourceValue"/>
                    </xsl:element>
                </xsl:element>
            </xsl:element>
        </xsl:element>
    </xsl:template>

    <xsl:template match="*[starts-with(local-name(),'authortype')]">
        <xsl:variable name="ordinal" select="substring-after(local-name(),'authortype')"/>
        <xsl:variable name="role" select="translate(text(), 'ABCDEFGHIJKLMNOPQRSTUVWXYZ', 'abcdefghijklmnopqrstuvwxyz')"/>
        <!--
        QQQ: Shouldn't all roles be allowed?
        <xsl:if test="$role='author' or $role='contributor' or $role='translator' or contains($role, 'editor')">
        -->
        <xsl:if test="$role='author' or $role='editor' or $role='contributor' or $role='translator' or contains($role, 'editor')">
            <xsl:element name="person_name" namespace="{$NAMESPACE_URL}">
                <xsl:attribute name="sequence">
                    <xsl:choose>
                        <xsl:when test="$ordinal='1'">
                            <xsl:value-of select="'first'"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="'additional'"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:attribute>
                <xsl:attribute name="contributor_role">
                    <xsl:choose>
                        <xsl:when test="$role='author' or $role='contributor'">
                            <xsl:value-of select="'author'"/>
                        </xsl:when>
                        <xsl:when test="$role='editor' or contains($role, 'editor')">
                            <xsl:value-of select="'editor'"/>
                        </xsl:when>
                        <xsl:when test="$role='translator'">
                            <xsl:value-of select="$role"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <!--<xsl:value-of select="text()"/>-->
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:attribute>
                <xsl:if test="following-sibling::*[starts-with(local-name(),concat('authorfirstname',$ordinal)) and text()]">
                    <xsl:element name="given_name" namespace="{$NAMESPACE_URL}">
                        <xsl:value-of select="normalize-space(following-sibling::*[starts-with(local-name(),concat('authorfirstname',$ordinal))][1])"/>
                    </xsl:element>
                </xsl:if>
                <xsl:if test="following-sibling::*[starts-with(local-name(),concat('authorlastname',$ordinal)) and text()]">
                    <xsl:element name="surname" namespace="{$NAMESPACE_URL}">
                        <xsl:value-of select="normalize-space(following-sibling::*[starts-with(local-name(),concat('authorlastname',$ordinal))][1])"/>
                    </xsl:element>
                </xsl:if>
            </xsl:element>
        </xsl:if>
    </xsl:template>

    <xsl:template match="titleprefixandtitle">
        <xsl:element name="title" namespace="{$NAMESPACE_URL}">
            <xsl:value-of select="text()"/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="subtitle">
        <xsl:element name="subtitle" namespace="{$NAMESPACE_URL}">
            <xsl:value-of select="text()"/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="pubyear">
        <xsl:element name="publication_date" namespace="{$NAMESPACE_URL}">
            <xsl:element name="year" namespace="{$NAMESPACE_URL}">
                <xsl:value-of select="text()"/>
            </xsl:element>
        </xsl:element>
    </xsl:template>

    <xsl:template match="printISBN|secondaryISBN">
        <xsl:element name="isbn" namespace="{$NAMESPACE_URL}">
            <xsl:attribute name="media_type">
                <xsl:value-of select="'print'"/>
            </xsl:attribute>
            <xsl:value-of select="text()"/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="eISBN">
        <xsl:element name="isbn" namespace="{$NAMESPACE_URL}">
            <xsl:attribute name="media_type">
                <xsl:value-of select="'electronic'"/>
            </xsl:attribute>
            <xsl:value-of select="text()"/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="groupentry3">
        <xsl:element name="publisher" namespace="{$NAMESPACE_URL}">
            <xsl:element name="publisher_name" namespace="{$NAMESPACE_URL}">
                <xsl:value-of select="text()"/>
            </xsl:element>
            <xsl:element name="publisher_place" namespace="{$NAMESPACE_URL}">
                <xsl:value-of select="$UMP_PUBLISHER_PLACE"/>
            </xsl:element>
        </xsl:element>
    </xsl:template>

</xsl:stylesheet>
