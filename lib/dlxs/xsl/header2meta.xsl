<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:xi="http://www.w3.org/2001/XInclude"
                exclude-result-prefixes="xs xi"
                version="2.0">

    <xsl:output method="text" indent="no"/>

    <!--
    <xsl:variable name="PROPERTIES"
                  select="'ID,Identifier(s),Title,Resource Type,Representative Kind,Caption,Alternative Text,Copyright Holder,Allow High-Res Display?,Allow Download?,Copyright Status,Holding Contact,Content Type,Creator(s),Primary Creator Role,Additional Creator(s),Series,Description,Keywords,Section,Language,Publisher,Subject,ISBN(s),Pub Year,Pub Location'"/>
    -->
    <xsl:variable name="PROPERTIES"
                  select="'ID,Title,Creator(s),Publisher,Pub Location,Pub Year,Series,Keywords,Representative Kind,Identifier(s),Copyright Holder,Copyright Status,Holding Contact,Additional Creator(s)'"/>
    <xsl:variable name="propertyList" select="tokenize($PROPERTIES,',')"/>
    <xsl:variable name="propertyListCnt" select="count($propertyList)"/>

    <xsl:param name="SEPARATOR_FIELD" select="','"/>
    <xsl:param name="SEPARATOR_VALUE" select="';'"/>
    <xsl:param name="SEPARATOR_RECORD" select="'&#xa;'"/>
    <xsl:variable name="QUOTE">"</xsl:variable>

    <!--
    <xsl:param name="language">
        <xsl:choose>
            <xsl:when test="contains($language-list,'eng')">
                <xsl:value-of select="$language-en"/>
            </xsl:when>
            <xsl:when test="string-length($language-list) > 0">
                <xsl:value-of select="$language-list"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="''"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:param>

    <xsl:variable name="QUOTE">"</xsl:variable>

    <xsl:variable name="BLANK_MSG" select="'*** row intentionally left blank ***'"/>
    <xsl:variable name="MONOGRAPH_MARKER" select="'://:MONOGRAPH://:'"/>
    -->

    <xsl:template match="/">
        <xsl:call-template name="insertHeaderRow"/>

        <xsl:for-each-group select="//DLPSTEXTCLASS/HEADER"
                            group-by="FILEDESC/SOURCEDESC/BIBL/BIBLSCOPE[@TYPE='volno']">

            <xsl:sort select="FILEDESC/SOURCEDESC/BIBL/BIBLSCOPE[@TYPE='volno']"/>

            <xsl:variable name="volumeYear" select="current-grouping-key()"/>

            <!-- File Name (volume) -->
            <!--
            <xsl:value-of select="concat($QUOTE,FILEDESC/SERIESSTMT/IDNO[@TYPE='aleph'],'_',$volumeYear,$QUOTE)"/>
            -->
            <xsl:value-of select="concat($QUOTE,FILEDESC/PUBLICATIONSTMT/IDNO[@TYPE='dlps'],$QUOTE)"/>
            <xsl:call-template name="insertFieldSeparator"/>

            <!-- Title (issuetitle) -->
            <xsl:call-template name="insertValue">
                <xsl:with-param name="list" select="current-group()/FILEDESC/SOURCEDESC/BIBL/TITLE"/>
            </xsl:call-template>
            <!--
            <xsl:variable name="title">
                <xsl:for-each-group select="current-group()/FILEDESC/SOURCEDESC/BIBL/BIBLSCOPE[@TYPE='issuetitle']" group-by=".">
                    <xsl:variable name="value" select="normalize-space(.)"/>
                    <xsl:if test="$value!=''">
                        <xsl:value-of select="$value"/>
                        <xsl:value-of select="$SEPARATOR_VALUE"/>
                    </xsl:if>
                </xsl:for-each-group>
            </xsl:variable>
            <xsl:value-of select="concat($QUOTE,substring($title,1,string-length($title)-1),$QUOTE)"/>
            <xsl:call-template name="insertFieldSeparator"/>
            -->

            <!-- Creator(s) (author) -->
            <xsl:call-template name="insertValue">
                <xsl:with-param name="list" select="current-group()/FILEDESC/SOURCEDESC/BIBL/AUTHORIND"/>
            </xsl:call-template>

            <!-- Publisher -->
            <xsl:call-template name="insertValue">
                <xsl:with-param name="list" select="current-group()/FILEDESC/PUBLICATIONSTMT/PUBLISHER"/>
            </xsl:call-template>

            <!-- Pub Location -->
            <xsl:call-template name="insertValue">
                <xsl:with-param name="list" select="current-group()/FILEDESC/PUBLICATIONSTMT/PUBPLACE"/>
            </xsl:call-template>

            <!-- Pub Year -->
            <xsl:call-template name="insertValue">
                <xsl:with-param name="list" select="current-group()/FILEDESC/PUBLICATIONSTMT/DATE[not(exists(@TYPE))]"/>
            </xsl:call-template>

            <!-- Series -->
            <xsl:call-template name="insertValue">
                <xsl:with-param name="list" select="current-group()/FILEDESC/SERIESSTMT/TITLE"/>
            </xsl:call-template>

            <!-- Keywords -->
            <xsl:call-template name="insertValue">
                <xsl:with-param name="list" select="current-group()/PROFILEDESC/TEXTCLASS/KEYWORDS"/>
            </xsl:call-template>

            <!-- Representative Kind -->
            <xsl:value-of select="concat($QUOTE,$QUOTE)"/>

            <xsl:call-template name="insertRecordSeparator"/>
        </xsl:for-each-group>
    </xsl:template>

    <xsl:template name="insertValue">
        <xsl:param name="list" required="yes"/>
        <xsl:param name="insertSeparator" select="true()" as="xs:boolean"/>

        <xsl:variable name="value">
            <xsl:for-each-group select="$list" group-by=".">
                <xsl:variable name="v" select="normalize-space(.)"/>
                <xsl:if test="$v!=''">
                    <xsl:value-of select="$v"/>
                    <xsl:value-of select="$SEPARATOR_VALUE"/>
                </xsl:if>
            </xsl:for-each-group>
        </xsl:variable>
        <xsl:value-of select="concat($QUOTE,substring($value,1,string-length($value)-1),$QUOTE)"/>
        <xsl:if test="$insertSeparator=true()">
            <xsl:call-template name="insertFieldSeparator"/>
        </xsl:if>
    </xsl:template>

    <xsl:template name="insertHeaderRow">
        <xsl:for-each select="$propertyList">
            <xsl:call-template name="insertField">
                <xsl:with-param name="value" select="."/>
                <xsl:with-param name="insertSeparator" select="$propertyListCnt > position()"/>
            </xsl:call-template>
        </xsl:for-each>

        <xsl:call-template name="insertRecordSeparator"/>
    </xsl:template>

    <xsl:template name="insertField">
        <xsl:param name="value" select="''"/>
        <xsl:param name="insertSeparator" select="true()" as="xs:boolean"/>

        <xsl:choose>
            <xsl:when test="string-length($value) > 0">
                <xsl:text>&quot;</xsl:text>
                <!--
                <xsl:value-of select="$value"/>
                -->
                <xsl:value-of select="replace($value,$QUOTE,concat($QUOTE,$QUOTE))"/>
                <xsl:text>&quot;</xsl:text>
            </xsl:when>
            <xsl:otherwise/>
        </xsl:choose>

        <xsl:if test="$insertSeparator = true()">
            <xsl:call-template name="insertFieldSeparator"/>
        </xsl:if>
    </xsl:template>

    <xsl:template name="insertFieldSeparator">
        <xsl:value-of select="$SEPARATOR_FIELD"/>
    </xsl:template>

    <xsl:template name="insertRecordSeparator">
        <xsl:text>&#xa;</xsl:text>
    </xsl:template>

</xsl:stylesheet>