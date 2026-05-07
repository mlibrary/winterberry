<xsl:stylesheet version="1.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:mml="http://www.w3.org/1998/Math/MathML" xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:tei="http://www.tei-c.org/ns/1.0"
                exclude-result-prefixes="xsi xs mml">

    <xsl:template match="*[local-name()='media' and ./*[local-name()='attrib' and @specific-use='umptg_fulcrum_resource']]">
        <xsl:variable name="data-doi" select="child::object-id[@pub-id-type='doi']/text()"/>

        <!-- Handle Fulcrum Resource Media -->
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

        <xsl:element name="div">
            <xsl:attribute name="class">
                <xsl:value-of select="'media'"/>
            </xsl:attribute>
            <xsl:attribute name="data-doi">
                <xsl:value-of select="$data-doi"/>
            </xsl:attribute>
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
        </xsl:element>
    </xsl:template>

    <xsl:template match="*[local-name()='media' and ./*[local-name()='attrib' and @specific-use='umptg_fulcrum_ableplayer_embed_two']]">
        <xsl:variable name="data-doi" select="child::object-id[@pub-id-type='doi']/text()"/>

        <!-- Handle Fulcrum Ableplayer Media -->
        <xsl:variable name="fulcrum_elem" select="./*[local-name()='attrib' and @specific-use='umptg_fulcrum_ableplayer_embed_two']"/>
        <xsl:variable name="identifier" select="$fulcrum_elem/*[local-name()='alternatives']/*[@specific-use='umptg_fulcrum_resource_identifier']"/>
        <xsl:variable name="title" select="$fulcrum_elem/*[local-name()='alternatives']/*[@specific-use='umptg_fulcrum_resource_title']"/>

        <xsl:variable name="resource_identifier"
                      select="$fulcrum_elem/*[local-name()='alternatives']/*[local-name()='preformat' and @specific-use='umptg_fulcrum_resource_identifier']"/>
        <xsl:variable name="resource_present_identifier"
                      select="$fulcrum_elem/*[local-name()='alternatives']/*[local-name()='preformat' and @specific-use='umptg_fulcrum_ableplayer_present_identifier']"/>

        <xsl:variable name="resource_mime_type"
                      select="$fulcrum_elem/*[local-name()='alternatives']/*[local-name()='preformat' and @specific-use='umptg_fulcrum_resource_identifier']/@preformat-type"/>
        <xsl:variable name="resource_present_mime_type"
                      select="$fulcrum_elem/*[local-name()='alternatives']/*[local-name()='preformat' and @specific-use='umptg_fulcrum_ableplayer_present_identifier']/@preformat-type"/>

        <xsl:variable name="resource_type"
                      select="substring-after($resource_mime_type,'/')"/>
        <xsl:variable name="resource_present_type"
                      select="substring-after($resource_present_mime_type,'/')"/>

        <xsl:variable name="resource_type_link">
            <xsl:choose>
                <xsl:when test="$fulcrum_elem/*[local-name()='ext-link' and @specific-use='umptg_fulcrum_resource_link']/@xlink:href">
                    <xsl:value-of select="$fulcrum_elem/*[local-name()='ext-link' and @specific-use='umptg_fulcrum_resource_link']/@xlink:href"/>
                </xsl:when>
                <xsl:when test="$resource_identifier">
                    <xsl:value-of select="concat('https://fulcrum.org/downloads/',$resource_identifier,'?file=',$resource_type,'&amp;locale=en')"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="''"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="resource_present_link">
            <xsl:choose>
                <xsl:when test="$fulcrum_elem/*[local-name()='ext-link' and @specific-use='umptg_fulcrum_ableplayer_present_link']/@xlink:href">
                    <xsl:value-of select="$fulcrum_elem/*[local-name()='ext-link' and @specific-use='umptg_fulcrum_ableplayer_present_link']/@xlink:href"/>
                </xsl:when>
                <xsl:when test="$resource_present_identifier">
                    <xsl:value-of select="concat('https://fulcrum.org/downloads/',$resource_present_identifier,'?file=',$resource_present_type,'&amp;locale=en')"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="''"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <xsl:element name="div">
            <xsl:attribute name="class">
                <xsl:value-of select="'ableplayer-embed-two-wrapper'"/>
            </xsl:attribute>
            <xsl:if test="$data-doi != ''">
                <xsl:attribute name="data-doi">
                    <xsl:value-of select="$data-doi"/>
                </xsl:attribute>
            </xsl:if>

            <xsl:call-template name="fulcrum_ableplayer_includes"/>

            <xsl:element name="div">
                <xsl:attribute name="id">
                    <xsl:value-of select="'player'"/>
                </xsl:attribute>
                <xsl:element name="video">
                    <xsl:attribute name="preload">
                        <xsl:value-of select="'auto'"/>
                    </xsl:attribute>
                    <xsl:attribute name="data-able-player"/>
                    <xsl:attribute name="data-debug"/>
                    <xsl:attribute name="data-hide-controls"/>
                    <xsl:attribute name="playsinline"/>
                    <xsl:attribute name="data-captions-position">
                        <xsl:value-of select="'below'"/>
                    </xsl:attribute>
                    <xsl:attribute name="data-meta-type">
                        <xsl:value-of select="'selector'"/>
                    </xsl:attribute>
                    <xsl:attribute name="data-skin">
                        <xsl:value-of select="'2020'"/>
                    </xsl:attribute>
                    <xsl:attribute name="data-transcript-div">
                        <xsl:value-of select="'transcript'"/>
                    </xsl:attribute>
                    <xsl:attribute name="data-seek-interval">
                        <xsl:value-of select="'10'"/>
                    </xsl:attribute>
                    <!--
                    <xsl:attribute name="poster">
                        <xsl:value-of select="'[path or URL to poster image *-thumbnail.jpg file]'"/>
                    </xsl:attribute>
                    -->
                    <xsl:element name="source">
                        <xsl:attribute name="type">
                            <xsl:value-of select="$resource_present_mime_type"/>
                        </xsl:attribute>
                        <xsl:attribute name="src">
                            <xsl:value-of select="$resource_present_link"/>
                        </xsl:attribute>
                    </xsl:element>
                    <xsl:element name="source">
                        <xsl:attribute name="type">
                            <xsl:value-of select="$resource_mime_type"/>
                        </xsl:attribute>
                        <xsl:attribute name="src">
                            <xsl:value-of select="$resource_type_link"/>
                        </xsl:attribute>
                    </xsl:element>
                    <xsl:element name="track">
                        <xsl:attribute name="kind">
                            <xsl:value-of select="'captions'"/>
                        </xsl:attribute>
                        <xsl:attribute name="src">
                            <xsl:value-of select="$fulcrum_elem/ext-link[@specific-use='umptg_fulcrum_ableplayer_vtt_link']/@xlink:href"/>
                        </xsl:attribute>
                        <xsl:attribute name="srclang">
                            <xsl:value-of select="$fulcrum_elem/alternatives/preformat[@specific-use='umptg_fulcrum_ableplayer_vtt_lang']"/>
                        </xsl:attribute>
                    </xsl:element>
                </xsl:element>
            </xsl:element>
            <xsl:element name="div">
                <xsl:attribute name="id">
                    <xsl:value-of select="'transcript'"/>
                </xsl:attribute>
            </xsl:element>
        </xsl:element>
    </xsl:template>

    <xsl:template match="*[local-name()='media' and ./*[local-name()='attrib' and @specific-use='umptg_fulcrum_ableplayer_embed_three']]">
        <xsl:variable name="data-doi" select="child::object-id[@pub-id-type='doi']/text()"/>

        <!-- Handle Fulcrum Ableplayer Media -->
        <xsl:variable name="fulcrum_elem" select="./*[local-name()='attrib' and @specific-use='umptg_fulcrum_ableplayer_embed_three']"/>
        <xsl:variable name="identifier" select="$fulcrum_elem/*[local-name()='alternatives']/*[@specific-use='umptg_fulcrum_resource_identifier']"/>
        <xsl:variable name="title" select="$fulcrum_elem/*[local-name()='alternatives']/*[@specific-use='umptg_fulcrum_resource_title']"/>

        <xsl:variable name="resource_identifier"
                      select="$fulcrum_elem/*[local-name()='alternatives']/*[local-name()='preformat' and @specific-use='umptg_fulcrum_resource_identifier']"/>
        <xsl:variable name="resource_sign_identifier"
                      select="$fulcrum_elem/*[local-name()='alternatives']/*[local-name()='preformat' and @specific-use='umptg_fulcrum_ableplayer_sign_identifier']"/>
        <xsl:variable name="resource_present_identifier"
                      select="$fulcrum_elem/*[local-name()='alternatives']/*[local-name()='preformat' and @specific-use='umptg_fulcrum_ableplayer_present_identifier']"/>
        <xsl:variable name="resource_present_sign_identifier"
                      select="$fulcrum_elem/*[local-name()='alternatives']/*[local-name()='preformat' and @specific-use='umptg_fulcrum_ableplayer_present_sign_identifier']"/>

        <xsl:variable name="resource_mime_type"
                      select="$fulcrum_elem/*[local-name()='alternatives']/*[local-name()='preformat' and @specific-use='umptg_fulcrum_resource_identifier']/@preformat-type"/>
        <xsl:variable name="resource_sign_mime_type"
                      select="$fulcrum_elem/*[local-name()='alternatives']/*[local-name()='preformat' and @specific-use='umptg_fulcrum_ableplayer_sign_identifier']/@preformat-type"/>
        <xsl:variable name="resource_present_mime_type"
                      select="$fulcrum_elem/*[local-name()='alternatives']/*[local-name()='preformat' and @specific-use='umptg_fulcrum_ableplayer_present_identifier']/@preformat-type"/>
        <xsl:variable name="resource_present_sign_mime_type"
                      select="$fulcrum_elem/*[local-name()='alternatives']/*[local-name()='preformat' and @specific-use='umptg_fulcrum_ableplayer_present_sign_identifier']/@preformat-type"/>

        <xsl:variable name="resource_type"
                      select="substring-after($resource_mime_type,'/')"/>
        <xsl:variable name="resource_sign_type"
                      select="substring-after($resource_sign_mime_type,'/')"/>
        <xsl:variable name="resource_present_type"
                      select="substring-after($resource_present_mime_type,'/')"/>
        <xsl:variable name="resource_present_sign_type"
                      select="substring-after($resource_present_sign_mime_type,'/')"/>

        <xsl:variable name="resource_type_link">
            <xsl:choose>
                <xsl:when test="$fulcrum_elem/*[local-name()='ext-link' and @specific-use='umptg_fulcrum_resource_link']/@xlink:href">
                    <xsl:value-of select="$fulcrum_elem/*[local-name()='ext-link' and @specific-use='umptg_fulcrum_resource_link']/@xlink:href"/>
                </xsl:when>
                <xsl:when test="$resource_identifier">
                    <xsl:value-of select="concat('https://fulcrum.org/downloads/',$resource_identifier,'?file=',$resource_type,'&amp;locale=en')"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="''"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="resource_type_sign_link">
            <xsl:choose>
                <xsl:when test="$fulcrum_elem/*[local-name()='ext-link' and @specific-use='umptg_fulcrum_ableplayer_type_sign_link']/@xlink:href">
                    <xsl:value-of select="$fulcrum_elem/*[local-name()='ext-link' and @specific-use='umptg_fulcrum_ableplayer_type_sign_link']/@xlink:href"/>
                </xsl:when>
                <xsl:when test="$resource_sign_identifier">
                    <xsl:value-of select="concat('https://fulcrum.org/downloads/',$resource_sign_identifier,'?file=',$resource_sign_type,'&amp;locale=en')"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="''"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="resource_present_link">
            <xsl:choose>
                <xsl:when test="$fulcrum_elem/*[local-name()='ext-link' and @specific-use='umptg_fulcrum_ableplayer_present_link']/@xlink:href">
                    <xsl:value-of select="$fulcrum_elem/*[local-name()='ext-link' and @specific-use='umptg_fulcrum_ableplayer_present_link']/@xlink:href"/>
                </xsl:when>
                <xsl:when test="$resource_present_identifier">
                    <xsl:value-of select="concat('https://fulcrum.org/downloads/',$resource_present_identifier,'?file=',$resource_present_type,'&amp;locale=en')"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="''"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="resource_present_sign_link">
            <xsl:choose>
                <xsl:when test="$fulcrum_elem/*[local-name()='ext-link' and @specific-use='umptg_fulcrum_ableplayer_present_sign_link']/@xlink:href">
                    <xsl:value-of select="$fulcrum_elem/*[local-name()='ext-link' and @specific-use='umptg_fulcrum_ableplayer_present_sign_link']/@xlink:href"/>
                </xsl:when>
                <xsl:when test="$resource_present_sign_identifier">
                    <xsl:value-of select="concat('https://fulcrum.org/downloads/',$resource_present_sign_identifier,'?file=',$resource_present_sign_type,'&amp;locale=en')"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="''"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <xsl:element name="div">
            <xsl:attribute name="class">
                <xsl:value-of select="'ableplayer-embed-three-wrapper'"/>
            </xsl:attribute>
            <xsl:if test="$data-doi != ''">
                <xsl:attribute name="data-doi">
                    <xsl:value-of select="$data-doi"/>
                </xsl:attribute>
            </xsl:if>

            <xsl:call-template name="fulcrum_ableplayer_includes"/>

            <xsl:element name="div">
                <xsl:attribute name="id">
                    <xsl:value-of select="'player'"/>
                </xsl:attribute>
                <xsl:element name="video">
                    <xsl:attribute name="preload">
                        <xsl:value-of select="'auto'"/>
                    </xsl:attribute>
                    <xsl:attribute name="data-able-player"/>
                    <xsl:attribute name="data-debug"/>
                    <xsl:attribute name="data-hide-controls"/>
                    <xsl:attribute name="playsinline"/>
                    <xsl:attribute name="data-captions-position">
                        <xsl:value-of select="'below'"/>
                    </xsl:attribute>
                    <xsl:attribute name="data-meta-type">
                        <xsl:value-of select="'selector'"/>
                    </xsl:attribute>
                    <xsl:attribute name="data-skin">
                        <xsl:value-of select="'2020'"/>
                    </xsl:attribute>
                    <xsl:attribute name="data-transcript-div">
                        <xsl:value-of select="'transcript'"/>
                    </xsl:attribute>
                    <xsl:attribute name="data-seek-interval">
                        <xsl:value-of select="'10'"/>
                    </xsl:attribute>
                    <!--
                    <xsl:attribute name="poster">
                        <xsl:value-of select="'[path or URL to poster image *-thumbnail.jpg file]'"/>
                    </xsl:attribute>
                    -->
                    <xsl:element name="source">
                        <xsl:attribute name="type">
                            <xsl:value-of select="$resource_present_mime_type"/>
                        </xsl:attribute>
                        <xsl:attribute name="src">
                            <xsl:value-of select="$resource_present_link"/>
                        </xsl:attribute>
                        <xsl:attribute name="data-sign-src">
                            <xsl:value-of select="$resource_present_sign_link"/>
                        </xsl:attribute>
                    </xsl:element>
                    <xsl:element name="source">
                        <xsl:attribute name="type">
                            <xsl:value-of select="$resource_mime_type"/>
                        </xsl:attribute>
                        <xsl:attribute name="src">
                            <xsl:value-of select="$resource_type_link"/>
                        </xsl:attribute>
                        <xsl:attribute name="data-sign-src">
                            <xsl:value-of select="$resource_type_sign_link"/>
                        </xsl:attribute>
                    </xsl:element>
                    <xsl:element name="track">
                        <xsl:attribute name="kind">
                            <xsl:value-of select="'captions'"/>
                        </xsl:attribute>
                        <xsl:attribute name="src">
                            <xsl:value-of select="$fulcrum_elem/ext-link[@specific-use='umptg_fulcrum_ableplayer_vtt_link']/@xlink:href"/>
                        </xsl:attribute>
                        <xsl:attribute name="srclang">
                            <xsl:value-of select="$fulcrum_elem/alternatives/preformat[@specific-use='umptg_fulcrum_ableplayer_vtt_lang']"/>
                        </xsl:attribute>
                    </xsl:element>
                </xsl:element>
            </xsl:element>
            <xsl:element name="div">
                <xsl:attribute name="id">
                    <xsl:value-of select="'transcript'"/>
                </xsl:attribute>
            </xsl:element>
        </xsl:element>
    </xsl:template>

    <xsl:template name="fulcrum_ableplayer_includes">
        <xsl:element name="div">
            <xsl:attribute name="id">
                <xsl:value-of select="'Fulcrum_ableplayer'"/>
            </xsl:attribute>
            <xsl:comment>AblePlayer Dependencies</xsl:comment>
            <xsl:element name="script">
                <xsl:attribute name="src">
                    <xsl:value-of select="'https://ajax.googleapis.com/ajax/libs/jquery/3.2.1/jquery.min.js'"/>
                </xsl:attribute>
            </xsl:element>
            <xsl:element name="script">
                <xsl:attribute name="src">
                    <xsl:value-of select="'https://publishing.umich.edu/assets/ableplayer/thirdparty/js.cookie.js'"/>
                </xsl:attribute>
            </xsl:element>
            <xsl:comment>AblePlayer JS</xsl:comment>
            <xsl:element name="script">
                <xsl:attribute name="src">
                    <xsl:value-of select="'https://publishing.umich.edu/assets/ableplayer/build/ableplayer.js'"/>
                </xsl:attribute>
            </xsl:element>
        </xsl:element>
    </xsl:template>
</xsl:stylesheet>