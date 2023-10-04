<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet
        xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
        xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
        xmlns:date="http://exslt.org/dates-and-times"
        extension-element-prefixes="date"
        version="1.1"
        >
    <xsl:output method="xml" encoding="utf-8" omit-xml-declaration="no" indent="yes"/>
    <xsl:strip-space elements="*"/>

    <!-- Defined paramters that can be overridden -->
    <xsl:param name="UMP_URL_PREFIX" select="'https://press.umich.edu/isbn/'"/>
    <xsl:param name="UMP_DEPOSITOR" select="'scpo'"/>
    <xsl:param name="UMP_EMAIL" select="'mpub.xref@gmail.com'"/>
    <xsl:param name="UMP_REGISTRANT" select="'MPublishing'"/>
    <xsl:param name="UMP_PUBLISHER_PLACE" select="'Ann Arbor, MI'"/>

    <!-- Current Crossref namespace -->
    <xsl:variable name="NAMESPACE_URL" select="'http://www.crossref.org/schema/5.3.1'"/>

    <xsl:template match="root">
        <xsl:element name="doi_batch" namespace="{$NAMESPACE_URL}">
            <xsl:attribute name="version">
                <xsl:value-of select="'5.3.1'"/>
            </xsl:attribute>
            <xsl:attribute name="xsi:schemaLocation">
                <xsl:value-of select="'http://www.crossref.org/schema/5.3.1 http://www.crossref.org/schema/deposit/crossref5.3.1.xsd'"/>
            </xsl:attribute>
            <xsl:element name="head" namespace="{$NAMESPACE_URL}">
                <xsl:element name="doi_batch_id" namespace="{$NAMESPACE_URL}">
                    <xsl:value-of select="concat('umpre-backlist-',date:date-time(),'-submission')"/>
                </xsl:element>
                <xsl:element name="timestamp" namespace="{$NAMESPACE_URL}">
                    <xsl:value-of select="concat(date:year(),format-number(date:month-in-year(),'00'),format-number(date:day-in-month(),'00'),format-number(date:hour-in-day(),'00'),format-number(date:minute-in-hour(),'00'),format-number(date:second-in-minute(),'00'),'00000')"/>
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
                <xsl:apply-templates select="book"/>
            </xsl:element>
        </xsl:element>
    </xsl:template>

    <xsl:template match="book">
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
                <xsl:apply-templates select="./printISBN|./eISBN"/>
                <xsl:apply-templates select="./groupentry3"/>
                <xsl:element name="doi_data" namespace="{$NAMESPACE_URL}">
                    <xsl:element name="doi" namespace="{$NAMESPACE_URL}">
                        <xsl:choose>
                            <xsl:when test="./doi">
                                <xsl:value-of select="substring-after(./doi,'https://doi.org/')"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="concat('10.3998/mpub.',./workkey)"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:element>
                    <xsl:variable name="pbisac" select="translate(./primaryBISAC, 'ABCDEFGHIJKLMNOPQRSTUVWXYZ', 'abcdefghijklmnopqrstuvwxyz')"/>
                    <xsl:variable name="resourceValue">
                        <xsl:choose>
                            <xsl:when test="$pbisac='out of print' and ./secondaryISBN">
                                <xsl:value-of select="concat($UMP_URL_PREFIX, ./secondaryISBN)"/>
                            </xsl:when>
                            <xsl:when test="./printISBN">
                                <xsl:value-of select="concat($UMP_URL_PREFIX, ./printISBN)"/>
                            </xsl:when>
                            <xsl:when test="./eISBN">
                                <xsl:value-of select="concat($UMP_URL_PREFIX, ./eISBN)"/>
                            </xsl:when>
                            <xsl:otherwise>
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

    <xsl:template match="printISBN">
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
