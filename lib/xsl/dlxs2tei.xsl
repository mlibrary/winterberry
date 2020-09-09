<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
        xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
        xmlns:xs="http://www.w3.org/2001/XMLSchema"
        xmlns:xi="http://www.w3.org/2001/XInclude"
        xmlns:dlxs="http://mlib.umich.edu/namespace/dlxs"
        exclude-result-prefixes="xs xi dlxs"
        version="2.0">

    <xsl:variable name="TEI_URL" select="'http://www.tei-c.org/ns/1.0'"/>
    <xsl:variable name="DLXS_URL" select="'http://mlib.umich.edu/namespace/dlxs'"/>
    <xsl:variable name="XI_URL" select="'http://www.w3.org/2001/XInclude'"/>
    <xsl:variable name="HTML_URL" select="'http://www.w3.org/1999/xhtml'"/>

    <xsl:output method="xml"
                xpath-default-namespace="{$TEI_URL}"
                indent="yes"/>

    <xsl:variable name="element_name_map">
        <entry key="EDITORIALDECL">editorialDecl</entry>
        <entry key="ENCODINGDESC">encodingDesc</entry>
        <entry key="FILEDESC">fileDesc</entry>
        <entry key="PROFILEDESC">profileDesc</entry>
        <entry key="PUBLICATIONSTMT">publicationStmt</entry>
        <entry key="PUBPLACE">pubPlace</entry>
        <entry key="SERIESSTMT">seriesStmt</entry>
        <entry key="SOURCEDESC">sourceDesc</entry>
        <entry key="TEXTCLASS">textClass</entry>
        <entry key="TITLESTMT">titleStmt</entry>
    </xsl:variable>

    <xsl:template match="/">
        <xsl:apply-templates/>
    </xsl:template>

    <xsl:template match="DLPSTEXTCLASS">
        <xsl:element name="TEI" namespace="{$TEI_URL}">
            <xsl:namespace name="dlxs" select="$DLXS_URL"/>

            <xsl:apply-templates select="@*|node()"/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="HEADER">
        <xsl:element name="teiHeader" namespace="{$TEI_URL}">
            <xsl:apply-templates select="@*|node()"/>

            <!--
            <xsl:element name="xenoData" namespace="{$TEI_URL}">
                <xsl:attribute name="type" select="'marcxml'"/>

                <xsl:element name="xi:include" namespace="{$XI_URL}">
                    <xsl:attribute name="href" select="'marc.xml'"/>
                </xsl:element>
            </xsl:element>

            <xsl:element name="xenoData" namespace="{$TEI_URL}">
                <xsl:attribute name="type" select="'copyholder'"/>

                <xsl:element name="xi:include" namespace="{$XI_URL}">
                    <xsl:attribute name="href" select="'copyholder.html'"/>
                </xsl:element>
            </xsl:element>

            <xsl:element name="xenoData" namespace="{$TEI_URL}">
                <xsl:attribute name="type" select="'related_title'"/>

                <xsl:element name="xi:include" namespace="{$XI_URL}">
                    <xsl:attribute name="href" select="'related.html'"/>
                    <xsl:call-template name="insertFallback"/>
                </xsl:element>
            </xsl:element>

            <xsl:element name="xenoData" namespace="{$TEI_URL}">
                <xsl:attribute name="type" select="'reviews'"/>

                <xsl:element name="xi:include" namespace="{$XI_URL}">
                    <xsl:attribute name="href" select="'reviews.html'"/>
                    <xsl:call-template name="insertFallback"/>
                </xsl:element>
            </xsl:element>

            <xsl:element name="xenoData" namespace="{$TEI_URL}">
                <xsl:attribute name="type" select="'series'"/>

                <xsl:element name="xi:include" namespace="{$XI_URL}">
                    <xsl:attribute name="href" select="'series.html'"/>
                    <xsl:call-template name="insertFallback"/>
                </xsl:element>
            </xsl:element>

            <xsl:element name="xenoData" namespace="{$TEI_URL}">
                <xsl:attribute name="type" select="'subject'"/>

                <xsl:element name="xi:include" namespace="{$XI_URL}">
                    <xsl:attribute name="href" select="'subject.html'"/>
                    <xsl:call-template name="insertFallback"/>
                </xsl:element>
            </xsl:element>
            -->
            <xsl:element name="xenoData" namespace="{$TEI_URL}">
                <xsl:attribute name="type" select="'assets'"/>

                <xsl:element name="xi:include" namespace="{$XI_URL}">
                    <xsl:attribute name="href" select="'assets.html'"/>
                    <xsl:call-template name="insertFallback"/>
                </xsl:element>
            </xsl:element>

            <!--
            <xsl:element name="xenoData" namespace="{$TEI_URL}">
                <xsl:attribute name="type" select="'fonts'"/>

                <xsl:element name="xi:include" namespace="{$XI_URL}">
                    <xsl:attribute name="href" select="'fonts.html'"/>
                    <xsl:call-template name="insertFallback"/>
                </xsl:element>
            </xsl:element>

            <xsl:element name="xenoData" namespace="{$TEI_URL}">
                <xsl:attribute name="type" select="'links'"/>

                <xsl:element name="xi:include" namespace="{$XI_URL}">
                    <xsl:attribute name="href" select="'links.html'"/>
                    <xsl:call-template name="insertFallback"/>
                </xsl:element>
            </xsl:element>

            <xsl:element name="xenoData" namespace="{$TEI_URL}">
                <xsl:attribute name="type" select="'stylesheets'"/>

                <xsl:element name="xi:include" namespace="{$XI_URL}">
                    <xsl:attribute name="href" select="'stylesheets.html'"/>
                    <xsl:call-template name="insertFallback"/>
                </xsl:element>
            </xsl:element>

            <xsl:element name="xenoData" namespace="{$TEI_URL}">
                <xsl:attribute name="type" select="'images'"/>

                <xsl:element name="xi:include" namespace="{$XI_URL}">
                    <xsl:attribute name="href" select="'images.html'"/>
                    <xsl:call-template name="insertFallback"/>
                </xsl:element>
            </xsl:element>

            <xsl:element name="xenoData" namespace="{$TEI_URL}">
                <xsl:attribute name="type" select="'coverpages'"/>

                <xsl:element name="xi:include" namespace="{$XI_URL}">
                    <xsl:attribute name="href" select="'coverpages.html'"/>
                    <xsl:call-template name="insertFallback"/>
                </xsl:element>
            </xsl:element>

             <xsl:element name="xenoData" namespace="{$TEI_URL}">
                 <xsl:attribute name="type" select="'jp2'"/>

                 <xsl:element name="xi:include" namespace="{$XI_URL}">
                     <xsl:attribute name="href" select="'jp2.html'"/>
                     <xsl:call-template name="insertFallback"/>
                 </xsl:element>
             </xsl:element>

             <xsl:element name="xenoData" namespace="{$TEI_URL}">
                 <xsl:attribute name="type" select="'tif'"/>

                 <xsl:element name="xi:include" namespace="{$XI_URL}">
                     <xsl:attribute name="href" select="'tif.html'"/>
                     <xsl:call-template name="insertFallback"/>
                 </xsl:element>
             </xsl:element>

             <xsl:element name="xenoData" namespace="{$TEI_URL}">
                 <xsl:attribute name="type" select="'imgtable'"/>

                 <xsl:element name="xi:include" namespace="{$XI_URL}">
                     <xsl:attribute name="href" select="'imgtable.html'"/>
                     <xsl:call-template name="insertFallback"/>
                 </xsl:element>
             </xsl:element>
             -->
        </xsl:element>
    </xsl:template>

    <xsl:template match="MILESTONE">
        <xsl:element name="milestone" namespace="{$TEI_URL}">
            <xsl:choose>
                <!--
                <xsl:when test="lower-case(@TYPE)='skipline'">
                    <xsl:attribute name="unit" select="'line'"/>
                </xsl:when>
                -->
                <xsl:when test="not(exists(@UNIT))">
                    <xsl:attribute name="unit" select="'absent'"/>
                </xsl:when>
            </xsl:choose>

            <xsl:apply-templates select="@*|node()"/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="REF">
        <xsl:element name="{lower-case(local-name())}" namespace="{$TEI_URL}">
            <xsl:apply-templates select="@*"/>
            <xsl:choose>
                <xsl:when test="lower-case(@TYPE) = 'unity'">
                    <xsl:attribute name="target" select="@NAME"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:if test="string-length(@TARGET) > 0 and substring(@TARGET,1,1) != '#'">
                        <xsl:attribute name="target" select="concat('#',@TARGET)"/>
                    </xsl:if>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:apply-templates select="node()"/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="element()">
        <xsl:variable name="elemName">
            <xsl:analyze-string select="local-name()" regex="^([^0-9]+)([0-9]*)$">
                <xsl:matching-substring>
                    <xsl:value-of select="regex-group(1)"/>
                </xsl:matching-substring>
            </xsl:analyze-string>
        </xsl:variable>
        <xsl:variable name="elemLevel">
            <xsl:analyze-string select="local-name()" regex="^[^0-9]+([0-9]*)$">
                <xsl:matching-substring>
                    <xsl:value-of select="regex-group(1)"/>
                </xsl:matching-substring>
            </xsl:analyze-string>
        </xsl:variable>

        <xsl:variable name="mapped_element_name">
            <xsl:choose>
                <xsl:when test="exists($element_name_map/entry[@key=$elemName])">
                    <xsl:value-of select="$element_name_map/entry[@key=$elemName]"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="lower-case($elemName)"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:element name="{$mapped_element_name}" namespace="{$TEI_URL}">
            <xsl:if test="string-length($elemLevel) > 0">
                <xsl:attribute name="dlxs:level" select="$elemLevel"/>
            </xsl:if>
            <xsl:apply-templates select="@*"/>
            <xsl:if test="exists(@NODE) and not(exists(@ID))">
                <xsl:attribute name="xml:id"
                               select="concat('div',replace(normalize-space(@NODE),'[.:]','_'))"/>
            </xsl:if>
            <xsl:apply-templates select="node()"/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="@ID">
        <xsl:attribute name="{concat('xml:',lower-case(local-name()))}" select="."/>
    </xsl:template>

    <xsl:template match="BIBLSCOPE/@TYPE">
        <xsl:variable name="type" select="."/>
        <xsl:choose>
            <xsl:when test="$type = 'pg'">
                <xsl:attribute name="unit" select="'page'"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:attribute name="{concat('dlxs:',lower-case(local-name()))}" select="$type"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="REF/@FILENAME">
        <xsl:attribute name="source" select="."/>
    </xsl:template>

    <xsl:template match="@TYPE">
        <xsl:attribute name="style" select="."/>
    </xsl:template>

    <xsl:template match="@REND">
        <xsl:choose>
            <xsl:when test=". = 'i'">
                <xsl:attribute name="rend" select="'italic'"/>
            </xsl:when>
            <xsl:when test=". = 'b'">
                <xsl:attribute name="rend" select="'bold'"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:attribute name="{lower-case(local-name())}" select="lower-case(.)"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="PTR/@TARGET">
        <xsl:attribute name="{lower-case(local-name())}" select="."/>
    </xsl:template>

    <xsl:template match="AVAILABILITY/@TYPE">
        <xsl:attribute name="{concat('dlxs:',lower-case(local-name()))}" select="."/>
    </xsl:template>

    <xsl:template match="@NAME|@NODE|@ENTITY|@URL|@BORDER|@COLSPAN|@ROWSPAN|@STATUS
            |AUTHOR/@TYPE|PB/@REF|PB/@SEQ|PB/@RES|PB/@FMT|PB/@FTR|PB/@CNF|LIST/@TYPE
            |P/@ALIGN|TABLE/@ALIGN|CELL/@TYPE|SIGNED/@ALIGN|DATELINE/@ALIGN|SALUTE/@ALIGN">
        <xsl:attribute name="{concat('dlxs:',lower-case(local-name()))}" select="lower-case(.)"/>
    </xsl:template>

    <xsl:template match="@*">
        <xsl:attribute name="{lower-case(local-name())}" select="."/>
    </xsl:template>

    <xsl:template match="text()">
        <xsl:copy>.</xsl:copy>
        <!--
        <xsl:value-of select="." disable-output-escaping="no"/>
        -->
    </xsl:template>

    <xsl:template name="insertFallback">
        <xsl:element name="xi:fallback" namespace="{$XI_URL}">
            <xsl:element name="table" namespace="{$HTML_URL}">
                <xsl:element name="tbody" namespace="{$HTML_URL}">
                    <xsl:element name="tr" namespace="{$HTML_URL}">
                        <xsl:element name="th" namespace="{$HTML_URL}">
                        </xsl:element>
                    </xsl:element>
                </xsl:element>
            </xsl:element>
        </xsl:element>
    </xsl:template>

</xsl:stylesheet>
