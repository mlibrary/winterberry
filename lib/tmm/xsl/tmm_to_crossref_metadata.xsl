<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet
        version="1.1"
        xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
        xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
>
    <!--
    xmlns:date="http://exslt.org/dates-and-times"
    extension-element-prefixes="date"
    -->

    <xsl:include href="tmm_to_crossref_common.xsl"/>

    <xsl:param name="MPS_SERVICES_IMPRINTS" select="'a2ru intervals;against the grain, llc;american pancreatic association;amherst college press;bridwell press;disobedience press;faculty reprints;health sciences publishing services;lever press;maize books;michigan publishing services;no imprint;open humanities press;school for environment sustainability;society for cinema and media studies;university of westminster press;'"/>

    <xsl:variable name="FORMAT_MPS_SERVICES_IMPRINTS" select="concat(';',$MPS_SERVICES_IMPRINTS,';')"/>
    <xsl:variable name="NAMESPACE_URL" select="'http://www.crossref.org/schema/5.4.0'"/>

    <xsl:template match="root">
        <xsl:if test="normalize-space($BATCH_ID)!='' and normalize-space($TIMESTAMP)!=''">
            <xsl:element name="doi_batch" namespace="{$NAMESPACE_URL}">
                <xsl:attribute name="version">
                    <xsl:value-of select="'5.4.0'"/>
                </xsl:attribute>
                <xsl:attribute name="xsi:schemaLocation">
                    <xsl:value-of select="concat($NAMESPACE_URL,' ','https://www.crossref.org/schemas/crossref5.4.0.xsd')"/>
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
                            <xsl:apply-templates select="book[starts-with(eloquenceVerificationStatus,'Passed') and not(contains($EXCLUDE_ISBN_LIST,ISBN1))]"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:apply-templates select="book[not(contains($EXCLUDE_ISBN_LIST,ISBN1)) and (starts-with(resource,'https://www.fulcrum.org/') or starts-with(eloquenceVerificationStatus,'Passed'))]"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:element>
            </xsl:element>
        </xsl:if>
    </xsl:template>

    <xsl:template match="book">
        <xsl:variable name="book_node" select="."/>

        <xsl:variable name="doi">
            <xsl:choose>
                <xsl:when test="normalize-space(./doi) != ''">
                    <xsl:value-of select="normalize-space(./doi)"/>
                </xsl:when>
                <xsl:when test="normalize-space(./OAURL) != ''">
                    <xsl:value-of select="normalize-space(./OAURL)"/>
                </xsl:when>
                <xsl:otherwise>
                    <!--
                    <xsl:value-of select="''"/>
                    -->
                    <xsl:value-of select="concat('https://doi.org/10.3998/mpub.',./bookkey)"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:if test="$doi != ''">
            <xsl:element name="book" namespace="{$NAMESPACE_URL}">
                <xsl:attribute name="book_type"><xsl:value-of select="'monograph'"/></xsl:attribute>
                <xsl:element name="book_metadata" namespace="{$NAMESPACE_URL}">
                    <xsl:attribute name="language"><xsl:value-of select="'en'"/></xsl:attribute>
                    <xsl:if test="./*[starts-with(local-name(),'authortype') and (text()='Author' or text()='Editor' or contains(text(),'Editor'))]">
                        <!-- QQQ: Restricted to author and editor. Should all roles be allowed? -->
                        <xsl:element name="contributors" namespace="{$NAMESPACE_URL}">
                            <!--
                            <xsl:apply-templates select="./*[starts-with(local-name(),'authortype') and text()!='Contributor']"/>
                            -->
                            <xsl:variable name="primary_cnt" select="count(./*[starts-with(local-name(),'authorprimaryind') and text()='Y'])"/>
                            <xsl:choose>
                                <xsl:when test="$primary_cnt = 0">
                                    <xsl:apply-templates select="./*[starts-with(local-name(),'authorprimaryind')][1]">
                                        <xsl:with-param name="primary" select="'Y'"/>
                                    </xsl:apply-templates>
                                    <xsl:apply-templates select="./*[starts-with(local-name(),'authorprimaryind')][position() > 1]">
                                        <xsl:with-param name="primary" select="'N'"/>
                                    </xsl:apply-templates>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:apply-templates select="./*[starts-with(local-name(),'authorprimaryind') and text()='Y']">
                                        <xsl:with-param name="primary" select="'Y'"/>
                                    </xsl:apply-templates>
                                    <xsl:apply-templates select="./*[starts-with(local-name(),'authorprimaryind') and text()!='Y']">
                                        <xsl:with-param name="primary" select="'N'"/>
                                    </xsl:apply-templates>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:element>
                    </xsl:if>
                    <xsl:if test="./titleprefixandtitle or ./subittle">
                        <xsl:element name="titles" namespace="{$NAMESPACE_URL}">
                            <xsl:apply-templates select="./*[local-name()='titleprefixandtitle' or local-name()='subtitle']"/>
                        </xsl:element>
                    </xsl:if>
                    <!--
                    <xsl:apply-templates select="./bookkey"/>
                    -->
                    <xsl:apply-templates select="./pubyear"/>

                    <xsl:variable name="isbn_list" select="./*[starts-with(local-name(),'ISBN')]"/>
                    <xsl:variable name="bisac_list" select="./*[starts-with(local-name(),'BISAC')]"/>
                    <xsl:variable name="format_list" select="./*[starts-with(local-name(),'format')]"/>

                    <xsl:variable name="printISBNs">
                        <xsl:for-each select="$bisac_list">
                            <xsl:variable name="bisac_status" select="normalize-space(.)"/>
                            <xsl:variable name="active_status" select="contains($FORMAT_BISAC_LIST,translate($bisac_status, 'ABCDEFGHIJKLMNOPQRSTUVWXYZ', 'abcdefghijklmnopqrstuvwxyz'))"/>
                            <xsl:variable name="ndx" select="position()"/>
                            <xsl:variable name="format" select="concat(';',$format_list[$ndx],';')"/>
                            <xsl:if test="$bisac_status != '' and $active_status and contains($FORMAT_FORMAT_PRINT_LIST,$format)">
                                <xsl:value-of select="concat($isbn_list[$ndx],',')"/>
                            </xsl:if>
                        </xsl:for-each>
                    </xsl:variable>
                    <xsl:variable name="eISBNs">
                        <xsl:for-each select="$bisac_list">
                            <xsl:variable name="bisac_status" select="normalize-space(.)"/>
                            <xsl:variable name="active_status" select="contains($FORMAT_BISAC_LIST,translate($bisac_status, 'ABCDEFGHIJKLMNOPQRSTUVWXYZ', 'abcdefghijklmnopqrstuvwxyz'))"/>
                            <xsl:variable name="ndx" select="position()"/>
                            <xsl:variable name="format" select="$format_list[$ndx]"/>
                            <xsl:if test="$bisac_status != '' and $active_status and (starts-with($format,'All Ebooks') or $format='Online Resource (OA)')">
                                <xsl:value-of select="concat($isbn_list[$ndx],',')"/>
                            </xsl:if>
                        </xsl:for-each>
                    </xsl:variable>

                    <xsl:variable name="printISBN">
                        <xsl:choose>
                            <xsl:when test="$printISBNs='' and $eISBNs=''">
                                <xsl:value-of select="./ISBN1"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="substring-before($printISBNs,',')"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:variable>
                    <xsl:variable name="eISBN" select="substring-before($eISBNs,',')"/>

                    <xsl:if test="$printISBN !=''">
                        <xsl:call-template name="create_isbn">
                            <xsl:with-param name="isbn" select="$printISBN"/>
                            <xsl:with-param name="media_type" select="'print'"/>
                        </xsl:call-template>
                    </xsl:if>
                    <xsl:if test="$eISBN !=''">
                        <xsl:call-template name="create_isbn">
                            <xsl:with-param name="isbn" select="$eISBN"/>
                            <xsl:with-param name="media_type" select="'electronic'"/>
                        </xsl:call-template>
                    </xsl:if>

                    <xsl:apply-templates select="./groupentry3"/>
                    <xsl:element name="doi_data" namespace="{$NAMESPACE_URL}">
                        <xsl:element name="doi" namespace="{$NAMESPACE_URL}">
                            <xsl:value-of select="substring-after($doi,'://doi.org/')"/>
                        </xsl:element>
                        <xsl:variable name="imprint" select="translate(./groupentry3, 'ABCDEFGHIJKLMNOPQRSTUVWXYZ', 'abcdefghijklmnopqrstuvwxyz')"/>
                        <xsl:variable name="url_prefix">
                            <xsl:choose>
                                <xsl:when test="contains($FORMAT_MPS_SERVICES_IMPRINTS,$imprint)"><xsl:value-of select="$MPS_URL_PREFIX"/></xsl:when>
                                <xsl:otherwise><xsl:value-of select="$UMP_URL_PREFIX"/></xsl:otherwise>
                            </xsl:choose>
                        </xsl:variable>

                        <xsl:variable name="fURL">
                            <xsl:if test="$book_node/fulcrumURL">
                                <xsl:for-each select="$bisac_list">
                                    <xsl:variable name="bisac_status" select="normalize-space(.)"/>
                                    <xsl:variable name="ndx" select="position()"/>
                                    <xsl:variable name="format" select="$format_list[$ndx]"/>
                                    <xsl:variable name="active_status" select="contains($FORMAT_BISAC_ACTIVE_LIST,translate($bisac_status, 'ABCDEFGHIJKLMNOPQRSTUVWXYZ', 'abcdefghijklmnopqrstuvwxyz'))"/>
                                    <xsl:if test="$bisac_status != '' and $active_status and (starts-with($format,'All Ebooks') or $format='Online Resource (OA)')">
                                        <xsl:value-of select="$book_node/fulcrumURL"/>
                                    </xsl:if>
                                </xsl:for-each>
                            </xsl:if>
                        </xsl:variable>

                        <xsl:variable name="resourceValue">
                            <xsl:choose>
                                <xsl:when test="starts-with(./resource, 'https://www.fulcrum.org/')">
                                    <xsl:value-of select="./resource"/>
                                </xsl:when>
                                <xsl:when test="$fURL != '' and $book_node/fullTextOnFulcrum = 'Y' and (./ebookStatus='Published' or ./ebookStatus='' or ./currentOAStatus='Published' or ./currentOAStatus='')">
                                    <xsl:value-of select="./fulcrumURL"/>
                                </xsl:when>
                                <xsl:when test="$printISBN !=''">
                                    <xsl:value-of select="concat($url_prefix, $printISBN)"/>
                                </xsl:when>
                                <xsl:when test="$eISBN !=''">
                                    <xsl:value-of select="concat($url_prefix, $eISBN)"/>
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
        </xsl:if>
    </xsl:template>

    <xsl:template match="*[starts-with(local-name(),'authorprimaryind')]">
        <xsl:param name="primary"/>

        <xsl:variable name="ordinal" select="substring-after(local-name(),'authorprimaryind')"/>
        <xsl:variable name="role" select="translate(normalize-space(preceding-sibling::*[starts-with(local-name(),concat('authortype',$ordinal))][1]), 'ABCDEFGHIJKLMNOPQRSTUVWXYZ', 'abcdefghijklmnopqrstuvwxyz')"/>

        <!--
        QQQ: Shouldn't all roles be allowed?
        <xsl:if test="$role='author' or $role='contributor' or $role='translator' or contains($role, 'editor')">
        -->
        <xsl:if test="$role='author' or $role='editor' or $role='contributor' or $role='translator' or contains($role, 'editor')">
            <xsl:element name="person_name" namespace="{$NAMESPACE_URL}">
                <xsl:attribute name="sequence">
                    <xsl:choose>
                        <xsl:when test="$primary='Y'">
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
                <xsl:if test="preceding-sibling::*[starts-with(local-name(),concat('authorfirstname',$ordinal)) and text()]">
                    <xsl:element name="given_name" namespace="{$NAMESPACE_URL}">
                        <xsl:value-of select="normalize-space(preceding-sibling::*[starts-with(local-name(),concat('authorfirstname',$ordinal))][1])"/>
                    </xsl:element>
                </xsl:if>
                <xsl:if test="preceding-sibling::*[starts-with(local-name(),concat('authorlastname',$ordinal)) and text()]">
                    <xsl:element name="surname" namespace="{$NAMESPACE_URL}">
                        <xsl:value-of select="normalize-space(preceding-sibling::*[starts-with(local-name(),concat('authorlastname',$ordinal))][1])"/>
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
        <xsl:variable name="subtitle" select="normalize-space(.)"/>
        <xsl:if test="$subtitle != ''">
            <xsl:element name="subtitle" namespace="{$NAMESPACE_URL}">
                <xsl:value-of select="."/>
            </xsl:element>
        </xsl:if>
    </xsl:template>

    <xsl:template match="pubyear">
        <xsl:element name="publication_date" namespace="{$NAMESPACE_URL}">
            <xsl:element name="year" namespace="{$NAMESPACE_URL}">
                <xsl:value-of select="text()"/>
            </xsl:element>
        </xsl:element>
    </xsl:template>

    <xsl:template match="bookkey">
        <xsl:element name="edition_number" namespace="{$NAMESPACE_URL}">
            <xsl:value-of select="concat(text(),',',../fullTextOnFulcrum)"/>
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

    <xsl:template name="create_isbn">
        <xsl:param name="isbn"/>
        <xsl:param name="media_type"/>

        <xsl:element name="isbn" namespace="{$NAMESPACE_URL}">
            <xsl:attribute name="media_type"><xsl:value-of select="$media_type"/></xsl:attribute>
            <xsl:value-of select="$isbn"/>
        </xsl:element>
    </xsl:template>

</xsl:stylesheet>
