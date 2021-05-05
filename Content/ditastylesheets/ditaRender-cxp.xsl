<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:msxsl="urn:schemas-microsoft-com:xslt"
  xmlns:ext="http://exslt.org/common"
  exclude-result-prefixes="ext msxsl">

  <xsl:output method="xml" indent="yes" omit-xml-declaration="yes"/>

  <xsl:param name="ViewMode" select="Full" />

  <xsl:param name="ThisPageUrl" select="''" />

  <xsl:param name="RootMapPageId" select="''"/>

  <xsl:variable name="vLower" select=
 "'abcdefghijklmnopqrstuvwxyz'"/>

  <xsl:variable name="vUpper" select=
 "'ABCDEFGHIJKLMNOPQRSTUVWXYZ'"/>

  <xsl:key name="rellinks" match="//link[@role='friend'][@scope='local']" use="." />
  <xsl:variable name="allFootnotes" select="//fn"/>
  <xsl:variable name="allTables" select="//table/title[1]"/>
  <xsl:variable name="allFigures" select="//fig"/>

  <xsl:variable name="rootNodeName">
    <xsl:value-of select = "name(/*)"/>
  </xsl:variable>

  <xsl:template match="/">
    <xsl:choose>
      <xsl:when test="$ViewMode = 'TitleOnly'">
        <xsl:apply-templates select="/*/title"/>
      </xsl:when>
      <xsl:when test="$ViewMode = 'Partial'">
        <xsl:apply-templates select="/*/title"/>
        <xsl:apply-templates select="/*/shortdesc"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates select="dita"/>
        <!-- Addt Templates -->
        <xsl:apply-templates select="concept"/>
        <xsl:apply-templates select="reference"/>
        <xsl:apply-templates select="task"/>
        <xsl:apply-templates select="topic"/>

        <xsl:apply-templates select="map"/>
        <xsl:apply-templates select="glossentry"/>
        <xsl:apply-templates select="troubleshooting"/>
        <!-- Other Potential Types -->
        <xsl:apply-templates select="learningOverview" />
        <xsl:apply-templates select="learningAssessment"/>
        <xsl:apply-templates select="learningSummary"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- Composite DITA File from chunk=to-content -->
  <xsl:template match="dita">
    <xsl:apply-templates/>
  </xsl:template>



  <xsl:template match="dita/concept">
    <xsl:apply-templates select="./title"/>
    <xsl:apply-templates select="./shortdesc"/>
    <xsl:element name="hr"></xsl:element>
    <xsl:call-template name="prerequisites"/>
    <xsl:apply-templates select="./conbody"/>
    <xsl:apply-templates select="./related-links" />
    <xsl:variable name="allSectionNodes" select=".//concept | .//reference | .//task | .//topic"/>
    <xsl:for-each select="$allSectionNodes">
      <xsl:apply-templates select="." mode="isComposite">
        <xsl:with-param name="sectionNumber" select="position()"/>
      </xsl:apply-templates>
    </xsl:for-each>
    <xsl:call-template name="footnotes"/>
  </xsl:template>

  <xsl:template match="dita/reference">
    <xsl:apply-templates select="./title"/>
    <xsl:apply-templates select="./shortdesc"/>
    <xsl:element name="hr"></xsl:element>
    <xsl:call-template name="prerequisites"/>
    <xsl:apply-templates select="./refbody"/>
    <xsl:apply-templates select="./related-links" />
    <xsl:variable name="allSectionNodes" select=".//concept | .//reference | .//task | .//topic"/>
    <xsl:for-each select="$allSectionNodes">
      <xsl:apply-templates select="." mode="isComposite"/>
    </xsl:for-each>
    <xsl:call-template name="footnotes"/>
  </xsl:template>

  <xsl:template match="dita/task">
    <xsl:apply-templates select="./title"/>
    <xsl:apply-templates select="./shortdesc"/>
    <xsl:call-template name="prerequisites"/>
    <xsl:apply-templates select="./taskbody"/>
    <xsl:apply-templates select="./related-links" />
    <xsl:variable name="allSectionNodes" select=".//concept | .//reference | .//task | .//topic"/>
    <xsl:for-each select="$allSectionNodes">
      <xsl:apply-templates select="." mode="isComposite"/>
    </xsl:for-each>
    <xsl:call-template name="footnotes"/>
  </xsl:template>

  <xsl:template match="dita/topic">
    <xsl:apply-templates select="./title"/>
    <xsl:apply-templates select="./shortdesc"/>
    <xsl:call-template name="prerequisites"/>
    <xsl:apply-templates select="./body"/>
    <xsl:apply-templates select="./related-links" />
    <xsl:variable name="allSectionNodes" select=".//concept | .//reference | .//task | .//topic"/>
    <xsl:for-each select="$allSectionNodes">
      <xsl:apply-templates select="." mode="isComposite"/>
    </xsl:for-each>
    <xsl:call-template name="footnotes"/>
  </xsl:template>

  <!-- DITA Glossentry Template -->
  <xsl:template match="glossentry">
    <xsl:apply-templates select="./title"/>
    <!--<xsl:apply-templates select="shortdesc" />-->
    <xsl:element name="hr"></xsl:element>
    <xsl:apply-templates select="./glossBody">
      <xsl:with-param name="glossterm" select="glossterm"/>
      <xsl:with-param name="glossdef" select="glossdef"/>
    </xsl:apply-templates>
    <!--<xsl:apply-templates select="./related-links" />-->
  </xsl:template>

  <!-- glossBody Body Template -->
  <xsl:template match="glossBody">
    <xsl:param name="glossterm" />
    <xsl:param name="glossdef" />
    <div class="body glossBody">
      <xsl:apply-templates select="$glossterm"/>
      <p class="glossdef">
        <xsl:apply-templates select="$glossdef"/>
      </p>
      <p class="glossAcronym">
        <xsl:apply-templates select="glossAlt/glossAcronym"/>
      </p>
    </div>
  </xsl:template>
  <xsl:template match="glossAlt/glossAcronym">
    <strong>
      <xsl:text>Abbreviation: </xsl:text>
    </strong>
    <xsl:value-of select="."/>
  </xsl:template>

  <xsl:template match="glossterm">
    <h3 class="glossterm">
      <xsl:value-of select=
  "concat(translate(substring(.,1,1), $vLower, $vUpper),
          substring(., 2),
          substring(' ', 1 div not(position()=last()))
         )
  "/>
    </h3>
  </xsl:template>
  <xsl:template match="glossdef">
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="msgblock">
    <pre class="pre msgblock">
      <xsl:apply-templates />
    </pre>
  </xsl:template>

  <xsl:template match="msgph">
    <samp class="ph msgph">
      <xsl:apply-templates />
    </samp>
  </xsl:template>

  <!-- DITA Map Template : TOC -->
  <!--<xsl:template match="map">
    <xsl:choose>
      <xsl:when test="$ViewMode = 'LeftNavMap'">
        -->
  <!-- get first topicref for title link / first page link -->
  <!--
        <div class='dita-item-title' isFirstPage='True'>
          <xsl:variable name='titleHref' select='//topicref[1]/@href'/>
          <xsl:element name="a">
            <xsl:attribute name="href">
              <xsl:value-of select="concat($RootMapPageId, '.xml')"/>
              -->
  <!--<xsl:value-of select="$RootMapPageId"/>-->
  <!--
            </xsl:attribute>
            <xsl:value-of select="normalize-space(./title)"/>
          </xsl:element>
        </div>
        -->
  <!-- if there are any topic refs, wrap in UL -->
  <!--
        <xsl:element name="ul">
          <xsl:apply-templates select="./topicref[not(@toc = 'no') and not(@processing-role= 'resource-only') and not(@type='glossentry') and not(@outputclass='frontmatter') and not(@outputclass= 'backmatter')] | ./topichead" mode="LeftNavMap"/>
        </xsl:element>
      </xsl:when>
      <xsl:when test="$ViewMode = 'tocwithdesc'">
        <xsl:apply-templates select="./title"/>
        -->
  <!--<xsl:apply-templates select="./topicmeta/shortdesc"/>-->
  <!--
        <xsl:if test="./topicmeta/shortdesc != ''">
          <xsl:element name="div">
            <xsl:attribute name="class">
              <xsl:value-of select="'body conbody'"/>
            </xsl:attribute>
            <xsl:element name="p">
              <xsl:attribute name="class">
                <xsl:value-of select="'shortdesc'"/>
              </xsl:attribute>
              <xsl:value-of select="normalize-space(./topicmeta/shortdesc)"/>
            </xsl:element>
          </xsl:element>
        </xsl:if>
        <xsl:element name="div">
          <xsl:attribute name="class">
            <xsl:value-of select="'related-links'"/>
          </xsl:attribute>
          <xsl:element name="ul">
            <xsl:attribute name="class">
              <xsl:value-of select="'ullinks'"/>
            </xsl:attribute>
            -->
  <!--<xsl:apply-templates select="./topicref[not(@toc = 'no') and not(@type='reference')]"/>-->
  <!--
            <xsl:apply-templates select="./topicref[not(@toc = 'no') and not(@processing-role= 'resource-only') and not(@type='glossentry') and not(@outputclass='frontmatter') and not(@outputclass= 'backmatter')]" mode="tocwithdesc"/>
            <xsl:apply-templates select="./topicref[not(@toc = 'no') and not(@processing-role= 'resource-only') and not(@type='glossentry') and @outputclass='frontmatter' or @outputclass= 'backmatter']" mode="tocwithdesc"/>
          </xsl:element>
        </xsl:element>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates select="./title"/>
        <xsl:element name="ol">
          <xsl:attribute name="class">
            <xsl:value-of select="'toc'"/>
          </xsl:attribute>
          -->
  <!--<xsl:apply-templates select="./topicref[not(@toc = 'no') and not(@type='reference')]"/>-->
  <!--
          <xsl:apply-templates select="./topicref[not(@toc = 'no') and not(@processing-role= 'resource-only') and not(@type='glossentry') and not(@outputclass='frontmatter') and not(@outputclass= 'backmatter')]"/>
          <xsl:apply-templates select="./topicref[not(@toc = 'no') and not(@processing-role= 'resource-only') and not(@type='glossentry') and @outputclass='frontmatter' or @outputclass= 'backmatter']"/>
        </xsl:element>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>-->

  <!--<xsl:template match="topicref" mode="LeftNavMap">
    <xsl:element name="li">
      -->
  <!-- render link -->
  <!--
      <xsl:element name="a">
        <xsl:attribute name="itemId">
          <xsl:value-of select="@href"/>
        </xsl:attribute>
        <xsl:attribute name="href">
          <xsl:value-of select="concat(./@href, '.xml')"/>
        </xsl:attribute>
        <xsl:attribute name="title">
          <xsl:value-of select="normalize-space(./topicmeta/navtitle)"/>
        </xsl:attribute>
        <xsl:choose>
          <xsl:when test="./topicmeta/linktext != ''">
            <xsl:value-of select="normalize-space(./topicmeta/linktext)"/>
          </xsl:when>
          <xsl:when test="./topicmeta/navtitle != ''">
            <xsl:value-of select="normalize-space(./topicmeta/navtitle)"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="normalize-space(concat(./@href, '.xml'))"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:element>

      -->
  <!-- if children create UL and call same template -->
  <!--
      <xsl:if test="./topicref[not(@toc = 'no') and not(@processing-role= 'resource-only') and not(@type='glossentry') and not(@outputclass='frontmatter') and not(@outputclass= 'backmatter')]">
        <xsl:element name="ul">
          <xsl:apply-templates select="topicref[not(@toc = 'no') and not(@processing-role= 'resource-only') and not(@type='glossentry') and not(@outputclass='frontmatter') and not(@outputclass= 'backmatter')]" mode="LeftNavMap"/>
        </xsl:element>
      </xsl:if>

    </xsl:element>
  </xsl:template>-->

  <!--<xsl:template match="topichead" mode="LeftNavMap">
    <xsl:if test="./topicmeta/navtitle != '' or ./topicmeta/linktext != '' or ./topichead or ./topicref[not(@toc = 'no') and not(@processing-role= 'resource-only') and not(@type='glossentry') and not(@outputclass='frontmatter') and not(@outputclass= 'backmatter')]">
      <xsl:element name="li">        
        <xsl:choose>
          <xsl:when test="normalize-space(@href)">
            <xsl:element name="a">
              <xsl:attribute name="itemId">
                <xsl:value-of select="@href"/>
              </xsl:attribute>
              <xsl:attribute name="href">
                <xsl:value-of select="'#'"/>
              </xsl:attribute>
              <xsl:attribute name="title">
                <xsl:value-of select="normalize-space(./topicmeta/navtitle)"/>
              </xsl:attribute>
              <xsl:choose>
                <xsl:when test="./topichead/linktext != ''">
                  <xsl:value-of select="normalize-space(./topicmeta/linktext)"/>
                </xsl:when>
                <xsl:when test="./topichead/navtitle != ''">
                  <xsl:value-of select="normalize-space(./topicmeta/navtitle)"/>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:value-of select="normalize-space(./topicmeta/navtitle)"/>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:element>
          </xsl:when>
          <xsl:otherwise>
            <xsl:choose>
              <xsl:when test="./topichead/linktext != ''">
                <xsl:value-of select="normalize-space(./topicmeta/linktext)"/>
              </xsl:when>
              <xsl:when test="./topichead/navtitle != ''">
                <xsl:value-of select="normalize-space(./topicmeta/navtitle)"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="normalize-space(./topicmeta/navtitle)"/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:otherwise>
        </xsl:choose>
        <xsl:choose>
          <xsl:when test="./topicref[not(@toc = 'no') and not(@processing-role= 'resource-only') and not(@type='glossentry') and not(@outputclass='frontmatter') and not(@outputclass= 'backmatter')]">
            <xsl:element name="ul">
              <xsl:apply-templates select="topicref[not(@toc = 'no') and not(@processing-role= 'resource-only') and not(@type='glossentry') and not(@outputclass='frontmatter') and not(@outputclass= 'backmatter')]" mode="LeftNavMap"/>
            </xsl:element>
          </xsl:when>

          <xsl:when test="./topichead">
            <xsl:element name="ul">
              <xsl:apply-templates select="topichead" mode="LeftNavMap"/>
            </xsl:element>
          </xsl:when>
        </xsl:choose>

      </xsl:element>
    </xsl:if>
  </xsl:template>-->

  <xsl:template match="topicref" mode="tocwithdesc">
    <xsl:element name="li">
      <xsl:attribute name="class">
        <xsl:value-of select="'link ulchildlink'"/>
      </xsl:attribute>
      <xsl:choose>
        <xsl:when test="@navtitle='Notices'">
          <xsl:text>Notices</xsl:text>
        </xsl:when>
        <xsl:otherwise>
          <xsl:element name="strong">
            <xsl:element name="a">

              <xsl:variable name="path">
                <xsl:choose>
                  <xsl:when test="contains(./@href, '#')">
                    <xsl:value-of select="substring-before(./@href, '#')"/>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:value-of select="./@href"/>
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:variable>

              <xsl:variable name="pageUrl">
                <xsl:choose>
                  <xsl:when test="normalize-space($path) != ''">
                    <xsl:choose>
                      <xsl:when test="starts-with($path, 'x')">
                        <xsl:value-of select="concat($path, '.xml')"/>
                      </xsl:when>
                      <xsl:otherwise>
                        <xsl:value-of select="$path"/>
                      </xsl:otherwise>
                    </xsl:choose>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:value-of select="$ThisPageUrl"/>
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:variable>

              <xsl:variable name="bookmark" select="substring-after(./@href, '#')"></xsl:variable>

              <xsl:variable name="masterBookmark">
                <xsl:choose>
                  <xsl:when test="contains($bookmark, '/')">
                    <xsl:value-of select="substring-after($bookmark, '/')"/>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:value-of select="$bookmark"/>
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:variable>

              <xsl:attribute name="href">
                <xsl:choose>
                  <xsl:when test="$bookmark = ''">
                    <xsl:value-of select="$pageUrl"/>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:value-of select="concat($pageUrl, concat('#', $masterBookmark))"/>
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:attribute>
              <xsl:choose>
                <xsl:when test="./topicmeta/navtitle != ''">
                  <xsl:value-of select="normalize-space(./topicmeta/navtitle)"/>
                </xsl:when>
                <xsl:when test="./topicmeta/linktext != ''">
                  <xsl:value-of select="normalize-space(./topicmeta/linktext)"/>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:choose>
                    <xsl:when test="$bookmark = ''">
                      <xsl:value-of select="$pageUrl"/>
                    </xsl:when>
                    <xsl:otherwise>
                      <xsl:value-of select="concat($pageUrl, concat('#', $masterBookmark))"/>
                    </xsl:otherwise>
                  </xsl:choose>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:element>
          </xsl:element>
          <xsl:element name="br"></xsl:element>
          <xsl:value-of select="normalize-space(./topicmeta/shortdesc)"/>
        </xsl:otherwise>
      </xsl:choose>
      <!--<xsl:if test="topicref[not(@toc = 'no') and not(@processing-role= 'resource-only') and not(@type='glossentry') and not(@outputclass='frontmatter') and not(@outputclass= 'backmatter')]">
        <xsl:element name="ol">
          <xsl:attribute name="class">
            <xsl:value-of select="''"/>
          </xsl:attribute>
          <xsl:apply-templates select="topicref[not(@toc = 'no') and not(@processing-role= 'resource-only') and not(@type='glossentry') and not(@outputclass='frontmatter') and not(@outputclass= 'backmatter')]"/>
        </xsl:element>
      </xsl:if>-->
    </xsl:element>
  </xsl:template>

  <xsl:template match="topicref">
    <xsl:element name="li">
      <xsl:attribute name="class">
        <xsl:value-of select="'topicref'"/>
      </xsl:attribute>
      <xsl:choose>
        <xsl:when test="@navtitle='Notices'">
          <xsl:text>Notices</xsl:text>
        </xsl:when>
        <xsl:otherwise>
          <xsl:element name="a">
            <xsl:variable name="path">
              <xsl:choose>
                <xsl:when test="contains(./@href, '#')">
                  <xsl:value-of select="substring-before(./@href, '#')"/>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:value-of select="./@href"/>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:variable>

            <xsl:variable name="pageUrl">
              <xsl:choose>
                <xsl:when test="normalize-space($path) != ''">
                  <xsl:choose>
                    <xsl:when test="starts-with($path, 'x')">
                      <xsl:value-of select="concat($path, '.xml')"/>
                    </xsl:when>
                    <xsl:otherwise>
                      <xsl:value-of select="$path"/>
                    </xsl:otherwise>
                  </xsl:choose>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:value-of select="$ThisPageUrl"/>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:variable>

            <xsl:variable name="bookmark" select="substring-after(./@href, '#')"></xsl:variable>

            <xsl:variable name="masterBookmark">
              <xsl:choose>
                <xsl:when test="contains($bookmark, '/')">
                  <xsl:value-of select="substring-after($bookmark, '/')"/>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:value-of select="$bookmark"/>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:variable>


            <xsl:attribute name="href">
              <xsl:choose>
                <xsl:when test="$bookmark = ''">
                  <xsl:value-of select="$pageUrl"/>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:value-of select="concat($pageUrl, concat('#', $masterBookmark))"/>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:attribute>
            <xsl:choose>
              <xsl:when test="./topicmeta/navtitle != ''">
                <xsl:value-of select="normalize-space(./topicmeta/navtitle)"/>
              </xsl:when>
              <!--<xsl:when test="./topicmeta/linktext != ''">
            <xsl:value-of select="normalize-space(./topicmeta/linktext)"/>
          </xsl:when>-->
              <xsl:otherwise>
                <xsl:choose>
                  <xsl:when test="$bookmark = ''">
                    <xsl:value-of select="$pageUrl"/>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:value-of select="concat($pageUrl, concat('#', $masterBookmark))"/>
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:element>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:if test="topicref[not(@toc = 'no') and not(@processing-role= 'resource-only') and not(@type='glossentry') and not(@outputclass='frontmatter') and not(@outputclass= 'backmatter')]">
        <xsl:element name="ol">
          <xsl:attribute name="class">
            <xsl:value-of select="''"/>
          </xsl:attribute>
          <xsl:apply-templates select="topicref[not(@toc = 'no') and not(@processing-role= 'resource-only') and not(@type='glossentry') and not(@outputclass='frontmatter') and not(@outputclass= 'backmatter')]"/>
        </xsl:element>
      </xsl:if>
    </xsl:element>
  </xsl:template>

  <!-- DITA Concept Template -->
  <xsl:template match="concept">
    <xsl:apply-templates select="./title"/>
    <xsl:apply-templates select="./shortdesc"/>
    <xsl:element name="hr"></xsl:element>
    <xsl:call-template name="prerequisites"/>
    <xsl:apply-templates select="./conbody"/>
    <xsl:call-template name="footnotes"/>
    <xsl:apply-templates select="./related-links" />
  </xsl:template>

  <!-- DITA Concept Composite Template -->
  <xsl:template match="concept" mode="isComposite">
    <xsl:param name="sectionNumber" />
    <xsl:variable name="localFootnotes" select=".//fn"/>
    <xsl:apply-templates select="./title" mode="sectionTitle">
      <xsl:with-param name="sectionNumber" select="$sectionNumber" />
    </xsl:apply-templates>
    <xsl:apply-templates select="./shortdesc"/>
    <xsl:element name="hr"></xsl:element>
    <xsl:call-template name="prerequisites"/>
    <xsl:apply-templates select="./conbody"/>
    <!--<xsl:call-template name="localFootnotes">
      <xsl:with-param name="localFootnotes" select="$localFootnotes"/>
    </xsl:call-template>-->
    <!--<div class="spacer">
      <xsl:text> </xsl:text>
    </div>-->
    <xsl:apply-templates select="./related-links" />
  </xsl:template>


  <!-- Concept Body Template -->
  <xsl:template match="conbody">
    <div class="body conbody" id="{@id}">
      <xsl:apply-templates />
    </div>
  </xsl:template>

  <!-- DITA Reference Template -->
  <xsl:template match="reference">
    <xsl:apply-templates select="./title"/>
    <xsl:apply-templates select="./shortdesc"/>
    <xsl:element name="hr"></xsl:element>
    <xsl:call-template name="prerequisites"/>
    <xsl:apply-templates select="./refbody"/>
    <xsl:call-template name="footnotes"/>
    <xsl:apply-templates select="./related-links" />
  </xsl:template>

  <!-- DITA Reference Composite Template -->
  <xsl:template match="reference" mode="isComposite">
    <xsl:param name="sectionNumber" />
    <xsl:variable name="localFootnotes" select=".//fn"/>
    <xsl:apply-templates select="./title" mode="sectionTitle">
      <xsl:with-param name="sectionNumber" select="$sectionNumber" />
    </xsl:apply-templates>
    <xsl:apply-templates select="./shortdesc"/>
    <xsl:element name="hr"></xsl:element>
    <xsl:call-template name="prerequisites"/>
    <xsl:apply-templates select="./refbody"/>
    <!--<xsl:call-template name="localFootnotes">
      <xsl:with-param name="localFootnotes" select="$localFootnotes"/>
    </xsl:call-template>-->
    <!--<div class="spacer">
      <xsl:text> </xsl:text>
    </div>-->
    <xsl:apply-templates select="./related-links" />
  </xsl:template>

  <!-- Reference Body Template -->
  <xsl:template match="refbody">
    <div class="body refbody" id="{@id}">
      <xsl:apply-templates />
    </div>
  </xsl:template>

  <!-- DITA Task Template -->
  <xsl:template match="task">
    <xsl:apply-templates select="./title"/>
    <xsl:apply-templates select="./shortdesc"/>
    <xsl:element name="hr"></xsl:element>
    <xsl:call-template name="prerequisites"/>
    <xsl:apply-templates select="./taskbody"/>
    <xsl:variable name="allSectionNodes" select=".//concept | .//reference | .//task | .//topic"/>
    <xsl:for-each select="$allSectionNodes">
      <xsl:apply-templates select="." mode="isComposite"/>
    </xsl:for-each>
    <xsl:call-template name="footnotes"/>
    <xsl:apply-templates select="./related-links" />
  </xsl:template>

  <!-- DITA Task Composite Template -->
  <xsl:template match="task" mode="isComposite">
    <xsl:param name="sectionNumber" />
    <xsl:variable name="localFootnotes" select=".//fn"/>
    <xsl:apply-templates select="./title"/>
    <!--<xsl:apply-templates select="./title" mode="sectionTitle">
      <xsl:with-param name="sectionNumber" select="$sectionNumber" />
    </xsl:apply-templates>-->
    <xsl:apply-templates select="./shortdesc"/>
    <xsl:call-template name="prerequisites"/>
    <xsl:apply-templates select="./taskbody"/>
    <!--<xsl:call-template name="localFootnotes">
      <xsl:with-param name="localFootnotes" select="$localFootnotes"/>
    </xsl:call-template>-->
    <!--<div class="spacer">
      <xsl:text> </xsl:text>
    </div>-->
    <xsl:apply-templates select="./related-links" />
  </xsl:template>

  <!-- DITA Topic Template -->
  <xsl:template match="topic">
    <xsl:apply-templates select="./title"/>
    <xsl:apply-templates select="./shortdesc"/>
    <xsl:element name="hr"></xsl:element>
    <xsl:call-template name="prerequisites"/>
    <xsl:apply-templates select="./body"/>
    <xsl:call-template name="footnotes"/>
    <xsl:apply-templates select="./related-links" />
  </xsl:template>

  <!-- DITA Topic Composite Template -->
  <xsl:template match="topic" mode="isComposite">
    <xsl:param name="sectionNumber" />
    <xsl:variable name="localFootnotes" select=".//fn"/>
    <xsl:apply-templates select="./title" mode="sectionTitle">
      <xsl:with-param name="sectionNumber" select="$sectionNumber" />
    </xsl:apply-templates>
    <xsl:apply-templates select="./shortdesc"/>
    <xsl:element name="hr"></xsl:element>
    <xsl:call-template name="prerequisites"/>
    <xsl:apply-templates select="./body"/>
    <!--<xsl:call-template name="localFootnotes">
      <xsl:with-param name="localFootnotes" select="$localFootnotes"/>
    </xsl:call-template>-->
    <!--<div class="spacer">
      <xsl:text> </xsl:text>
    </div>-->
    <xsl:apply-templates select="./related-links" />
  </xsl:template>

  <!-- DITA Topic Template -->
  <xsl:template match="troubleshooting">
    <xsl:apply-templates select="./title"/>
    <xsl:apply-templates select="./shortdesc"/>
    <xsl:element name="hr"></xsl:element>
    <xsl:call-template name="prerequisites"/>
    <xsl:apply-templates select="./troublebody"/>
    <xsl:call-template name="footnotes"/>
    <xsl:apply-templates select="./related-links" />
  </xsl:template>

  <!-- DITA Topic Composite Template -->
  <xsl:template match="troubleshooting" mode="isComposite">
    <xsl:param name="sectionNumber" />
    <xsl:variable name="localFootnotes" select=".//fn"/>
    <xsl:apply-templates select="./title" mode="sectionTitle">
      <xsl:with-param name="sectionNumber" select="$sectionNumber" />
    </xsl:apply-templates>
    <xsl:apply-templates select="./shortdesc"/>
    <xsl:element name="hr"></xsl:element>
    <xsl:call-template name="prerequisites"/>
    <xsl:apply-templates select="./body"/>
    <!--<xsl:call-template name="localFootnotes">
      <xsl:with-param name="localFootnotes" select="$localFootnotes"/>
    </xsl:call-template>-->
    <!--<div class="spacer">
      <xsl:text> </xsl:text>
    </div>-->
    <xsl:apply-templates select="./related-links" />
  </xsl:template>


  <xsl:template name="prerequisites">
    <xsl:if test=".//link[@importance='required'] and not(.//prereq)">
      <ul style="list-style-type:none;">
        <!--<xsl:apply-templates select=".//link[@importance='required']" />-->
        <xsl:for-each select=".//link[@importance='required']">
          <xsl:variable name="path">
            <xsl:choose>
              <xsl:when test="contains(@href, '#')">
                <xsl:value-of select="substring-before(@href, '#')"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="@href"/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:variable>

          <xsl:variable name="pageUrl">
            <xsl:choose>
              <xsl:when test="normalize-space($path) != ''">
                <xsl:choose>
                  <xsl:when test="starts-with($path, 'x')">
                    <xsl:value-of select="concat($path, '.xml')"/>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:value-of select="$path"/>
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="$ThisPageUrl"/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:variable>

          <xsl:variable name="bookmark" select="substring-after(@href, '#')"></xsl:variable>

          <xsl:variable name="masterBookmark">
            <xsl:choose>
              <xsl:when test="contains($bookmark, '/')">
                <xsl:value-of select="substring-after($bookmark, '/')"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="$bookmark"/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:variable>

          <li class="related-link">
            <xsl:element name="a">
              <xsl:attribute name="href">
                <xsl:choose>
                  <xsl:when test="$bookmark = ''">
                    <xsl:value-of select="$pageUrl"/>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:value-of select="concat($pageUrl, concat('#', $masterBookmark))"/>
                  </xsl:otherwise>

                </xsl:choose>
              </xsl:attribute>
              <xsl:value-of select="linktext"/>
            </xsl:element>
          </li>
        </xsl:for-each>
      </ul>
    </xsl:if>
  </xsl:template>

  <xsl:template name="footnotes">
    <xsl:if test="$allFootnotes">
      <xsl:for-each select="$allFootnotes">
        <xsl:variable name="id" select="@id"/>
        <xsl:variable name="callout">
          <xsl:apply-templates select="." mode="callout"/>
        </xsl:variable>
        <xsl:choose>
          <xsl:when test="not(@id)">
            <div class="footnote" id="footnotes/{$callout}">
              <sup>
                <xsl:element name="a">
                  <xsl:copy-of select="$callout"/>
                </xsl:element>
              </sup>
              <xsl:text> </xsl:text>
              <xsl:apply-templates/>
            </div>
          </xsl:when>
          <xsl:otherwise>
            <!-- Footnote with id does not generate its own callout. -->
            <div class="footnote" name="footnotes/{@id}" id="footnotes/{@id}">
              <sup>
                <xsl:element name="a">
                  <xsl:copy-of select="$callout"/>
                </xsl:element>
              </sup>
              <xsl:text> </xsl:text>
              <xsl:apply-templates/>
            </div>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:for-each>
    </xsl:if>
  </xsl:template>

  <xsl:template name="localFootnotes">
    <xsl:param name="localFootnotes" />
    <xsl:variable name="footnoteTree">
      <xsl:if test="$localFootnotes">
        <xsl:value-of select="ext:node-set($localFootnotes)"/>
      </xsl:if>
    </xsl:variable>
    <xsl:if test="$localFootnotes">
      <xsl:for-each select="$localFootnotes">
        <xsl:variable name="id" select="@id"/>
        <xsl:variable name="callout">
          <xsl:apply-templates select="." mode="callout"/>
        </xsl:variable>
        <xsl:choose>
          <xsl:when test="not(@id)">
            <div class="footnote" id="footnotes/{$callout}">
              <sup>
                <xsl:element name="a">
                  <xsl:copy-of select="$callout"/>
                </xsl:element>
              </sup>
              <xsl:text> </xsl:text>
              <xsl:apply-templates/>
            </div>
          </xsl:when>
          <xsl:otherwise>
            <!-- Footnote with id does not generate its own callout. -->
            <div class="footnote" name="footnotes/{@id}" id="footnotes/{@id}">
              <sup>
                <xsl:element name="a">
                  <xsl:copy-of select="$callout"/>
                </xsl:element>
              </sup>
              <xsl:text> </xsl:text>
              <xsl:apply-templates/>
            </div>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:for-each>
    </xsl:if>
  </xsl:template>


  <!-- bug in import that sets #anchor links to include the root map xID so #anchor becomes xRootId#anchor -->
  <xsl:template match="imagemap">
    <div class="fig imagemap map" id="{@id}">
      <xsl:variable name="altText" select="./image/alt/text()[1]"></xsl:variable>

      <xsl:apply-templates select="./image"/>
      <map name="map_{./image/@id}" id="map_{./image/@id}">
        <xsl:for-each select=".//area">
          <xsl:variable name="path">
            <xsl:choose>
              <xsl:when test="contains(./xref/@href, '#')">
                <xsl:value-of select="substring-before(./xref/@href, '#')"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="./xref/@href"/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:variable>

          <xsl:variable name="pageUrl">
            <xsl:choose>
              <xsl:when test="normalize-space($path) != ''">
                <xsl:choose>
                  <xsl:when test="starts-with($path, 'x')">
                    <xsl:value-of select="concat($path, '.xml')"/>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:value-of select="$path"/>
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="$ThisPageUrl"/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:variable>

          <xsl:variable name="bookmark" select="substring-after(./xref/@href, '#')"></xsl:variable>

          <xsl:variable name="masterBookmark">
            <xsl:choose>
              <xsl:when test="contains($bookmark, '/')">
                <xsl:value-of select="substring-after($bookmark, '/')"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="$bookmark"/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:variable>

          <!--<xsl:variable name="pageLink">
            <xsl:choose>
              <xsl:when test="$bookmark != ''">
                <xsl:value-of select="concat(substring-before($path, '#'), '.xml')"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="concat($path, '.xml')"/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:variable>-->

          <xsl:element name="area">
            <xsl:attribute name="href">
              <xsl:choose>
                <xsl:when test="$bookmark = ''">
                  <xsl:value-of select="$pageUrl"/>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:value-of select="concat($pageUrl, concat('#', $masterBookmark))"/>
                </xsl:otherwise>

              </xsl:choose>
            </xsl:attribute>

            <xsl:attribute name="alt">
              <xsl:value-of select="$altText"/>
            </xsl:attribute>
            <xsl:attribute name="title">
              <xsl:value-of select="$altText"/>
            </xsl:attribute>

            <xsl:attribute name="shape">
              <xsl:value-of select="./shape"/>
            </xsl:attribute>
            <xsl:attribute name="coords">
              <xsl:value-of select="./coords"/>
            </xsl:attribute>

          </xsl:element>
        </xsl:for-each>
      </map>
    </div>
  </xsl:template>


  <!-- Task Body Template -->
  <xsl:template match="taskbody">
    <div class="body taskbody" id="{@id}">
      <xsl:apply-templates />
    </div>
  </xsl:template>

  <!-- Task Body Template -->
  <xsl:template match="body">
    <div class="body taskbody" id="{@id}">
      <xsl:apply-templates />
    </div>
  </xsl:template>

  <!-- Trouble Body Template -->
  <xsl:template match="troublebody">
    <div class="body troublebody" id="{@id}">
      <xsl:apply-templates />
    </div>
  </xsl:template>

  <xsl:template match="condition">
    <div class="section condition" id="{@id}">
      <xsl:apply-templates />
    </div>
  </xsl:template>

  <xsl:template match="sectiondiv">
    <!--<dl class="dl" id="{@id}">
      <dt class="dt dlterm">
        <xsl:value-of select="./div/b"/>
      </dt>
      <dd class="dd">
        <xsl:value-of select="./p"/>
      </dd>
    </dl>-->
    <div class="sectiondiv">
      <xsl:apply-templates />
    </div>
  </xsl:template>

  <xsl:template match="condition/title">
    <xsl:if test="normalize-space(.)">
      <h2 class="title sectiontitle">
        <xsl:apply-templates select="node()[string-length() != 0]"/>
      </h2>
    </xsl:if>
  </xsl:template>

  <xsl:template match="troubleSolution">
    <div class="bodydiv troubleSolution" id="{@id}">
      <xsl:apply-templates />
    </div>
  </xsl:template>

  <xsl:template match="cause">
    <div class="section cause" id="{@id}">
      <xsl:apply-templates />
    </div>
  </xsl:template>

  <xsl:template match="cause/title">
    <xsl:if test="normalize-space(.)">
      <h2 class="title sectiontitle">
        <xsl:apply-templates select="node()[string-length() != 0]"/>
      </h2>
    </xsl:if>
  </xsl:template>

  <xsl:template match="remedy">
    <div class="section remedy" id="{@id}">
      <xsl:apply-templates />
    </div>
  </xsl:template>

  <xsl:template match="remedy/title">
    <xsl:if test="normalize-space(.)">
      <h2 class="title sectiontitle">
        <xsl:apply-templates select="node()[string-length() != 0]"/>
      </h2>
    </xsl:if>
  </xsl:template>

  <xsl:template match="context">
    <div class="section context" id="{@id}">
      <xsl:apply-templates />
    </div>
  </xsl:template>

  <xsl:template match="prereq">
    <div class="prereq margin-full" id="{@id}">
      <strong>Prerequisites: </strong>
      <xsl:if test="//link[@importance='required']">
        <ul style="list-style-type:none;">
          <xsl:for-each select="//link[@importance='required']">
            <xsl:variable name="path">
              <xsl:choose>
                <xsl:when test="contains(@href, '#')">
                  <xsl:value-of select="substring-before(@href, '#')"/>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:value-of select="@href"/>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:variable>

            <xsl:variable name="pageUrl">
              <xsl:choose>
                <xsl:when test="normalize-space($path) != ''">
                  <xsl:choose>
                    <xsl:when test="starts-with($path, 'x')">
                      <xsl:value-of select="concat($path, '.xml')"/>
                    </xsl:when>
                    <xsl:otherwise>
                      <xsl:value-of select="$path"/>
                    </xsl:otherwise>
                  </xsl:choose>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:value-of select="$ThisPageUrl"/>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:variable>

            <xsl:variable name="bookmark" select="substring-after(@href, '#')"></xsl:variable>

            <xsl:variable name="masterBookmark">
              <xsl:choose>
                <xsl:when test="contains($bookmark, '/')">
                  <xsl:value-of select="substring-after($bookmark, '/')"/>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:value-of select="$bookmark"/>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:variable>

            <li class="related-link">
              <xsl:element name="a">
                <xsl:attribute name="href">
                  <xsl:choose>
                    <xsl:when test="$bookmark = ''">
                      <xsl:value-of select="$pageUrl"/>
                    </xsl:when>
                    <xsl:otherwise>
                      <xsl:value-of select="concat($pageUrl, concat('#', $masterBookmark))"/>
                    </xsl:otherwise>

                  </xsl:choose>
                </xsl:attribute>
                <xsl:value-of select="linktext"/>
              </xsl:element>
            </li>
          </xsl:for-each>
        </ul>
      </xsl:if>
      <xsl:apply-templates />
    </div>
    <hr/>
  </xsl:template>

  <xsl:template match="postreq">
    <p class="postreq">
      <strong>Next Steps: </strong>
      <xsl:apply-templates/>
    </p>
  </xsl:template>

  <xsl:template match="text()[normalize-space()][1]">
    <xsl:if test=". != ''">
      <xsl:value-of select="."/>
    </xsl:if>
  </xsl:template>


  <xsl:template match="xmlelement">
    <xsl:if test="node()[string-length() != 0]">
      <code class="keyword markupname xmlelement">
        <xsl:text>&lt;</xsl:text>
        <xsl:apply-templates select="node()" />
        <xsl:text>&gt;</xsl:text>
      </code>
    </xsl:if>
  </xsl:template>

  <xsl:template match="xmlatt">
    <xsl:if test="node()[string-length() != 0]">
      <code class="keyword xmlatt">
        <xsl:text>@</xsl:text>
        <xsl:apply-templates select="node()" />
      </code>
    </xsl:if>
  </xsl:template>

  <xsl:template match="xref[not(starts-with(@href, '#'))]">
    <xsl:text> </xsl:text>
    <xsl:element name="a">
      <xsl:variable name="path">
        <xsl:choose>
          <xsl:when test="contains(@href, '#')">
            <xsl:value-of select="substring-before(@href, '#')"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="@href"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>

      <xsl:variable name="pageUrl">
        <xsl:choose>
          <xsl:when test="normalize-space($path) != ''">
            <xsl:choose>
              <xsl:when test="starts-with($path, 'x')">
                <xsl:value-of select="concat($path, '.xml')"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="$path"/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="$ThisPageUrl"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>

      <xsl:variable name="bookmark" select="substring-after(@href, '#')"></xsl:variable>

      <xsl:variable name="masterBookmark">
        <xsl:choose>
          <xsl:when test="contains($bookmark, '/')">
            <xsl:value-of select="substring-after($bookmark, '/')"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="$bookmark"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>

      <xsl:attribute name="data-scope">
        <xsl:value-of select="@scope"/>
      </xsl:attribute>

      <xsl:attribute name="target">
        <xsl:choose>
          <xsl:when test="@scope = 'external'">
            <xsl:value-of select="string('_blank')"/>
          </xsl:when>
          <xsl:otherwise>
            <!--otherwise leave empty-->
          </xsl:otherwise>
        </xsl:choose>
      </xsl:attribute>

      <xsl:attribute name="href">
        <xsl:choose>
          <xsl:when test="@format = 'email'">
            <xsl:text>mailto:</xsl:text>
            <xsl:value-of select="." />
          </xsl:when>
          <xsl:when test="@scope = 'external'">
            <xsl:choose>
              <xsl:when test="starts-with(./@href, 'mailto:')">
                <xsl:value-of select="./@href"/>
              </xsl:when>
              <xsl:when test="starts-with(./@href, 'http')">
                <xsl:value-of select="./@href"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="concat('https://', ./@href)"/>
              </xsl:otherwise>
            </xsl:choose>

          </xsl:when>
          <xsl:otherwise>
            <xsl:choose>
              <xsl:when test="$bookmark = ''">
                <xsl:value-of select="$pageUrl"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="concat($pageUrl, concat('#', $masterBookmark))"/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:attribute>
      <xsl:attribute name="target">
        <xsl:choose>
          <xsl:when test="@scope = 'external'">
            <xsl:value-of select="string('_blank')"/>
          </xsl:when>
          <xsl:otherwise>
            <!--otherwise leave empty-->
          </xsl:otherwise>
        </xsl:choose>
      </xsl:attribute>
      <xsl:choose>
        <xsl:when test=". != ''">
          <xsl:value-of select="text()[normalize-space()]"/>
        </xsl:when>
        <xsl:when test="@scope = 'external'">
          <xsl:value-of select="./@href"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:choose>
            <xsl:when test="$bookmark = ''">
              <xsl:value-of select="$pageUrl"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="concat($pageUrl, concat('#', $masterBookmark))"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:element>
  </xsl:template>

  <xsl:template match="div[@outputclass='prereq margin-full']">
    <div class="prereq margin-full">
      <xsl:apply-templates/>
    <hr/>
    </div>
  </xsl:template>

  <xsl:template match="xref[@type='fn']">
    <xsl:if test ="normalize-space(@href)">
      <sup>
        <xsl:text> </xsl:text>
        <xsl:element name="a">
          <xsl:attribute name="href">
            <xsl:choose>
              <xsl:when test="starts-with(@href, '#')">
                <xsl:choose>
                  <xsl:when test="contains(@href, '/')">
                    <xsl:value-of select="concat($ThisPageUrl, concat('#footnotes/', substring-after(@href, '/')))"/>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:value-of select="concat($ThisPageUrl, concat('#footnotes/', substring-after(@href, '#')))"/>
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="@href"/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:attribute>
          <xsl:apply-templates/>
        </xsl:element>
      </sup>
    </xsl:if>
  </xsl:template>

  <xsl:template match="stepsection">
    <div class="li stepsection margin-full" id="{@id}">
      <xsl:apply-templates />
    </div>
  </xsl:template>

  <xsl:template match="remedy/steps">
    <div>
      <xsl:apply-templates select="./stepsection"/>
      <ol class="ol steps">
        <xsl:for-each select="step">
          <li class="li step stepexpanded">
            <xsl:if test="@importance = 'optional'">
              <strong>Optional: </strong>
            </xsl:if>
            <xsl:if test="@importance = 'required'">
              <strong>Required: </strong>
            </xsl:if>
            <xsl:apply-templates select="node()"/>
          </li>
        </xsl:for-each>
      </ol>
    </div>
  </xsl:template>

  <xsl:template match="steps">
    <xsl:apply-templates select="./stepsection"/>
    <ol class="ol steps">
      <xsl:for-each select="step">
        <li class="li step stepexpanded">
          <xsl:if test="@importance = 'optional'">
            <strong>Optional: </strong>
          </xsl:if>
          <xsl:if test="@importance = 'required'">
            <strong>Required: </strong>
          </xsl:if>
          <xsl:apply-templates select="node()"/>
        </li>
      </xsl:for-each>
    </ol>
  </xsl:template>

  <xsl:template match="steps-unordered">
    <xsl:apply-templates select="./stepsection"/>
    <ul class="ul steps">
      <xsl:for-each select="step">
        <li class="li step stepexpanded">
          <xsl:if test="@importance = 'optional'">
            <strong>Optional: </strong>
          </xsl:if>
          <xsl:if test="@importance = 'required'">
            <strong>Required: </strong>
          </xsl:if>
          <xsl:apply-templates select="node()"/>
        </li>
      </xsl:for-each>
    </ul>
  </xsl:template>

  <xsl:template match="steps-informal">
    <xsl:apply-templates />
  </xsl:template>

  <xsl:template match="substeps">
    <ol class="ol substeps">
      <xsl:for-each select="substep">
        <li class="li">
          <xsl:apply-templates select="node()"/>
        </li>
      </xsl:for-each>
    </ol>
  </xsl:template>

  <xsl:template match="result">
    <xsl:if test="node()[string-length() != 0]">
      <p class="p result">
        <xsl:apply-templates select="node()[string-length() != 0]"/>
      </p>
    </xsl:if>
  </xsl:template>

  <xsl:template match="stepresult">
    <div class="itemgroup stepresult" id="{@id}">
      <xsl:apply-templates />
    </div>
  </xsl:template>

  <!--TODO: How should Keyword DITA element styling look? Do these need to Link? -->
  <xsl:template match="keyword">
    <span class="keyword">
      <xsl:apply-templates />
    </span>
  </xsl:template>

  <!-- CMD example ot passing node() set vs select -->
  <!--<xsl:template match="cmd">
    <xsl:apply-templates select="node()"/>
  </xsl:template>-->

  <!-- ui-domain.ent domain: uicontrol | wintitle | menucascade | shortcut -->

  <xsl:template match="menucascade">
    <span class="menucascade">
      <xsl:for-each select=".//uicontrol">
        <span class="uicontrol">
          <xsl:apply-templates/>
        </span>
        <xsl:if test="position() != last()">
          <xsl:text> &gt; </xsl:text>
        </xsl:if>
      </xsl:for-each>
    </span>
  </xsl:template>

  <xsl:template match="uicontrol">
    <span class="ph uicontrol">
      <xsl:apply-templates />
    </span>
  </xsl:template>
  <xsl:template match="wintitle">
    <span class="keyword wintitle">
      <xsl:apply-templates />
    </span>
  </xsl:template>
  <xsl:template match="shortcut">
    <span class="shortcut">
      <xsl:apply-templates />
    </span>
  </xsl:template>
  <xsl:template match="cmd">
    <span class="ph cmd">
      <xsl:apply-templates />
    </span>
  </xsl:template>

  <!-- programming-domain.ent domain: codeblock | codeph | var | kwd | synph | oper | delim | sep | repsep |
                                    option | parmname | apiname-->

  <xsl:template match="codeblock">
    <xsl:if test="node()[string-length() != 0]">
      <pre>
        <code class="codeblock">
          <xsl:apply-templates select="node()" />
        </code>
      </pre>
    </xsl:if>
  </xsl:template>

  <xsl:template match="codeph">
    <xsl:if test="node()[string-length() != 0]">
      <code class="ph codeph">
        <xsl:apply-templates select="node()" />
      </code>
    </xsl:if>
  </xsl:template>

  <xsl:template match="kwd">
    <xsl:if test="node()[string-length() != 0]">
      <span class="kwd">
        <xsl:apply-templates select="node()" />
      </span>
    </xsl:if>
  </xsl:template>
  <xsl:template match="var">
    <xsl:if test="node()[string-length() != 0]">
      <span class="var">
        <xsl:apply-templates select="node()" />
      </span>
    </xsl:if>
  </xsl:template>
  <xsl:template match="synph">
    <xsl:if test="node()[string-length() != 0]">
      <span class="synph">
        <xsl:apply-templates select="node()" />
      </span>
    </xsl:if>
  </xsl:template>
  <xsl:template match="oper">
    <xsl:if test="node()[string-length() != 0]">
      <span class="oper">
        <xsl:apply-templates select="node()" />
      </span>
    </xsl:if>
  </xsl:template>
  <xsl:template match="delim">
    <xsl:if test="node()[string-length() != 0]">
      <span class="delim">
        <xsl:apply-templates select="node()" />
      </span>
    </xsl:if>
  </xsl:template>
  <xsl:template match="sep">
    <xsl:if test="node()[string-length() != 0]">
      <span class="sep">
        <xsl:apply-templates select="node()" />
      </span>
    </xsl:if>
  </xsl:template>
  <xsl:template match="repsep">
    <xsl:if test="node()[string-length() != 0]">
      <span class="repsep">
        <xsl:apply-templates select="node()" />
      </span>
    </xsl:if>
  </xsl:template>
  <xsl:template match="option">
    <xsl:if test="node()[string-length() != 0]">
      <span class="option">
        <xsl:apply-templates select="node()" />
      </span>
    </xsl:if>
  </xsl:template>
  <xsl:template match="parmname">
    <xsl:if test="node()[string-length() != 0]">
      <span class="parmname">
        <xsl:apply-templates select="node()" />
      </span>
    </xsl:if>
  </xsl:template>
  <xsl:template match="apiname">
    <xsl:if test="node()[string-length() != 0]">
      <span class="apiname">
        <xsl:apply-templates select="node()" />
      </span>
    </xsl:if>
  </xsl:template>
  <xsl:template match="varname">
    <xsl:if test="node()[string-length() != 0]">
      <span class="varname">
        <xsl:apply-templates select="node()" />
      </span>
    </xsl:if>
  </xsl:template>

  <xsl:template match="userinput">
    <xsl:if test="node()[string-length() != 0]">
      <span class="userinput">
        <xsl:value-of select="node()"/>
      </span>
    </xsl:if>
  </xsl:template>
  <xsl:template match="systemoutput">
    <xsl:if test="node()[string-length() != 0]">
      <span class="systemoutput">
        <xsl:value-of select="node()"/>
      </span>
    </xsl:if>
  </xsl:template>
  <xsl:template match="cmdname">
    <xsl:if test="node()[string-length() != 0]">
      <span class="cmdname">
        <xsl:apply-templates select="node()" />
      </span>
    </xsl:if>
  </xsl:template>

  <xsl:template match="filepath">
    <xsl:if test="node()[string-length() != 0]">
      <span class="filepath">
        <xsl:apply-templates select="node()" />
      </span>
    </xsl:if>
  </xsl:template>


  <!--<xsl:template match="codeblock">
    <pre>  
        <xsl:value-of select="node()"/>
    </pre>
  </xsl:template>-->

  <!--TODO: How should Cite DITA element styling look? Do these need to Link? -->
  <xsl:template match="cite">
    <em>
      <xsl:apply-templates />
    </em>
  </xsl:template>

  <!--<xsl:template match="info">
    <h3>Information</h3>
    <p>
      <xsl:apply-templates select="node()"/>
    </p>
  </xsl:template>-->

  <xsl:template match="info">
    <div class="itemgroup info" id="{@id}">
      <xsl:apply-templates />
    </div>
  </xsl:template>

  <xsl:template match="choices">
    <ul>
      <xsl:for-each select="choice">
        <li>
          <xsl:apply-templates select="node()"/>
        </li>
      </xsl:for-each>
    </ul>
  </xsl:template>

  <xsl:template match="learningAssessment">
    <xsl:apply-templates select="./title"/>
    <xsl:element name="hr"></xsl:element>
    <xsl:apply-templates select="learningAssessmentbody" />
  </xsl:template>

  <xsl:template match="learningAssessment/title">
    <h1>
      <xsl:apply-templates />
    </h1>
  </xsl:template>

  <xsl:template match="learningAssessmentbody">
    <xsl:apply-templates select="./lcIntro/title"/>
    <xsl:apply-templates select="./lcInteraction"/>
  </xsl:template>

  <xsl:template match="lcIntro/title">
    <h2>
      <xsl:apply-templates />
    </h2>
  </xsl:template>

  <xsl:template match="lcDuration">
    <!-- -->
  </xsl:template>

  <xsl:template match="lcInteraction">
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="lcSingleSelect">
    <form>
      <span class="question-header">
        <xsl:apply-templates select="lcQuestion"/>
      </span>
      <xsl:apply-templates select="lcAnswerOptionGroup" />
    </form>
  </xsl:template>

  <xsl:template match="lcAnswerOptionGroup">
    <xsl:apply-templates />
  </xsl:template>

  <xsl:template match="lcAnswerOption">
    <label style="display:block;">
      <input type="radio" onclick="return lcSingleSelect(event);">
        <xsl:attribute name="rel">
          <xsl:value-of select="@id"/>
        </xsl:attribute>
        <xsl:attribute name="name">question</xsl:attribute>
        <xsl:choose>
          <xsl:when test="./lcCorrectResponse">
            <xsl:attribute name="value">1</xsl:attribute>
          </xsl:when>
          <xsl:otherwise>
            <xsl:attribute name="value">0</xsl:attribute>
          </xsl:otherwise>
        </xsl:choose>
        <xsl:apply-templates select="./lcAnswerContent"/>
      </input>
    </label>
    <xsl:choose>
      <xsl:when test="./lcCorrectResponse">
        <div class="validation" style="display:none;">
          <xsl:attribute name="id">
            <xsl:value-of select="@id"/>
          </xsl:attribute>
          <span class="correct" style="color:green;font-style:italic;">Correct!</span>
        </div>
      </xsl:when>
      <xsl:otherwise>
        <div class="validation" style="display:none;">
          <xsl:attribute name="id">
            <xsl:value-of select="@id"/>
          </xsl:attribute>
          <span class="incorrect" style="color:red;font-style:italic;">Incorrect!</span>
        </div>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="learningOverview">
    <xsl:apply-templates select="./title"/>
    <xsl:element name="hr"></xsl:element>
    <xsl:apply-templates select="learningOverviewbody" />
  </xsl:template>

  <xsl:template match="learningOverview/title">
    <header>
      <h1>
        <xsl:apply-templates />
      </h1>
    </header>
  </xsl:template>

  <xsl:template match="learningOverviewbody">
    <xsl:apply-templates select="lcObjectives"/>
  </xsl:template>

  <xsl:template match="lcObjectives">
    <xsl:apply-templates select="./title"/>
    <xsl:apply-templates select="lcObjectivesGroup"/>
  </xsl:template>

  <xsl:template match="lcObjectivesGroup">
    <ul class="hero-list">
      <xsl:for-each select="lcObjective">
        <li>
          <xsl:apply-templates />
        </li>
      </xsl:for-each>
    </ul>
  </xsl:template>

  <xsl:template match="learningSummary">
    <xsl:apply-templates select="./title"/>
    <xsl:element name="hr"></xsl:element>
    <xsl:apply-templates select="learningSummarybody"/>
  </xsl:template>

  <xsl:template match="learningSummarybody">
    <xsl:apply-templates select="lcObjectives"/>
  </xsl:template>

  <!-- Specific Node Templates -->
  <xsl:template match="title">
    <xsl:if test="normalize-space(.)">
      <h2>
        <xsl:apply-templates />
      </h2>
    </xsl:if>
  </xsl:template>

  <!-- TODO: These title matches will probably need adjustment -->
  <xsl:template match="topic/topic/title">
    <xsl:if test="normalize-space(.)">
      <h2 class="topictitle2">
        <xsl:value-of select="."/>
      </h2>
    </xsl:if>
  </xsl:template>

  <xsl:template match="topic/topic/*/topic/title">
    <xsl:if test="normalize-space(.)">
      <h3 class="topictitle3">
        <xsl:value-of select="."/>
      </h3>
    </xsl:if>
  </xsl:template>

  <xsl:template match="topic/topic/*/topic/topic/title">
    <xsl:if test="normalize-space(.)">
      <h4 class="topictitle4">
        <xsl:value-of select="."/>
      </h4>
    </xsl:if>
  </xsl:template>

  <xsl:template match="title" mode="sectionTitle">
    <xsl:param name="sectionNumber" />
    <h2 class="scroll-to">
      <a class="go-to-top" href="#top">
        <i class="material-icons">keyboard_arrow_upward</i>
      </a>
      <!--<xsl:if test="$sectionNumber">
        <xsl:text>Section </xsl:text><xsl:value-of select="$sectionNumber"/><xsl:text>: </xsl:text>
      </xsl:if>-->
      <xsl:apply-templates/>
    </h2>
  </xsl:template>

  <xsl:template match="example/title">
    <xsl:if test="normalize-space(.)">
      <h2 class="topictitle2">
        <xsl:apply-templates />
      </h2>
    </xsl:if>
  </xsl:template>

  <xsl:template match="term">
    <xsl:choose>
      <xsl:when test="text and not(text())">
        <xsl:call-template name="term-description"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:element name="span">
          <xsl:attribute name="Title">
            <xsl:value-of select="./text/text()"/>
          </xsl:attribute>
          <xsl:attribute name="class">
            <xsl:text>term</xsl:text>
          </xsl:attribute>
          <xsl:text> </xsl:text>
          <xsl:value-of select="text()"/>
        </xsl:element>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="term-description">
    <xsl:value-of select="./text/text()"/>
  </xsl:template>


  <xsl:template match="ul">
    <ul class="ul" id="{@id}">
      <xsl:apply-templates/>
    </ul>
  </xsl:template>

  <xsl:template match="li">
    <li class="li" id="{@id}">
      <xsl:apply-templates/>
    </li>
  </xsl:template>
  <xsl:template match="ol">
    <ol class="ol" id="{@id}">
      <xsl:apply-templates/>
    </ol>
  </xsl:template>

  <xsl:template match="lcObjectives/title">
    <h2>
      <xsl:apply-templates/>
    </h2>
  </xsl:template>

  <xsl:template match="shortdesc">
    <p class="large">
      <xsl:apply-templates/>
    </p>
  </xsl:template>

  <xsl:template match="fig">
    <xsl:variable name="currentFigure" select="."/>
    <figure class="fig">
      <xsl:choose>
        <xsl:when test="p/image">
          <xsl:apply-templates select="p/image"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates select="image"/>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:if test="./title != ''">
        <figcaption class="figcap">
          <strong>
            <em>
              <!--<xsl:for-each select="$allFigures">
              <xsl:if test="generate-id(./title) = generate-id($currentFigure/title)">
                <xsl:text>Figure: </xsl:text>
                <xsl:value-of select="position()"/>
                <xsl:text>: </xsl:text>
              </xsl:if>
            </xsl:for-each>-->
              <xsl:apply-templates select="./title"/>
            </em>
          </strong>
        </figcaption>
        <!--<xsl:apply-templates select="./title"/>-->
      </xsl:if>
    </figure>
  </xsl:template>

  <xsl:template match="fig/title">
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="section">
    <div class="section" id="{@id}">
      <xsl:apply-templates select="node()" />
    </div>
  </xsl:template>

  <xsl:template match="section/title">
    <xsl:if test="node()[string-length() != 0]">
      <h2 class="title sectiontitle">
        <xsl:apply-templates select="node()[string-length() != 0]"/>
      </h2>
    </xsl:if>
  </xsl:template>

  <xsl:template match="draft-comment">

  </xsl:template>

  <xsl:template match="p">
    <p class="p">
      <xsl:apply-templates select="node()"/>
    </p>
  </xsl:template>

  <!-- general DITA tag templates and some client specific ones - should be refactored -->
  <!--<xsl:template match="note">
    <aside>
      Note:
      <xsl:apply-templates select="node()"/>
    </aside>
  </xsl:template>-->

  <!--<xsl:template match="note">
    <div class="note">
      <span class="notetitle">Note:</span>
      <xsl:value-of select="."/>
    </div>
  </xsl:template>-->

  <!--<xsl:template match="lines">
    <span class="lines">
      <xsl:apply-templates/>
    </span>
  </xsl:template>-->
  <xsl:template match="lines">
    <p class="lines">
      <xsl:call-template name="replace">
        <xsl:with-param name="string" select="."/>
      </xsl:call-template>
    </p>
  </xsl:template>

  <xsl:template name="replace">
    <xsl:param name="string"/>
    <xsl:choose>
      <xsl:when test="contains($string,'&#10;')">
        <xsl:value-of select="substring-before($string,'&#10;')"/>
        <br/>
        <xsl:call-template name="replace">
          <xsl:with-param name="string" select="substring-after($string,'&#10;')"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$string"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- Notes - Google Materials Icon styling -->

  <!--<xsl:template match="note">
    <p class="small-text">
      <xsl:choose>
        <xsl:when test="@type = 'important'">
          <strong>Important: </strong>
        </xsl:when>
        <xsl:otherwise>
          <strong>Note: </strong>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates/>
    </p>
  </xsl:template>-->

  <xsl:template match="hazardstatement">
    <xsl:param name="type">
      <xsl:choose>
        <xsl:when test="@type != ''">
          <xsl:value-of select="@type"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="' '"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:param>
    <xsl:param name="title">
      <xsl:value-of select="concat(translate(substring($type,1,1), $vLower, $vUpper), substring($type, 2), substring(' ', 1 div not(position()=last())))"/>
    </xsl:param>
    <div class="note hazardstatement {@type} note_{@type}">
      <table role="presentation" border="1" class="note hazardstatement">

        <xsl:choose>
          <xsl:when test="@type = 'warning'">
            <tr>
              <th colspan="2" class="hazardstatement--warning">
                <svg xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:cc="http://creativecommons.org/ns#" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:svg="http://www.w3.org/2000/svg" xmlns="http://www.w3.org/2000/svg" class="hazardsymbol" version="1.1" height="1em" viewBox="0 0 600 525">
                  <metadata>
                    <rdf:RDF>
                      <cc:Work rdf:about="">
                        <dc:format>image/svg+xml</dc:format>
                        <dc:type rdf:resource="http://purl.org/dc/dcmitype/StillImage"></dc:type>
                        <dc:title></dc:title>
                      </cc:Work>
                    </rdf:RDF>
                  </metadata>
                  <defs>
                    <path d="M 2.8117,-1.046 A 3,3 0 0 1 0.5,2.958 V 4.5119 A 10.5,10.5 0 0 1 2,25.3078 v 0.5583 A 15,15 0 0 0 14.7975,8.5433 15,15 0 0 0 23.4007,-11.201 l -0.4835,0.2792 A 10.5,10.5 0 0 1 4.1574,-1.8229 z m 3.4148,8.871 a 10,10 0 0 1 -12.453,0 9.5,9.5 0 0 0 -2.1756,2.7417 13.5,13.5 0 0 0 16.8042,0 A 10,10 0 0 0 6.2265,7.825 z" transform="matrix(10,0,0,-10,260,260)"></path>
                  </defs>
                  <path d="M 597.6,499.6 313.8,8 C 310.9,3 305.6,0 299.9,0 294.2,0 288.9,3.1 286,8 L 2.2,499.6 c -2.9,5 -2.9,11.1 0,16 2.9,5 8.2,8 13.9,8 h 567.6 c 5.7,0 11,-3.1 13.9,-8 2.9,-5 2.9,-11.1 0,-16 z"></path>
                  <polygon points="43.875,491.5 299.875,48.2 555.875,491.5 " transform="matrix(1,0,0,0.99591458,0.125,2.0332437)" style="fill:#f6bd16;fill-opacity:1;stroke:none;overflow:visible"></polygon>
                  <path d="m -384.00937,417.52725 a 38.151581,36.156727 0 1 1 -76.30316,0 38.151581,36.156727 0 1 1 76.30316,0 z" transform="matrix(0.99319888,0,0,1.0479962,719.28979,-2.9357862)" style="fill:#000000;fill-opacity:1;stroke:#000000;stroke-width:0.62514842;stroke-linecap:square;stroke-miterlimit:4;stroke-opacity:0.4;stroke-dasharray:none;stroke-dashoffset:0"></path>
                  <path d="m 300,168.60074 c -20.64745,0 -37.26716,16.97292 -37.26716,38.05658 l 11.01897,133.31318 c 2.10449,17.24457 3.90184,27.0149 11.01898,31.60966 4.64712,2.1172 9.79468,3.32214 15.22921,3.32214 5.40832,0 10.53383,-1.1913 15.16343,-3.28925 7.15697,-4.58178 8.97556,-14.35941 11.08476,-31.64255 l 11.01898,-133.31318 c 0,-21.08366 -16.61973,-38.05658 -37.26717,-38.05658 z" style="fill:#000000;fill-opacity:1;stroke:#000000;stroke-width:0.88582677;stroke-linecap:square;stroke-miterlimit:4;stroke-opacity:1;stroke-dashoffset:0"></path>
                </svg> WARNING
              </th>
            </tr>
          </xsl:when>
          <xsl:when test="@type = 'caution'">
            <tr>
              <th colspan="2" class="hazardstatement--caution">
                <svg xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:cc="http://creativecommons.org/ns#" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:svg="http://www.w3.org/2000/svg" xmlns="http://www.w3.org/2000/svg" class="hazardsymbol" version="1.1" height="1em" viewBox="0 0 600 525">
                  <metadata>

                    <rdf:RDF>

                      <cc:Work rdf:about="">

                        <dc:format>image/svg+xml</dc:format>

                        <dc:type rdf:resource="http://purl.org/dc/dcmitype/StillImage"></dc:type>

                        <dc:title></dc:title>
                      </cc:Work>
                    </rdf:RDF>
                  </metadata>
                  <defs>

                    <path d="M 2.8117,-1.046 A 3,3 0 0 1 0.5,2.958 V 4.5119 A 10.5,10.5 0 0 1 2,25.3078 v 0.5583 A 15,15 0 0 0 14.7975,8.5433 15,15 0 0 0 23.4007,-11.201 l -0.4835,0.2792 A 10.5,10.5 0 0 1 4.1574,-1.8229 z m 3.4148,8.871 a 10,10 0 0 1 -12.453,0 9.5,9.5 0 0 0 -2.1756,2.7417 13.5,13.5 0 0 0 16.8042,0 A 10,10 0 0 0 6.2265,7.825 z" transform="matrix(10,0,0,-10,260,260)"></path>
                  </defs>
                  <path d="M 597.6,499.6 313.8,8 C 310.9,3 305.6,0 299.9,0 294.2,0 288.9,3.1 286,8 L 2.2,499.6 c -2.9,5 -2.9,11.1 0,16 2.9,5 8.2,8 13.9,8 h 567.6 c 5.7,0 11,-3.1 13.9,-8 2.9,-5 2.9,-11.1 0,-16 z"></path>
                  <polygon points="43.875,491.5 299.875,48.2 555.875,491.5 " transform="matrix(1,0,0,0.99591458,0.125,2.0332437)" style="fill:#f6bd16;fill-opacity:1;stroke:none;overflow:visible"></polygon>
                  <path d="m -384.00937,417.52725 a 38.151581,36.156727 0 1 1 -76.30316,0 38.151581,36.156727 0 1 1 76.30316,0 z" transform="matrix(0.99319888,0,0,1.0479962,719.28979,-2.9357862)" style="fill:#000000;fill-opacity:1;stroke:#000000;stroke-width:0.62514842;stroke-linecap:square;stroke-miterlimit:4;stroke-opacity:0.4;stroke-dasharray:none;stroke-dashoffset:0"></path>
                  <path d="m 300,168.60074 c -20.64745,0 -37.26716,16.97292 -37.26716,38.05658 l 11.01897,133.31318 c 2.10449,17.24457 3.90184,27.0149 11.01898,31.60966 4.64712,2.1172 9.79468,3.32214 15.22921,3.32214 5.40832,0 10.53383,-1.1913 15.16343,-3.28925 7.15697,-4.58178 8.97556,-14.35941 11.08476,-31.64255 l 11.01898,-133.31318 c 0,-21.08366 -16.61973,-38.05658 -37.26717,-38.05658 z" style="fill:#000000;fill-opacity:1;stroke:#000000;stroke-width:0.88582677;stroke-linecap:square;stroke-miterlimit:4;stroke-opacity:1;stroke-dashoffset:0"></path>
                </svg> Caution
              </th>
            </tr>
          </xsl:when>
        </xsl:choose>
        <tr>
          <td class="hazard__icon__col">
            <xsl:call-template name="getHazardIcon">
              <xsl:with-param name="type" select="$type"/>
            </xsl:call-template>
          </td>
          <td class="hazard__message__col">
            <div class="messagepanel">
              <xsl:apply-templates/>
            </div>
          </td>
        </tr>
      </table>
    </div>
  </xsl:template>

  <xsl:template match="messagepanel">
    <ul class="ul messagepanel">
      <xsl:apply-templates/>
    </ul>
  </xsl:template>

  <xsl:template match="typeofhazard">
    <xsl:if test="node()[string-length() != 0]">
      <div class="typeofhazard">
        <xsl:apply-templates/>
      </div>
    </xsl:if>
  </xsl:template>

  <xsl:template match="howtoavoid">
    <xsl:if test="node()[string-length() != 0]">
      <div class="howtoavoid">
        <xsl:apply-templates/>
      </div>
    </xsl:if>
  </xsl:template>

  <!--<xsl:template match="note">
    <xsl:param name="type">
      <xsl:choose>
        <xsl:when test="@type != ''">
          <xsl:value-of select="@type"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="' '"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:param>
    <xsl:param name="title">
      <xsl:value-of select="concat(translate(substring($type,1,1), $vLower, $vUpper), substring($type, 2), substring(' ', 1 div not(position()=last())))"/>
    </xsl:param>
    <div class="note {@type} note_{@type}">
      <table class="note__table">
        <tr>
          <td class="note__icon__col">
            <xsl:call-template name="getNoteIcon">
              <xsl:with-param name="type" select="$type"/>
            </xsl:call-template>
          </td>
          <td class="note__content__col">
            <span class="note__title">
              <xsl:call-template name="getNoteTitle">
                <xsl:with-param name="type" select="$type"/>
              </xsl:call-template>
            </span>
            <xsl:apply-templates/>
          </td>
        </tr>
      </table>
    </div>
  </xsl:template>-->

  <xsl:template match="note">
    <xsl:param name="type">
      <xsl:choose>
        <xsl:when test="@type != ''">
          <xsl:value-of select="@type"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="' '"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:param>
    <xsl:param name="title">
      <xsl:value-of select="concat(translate(substring($type,1,1), $vLower, $vUpper), substring($type, 2), substring(' ', 1 div not(position()=last())))"/>
    </xsl:param>
    <div class="note {@type} note_{@type}">
      <span class="note__title">
        <xsl:call-template name="getNoteTitle">
          <xsl:with-param name="type" select="$type"/>
        </xsl:call-template>
      </span>
      <xsl:apply-templates/>
    </div>
  </xsl:template>


  <xsl:template name="getNoteIcon">
    <xsl:param name="type"/>
    <xsl:choose>
      <xsl:when test="$type = ''">
        <img class="note__icon" src="Content/ditastylesheets/img/important.png" />
      </xsl:when>
      <xsl:when test="$type = 'attention'">
        <img class="note__icon" src="Content/ditastylesheets/img/important.png" />
      </xsl:when>
      <xsl:when test="$type = 'caution'">
        <img class="note__icon" src="Content/ditastylesheets/img/caution.png" />
      </xsl:when>
      <xsl:when test="$type = 'danger'">
        <img class="note__icon" src="Content/ditastylesheets/img/caution.png" />
      </xsl:when>
      <xsl:when test="$type = 'fastpath'">
        <img class="note__icon" src="Content/ditastylesheets/img/important.png" />
      </xsl:when>
      <xsl:when test="$type = 'important'">
        <img class="note__icon" src="Content/ditastylesheets/img/important.png" />
      </xsl:when>
      <xsl:when test="$type = 'note'">
        <img class="note__icon" src="Content/ditastylesheets/img/important.png" />
      </xsl:when>
      <xsl:when test="$type = 'notice'">
        <img class="note__icon" src="Content/ditastylesheets/img/important.png" />
      </xsl:when>
      <xsl:when test="$type = 'other'">
        <img class="note__icon" src="Content/ditastylesheets/img/important.png" />
      </xsl:when>
      <xsl:when test="$type = 'remember'">
        <img class="note__icon" src="Content/ditastylesheets/img/important.png" />
      </xsl:when>
      <xsl:when test="$type = 'restriction'">
        <img class="note__icon" src="Content/ditastylesheets/img/important.png" />
      </xsl:when>
      <xsl:when test="$type = 'tip'">
        <img class="note__icon" src="Content/ditastylesheets/img/tip.png" />
      </xsl:when>
      <xsl:when test="$type = 'trouble'">
        <img class="note__icon" src="Content/ditastylesheets/img/important.png" />
      </xsl:when>
      <xsl:when test="$type = 'warning'">
        <img class="note__icon" src="Content/ditastylesheets/img/important.png" />
      </xsl:when>
      <xsl:otherwise>
        <img class="note__icon" src="Content/ditastylesheets/img/important.png" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="getHazardIcon">
    <xsl:param name="type"/>
    <xsl:choose>
      <xsl:when test="$type = ''">
        <img class="note__icon" src="resources/img/important.png" />
      </xsl:when>
      <xsl:when test="$type = 'attention'">
        <img class="note__icon" src="resources/img/important.png" />
      </xsl:when>
      <xsl:when test="$type = 'caution'">
        <img class="note__icon" src="Content/ditastylesheets/img/caution.png" />
      </xsl:when>
      <xsl:when test="$type = 'danger'">
        <img class="note__icon" src="Content/ditastylesheets/img/caution.png" />
      </xsl:when>
      <xsl:when test="$type = 'fastpath'">
        <img class="note__icon" src="Content/ditastylesheets/img/important.png" />
      </xsl:when>
      <xsl:when test="$type = 'important'">
        <img class="note__icon" src="Content/ditastylesheets/img/important.png" />
      </xsl:when>
      <xsl:when test="$type = 'note'">
        <img class="note__icon" src="Content/ditastylesheets/img/important.png" />
      </xsl:when>
      <xsl:when test="$type = 'notice'">
        <img class="note__icon" src="Content/ditastylesheets/img/important.png" />
      </xsl:when>
      <xsl:when test="$type = 'other'">
        <img class="note__icon" src="Content/ditastylesheets/img/important.png" />
      </xsl:when>
      <xsl:when test="$type = 'remember'">
        <img class="note__icon" src="Content/ditastylesheets/img/important.png" />
      </xsl:when>
      <xsl:when test="$type = 'restriction'">
        <img class="note__icon" src="Content/ditastylesheets/img/important.png" />
      </xsl:when>
      <xsl:when test="$type = 'tip'">
        <img class="note__icon" src="Content/ditastylesheets/img/tip.png" />
      </xsl:when>
      <xsl:when test="$type = 'trouble'">
        <img class="note__icon" src="Content/ditastylesheets/img/important.png" />
      </xsl:when>
      <xsl:when test="$type = 'warning'">
        <img class="note__icon" src="Content/ditastylesheets/img/warning.png" />
      </xsl:when>
      <xsl:otherwise>
        <img class="note__icon" src="Content/ditastylesheets/img/important.png" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="getNoteTitle">
    <xsl:param name="type"/>
    <xsl:choose>
      <xsl:when test="$type = ''">
        <xsl:text>Note: </xsl:text>
      </xsl:when>
      <xsl:when test="$type = 'attention'">
        <xsl:text>Important: </xsl:text>
      </xsl:when>
      <xsl:when test="$type = 'caution'">
        <xsl:text>Caution: </xsl:text>
      </xsl:when>
      <xsl:when test="$type = 'danger'">
        <xsl:text>Warning: </xsl:text>
      </xsl:when>
      <xsl:when test="$type = 'fastpath'">
        <xsl:text>Fastpath: </xsl:text>
      </xsl:when>
      <xsl:when test="$type = 'important'">
        <xsl:text>Important: </xsl:text>
      </xsl:when>
      <xsl:when test="$type = 'note'">
        <xsl:text>Note: </xsl:text>
      </xsl:when>
      <xsl:when test="$type = 'notice'">
        <xsl:text>Notice: </xsl:text>
      </xsl:when>
      <xsl:when test="$type = 'other'">
        <xsl:text>Note: </xsl:text>
      </xsl:when>
      <xsl:when test="$type = 'remember'">
        <xsl:text>Remember: </xsl:text>
      </xsl:when>
      <xsl:when test="$type = 'restriction'">
        <xsl:text>Restriction: </xsl:text>
      </xsl:when>
      <xsl:when test="$type = 'tip'">
        <xsl:text>Tip: </xsl:text>
      </xsl:when>
      <xsl:when test="$type = 'trouble'">
        <xsl:text>Troubleshooting: </xsl:text>
      </xsl:when>
      <xsl:when test="$type = 'warning'">
        <xsl:text>Warning: </xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>Note: </xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="getHazardTitle">
    <xsl:param name="type"/>
    <xsl:choose>
      <xsl:when test="$type = ''">
        <xsl:text>Important: </xsl:text>
      </xsl:when>
      <xsl:when test="$type = 'attention'">
        <xsl:text>Important: </xsl:text>
      </xsl:when>
      <xsl:when test="$type = 'caution'">
        <xsl:text>Caution: </xsl:text>
      </xsl:when>
      <xsl:when test="$type = 'danger'">
        <xsl:text>Warning: </xsl:text>
      </xsl:when>
      <xsl:when test="$type = 'fastpath'">
        <xsl:text>Fastpath: </xsl:text>
      </xsl:when>
      <xsl:when test="$type = 'important'">
        <xsl:text>Important: </xsl:text>
      </xsl:when>
      <xsl:when test="$type = 'note'">
        <xsl:text>Important: </xsl:text>
      </xsl:when>
      <xsl:when test="$type = 'notice'">
        <xsl:text>Notice: </xsl:text>
      </xsl:when>
      <xsl:when test="$type = 'other'">
        <xsl:text>Important: </xsl:text>
      </xsl:when>
      <xsl:when test="$type = 'remember'">
        <xsl:text>Remember: </xsl:text>
      </xsl:when>
      <xsl:when test="$type = 'restriction'">
        <xsl:text>Restriction: </xsl:text>
      </xsl:when>
      <xsl:when test="$type = 'tip'">
        <xsl:text>Tip: </xsl:text>
      </xsl:when>
      <xsl:when test="$type = 'trouble'">
        <xsl:text>Troubleshooting: </xsl:text>
      </xsl:when>
      <xsl:when test="$type = 'warning'">
        <xsl:text>Warning: </xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>Important: </xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- description list templates -->
  <xsl:template match="dl">
    <dl class="dl">
      <xsl:apply-templates />
    </dl>
  </xsl:template>

  <xsl:template match="dlentry">
    <xsl:apply-templates />
  </xsl:template>

  <xsl:template match="dt">
    <dt class="dt dlterm">
      <xsl:apply-templates/>
    </dt>
  </xsl:template>

  <xsl:template match="dd">
    <dd class="dd">
      <xsl:apply-templates/>
    </dd>
  </xsl:template>

  <!-- end description list templates -->

  <!-- table templates -->
  <xsl:template match="table">
    <xsl:variable name="current" select="."/>
    <div class="table-wrap">
      <xsl:element name="table">
        <xsl:attribute name="class">
          <xsl:text>table</xsl:text>
        </xsl:attribute>
        <xsl:if test="./title != ''">
          <caption>
            <!-- table counter here -->
            <!--<xsl:for-each select="$allTables">
              <xsl:if test="generate-id() = generate-id($current/title)">
                <span class="table-title-label">
                  <xsl:text>Table: </xsl:text>
                  <xsl:value-of select="position()"/>
                  <xsl:text>. </xsl:text>
                </span>
              </xsl:if>
            </xsl:for-each>-->
            <span class="title">
              <xsl:value-of select="./title"/>
            </span>
          </caption>
        </xsl:if>
        <xsl:apply-templates select="./tgroup"/>
      </xsl:element>
    </div>
  </xsl:template>

  <xsl:template match="properties">
    <div class="table-wrap scroll">
      <table class="simpletable properties simpletableborder">
        <xsl:if test="not(prophead)">
          <thead align="left" style="display: table-header-group;">
            <tr class="sthead prophead">
              <th style="vertical-align:bottom;text-align:left;" class="stentry proptypehd">
                Parameter
              </th>
              <th style="vertical-align:bottom;text-align:left;" class="stentry propvaluehd">
                Value
              </th>
              <th style="vertical-align:bottom;text-align:left;" class="stentry propdeschd">
                Description
              </th>
            </tr>
          </thead>
        </xsl:if>
        <xsl:apply-templates />
      </table>
    </div>
  </xsl:template>
  <xsl:template match="prophead">
    <thead>
      <tr class="sthead prophead">
        <xsl:apply-templates />
      </tr>
    </thead>
  </xsl:template>
  <xsl:template match="proptypehd">
    <th style="vertical-align:bottom;text-align:left;" class="stentry proptypehd">
      <xsl:apply-templates />
    </th>
  </xsl:template>
  <xsl:template match="propvaluehd">
    <th style="vertical-align:bottom;text-align:left;" class="stentry propvaluehd">
      <xsl:apply-templates />
    </th>
  </xsl:template>
  <xsl:template match="propdeschd">
    <th style="vertical-align:bottom;text-align:left;" class="stentry propdeschd">
      <xsl:apply-templates />
    </th>
  </xsl:template>

  <xsl:template match="property">
    <tr class="strow property">
      <xsl:apply-templates />
    </tr>
  </xsl:template>
  <xsl:template match="proptype">
    <td class="stentry proptype">
      <xsl:apply-templates />
    </td>
  </xsl:template>
  <xsl:template match="propvalue">
    <td class="stentry propvalue">
      <xsl:apply-templates />
    </td>
  </xsl:template>
  <xsl:template match="propdesc">
    <td class="stentry propdesc">
      <xsl:apply-templates />
    </td>
  </xsl:template>

  <xsl:template match="choicetable">
    <div class="table-wrap scroll">
      <xsl:element name="table">
        <xsl:if test="not(chhead)">
          <thead align="left" style="display: table-header-group;">
            <tr class="row">
              <th>Option</th>
              <th>Description</th>
            </tr>
          </thead>
        </xsl:if>
        <xsl:apply-templates />
      </xsl:element>
    </div>
  </xsl:template>
  <xsl:template match="chhead">
    <thead align="left" style="display: table-header-group;">
      <tr class="row">
        <xsl:apply-templates />
      </tr>
    </thead>
  </xsl:template>
  <xsl:template match="choptionhd">
    <th>
      <xsl:apply-templates />
    </th>
  </xsl:template>
  <xsl:template match="chdeschd">
    <th>
      <xsl:apply-templates />
    </th>
  </xsl:template>
  <xsl:template match="chrow">
    <tr class="row">
      <xsl:apply-templates />
    </tr>
  </xsl:template>
  <xsl:template match="choption">

    <xsl:variable name="namest" select="substring(@namest, 4, 2)"/>
    <xsl:variable name="nameend" select="substring(@nameend, 4, 2)"/>
    <td class="entry">
      <xsl:attribute name="align">
        <xsl:value-of select="./@align"/>
      </xsl:attribute>
      <xsl:if test="./@namest">
        <xsl:attribute name="colspan">
          <xsl:value-of select="$nameend - $namest + 1"/>
        </xsl:attribute>
      </xsl:if>
      <xsl:if test="./@morerows">
        <xsl:attribute name="rowspan">
          <xsl:value-of select="number(./@morerows) + 1"/>
        </xsl:attribute>
      </xsl:if>
      <xsl:apply-templates />
    </td>
  </xsl:template>
  <xsl:template match="chdesc">
    <xsl:variable name="namest" select="substring(@namest, 4, 2)"/>
    <xsl:variable name="nameend" select="substring(@nameend, 4, 2)"/>
    <td class="entry">
      <xsl:attribute name="align">
        <xsl:value-of select="./@align"/>
      </xsl:attribute>
      <xsl:if test="./@namest">
        <xsl:attribute name="colspan">
          <xsl:value-of select="$nameend - $namest + 1"/>
        </xsl:attribute>
      </xsl:if>
      <xsl:if test="./@morerows">
        <xsl:attribute name="rowspan">
          <xsl:value-of select="number(./@morerows) + 1"/>
        </xsl:attribute>
      </xsl:if>
      <xsl:apply-templates />
    </td>
  </xsl:template>

  <xsl:template match="table/title">
    <xsl:apply-templates />
  </xsl:template>

  <xsl:template match="table/tgroup">
    <!--<xsl:apply-templates select="caption"/>-->
    <xsl:if test="//colspec">
      <colgroup>
        <!--<xsl:for-each select="colspec">
          <xsl:choose>
            <xsl:when test="@colwidth = '1*'">
              <col style="width:25%" />
            </xsl:when>
            <xsl:when test="@colwidth = '2*'">
              <col style="width:50%" />
            </xsl:when>
            <xsl:when test="@colwidth = '3*'">
              <col style="width:75%" />
            </xsl:when>
            <xsl:when test="@colwidth = '4*'">
              <col style="width:100%" />
            </xsl:when>
          </xsl:choose>
        </xsl:for-each>-->
      </colgroup>
    </xsl:if>
    <xsl:apply-templates select="thead"/>
    <xsl:apply-templates select="tbody">
      <xsl:with-param name="colSpan" select="./@cols"/>
    </xsl:apply-templates>
  </xsl:template>

  <xsl:template match="thead">
    <thead class="thead">
      <xsl:for-each select="row">
        <tr class="row">
          <xsl:for-each select="entry">
            <xsl:apply-templates select="." mode="table-head"/>
          </xsl:for-each>
        </tr>
      </xsl:for-each>
      <!--<tr class="row">
        <xsl:for-each select="row/entry">
          <th>
            <xsl:apply-templates />
          </th>
        </xsl:for-each>
      </tr>-->
    </thead>
  </xsl:template>

  <xsl:template match="tbody">
    <xsl:param name="colSpan"/>
    <tbody class="tbody">
      <xsl:apply-templates />
    </tbody>
  </xsl:template>


  <xsl:template match="row">
    <tr class="row">
      <xsl:apply-templates />
    </tr>
  </xsl:template>

  <xsl:template match="entry">
    <xsl:variable name="entrycol" select="./@colname"/>
    <xsl:variable name="namest" select="substring(@namest, 4, 2)"/>
    <xsl:variable name="nameend" select="substring(@nameend, 4, 2)"/>
    <xsl:variable name="tgroupAlign" select="./ancestor::tgroup/@align"/>
    <td class="entry" test="{$entrycol}" test2="{./ancestor::tgroup/colspec[@colname='col1']/@align}">
      <xsl:attribute name="align">
        <xsl:choose>
          <xsl:when test="./@align != ''">
            <xsl:value-of select="./@align"/>
          </xsl:when>
          <xsl:when test="$tgroupAlign != ''">
            <xsl:value-of select="$tgroupAlign"/>
          </xsl:when>
          <xsl:when test="$entrycol = 'col1'">
            <xsl:value-of select="./ancestor::tgroup/colspec[@colname='col1']/@align"/>
          </xsl:when>
          <xsl:when test="$entrycol = 'col2'">
            <xsl:value-of select="./ancestor::tgroup/colspec[@colname='col2']/@align"/>
          </xsl:when>
          <xsl:when test="$entrycol = 'col3'">
            <xsl:value-of select="./ancestor::tgroup/colspec[@colname='col3']/@align"/>
          </xsl:when>
          <xsl:when test="$entrycol = 'col4'">
            <xsl:value-of select="./ancestor::tgroup/colspec[@colname='col4']/@align"/>
          </xsl:when>
          <xsl:when test="$entrycol = 'col5'">
            <xsl:value-of select="./ancestor::tgroup/colspec[@colname='col5']/@align"/>
          </xsl:when>
          <xsl:when test="$entrycol = 'col6'">
            <xsl:value-of select="./ancestor::tgroup/colspec[@colname='col6']/@align"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="./ancestor::tgroup/colspec[@colname='{$entrycol}']/@align"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:attribute>
      <xsl:if test="./@namest">
        <xsl:attribute name="colspan">
          <xsl:value-of select="$nameend - $namest + 1"/>
        </xsl:attribute>
      </xsl:if>
      <xsl:if test="./@morerows">
        <xsl:attribute name="rowspan">
          <xsl:value-of select="number(./@morerows) + 1"/>
        </xsl:attribute>
      </xsl:if>
      <xsl:apply-templates />
    </td>
  </xsl:template>

  <xsl:template match="entry" mode="table-head">
    <xsl:variable name="entrycol" select="./@colname"/>
    <xsl:variable name="namest" select="substring(@namest, 4, 2)"/>
    <xsl:variable name="nameend" select="substring(@nameend, 4, 2)"/>
    <th class="entry {./@align}">
      <xsl:attribute name="align">
        <xsl:choose>
          <xsl:when test="./@align != ''">
            <xsl:value-of select="./@align"/>
          </xsl:when>
          <xsl:when test="$entrycol = 'col1'">
            <xsl:value-of select="./ancestor::tgroup/colspec[@colname='col1']/@align"/>
          </xsl:when>
          <xsl:when test="$entrycol = 'col2'">
            <xsl:value-of select="./ancestor::tgroup/colspec[@colname='col2']/@align"/>
          </xsl:when>
          <xsl:when test="$entrycol = 'col3'">
            <xsl:value-of select="./ancestor::tgroup/colspec[@colname='col3']/@align"/>
          </xsl:when>
          <xsl:when test="$entrycol = 'col4'">
            <xsl:value-of select="./ancestor::tgroup/colspec[@colname='col4']/@align"/>
          </xsl:when>
          <xsl:when test="$entrycol = 'col5'">
            <xsl:value-of select="./ancestor::tgroup/colspec[@colname='col5']/@align"/>
          </xsl:when>
          <xsl:when test="$entrycol = 'col6'">
            <xsl:value-of select="./ancestor::tgroup/colspec[@colname='col6']/@align"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="./ancestor::tgroup/colspec[@colname='{$entrycol}']/@align"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:attribute>
      <xsl:if test="./@namest">
        <xsl:attribute name="colspan">
          <xsl:value-of select="$nameend - $namest + 1"/>
        </xsl:attribute>
      </xsl:if>
      <xsl:if test="./@morerows">
        <xsl:attribute name="rowspan">
          <xsl:value-of select="number(./@morerows) + 1"/>
        </xsl:attribute>
      </xsl:if>
      <xsl:apply-templates />
    </th>
  </xsl:template>
  <!-- end table templates -->

  <!-- simpletable templates -->
  <xsl:template match="simpletable">
    <div class="table-wrap scroll">
      <table class="simpletable properties simpletableborder">
        <xsl:apply-templates />
      </table>
    </div>
  </xsl:template>

  <xsl:template match="sthead">
    <thead>
      <tr>
        <xsl:for-each select="stentry">
          <th>
            <xsl:apply-templates />
          </th>
        </xsl:for-each>
      </tr>
    </thead>
  </xsl:template>

  <xsl:template match="strow">
    <tr>
      <xsl:apply-templates />
    </tr>
  </xsl:template>

  <xsl:template match="stentry">
    <xsl:variable name="namest" select="substring(@namest, 4, 2)"/>
    <xsl:variable name="nameend" select="substring(@nameend, 4, 2)"/>
    <td class="entry">
      <xsl:attribute name="align">
        <xsl:value-of select="./@align"/>
      </xsl:attribute>
      <xsl:if test="./@namest">
        <xsl:attribute name="colspan">
          <xsl:value-of select="$nameend - $namest + 1"/>
        </xsl:attribute>
      </xsl:if>
      <xsl:if test="./@morerows">
        <xsl:attribute name="rowspan">
          <xsl:value-of select="number(./@morerows) + 1"/>
        </xsl:attribute>
      </xsl:if>
      <xsl:apply-templates />
    </td>

  </xsl:template>

  <!--<xsl:template match="fn">
    <xsl:variable name="id" select="@id"/>
    <xsl:variable name="callout">
      <xsl:apply-templates select="." mode="callout"/>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="not(@id)">
        <sup>
          <xsl:text> </xsl:text>
          <xsl:element name="a">
            <xsl:attribute name="href">
              <xsl:value-of select="$ThisPageUrl"/>
              <xsl:text>#footnotes/</xsl:text>
              <xsl:value-of select="$callout"/>
            </xsl:attribute>
            <xsl:copy-of select="$callout"/>
          </xsl:element>
        </sup>
      </xsl:when>
      <xsl:otherwise>-->
  <!-- Footnote with id does not generate its own callout. -->
  <!--</xsl:otherwise>
    </xsl:choose>
  </xsl:template>-->

  <xsl:template match="fn">
    <xsl:variable name="id" select="@id"/>
    <xsl:variable name="callout">
      <xsl:apply-templates select="." mode="callout"/>
    </xsl:variable>
    <sup>
      <xsl:text> </xsl:text>
      <xsl:element name="a">
        <xsl:attribute name="href">
          <xsl:value-of select="$ThisPageUrl"/>
          <xsl:text>#footnotes/</xsl:text>
          <xsl:value-of select="$callout"/>
        </xsl:attribute>
        <xsl:copy-of select="$callout"/>
      </xsl:element>
    </sup>
  </xsl:template>

  <xsl:template name="getFootnoteInternalID">
    <xsl:param name="ctx" />
    <xsl:value-of select="concat('fn',generate-id($ctx))"/>
  </xsl:template>

  <xsl:template match="fn" mode="callout">
    <xsl:variable name="current" select="."/>
    <xsl:choose>
      <xsl:when test="@callout">
        <xsl:value-of select="@callout"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:for-each select="$allFootnotes">
          <xsl:if test="generate-id(.) = generate-id($current)">
            <xsl:value-of select="position()"/>
          </xsl:if>
        </xsl:for-each>
        <!--<xsl:number select="count(key('footnotesByString', text()))+1"/>-->
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- end simpletable templates-->

  <!-- simple list templates -->

  <xsl:template match="sl">
    <ul style="list-style-type:none;">
      <xsl:apply-templates/>
    </ul>
  </xsl:template>

  <xsl:template match="sli">
    <li>
      <xsl:apply-templates/>
    </li>
  </xsl:template>

  <xsl:template match="tm[@tmtype='tm']">
    <xsl:value-of select="."/>
    <xsl:text> ™</xsl:text>
  </xsl:template>
  <xsl:template match="tm[@tmtype='reg']">
    <xsl:value-of select="."/>
    <xsl:text> ®</xsl:text>
  </xsl:template>

  <xsl:template match="sl[@outputclass='twocol']">
    <xsl:variable name="count" select="ceiling(count(sli) div 2)"/>
    <div class="row">
      <div class="col-md-6">
        <ul style="list-style-type:none;">
          <xsl:for-each select="sli[position() &lt;= $count]" >
            <xsl:apply-templates select="."/>
          </xsl:for-each>
        </ul>
      </div>
      <div class="col-md-6">
        <ul style="list-style-type:none;">
          <xsl:for-each select="sli[position() &gt; $count]" >
            <xsl:apply-templates select="." />
          </xsl:for-each>
        </ul>
      </div>
    </div>
  </xsl:template>


  <xsl:template match="related-links">
    <xsl:if test="//link[@role='child']">
      <xsl:call-template name="child-links-section"/>
    </xsl:if>
    <!--<xsl:if test="//link[@role='parent']">
      <xsl:call-template name="parent-links-section"/>
    </xsl:if>-->
    <!--<xsl:if test="//link[@role='sibling'][@scope='local']">
      <xsl:call-template name="sibling-links-section"/>
    </xsl:if>-->
    <xsl:if test="//link[@role='friend'] | //link[@role='sibling'][@scope='local'] | //link[@scope='external']">
      <xsl:call-template name="related-links-section"/>
    </xsl:if>

    <xsl:if test="//link[not(@role)][not(@scope)]">
      <xsl:call-template name="general-links-section"/>
    </xsl:if>
  </xsl:template>

  <!--<xsl:template name="child-links-section">
    <ul class="ullinks">
      <xsl:for-each select="//link[@role='child']">
        <li class="link ulchildlink">
          <strong>
            <a class="link" href="{concat(@href, '.xml')}">
              <xsl:value-of select="linktext"/>
            </a>
          </strong>
          <br/>
          <xsl:apply-templates select="desc"/>
        </li>
      </xsl:for-each>
    </ul> 
  </xsl:template>-->

  <xsl:template name="child-links-section">

    <p>This section includes:</p>
    <ul>
      <xsl:for-each select="//link[@role='child']">

        <xsl:variable name="path">
          <xsl:choose>
            <xsl:when test="contains(@href, '#')">
              <xsl:value-of select="substring-before(@href, '#')"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="@href"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:variable>

        <xsl:variable name="pageUrl">
          <xsl:choose>
            <xsl:when test="normalize-space($path) != ''">
              <xsl:choose>
                <xsl:when test="starts-with($path, 'x')">
                  <xsl:value-of select="concat($path, '.xml')"/>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:value-of select="$path"/>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="$ThisPageUrl"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:variable>

        <xsl:variable name="bookmark" select="substring-after(@href, '#')"></xsl:variable>

        <xsl:variable name="masterBookmark">
          <xsl:choose>
            <xsl:when test="contains($bookmark, '/')">
              <xsl:value-of select="substring-after($bookmark, '/')"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="$bookmark"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:variable>

        <li>
          <xsl:element name="a">
            <xsl:attribute name="href">
              <xsl:choose>
                <xsl:when test="$bookmark = ''">
                  <xsl:value-of select="$pageUrl"/>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:value-of select="concat($pageUrl, concat('#', $masterBookmark))"/>
                </xsl:otherwise>

              </xsl:choose>
            </xsl:attribute>
            <xsl:value-of select="linktext"/>
          </xsl:element>
        </li>
      </xsl:for-each>
    </ul>

  </xsl:template>


  <!--<xsl:template name="parent-links-section">
    <div class="familylinks">
      <xsl:for-each select="//link[@role='parent']">
        <div class="parentlink">
          <strong>Parent topic:</strong>
          <a class="link" href="{concat(@href, '.xml')}">
            <xsl:value-of select="linktext"/>
          </a>
        </div>
      </xsl:for-each>
    </div>
  </xsl:template>-->

  <xsl:template name="sibling-links-section">
    <div class="row">
      <div class="col-md-9">
        <div class="border-box off-white">
          <h4 class="margin-half">Related Topics</h4>
          <ul class="no-bull no-margin">
            <xsl:for-each select="//link[@role='sibling'][@scope='local']">

              <xsl:variable name="path">
                <xsl:choose>
                  <xsl:when test="contains(@href, '#')">
                    <xsl:value-of select="substring-before(@href, '#')"/>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:value-of select="@href"/>
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:variable>

              <xsl:variable name="pageUrl">
                <xsl:choose>
                  <xsl:when test="normalize-space($path) != ''">
                    <xsl:choose>
                      <xsl:when test="starts-with($path, 'x')">
                        <xsl:value-of select="concat($path, '.xml')"/>
                      </xsl:when>
                      <xsl:otherwise>
                        <xsl:value-of select="$path"/>
                      </xsl:otherwise>
                    </xsl:choose>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:value-of select="$ThisPageUrl"/>
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:variable>

              <xsl:variable name="bookmark" select="substring-after(@href, '#')"></xsl:variable>

              <xsl:variable name="masterBookmark">
                <xsl:choose>
                  <xsl:when test="contains($bookmark, '/')">
                    <xsl:value-of select="substring-after($bookmark, '/')"/>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:value-of select="$bookmark"/>
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:variable>

              <li>
                <xsl:element name="a">
                  <xsl:attribute name="href">
                    <xsl:choose>
                      <xsl:when test="$bookmark = ''">
                        <xsl:value-of select="$pageUrl"/>
                      </xsl:when>
                      <xsl:otherwise>
                        <xsl:value-of select="concat($pageUrl, concat('#', $masterBookmark))"/>
                      </xsl:otherwise>

                    </xsl:choose>
                  </xsl:attribute>
                  <xsl:value-of select="linktext"/>
                </xsl:element>
              </li>
            </xsl:for-each>
          </ul>
        </div>
      </div>
    </div>
  </xsl:template>

  <xsl:template name="related-links-section">
    <div class="border-box-thick">
      <div class="border-bar accent-1">
        <xsl:text> </xsl:text>
      </div>
      <h2 class="accent-1-text">
        <i class="fa fa-file" aria-hidden="true">
          <xsl:text> </xsl:text>
        </i>
        Related Topics
      </h2>
      <ul class="border-list">
        <xsl:for-each select="//link[@role='sibling'][@scope='local']">

          <xsl:variable name="path">
            <xsl:choose>
              <xsl:when test="contains(@href, '#')">
                <xsl:value-of select="substring-before(@href, '#')"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="@href"/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:variable>

          <xsl:variable name="pageUrl">
            <xsl:choose>
              <xsl:when test="normalize-space($path) != ''">
                <xsl:choose>
                  <xsl:when test="starts-with($path, 'x')">
                    <xsl:value-of select="concat($path, '.xml')"/>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:value-of select="$path"/>
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="$ThisPageUrl"/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:variable>

          <xsl:variable name="bookmark" select="substring-after(@href, '#')"></xsl:variable>

          <xsl:variable name="masterBookmark">
            <xsl:choose>
              <xsl:when test="contains($bookmark, '/')">
                <xsl:value-of select="substring-after($bookmark, '/')"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="$bookmark"/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:variable>

          <li>
            <xsl:element name="a">
              <xsl:attribute name="href">
                <xsl:choose>
                  <xsl:when test="$bookmark = ''">
                    <xsl:value-of select="$pageUrl"/>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:value-of select="concat($pageUrl, concat('#', $masterBookmark))"/>
                  </xsl:otherwise>

                </xsl:choose>
              </xsl:attribute>
              <xsl:value-of select="linktext"/>
            </xsl:element>
          </li>
        </xsl:for-each>
        <xsl:for-each select="//link[@scope='external']">

          <xsl:variable name="path">
            <xsl:choose>
              <xsl:when test="contains(@href, '#')">
                <xsl:value-of select="substring-before(@href, '#')"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="@href"/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:variable>

          <xsl:variable name="pageUrl">
            <xsl:choose>
              <xsl:when test="normalize-space($path) != ''">
                <xsl:choose>
                  <xsl:when test="starts-with($path, 'x')">
                    <xsl:value-of select="concat($path, '.xml')"/>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:value-of select="$path"/>
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="$ThisPageUrl"/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:variable>

          <xsl:variable name="bookmark" select="substring-after(@href, '#')"></xsl:variable>

          <xsl:variable name="masterBookmark">
            <xsl:choose>
              <xsl:when test="contains($bookmark, '/')">
                <xsl:value-of select="substring-after($bookmark, '/')"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="$bookmark"/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:variable>

          <li>
            <xsl:element name="a">
              <xsl:attribute name="target">
                <xsl:value-of select="string('_blank')"/>
              </xsl:attribute>
              <xsl:attribute name="href">
                <xsl:choose>
                  <xsl:when test="$bookmark = ''">
                    <xsl:value-of select="$pageUrl"/>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:value-of select="concat($pageUrl, concat('#', $masterBookmark))"/>
                  </xsl:otherwise>

                </xsl:choose>
              </xsl:attribute>
              <xsl:value-of select="linktext"/>
            </xsl:element>
          </li>
        </xsl:for-each>
        <xsl:for-each select="//link[@role='friend'][generate-id() = generate-id(key('rellinks',.)[1])]">

          <xsl:variable name="path">
            <xsl:choose>
              <xsl:when test="contains(@href, '#')">
                <xsl:value-of select="substring-before(@href, '#')"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="@href"/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:variable>

          <xsl:variable name="pageUrl">
            <xsl:choose>
              <xsl:when test="normalize-space($path) != ''">
                <xsl:choose>
                  <xsl:when test="starts-with($path, 'x')">
                    <xsl:value-of select="concat($path, '.xml')"/>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:value-of select="$path"/>
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="$ThisPageUrl"/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:variable>

          <xsl:variable name="bookmark" select="substring-after(@href, '#')"></xsl:variable>

          <xsl:variable name="masterBookmark">
            <xsl:choose>
              <xsl:when test="contains($bookmark, '/')">
                <xsl:value-of select="substring-after($bookmark, '/')"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="$bookmark"/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:variable>

          <li>
            <xsl:element name="a">
              <xsl:attribute name="href">
                <xsl:choose>
                  <xsl:when test="$bookmark = ''">
                    <xsl:value-of select="$pageUrl"/>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:value-of select="concat($pageUrl, concat('#', $masterBookmark))"/>
                  </xsl:otherwise>

                </xsl:choose>
              </xsl:attribute>
              <xsl:value-of select="linktext"/>
            </xsl:element>
          </li>
        </xsl:for-each>
      </ul>
    </div>
  </xsl:template>


  <xsl:template name="general-links-section">
    <div class="row">
      <div class="col-md-9">
        <div class="border-box off-white">
          <ul class="no-bull no-margin">
            <xsl:for-each select="//link[not(@role)][not(@scope)]">

              <xsl:variable name="path">
                <xsl:choose>
                  <xsl:when test="contains(@href, '#')">
                    <xsl:value-of select="substring-before(@href, '#')"/>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:value-of select="@href"/>
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:variable>

              <xsl:variable name="pageUrl">
                <xsl:choose>
                  <xsl:when test="normalize-space($path) != ''">
                    <xsl:choose>
                      <xsl:when test="starts-with($path, 'x')">
                        <xsl:value-of select="concat($path, '.xml')"/>
                      </xsl:when>
                      <xsl:otherwise>
                        <xsl:value-of select="$path"/>
                      </xsl:otherwise>
                    </xsl:choose>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:value-of select="$ThisPageUrl"/>
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:variable>

              <xsl:variable name="bookmark" select="substring-after(@href, '#')"></xsl:variable>

              <xsl:variable name="masterBookmark">
                <xsl:choose>
                  <xsl:when test="contains($bookmark, '/')">
                    <xsl:value-of select="substring-after($bookmark, '/')"/>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:value-of select="$bookmark"/>
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:variable>

              <li>
                <xsl:element name="a">
                  <xsl:attribute name="href">
                    <xsl:choose>
                      <xsl:when test="$bookmark = ''">
                        <xsl:value-of select="$pageUrl"/>
                      </xsl:when>
                      <xsl:otherwise>
                        <xsl:value-of select="concat($pageUrl, concat('#', $masterBookmark))"/>
                      </xsl:otherwise>

                    </xsl:choose>
                  </xsl:attribute>
                  <xsl:value-of select="linktext"/>
                </xsl:element>
              </li>
            </xsl:for-each>
          </ul>
        </div>
      </div>
    </div>
  </xsl:template>

  <!--<xsl:template name="build-minitoc">
    <nav class='mini-toc' role="navigation">
      <xsl:choose>
        <xsl:when test=".//linkpool[@collection-type='sequence']">
          <ol>
            <xsl:for-each select="//link[@role='child']">
              <li>
                <strong>
                  <a href="{concat(@href, '.xml')}">
                    <xsl:apply-templates select="linktext"/>
                  </a>
                </strong>
                <br/>
                <xsl:apply-templates select="desc"/>
              </li>
            </xsl:for-each>
          </ol>
        </xsl:when>
        <xsl:otherwise>
          <ul style="list-style-type:none;">
            <xsl:for-each select="//link[@role='child']">
              <li>
                <strong>
                  <a href="{concat(@href, '.xml')}">
                    <xsl:apply-templates select="linktext"/>
                  </a>
                </strong>
                <br/>
                <xsl:apply-templates select="desc"/>
              </li>
            </xsl:for-each>
          </ul>
        </xsl:otherwise>
      </xsl:choose>
    </nav>
  </xsl:template>-->

  <!--<xsl:template name="build-related-links">
    <xsl:if test="//link[@role='friend']">
      <div class='related-information'>
        <strong>Related information</strong>
        <xsl:for-each select="//link[@role='friend']">
          <div class="related-link">
            <a href="{concat(@href, '.xml')}">
              <xsl:apply-templates select="linktext"/>
            </a>
          </div>
        </xsl:for-each>
      </div>
    </xsl:if>
  </xsl:template>-->

  <!-- Many different variations of the related-links section -->
  <!-- Related links have linkpools collection-type = family -->
  <!-- Each link has role parent,sibling,child -->
  <!-- Only render 'child' links for now? -->
  <!--<xsl:template match="link[@importance='required']">
    <li class="link ulchildlink">
      <strong>
        <xsl:element name="a">
          <xsl:attribute name="class">navheader_parent_path</xsl:attribute>
          <xsl:attribute name="href">
            <xsl:value-of select="concat(./@href, '.xml')"/>
          </xsl:attribute>
          <xsl:attribute name="title">
            <xsl:choose>
              <xsl:when test="./linktext != ''">
                <xsl:value-of select="./linktext"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="concat(./@href, '.xml')"/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:attribute>
          <xsl:choose>
            <xsl:when test="./linktext != ''">
              <xsl:value-of select="./linktext"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="concat(./@href, '.xml')"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:element>
      </strong>
    </li>
  </xsl:template>-->

  <!--<xsl:template match="related-links">
    <nav role="navigation" class="related-links">
      <xsl:if test=".//link[@role='child' and @scope='local']">
        <ul class="ullinks">
          <xsl:apply-templates select=".//link[@role='child' and @scope='local']" />
        </ul>
      </xsl:if>

      <xsl:choose>
        <xsl:when test=".//linkpool[@collection-type='sequence']//link[@role='child' and @scope='local']">
          <ol class="ollinks">
            <xsl:apply-templates select=".//linkpool[@collection-type='sequence']//link[@role='child' and @scope='local']" />
          </ol>
        </xsl:when>
        <xsl:otherwise>
          <xsl:if test=".//link[@role='child' and @scope='local']">
            <ul class="ullinks">
              <xsl:apply-templates select=".//link[@role='child' and @scope='local']" />
            </ul>
          </xsl:if>
        </xsl:otherwise>
      </xsl:choose>

      <xsl:if test=".//link[@role='friend' and @type='concept']">
        <div class="linklist linklist relinfo relconcepts">
          <strong>Related concepts</strong>
          <br/>
          <xsl:apply-templates select=".//link[@role='friend' and @type='concept']" />
        </div>
      </xsl:if>

      <xsl:if test=".//link[@role='friend' and @type='reference']">
        <div class="linklist linklist relinfo relref">
          <strong>Related reference</strong>
          <br/>
          <xsl:apply-templates select=".//link[@role='friend' and @type='reference']" />
        </div>
      </xsl:if>

      <xsl:if test="linkpool[link/@role='parent']">
      </xsl:if>
    </nav>
  </xsl:template>

  <xsl:template match="link[@role='child' and @scope='local']">
    <li class="link ulchildlink">
      <strong>
        <xsl:element name="a">
          <xsl:attribute name="class">navheader_parent_path</xsl:attribute>
          <xsl:attribute name="href">
            <xsl:value-of select="concat(./@href, '.xml')"/>
          </xsl:attribute>
          <xsl:attribute name="title">
            <xsl:choose>
              <xsl:when test="./linktext != ''">
                <xsl:value-of select="./linktext"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="concat(./@href, '.xml')"/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:attribute>
          <xsl:choose>
            <xsl:when test="./linktext != ''">
              <xsl:value-of select="./linktext"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="concat(./@href, '.xml')"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:element>
      </strong>
      <br/>
      <xsl:value-of select="./desc"/>
    </li>
  </xsl:template>

  <xsl:template match="link[@role='friend' and @type='concept']">
    <div class="related_link">
      <xsl:element name="a">
        <xsl:attribute name="class">navheader_parent_path</xsl:attribute>
        <xsl:attribute name="href">
          <xsl:value-of select="concat(./@href, '.xml')"/>
        </xsl:attribute>
        <xsl:attribute name="title">
          <xsl:choose>
            <xsl:when test="./linktext != ''">
              <xsl:value-of select="./linktext"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="concat(./@href, '.xml')"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:attribute>
        <xsl:choose>
          <xsl:when test="./linktext != ''">
            <xsl:value-of select="./linktext"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="concat(./@href, '.xml')"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:element>
    </div>
  </xsl:template>

  <xsl:template match="link[@role='friend' and @type='reference']">
    <div class="related_link">
      <xsl:element name="a">
        <xsl:attribute name="class">navheader_parent_path</xsl:attribute>
        <xsl:attribute name="href">
          <xsl:value-of select="concat(./@href, '.xml')"/>
        </xsl:attribute>
        <xsl:attribute name="title">
          <xsl:choose>
            <xsl:when test="./linktext != ''">
              <xsl:value-of select="./linktext"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="concat(./@href, '.xml')"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:attribute>
        <xsl:choose>
          <xsl:when test="./linktext != ''">
            <xsl:value-of select="./linktext"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="concat(./@href, '.xml')"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:element>
    </div>
  </xsl:template>-->

  <xsl:template match="data/title">

  </xsl:template>

  <xsl:template match="p/image">
    <xsl:choose>
      <xsl:when test="@placement='break'">
        <br/>
        <img src="assets/{./@href}" alt="{./alt/text()[1]}" title="{./alt/text()[1]}" width="{./@width}"/>
        <br/>
      </xsl:when>
      <xsl:when test="contains(@href, '.svg') or contains(@href, '.svgz')">
        <p class="img-wrap">
          <object id="@id" data="assets/{./@href}" type="image/svg+xml">
            <img src="assets/{./@href}" alt="" />
          </object>
        </p>
      </xsl:when>
      <xsl:otherwise>
        <img src="assets/{./@href}" alt="{./alt/text()[1]}" title="{./alt/text()[1]}" width="{./@width}"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="image">
    <xsl:choose>
      <xsl:when test="contains(@href, '.svg') or contains(@href, '.svgz')">
        <p class="img-wrap">
          <object id="@id" data="assets/{./@href}" type="image/svg+xml">
            <img src="assets/{./@href}" alt="" />
          </object>
        </p>
      </xsl:when>
      <xsl:otherwise>
        <p class="img-wrap">
          <img src="assets/{./@href}" alt="{./alt/text()[1]}" title="{./alt/text()[1]}" width="{./@width}" />
        </p>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>


  <xsl:template match="imagemap/image">
    <img usemap="#map_{@id}" class="image map" id="imagemap__{@id}" src="assets/{./@href}" width="{./@width}" alt="{./alt/text()[1]}" title="{./alt/text()[1]}"/>
  </xsl:template>



  <!-- identity transform -->
  <xsl:template match="@* | node()">
    <xsl:copy>
      <xsl:apply-templates select="@* | node()"/>
    </xsl:copy>
  </xsl:template>
</xsl:stylesheet>
