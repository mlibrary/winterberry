<xsl:stylesheet version="1.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:mml="http://www.w3.org/1998/Math/MathML" xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:tei="http://www.tei-c.org/ns/1.0"
                exclude-result-prefixes="xsi xs xlink mml">
    <!--
    <xsl:import href="/var/www/michigan/src/files/xsl/default-v1.4.3.xsl"/>
    -->
    <xsl:import href="janeway_default.xsl"/>

    <!-- Version 1.4.3 2023-09-22 UMPTG 1.1 -->
    <xsl:template match="*[local-name()='media' and ./*[local-name()='attrib' and @specific-use='umptg_fulcrum_resource']]">
        <xsl:variable name="data-doi" select="child::object-id[@pub-id-type='doi']/text()"/>

        <!-- Handle Fulcrum Media -->
        <xsl:variable name="fulcrum_elem" select="./*[local-name()='attrib' and @specific-use='umptg_fulcrum_resource']"/>
        <xsl:variable name="embed_link">
            <xsl:choose>
                <xsl:when test="@mimetype='video'">
                    <xsl:value-of select="concat(@xlink:href,'&amp;fs=1')"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="@xlink:href"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="css_link" select="$fulcrum_elem/ext-link[@specific-use='umptg_fulcrum_resource_css_stylesheet_link']/@xlink:href"/>
        <xsl:variable name="identifier" select="$fulcrum_elem/*[local-name()='alternatives']/*[@specific-use='umptg_fulcrum_resource_identifier']"/>
        <xsl:variable name="title" select="$fulcrum_elem/*[local-name()='alternatives']/*[@specific-use='umptg_fulcrum_resource_title']"/>

        <div class="media" data-doi="{$data-doi}">
            <xsl:element name="link">
                <xsl:attribute name="href">
                    <xsl:value-of select="$css_link"/>
                </xsl:attribute>
                <xsl:attribute name="rel">
                    <xsl:value-of select="'stylesheet'"/>
                </xsl:attribute>
                <xsl:attribute name="type">
                    <xsl:value-of select="'text/css'"/>
                </xsl:attribute>
            </xsl:element>
            <xsl:element name="div">
                <xsl:attribute name="id">
                    <xsl:value-of select="concat('fulcrum-embed-outer-',$identifier)"/>
                </xsl:attribute>
                <xsl:element name="div">
                    <xsl:attribute name="id">
                        <xsl:value-of select="concat('fulcrum-embed-inner-',$identifier)"/>
                    </xsl:attribute>
                    <xsl:element name="iframe">
                        <xsl:attribute name="id">
                            <xsl:value-of select="concat('fulcrum-embed-iframe-',$identifier)"/>
                        </xsl:attribute>
                        <xsl:attribute name="src">
                            <xsl:value-of select="$embed_link"/>
                        </xsl:attribute>
                        <xsl:attribute name="title">
                            <xsl:value-of select="$title"/>
                        </xsl:attribute>
                        <xsl:attribute name="allowfullscreen">
                            <xsl:value-of select="'true'"/>
                        </xsl:attribute>
                    </xsl:element>
                </xsl:element>
            </xsl:element>
            <xsl:apply-templates select="*[local-name()!='attrib' or @specific-use!='umptg_fulcrum_resource']"/>
        </div>
    </xsl:template>

    <xsl:template match="table-wrap//caption/title">
        <span class="caption-title">
            <xsl:apply-templates/>
        </span>
    </xsl:template>

    <xsl:template match="email">
        <xsl:element name="a">
            <xsl:attribute name="href">
                <xsl:value-of select="concat('mailto:',.)"/>
            </xsl:attribute>
            <xsl:attribute name="class">email</xsl:attribute>
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>

</xsl:stylesheet>