<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
        xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
        xmlns:xs="http://www.w3.org/2001/XMLSchema"
        xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
        xmlns:xi="http://www.w3.org/2001/XInclude"
        xmlns:xlink="http://www.w3.org/1999/xlink"
        xmlns:dlxs="http://mlib.umich.edu/namespace/dlxs"
        xmlns:mlibxsl="http://www.mlib.umich.edu/namespace/mlibxsl"
        exclude-result-prefixes="xs xi dlxs mlibxsl"
        version="2.0">

    <xsl:output method="xml" doctype-public="-//NLM//DTD JATS (Z39.96) Journal Publishing DTD with MathML3 v1.3d1 20190831//EN" doctype-system="http://jats.nlm.nih.gov/publishing/1.3d1/JATS-journalpublishing1-mathml3.dtd" xpath-default-namespace="" indent="yes"/>

    <xsl:param name="image_list" required="no"/>

    <xsl:variable name="image_doc">
        <xsl:element name="imagedoc">
            <xsl:for-each select="tokenize($image_list,';')">
                <xsl:element name="image">
                    <xsl:attribute name="entity" select="tokenize(.,':')[1]"/>
                    <xsl:attribute name="path" select="tokenize(.,':')[2]"/>
                </xsl:element>
            </xsl:for-each>
        </xsl:element>
    </xsl:variable>

    <xsl:variable name="abstractDiv"
                  select="/DLPSTEXTCLASS/TEXT//*[local-name()='DIV1' and ./*[local-name()='HEAD' and lower-case(string())='abstract']]"/>

    <xsl:template match="DLPSTEXTCLASS">
        <xsl:element name="article">
            <xsl:namespace name="xlink" select="'http://www.w3.org/1999/xlink'"/>
            <xsl:namespace name="mml" select="'http://www.w3.org/1998/Math/MathML'"/>
            <xsl:namespace name="xsi" select="'http://www.w3.org/2001/XMLSchema-instance'"/>

            <xsl:attribute name="article-type" select="'article'"/>

            <xsl:apply-templates select="@*|node()"/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="HEADER">
        <xsl:element name="front">
            <xsl:element name="journal-meta">
                <xsl:apply-templates select="FILEDESC/PUBLICATIONSTMT/IDNO[@TYPE='dlps']" mode="journal-id"/>
                <xsl:element name="journal-title-group">
                    <xsl:apply-templates select="FILEDESC/SERIESSTMT/TITLE"/>
                </xsl:element>
                <xsl:apply-templates select="FILEDESC/SERIESSTMT/IDNO[@TYPE='issn']"/>
                <xsl:if test="exists(FILEDESC/PUBLICATIONSTMT/*[local-name()='PUBLISHER' or local-name()='PUBPLACE'])">
                    <xsl:element name="publisher">
                        <xsl:apply-templates select="FILEDESC/PUBLICATIONSTMT/PUBLISHER"/>
                        <xsl:apply-templates select="FILEDESC/PUBLICATIONSTMT/PUBPLACE"/>
                    </xsl:element>
                </xsl:if>
            </xsl:element>
            <xsl:element name="article-meta">
                <xsl:apply-templates select="FILEDESC/PUBLICATIONSTMT/IDNO[@TYPE!='issn']"/>
                <xsl:element name="title-group">
                    <xsl:apply-templates select="FILEDESC/TITLESTMT/TITLE[@TYPE='main' or not(exists(@TYPE))]"/>
                </xsl:element>
                <xsl:variable name="authorList"
                              select="/DLPSTEXTCLASS/TEXT//DIV1/P[@TYPE='author']"/>
                <xsl:variable name="authorIndList"
                              select="FILEDESC/SOURCEDESC/BIBL/AUTHORIND[normalize-space(string())!='']"/>
                <xsl:if test="count($authorIndList) > 0">
                    <xsl:element name="contrib-group">
                        <xsl:for-each select="$authorIndList">
                            <xsl:variable name="ndx" select="position()"/>
                            <xsl:element name="contrib">
                                <xsl:attribute name="contrib-type" select="'author'"/>
                                <xsl:apply-templates select="."/>

                                <xsl:variable name="authorNode" select="$authorList[$ndx]"/>
                                <xsl:if test="exists($authorNode)">
                                    <xsl:variable name="institution"
                                                  select="$authorNode/following-sibling::*[@TYPE='author-notes' and not(exists(REF[@TYPE='url']))]"/>
                                    <xsl:variable name="email"
                                                  select="$authorNode/following-sibling::*[@TYPE='author-notes' and exists(REF[@TYPE='url'])]"/>
                                    <xsl:if test="exists($institution) or exists($email)">
                                        <xsl:element name="address">
                                            <xsl:if test="exists($institution)">
                                                <xsl:element name="institution">
                                                    <xsl:value-of select="$institution[1]"/>
                                                </xsl:element>
                                            </xsl:if>
                                            <xsl:if test="exists($email)">
                                                <xsl:element name="email">
                                                    <xsl:value-of select="$email[1]"/>
                                                </xsl:element>
                                            </xsl:if>
                                        </xsl:element>
                                    </xsl:if>
                                </xsl:if>
                            </xsl:element>
                        </xsl:for-each>
                    </xsl:element>
                </xsl:if>
                <xsl:apply-templates select="FILEDESC/PUBLICATIONSTMT/DATE[@TYPE='sort']"/>
                <xsl:apply-templates select="FILEDESC/SOURCEDESC/BIBL/BIBLSCOPE[@TYPE='volno']"/>
                <xsl:if test="exists(FILEDESC/PUBLICATIONSTMT/AVAILABILITY/P)">
                    <xsl:element name="permissions">
                        <xsl:apply-templates select="FILEDESC/PUBLICATIONSTMT/AVAILABILITY/P"/>
                    </xsl:element>
                </xsl:if>

                <xsl:choose>
                    <xsl:when test="exists($abstractDiv)">
                        <xsl:element name="abstract">
                            <xsl:call-template name="add-section">
                                <xsl:with-param name="divNode" select="$abstractDiv"/>
                            </xsl:call-template>
                        </xsl:element>
                    </xsl:when>
                    <!--
                    <xsl:when test="exists(/DLPSTEXTCLASS/TEXT/FRONT/DIV1)">
                        <xsl:element name="abstract">
                            <xsl:apply-templates select="/DLPSTEXTCLASS/TEXT/FRONT/DIV1"/>
                        </xsl:element>
                    </xsl:when>
                    -->
                </xsl:choose>
            </xsl:element>
        </xsl:element>
    </xsl:template>

    <xsl:template match="FILEDESC/PUBLICATIONSTMT/IDNO[@TYPE='dlps']" mode="journal-id">
        <xsl:element name="journal-id">
            <xsl:attribute name="journal-id-type" select="@TYPE"/>
            <xsl:value-of select="."/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="FILEDESC/PUBLICATIONSTMT/PUBLISHER">
        <xsl:element name="publisher-name">
            <xsl:value-of select="."/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="FILEDESC/PUBLICATIONSTMT/PUBPLACE">
        <xsl:element name="publisher-loc">
            <xsl:value-of select="."/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="FILEDESC/SERIESSTMT/IDNO[@TYPE='issn']">
        <xsl:element name="issn">
            <xsl:value-of select="."/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="FILEDESC/SERIESSTMT/TITLE">
        <xsl:element name="journal-title">
            <xsl:value-of select="."/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="FILEDESC/PUBLICATIONSTMT/IDNO[@TYPE!='issn']">
        <xsl:element name="article-id">
            <xsl:attribute name="pub-id-type">
                <xsl:choose>
                    <xsl:when test="@TYPE='purl'">
                        <xsl:value-of select="'handle'"/>
                    </xsl:when>
                    <xsl:when test="@TYPE='dlps'">
                        <xsl:value-of select="'other'"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="@TYPE"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:attribute>
            <xsl:value-of select="."/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="FILEDESC/TITLESTMT/TITLE">
        <xsl:element name="article-title">
            <xsl:value-of select="."/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="FILEDESC/SOURCEDESC/BIBL/AUTHORIND">
        <xsl:variable name="nameList" select="tokenize(., ',')"/>
        <xsl:element name="name">
            <xsl:choose>
                <xsl:when test="count($nameList) > 1">
                    <xsl:element name="surname">
                        <xsl:value-of select="normalize-space($nameList[1])"/>
                    </xsl:element>
                    <xsl:element name="given-names">
                        <xsl:value-of select="normalize-space($nameList[2])"/>
                    </xsl:element>
                </xsl:when>
                <xsl:when test="count(tokenize(.,'[ ]+')) > 1">
                    <xsl:element name="surname">
                        <xsl:value-of select="normalize-space($nameList[2])"/>
                    </xsl:element>
                    <xsl:element name="given-names">
                        <xsl:value-of select="normalize-space($nameList[1])"/>
                    </xsl:element>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="."/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:element>
    </xsl:template>

    <xsl:template match="FILEDESC_OLD/SOURCEDESC/BIBL/AUTHORIND">
        <xsl:variable name="nameList" select="tokenize(., ',')"/>
        <xsl:element name="contrib">
            <xsl:attribute name="contrib-type" select="'author'"/>
            <xsl:element name="name">
                <xsl:choose>
                    <xsl:when test="count($nameList) > 1">
                        <xsl:element name="surname">
                            <xsl:value-of select="normalize-space($nameList[1])"/>
                        </xsl:element>
                        <xsl:element name="given-names">
                            <xsl:value-of select="normalize-space($nameList[2])"/>
                        </xsl:element>
                    </xsl:when>
                    <xsl:when test="count(tokenize(.,'[ ]+')) > 1">
                        <xsl:element name="surname">
                            <xsl:value-of select="normalize-space($nameList[2])"/>
                        </xsl:element>
                        <xsl:element name="given-names">
                            <xsl:value-of select="normalize-space($nameList[1])"/>
                        </xsl:element>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="."/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:element>
            <xsl:variable name="institution"
                          select="/DLPSTEXTCLASS/TEXT//DIV1/P[@TYPE='author-notes' and not(exists(REF[@TYPE='url']))]"/>
            <xsl:variable name="email"
                          select="/DLPSTEXTCLASS/TEXT//DIV1/P[@TYPE='author-notes' and exists(REF[@TYPE='url'])]"/>
            <xsl:if test="exists($institution) or exists($email)">
                <xsl:element name="address">
                    <xsl:if test="exists($institution)">
                        <xsl:element name="institution">
                            <xsl:value-of select="$institution"/>
                        </xsl:element>
                    </xsl:if>
                    <xsl:if test="exists($email)">
                        <xsl:element name="email">
                            <xsl:value-of select="$email"/>
                        </xsl:element>
                    </xsl:if>
                </xsl:element>
            </xsl:if>
        </xsl:element>
    </xsl:template>

    <xsl:template match="FILEDESC/PUBLICATIONSTMT/DATE[@TYPE='sort']">
        <xsl:call-template name="dateToDMYTags">
            <xsl:with-param name="inDate" select="."/>
            <xsl:with-param name="outTagName" select="'pub-date'"/>
        </xsl:call-template>
    </xsl:template>

    <xsl:template match="FILEDESC/SOURCEDESC/BIBL/BIBLSCOPE[@TYPE='volno']">
        <xsl:element name="volume">
            <xsl:value-of select="normalize-space(.)"/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="FILEDESC/PUBLICATIONSTMT/AVAILABILITY/P">
        <xsl:element name="copyright-statement">
            <xsl:value-of select="."/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="TEXT">
        <xsl:apply-templates select="@*|node()"/>
    </xsl:template>

    <xsl:template match="BODY">
        <xsl:element name="body">
            <xsl:apply-templates select="/DLPSTEXTCLASS/TEXT/FRONT/*"/>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="DIV1|DIV2|DIV3|DIV4">
        <xsl:choose>
            <xsl:when test="lower-case(./HEAD)='abstract' or exists(./P[@TYPE='author'])">
                <!-- This should be the abtract and should have
                    been processed by the HEADER. Skip. -->
                <xsl:message>Skip <xsl:value-of select="local-name(.)"/></xsl:message>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="add-section">
                    <xsl:with-param name="divNode" select="."/>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="HEAD">
        <xsl:element name="title">
            <xsl:apply-templates select="@*|node()"/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="P[@TYPE='title' or @TYPE='author' or @TYPE='author-notes']"/>

    <xsl:template match="P">
        <xsl:element name="p">
            <xsl:if test="@TYPE">
                <xsl:attribute name="content-type" select="@TYPE"/>
            </xsl:if>
            <xsl:choose>
                <xsl:when test="exists(@REND) and not(empty(@REND))">
                    <xsl:call-template name="add-inline-style">
                        <xsl:with-param name="node" select="."/>
                        <xsl:with-param name="style" select="@REND"/>
                    </xsl:call-template>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates select="@*[name()!='TYPE'and name()!='REND']|node()"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:element>
    </xsl:template>

    <xsl:template match="PTR">
        <xsl:element name="xref">
            <xsl:attribute name="rid" select="@TARGET"/>
            <xsl:attribute name="ref-type" select="'fn'"/>
            <xsl:apply-templates select="@*[name()!='TARGET' and name()!='N']|node()"/>
            <xsl:value-of select="@N"/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="REF">
        <xsl:choose>
            <xsl:when test="@TYPE = 'youtube'">
                <xsl:element name="media">
                    <xsl:attribute name="mimetype" select="'video'"/>
                    <xsl:attribute name="xlink:show" select="'embed'"/>
                    <xsl:attribute name="xlink:href" select="concat('https://youtu.be/',@ENTITY)"/>
                    <xsl:element name="caption">
                        <xsl:element name="title">
                            <xsl:value-of select="concat('https://youtu.be/',@ENTITY)"/>
                        </xsl:element>
                    </xsl:element>
                </xsl:element>
            </xsl:when>
            <xsl:when test="starts-with(lower-case(@URL), 'mailto:')">
                <xsl:element name="email">
                    <xsl:attribute name="xlink:href" select="@URL"/>
                    <xsl:value-of select="."/>
                </xsl:element>
            </xsl:when>
            <xsl:otherwise>
                <xsl:element name="ext-link">
                    <xsl:call-template name="set-reference-attributes">
                        <xsl:with-param name="refNode" select="."/>
                    </xsl:call-template>
                    <xsl:apply-templates select="@*[name()!='TYPE' and name()!='URL' and name()!='ENTITY' and name()!='FILENAME']|node()"/>
                </xsl:element>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="Q1">
        <xsl:element name="disp-quote">
            <xsl:if test="exists(@TYPE)">
                <xsl:attribute name="content-type" select="@TYPE"/>
            </xsl:if>
            <xsl:apply-templates select="@*[name()!='TYPE']|node()"/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="FIGURE[@TYPE='inline']">
        <xsl:element name="inline-graphic">
            <xsl:if test="exists(@ENTITY)">
                <xsl:attribute name="xlink:href" select="mlibxsl:make-resource-path(@ENTITY)"/>
                <xsl:apply-templates select="@*[name()!='ENTITY' and name()!='TYPE']|node()"/>
            </xsl:if>
        </xsl:element>
    </xsl:template>

    <xsl:template match="FIGURE">
        <xsl:element name="fig">
            <xsl:if test="exists(@REND)">
                <xsl:attribute name="fig-type" select="@REND"/>
            </xsl:if>
            <xsl:if test="exists(HEAD)">
                <xsl:for-each select="HEAD">
                    <xsl:apply-templates select="."/>
                </xsl:for-each>
            </xsl:if>
            <xsl:apply-templates select="@*[name()!='ENTITY' and name()!='REND']|*[local-name()!='HEAD']"/>
            <xsl:if test="exists(@ENTITY)">
                <xsl:element name="graphic">
                    <xsl:attribute name="xlink:href" select="mlibxsl:make-resource-path(@ENTITY)"/>
                </xsl:element>
            </xsl:if>
        </xsl:element>
    </xsl:template>

    <xsl:template match="FIGURE/HEAD">
        <xsl:element name="caption">
            <xsl:element name="title">
                <xsl:apply-templates select="@*|node()"/>
            </xsl:element>
        </xsl:element>
    </xsl:template>

    <xsl:template match="NOTE1[@TYPE='sidebar']">
        <xsl:element name="boxed-text">
            <xsl:if test="exists(@ID)">
                <xsl:attribute name="id" select="@ID"/>
            </xsl:if>
            <xsl:attribute name="position" select="'float'"/>
            <xsl:apply-templates select="*"/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="NOTE1[(empty(preceding-sibling::*) or preceding-sibling::*[position()=1 and local-name()!='NOTE1']) and (empty(following-sibling::*) or following-sibling::*[position()=1 and local-name()!='NOTE1'])]">
        <xsl:element name="fn-group">
            <xsl:call-template name="add-footnote">
                <xsl:with-param name="fnNode" select="."/>
            </xsl:call-template>
        </xsl:element>
    </xsl:template>

    <xsl:template match="NOTE1[(empty(preceding-sibling::*) or preceding-sibling::*[position()=1 and local-name()!='NOTE1']) and following-sibling::*[position()=1 and local-name()='NOTE1']]">
        <xsl:element name="fn-group">
            <xsl:call-template name="add-footnote">
                <xsl:with-param name="fnNode" select="."/>
            </xsl:call-template>
            <xsl:for-each select="following-sibling::*[local-name()='NOTE1']">
                <xsl:call-template name="add-footnote">
                    <xsl:with-param name="fnNode" select="."/>
                </xsl:call-template>
            </xsl:for-each>
        </xsl:element>
    </xsl:template>

    <xsl:template match="NOTE1[preceding-sibling::*[position()=1 and local-name()='NOTE1']]"/>

    <xsl:template match="NOTE1/LG">
        <xsl:element name="p">
            <xsl:element name="verse-group">
                <xsl:apply-templates select="@*|node()"/>
            </xsl:element>
        </xsl:element>
    </xsl:template>

    <xsl:template match="NOTE1/Q1">
        <xsl:element name="p">
            <xsl:element name="disp-quote">
                <xsl:if test="exists(@TYPE)">
                    <xsl:attribute name="content-type" select="@TYPE"/>
                </xsl:if>
                <xsl:apply-templates select="@*[name()!='TYPE']|node()"/>
            </xsl:element>
        </xsl:element>
    </xsl:template>

    <xsl:template match="NOTE1//LG/L|Q1[@TYPE='epig']/P">
        <xsl:element name="verse-line">
            <xsl:if test="exists(@REND)">
                <xsl:attribute name="style-detail" select="@REND"/>
            </xsl:if>
            <xsl:apply-templates select="@*[name()!='REND']|node()"/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="LIST/@TYPE">
        <xsl:attribute name="list-type" select="."/>
    </xsl:template>

    <xsl:template match="BIBL/P">
        <xsl:apply-templates select="./*"/>
    </xsl:template>

    <xsl:template match="BIBL">
        <xsl:element name="ref">
            <xsl:element name="mixed-citation">
                <xsl:element name="source">
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:element>
        </xsl:element>
    </xsl:template>

    <xsl:template match="ITEM">
        <xsl:element name="list-item">
            <xsl:apply-templates select="@*"/>

            <xsl:choose>
                <xsl:when test="count(P) = 0">
                    <xsl:element name="p">
                        <xsl:apply-templates/>
                    </xsl:element>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:element>
    </xsl:template>

    <xsl:template match="LISTBIBL">
        <xsl:element name="ref-list">
            <xsl:apply-templates select="@*|node()"/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="ITEM|BIBL" mode="OLD">
        <xsl:element name="list-item">
            <xsl:apply-templates select="@*"/>

            <xsl:choose>
                <xsl:when test="count(P) = 0">
                    <xsl:element name="p">
                        <xsl:apply-templates/>
                    </xsl:element>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:element>
    </xsl:template>

    <xsl:template match="LISTBIBL" mode="OLD">
        <xsl:element name="list">
            <xsl:attribute name="list-type" select="'ordered'"/>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="Q1[@TYPE='epig']">
        <xsl:element name="verse-group">
            <xsl:apply-templates select="@*[name()!='TYPE']|node()"/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="LG">
        <xsl:element name="verse-group">
            <xsl:apply-templates select="@*|node()"/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="L">
        <xsl:element name="verse-line">
            <xsl:choose>
                <xsl:when test="exists(@REND) and not(empty(@REND))">
                    <xsl:call-template name="add-inline-style">
                        <xsl:with-param name="node" select="."/>
                        <xsl:with-param name="style" select="@REND"/>
                    </xsl:call-template>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates select="@*[name()!='TYPE'and name()!='REND']|node()"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:element>
    </xsl:template>

    <xsl:template match="NOTE1/TABLE">
        <xsl:element name="p">
            <xsl:call-template name="add-table">
                <xsl:with-param name="node" select="."/>
            </xsl:call-template>
        </xsl:element>
    </xsl:template>

    <xsl:template match="TABLE">
        <xsl:call-template name="add-table">
            <xsl:with-param name="node" select="."/>
        </xsl:call-template>
    </xsl:template>

    <xsl:template match="TABLE/CAPTION|TABLE/HEAD">
        <xsl:apply-templates select="@*"/>

        <xsl:choose>
            <xsl:when test="count(P) = 0">
                <xsl:element name="p">
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="ROW">
        <xsl:element name="tr">
            <xsl:apply-templates select="@*|node()"/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="CELL">
        <xsl:element name="td">
            <xsl:choose>
                <xsl:when test="exists(@ROLE)">
                    <xsl:attribute name="content-type" select="@ROLE"/>
                </xsl:when>
                <xsl:when test="exists(@TYPE)">
                    <xsl:attribute name="content-type" select="@TYPE"/>
                </xsl:when>
            </xsl:choose>
            <xsl:if test="exists(@REND)">
                <xsl:attribute name="align" select="@REND"/>
            </xsl:if>
            <xsl:apply-templates select="@*[name()!='ROLE' and name()!='REND' and name()!='TYPE']|node()"/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="CELL/FIGURE">
        <xsl:if test="exists(@ENTITY)">
            <xsl:element name="graphic">
                <xsl:attribute name="xlink:href" select="mlibxsl:make-resource-path(@ENTITY)"/>
            </xsl:element>
        </xsl:if>
    </xsl:template>

    <!--
    <xsl:template match="LISTBIBL/BIBL/REF|LIST/ITEM/REF">
        <xsl:element name="p">
            <xsl:element name="ext-link">
                <xsl:call-template name="set-reference-attributes">
                    <xsl:with-param name="refNode" select="."/>
                </xsl:call-template>
                <xsl:apply-templates select="@*[name()!='TYPE' and name()!='URL' and name()!='ENTITY' and name()!='FILENAME']|node()"/>
            </xsl:element>
        </xsl:element>
    </xsl:template>

    <xsl:template match="LISTBIBL/BIBL/HI1|LIST/ITEM/HI1">
        <xsl:element name="p">
            <xsl:call-template name="add-inline-style">
                <xsl:with-param name="node" select="."/>
                <xsl:with-param name="style" select="@REND"/>
            </xsl:call-template>
        </xsl:element>
    </xsl:template>

    <xsl:template match="*[local-name()='ITEM' or local-name()='BIBL']/text()">
        <xsl:element name="p"><xsl:copy>.</xsl:copy></xsl:element>
    </xsl:template>
    -->

    <!--
    <xsl:template match="LISTBIBL/BIBL/*[local-name()!='P' and local-name()!='REF' and local-name()!='HI1']">
        <xsl:element name="p">
            <xsl:element name="{local-name()}">
                <xsl:apply-templates select="@*|./node()"/>
            </xsl:element>
        </xsl:element>
    </xsl:template>
    -->

    <xsl:template match="HI1">
        <xsl:choose>
            <xsl:when test="exists(@REND) and not(empty(@REND))">
                <xsl:call-template name="add-inline-style">
                    <xsl:with-param name="node" select="."/>
                    <xsl:with-param name="style" select="@REND"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates select="@*[name()!='TYPE'and name()!='REND']|node()"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="FRONT|LB|MILESTONE"/>

    <xsl:template match="TD/@TYPE"/>

    <xsl:template match="element()">
        <xsl:element name="{lower-case(local-name())}">
            <xsl:apply-templates select="@*|node()"/>
        </xsl:element>
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

    <xsl:template name="add-section">
        <xsl:param name="divNode"/>

        <xsl:element name="sec">
            <xsl:choose>
                <xsl:when test="exists($divNode/*[local-name()='HEAD'])">
                    <xsl:apply-templates select="$divNode/*[local-name()='HEAD']"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:element name="title"/>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:apply-templates select="$divNode/*[local-name()!='HEAD']"/>
        </xsl:element>
    </xsl:template>

    <xsl:template name="add-inline-style">
        <xsl:param name="node"/>
        <xsl:param name="style"/>

        <xsl:choose>
            <xsl:when test="$style='isub'">
                <xsl:element name="sub">
                    <xsl:element name="italic">
                        <xsl:apply-templates select="$node/@*[name()!='REND']|node()"/>
                    </xsl:element>
                </xsl:element>
            </xsl:when>
            <xsl:when test="$style='isup'">
                <xsl:element name="sup">
                    <xsl:element name="italic">
                        <xsl:apply-templates select="$node/@*[name()!='REND']|node()"/>
                    </xsl:element>
                </xsl:element>
            </xsl:when>
            <xsl:when test="$style='scital'">
                <xsl:element name="sc">
                    <xsl:element name="italic">
                        <xsl:apply-templates select="$node/@*[name()!='REND']|node()"/>
                    </xsl:element>
                </xsl:element>
            </xsl:when>
            <xsl:when test="$style='bolditalic' or $style='bi'">
                <xsl:element name="bold">
                    <xsl:element name="italic">
                        <xsl:apply-templates select="$node/@*[name()!='REND']|node()"/>
                    </xsl:element>
                </xsl:element>
            </xsl:when>
            <xsl:when test="$style='center' or $style='right' or $style='left' or $style='indent5' or $style='alignright' or $style='alignleft'">
                <xsl:message>Style ignored: <xsl:value-of select="$style"/></xsl:message>
                <xsl:apply-templates select="$node/@*[name()!='REND']|node()"/>
            </xsl:when>
            <xsl:when test="$style='indent1'">
                <xsl:apply-templates select="$node/@*[name()!='REND']|node()"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:variable name="sstyle">
                    <xsl:choose>
                        <xsl:when test="$style='b'">
                            <xsl:value-of select="'bold'"/>
                        </xsl:when>
                        <xsl:when test="$style='i' or $style='math'">
                            <xsl:value-of select="'italic'"/>
                        </xsl:when>
                        <xsl:when test="$style='u' or $style='underlined'">
                            <xsl:value-of select="'underline'"/>
                        </xsl:when>
                        <xsl:when test="$style='smcap'">
                            <xsl:value-of select="'sc'"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="$style"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                <xsl:element name="{$sstyle}">
                    <xsl:apply-templates select="$node/@*[name()!='REND']|node()"/>
                </xsl:element>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="add-footnote">
        <xsl:param name="fnNode"/>

        <xsl:element name="fn">
            <xsl:apply-templates select="@*[name()!='N']|node()"/>
        </xsl:element>
    </xsl:template>

    <xsl:template name="add-table">
        <xsl:param name="node"/>

        <xsl:element name="table-wrap">
            <xsl:if test="count($node/HEAD) > 0">
                <xsl:element name="caption">
                    <xsl:apply-templates select="$node/HEAD"/>
                </xsl:element>
            </xsl:if>
            <xsl:element name="table">
                <xsl:apply-templates select="$node/@*[name()!='REND']"/>
                <xsl:element name="tbody">
                    <xsl:apply-templates select="$node/*[local-name()!='HEAD' and local-name()!='CAPTION']"/>
                </xsl:element>
            </xsl:element>
            <xsl:if test="exists($node/CAPTION)">
                <xsl:element name="table-wrap-foot">
                    <xsl:apply-templates select="$node/CAPTION"/>
                </xsl:element>
            </xsl:if>
        </xsl:element>

    </xsl:template>

    <xsl:template name="set-reference-attributes">
        <xsl:param name="refNode"/>

        <xsl:if test="exists($refNode/@TYPE)">
            <xsl:attribute name="ext-link-type" select="$refNode/@TYPE"/>
        </xsl:if>
        <xsl:choose>
            <xsl:when test="exists($refNode/@URL)">
                <xsl:attribute name="xlink:href" select="$refNode/@URL"/>
            </xsl:when>
            <xsl:when test="exists($refNode/@FILENAME)">
                <xsl:attribute name="xlink:href" select="$refNode/@FILENAME"/>
            </xsl:when>
            <xsl:when test="exists($refNode/@ENTITY)">
                <xsl:attribute name="xlink:href" select="$refNode/@ENTITY"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:message>No REF link attribute found.</xsl:message>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="dateToDMYTags">
        <xsl:param name="inDate" />
        <xsl:param name="outTagName" />
        <xsl:element name="{$outTagName}">
            <xsl:variable name="frags" select="tokenize($inDate, '-')" />
            <xsl:if test="count($frags) gt 2">
                <day><xsl:value-of select="$frags[3]" /></day>
            </xsl:if>
            <xsl:if test="count($frags) gt 1">
                <month><xsl:value-of select="$frags[2]" /></month>
            </xsl:if>
            <xsl:if test="count($frags) gt 0">
                <year><xsl:value-of select="$frags[1]" /></year>
            </xsl:if>
        </xsl:element>
    </xsl:template>

    <xsl:function name="mlibxsl:make-resource-path">
        <xsl:param name="entity"/>

        <xsl:variable name="item" select="$image_doc/imagedoc/image[@entity=$entity]"/>
        <xsl:sequence select="$item/@path"/>
    </xsl:function>
</xsl:stylesheet>