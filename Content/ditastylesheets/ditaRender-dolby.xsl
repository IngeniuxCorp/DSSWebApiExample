<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:msxsl="urn:schemas-microsoft-com:xslt"
  xmlns:ext="http://exslt.org/common"
  exclude-result-prefixes="ext msxsl">

  <xsl:output method="xml" indent="yes" omit-xml-declaration="yes"/>

  <xsl:param name="ViewMode" select="Full" />

  <xsl:param name="ThisPageUrl" select="''" />

  <xsl:variable name="vLower" select="'abcdefghijklmnopqrstuvwxyz'"/>

  <xsl:variable name="vUpper" select="'ABCDEFGHIJKLMNOPQRSTUVWXYZ'"/>

  <xsl:variable name="allFootnotes" select="//fn"/>
  <xsl:variable name="allTables" select="//table/title[1]"/>
  <xsl:variable name="allFigures" select="//fig"/>

  <xsl:variable name="rootNodeName">
    <xsl:value-of select = "name(/*)"/>
  </xsl:variable>

  <xsl:template match="/">
    <!-- <xsl:choose> -->
    <!-- <xsl:when test="$ViewMode = 'TitleOnly'"> -->
    <!-- <xsl:apply-templates select="/*/title"/> -->
    <!-- </xsl:when> -->
    <!-- <xsl:when test="$ViewMode = 'Partial'"> -->
    <!-- <xsl:apply-templates select="/*/title"/> -->
    <!-- <xsl:apply-templates select="/*/shortdesc"/> -->
    <!-- </xsl:when> -->
    <!-- <xsl:otherwise> -->
    <xsl:apply-templates select="bookmap"/>
    <xsl:apply-templates select="dita"/>
    <!-- Addt Templates -->
    <xsl:apply-templates select="concept"/>
    <xsl:apply-templates select="reference"/>
    <xsl:apply-templates select="task"/>
    <xsl:apply-templates select="topic"/>

    <xsl:apply-templates select="map"/>
    <xsl:apply-templates select="glossentry"/>
    <!-- Other Potential Types -->
    <xsl:apply-templates select="learningOverview" />
    <xsl:apply-templates select="learningAssessment"/>
    <xsl:apply-templates select="learningSummary"/>

    <xsl:apply-templates select="p-topic"/>
    <!-- </xsl:otherwise> -->
    <!-- </xsl:choose> -->
  </xsl:template>

  <xsl:template match="bookmap">
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="datasheet">
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="booktitle">
    <h1>
      <xsl:apply-templates />
    </h1>
  </xsl:template>

  <xsl:template match="bookmap/frontmatter">
    <xsl:apply-templates select="./preface" />
  </xsl:template>
  <!--<xsl:template match="bookmap/frontmatter/preface">
    <xsl:apply-templates />  
  </xsl:template>-->
  <xsl:template match="bookmap/bookmeta">
  </xsl:template>
  <xsl:template match="bookmap/backmatter">
  </xsl:template>
  <xsl:template match="bookmap/reltable">    
  </xsl:template>
  <xsl:template match="bookmeta/prodinfo">
  </xsl:template>
  <xsl:template match="bookmeta/bookrights">
  </xsl:template>
  <xsl:template match="bookmeta/data">
    <xsl:apply-templates />
    <hr/>
  </xsl:template>

  <xsl:template match="chapter">
    <xsl:if test="@processing-role != 'resource-only'">
      <h2>
        <xsl:element name="a">
          <xsl:attribute name="href">
            <xsl:choose>
              <xsl:when test="contains(@href, '#')">
                <xsl:variable name="xID" select="substring-before(@href, '#')"/>
                <xsl:variable name="Anchor" select="substring-after(@href, '#')"/>
                <xsl:variable name="newLink" select="concat($xID, '.xml')" />
                <xsl:value-of select="concat($newLink, '#', $Anchor)"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:variable name="xID" select="substring-before(@href, '#')"/>
                <xsl:variable name="newLink" select="concat(@href, '.xml')" />
                <xsl:value-of select="$newLink"/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:attribute>
          <xsl:apply-templates select="./topicmeta/navtitle"/>
        </xsl:element>
      </h2>
      <xsl:element name="ol">
        <!--<xsl:apply-templates select="./topicref[not(@toc = 'no') and not(@type='reference')]"/>-->
        <xsl:apply-templates select="./topicref[not(@toc = 'no') and not(@processing-role= 'resource-only') and not(@type='glossentry') and not(@outputclass='frontmatter') and not(@outputclass= 'backmatter')]"/>
        <xsl:apply-templates select="./topicref[not(@toc = 'no') and not(@processing-role= 'resource-only') and not(@type='glossentry') and @outputclass='frontmatter' or @outputclass= 'backmatter']"/>
      </xsl:element>
    </xsl:if>
  </xsl:template>

  <xsl:template match="preface">
    <div class="preface">
      <h2 class="scroll-to">
        <a class="go-to-top" href="#top">
          <i class="material-icons">keyboard_arrow_upward</i>
        </a>
        <xsl:element name="a">
          <xsl:attribute name="href">
            <xsl:choose>
              <xsl:when test="contains(@href, '#')">
                <xsl:variable name="xID" select="substring-before(@href, '#')"/>
                <xsl:variable name="Anchor" select="substring-after(@href, '#')"/>
                <xsl:variable name="newLink" select="concat($xID, '.xml')" />
                <xsl:value-of select="concat($newLink, '#', $Anchor)"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:variable name="xID" select="substring-before(@href, '#')"/>
                <xsl:variable name="newLink" select="concat(@href, '.xml')" />
                <xsl:value-of select="$newLink"/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:attribute>
          <xsl:apply-templates select="./topicmeta/navtitle"/>
        </xsl:element>
      </h2>
      <xsl:apply-templates select="./topicmeta/shortdesc"/>
      <xsl:element name="ol">
        <!--<xsl:apply-templates select="./topicref[not(@toc = 'no') and not(@type='reference')]"/>-->
        <xsl:apply-templates select="./topicref[not(@toc = '') and not(@processing-role= 'resource-only') and not(@type='glossentry') and not(@outputclass='frontmatter') and not(@outputclass= 'backmatter')]" mode="toc"/>
        <xsl:apply-templates select="./topicref[not(@toc = '') and not(@processing-role= 'resource-only') and not(@type='glossentry') and @outputclass='frontmatter' or @outputclass= 'backmatter']" mode="toc"/>
      </xsl:element>
    </div>
  </xsl:template>

  <xsl:template match="part">
    <div class="part">
      <h2 class="scroll-to">
        <a class="go-to-top" href="#top">
          <i class="material-icons">keyboard_arrow_upward</i>
        </a>
        <xsl:element name="a">
          <xsl:attribute name="href">
            <xsl:choose>
              <xsl:when test="contains(@href, '#')">
                <xsl:variable name="xID" select="substring-before(@href, '#')"/>
                <xsl:variable name="Anchor" select="substring-after(@href, '#')"/>
                <xsl:variable name="newLink" select="concat($xID, '.xml')" />
                <xsl:value-of select="concat($newLink, '#', $Anchor)"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:variable name="xID" select="substring-before(@href, '#')"/>
                <xsl:variable name="newLink" select="concat(@href, '.xml')" />
                <xsl:value-of select="$newLink"/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:attribute>
          <xsl:apply-templates select="./topicmeta/navtitle"/>
        </xsl:element>
      </h2>
      <xsl:apply-templates select="./topicmeta/shortdesc"/>
      <xsl:element name="ol">
        <!--<xsl:apply-templates select="./topicref[not(@toc = 'no') and not(@type='reference')]"/>-->
        <xsl:apply-templates select="./topicref[not(@processing-role= 'resource-only') and not(@type='glossentry') and not(@outputclass='frontmatter') and not(@outputclass= 'backmatter')]" mode="toc"/>
        <xsl:apply-templates select="./topicref[not(@processing-role= 'resource-only') and not(@type='glossentry') and @outputclass='frontmatter' or @outputclass= 'backmatter']" mode="toc"/>
        <xsl:apply-templates select="./chapter[not(@processing-role= 'resource-only')]" mode="toc"/>
      </xsl:element>
    </div>
  </xsl:template>

  <xsl:template match="appendices">
    <div class="appendices">
      <h2 class="scroll-to">
        <a class="go-to-top" href="#top">
          <i class="material-icons">keyboard_arrow_upward</i>
        </a>
        <xsl:element name="a">
          <xsl:attribute name="href">
            <xsl:choose>
              <xsl:when test="contains(@href, '#')">
                <xsl:variable name="xID" select="substring-before(@href, '#')"/>
                <xsl:variable name="Anchor" select="substring-after(@href, '#')"/>
                <xsl:variable name="newLink" select="concat($xID, '.xml')" />
                <xsl:value-of select="concat($newLink, '#', $Anchor)"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:variable name="xID" select="substring-before(@href, '#')"/>
                <xsl:variable name="newLink" select="concat(@href, '.xml')" />
                <xsl:value-of select="$newLink"/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:attribute>
          <xsl:apply-templates select="./topicmeta/navtitle"/>
        </xsl:element>
      </h2>
      <xsl:apply-templates select="./topicmeta/shortdesc"/>
      <xsl:element name="ol">
        <!--<xsl:apply-templates select="./topicref[not(@toc = 'no') and not(@type='reference')]"/>-->
        <xsl:apply-templates select="./topicref[not(@processing-role= 'resource-only') and not(@type='glossentry') and not(@outputclass='frontmatter') and not(@outputclass= 'backmatter')]" mode="toc"/>
        <xsl:apply-templates select="./topicref[not(@processing-role= 'resource-only') and not(@type='glossentry') and @outputclass='frontmatter' or @outputclass= 'backmatter']" mode="toc"/>
        <xsl:apply-templates select="./appendix[not(@processing-role= 'resource-only')]" mode="toc"/>
      </xsl:element>
    </div>
  </xsl:template>

  <xsl:template match="topichead[@href != '']">
    <h2>
      <xsl:element name="a">
        <xsl:attribute name="href">
          <xsl:choose>
            <xsl:when test="contains(@href, '#')">
              <xsl:variable name="xID" select="substring-before(@href, '#')"/>
              <xsl:variable name="Anchor" select="substring-after(@href, '#')"/>
              <xsl:variable name="newLink" select="concat($xID, '.xml')" />
              <xsl:value-of select="concat($newLink, '#', $Anchor)"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="@href"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:attribute>
        <xsl:apply-templates select="./topicmeta/navtitle"/>
      </xsl:element>
    </h2>
    <xsl:element name="ol">
      <!--<xsl:apply-templates select="./topicref[not(@toc = 'no') and not(@type='reference')]"/>-->
      <xsl:apply-templates select="./topicref[not(@toc = 'no') and not(@processing-role= 'resource-only') and not(@type='glossentry') and not(@outputclass='frontmatter') and not(@outputclass= 'backmatter')]"/>
      <xsl:apply-templates select="./topicref[not(@toc = 'no') and not(@processing-role= 'resource-only') and not(@type='glossentry') and @outputclass='frontmatter' or @outputclass= 'backmatter']"/>
    </xsl:element>
  </xsl:template>

  <xsl:template match="chapter[@navtitle != '']">
    <h2>
      <xsl:value-of select="@navtitle"/>
    </h2>
    <hr/>
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="mainbooktitle">
    <xsl:apply-templates />
  </xsl:template>

  <!-- Composite DITA File from chunk=to-content -->
  <xsl:template match="dita">
    <div class="anchor-offset" id="{@id}">
      <xsl:apply-templates/>
    </div>
  </xsl:template>

  <xsl:template match="dita/concept">
    <div class="anchor-offset" id="{@id}">
      <xsl:apply-templates select="./title"/>
      <xsl:apply-templates select="./shortdesc"/>
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
    </div>
  </xsl:template>

  <xsl:template match="dita/reference">
    <div class="anchor-offset" id="{@id}">
      <xsl:apply-templates select="./title"/>
      <xsl:apply-templates select="./shortdesc"/>
      <xsl:call-template name="prerequisites"/>
      <xsl:apply-templates select="./refbody"/>
      <xsl:apply-templates select="./related-links" />
      <xsl:variable name="allSectionNodes" select=".//concept | .//reference | .//task | .//topic"/>
      <xsl:for-each select="$allSectionNodes">
        <xsl:apply-templates select="." mode="isComposite"/>
      </xsl:for-each>
      <xsl:call-template name="footnotes"/>
    </div>
  </xsl:template>

  <xsl:template match="dita/task">
    <div class="anchor-offset" id="{@id}">
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
    </div>
  </xsl:template>

  <xsl:template match="dita/topic">
    <div class="anchor-offset" id="{@id}">
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
    </div>
  </xsl:template>

  <!-- DITA Glossentry Template -->
  <xsl:template match="glossentry">
    <div class="anchor-offset" id="{@id}">
      <xsl:apply-templates select="./title"/>
      <!--<xsl:apply-templates select="shortdesc" />-->
      <xsl:apply-templates select="./glossBody">
        <xsl:with-param name="glossterm" select="glossterm"/>
        <xsl:with-param name="glossdef" select="glossdef"/>
      </xsl:apply-templates>
      <!--<xsl:apply-templates select="./related-links" />-->
    </div>
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

  <xsl:template match="topichead">
    <xsl:apply-templates/>
  </xsl:template>
  
  <!-- DITA Map Template : TOC -->
  <xsl:template match="map">
    <xsl:choose>
      <xsl:when test="$ViewMode = 'SinglePageMap'">
        <xsl:apply-templates select="./title"/>
        <!--<xsl:apply-templates select="./topicmeta/shortdesc"/>-->
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
        <xsl:apply-templates select="/*/topicmeta/following-sibling::*" mode="noli"/>
        <!--<xsl:element name="div">
          <xsl:attribute name="class">
            <xsl:value-of select="'related-links'"/>
          </xsl:attribute>
          <xsl:element name="ul">
            <xsl:attribute name="class">
              <xsl:value-of select="'ullinks'"/>
            </xsl:attribute>
            --><!--<xsl:apply-templates select="./topicref[not(@toc = 'no') and not(@type='reference')]"/>--><!--
            <xsl:apply-templates select="./topicref[not(@toc = 'no') and not(@processing-role= 'resource-only') and not(@type='glossentry') and not(@outputclass='frontmatter') and not(@outputclass= 'backmatter')]" mode="tocwithdesc"/>
            <xsl:apply-templates select="./topicref[not(@toc = 'no') and not(@processing-role= 'resource-only') and not(@type='glossentry') and @outputclass='frontmatter' or @outputclass= 'backmatter']" mode="tocwithdesc"/>
          </xsl:element>
        </xsl:element>-->
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates select="./title"/>
        <xsl:element name="ol">
          <xsl:attribute name="class">
            <xsl:value-of select="'toc'"/>
          </xsl:attribute>
          <!--<xsl:apply-templates select="./topicref[not(@toc = 'no') and not(@type='reference')]"/>-->
          <xsl:apply-templates select="./topicref[not(@toc = 'no') and not(@processing-role= 'resource-only') and not(@type='glossentry') and not(@outputclass='frontmatter') and not(@outputclass= 'backmatter')]"/>
          <xsl:apply-templates select="./topicref[not(@toc = 'no') and not(@processing-role= 'resource-only') and not(@type='glossentry') and @outputclass='frontmatter' or @outputclass= 'backmatter']"/>
        </xsl:element>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="topicgroup[@outputclass='tabs']" mode="noli">
    <div class="tabs-container">
      <ul class="nav nav-tabs">
          <xsl:for-each select="./topicref">
            <xsl:element name="li">
              <xsl:if test="position()=1">
                <xsl:attribute name="class">
                  <xsl:value-of select="'active'"/>
                </xsl:attribute>
              </xsl:if>
              <xsl:element name="a">
                <xsl:attribute name="class">
                  <xsl:value-of select="'btn btn-primary'"/>
                </xsl:attribute>
                <xsl:attribute name="data-toggle">
                  <xsl:value-of select="'tab'"/>
                </xsl:attribute>
                <xsl:attribute name="href">
                  <xsl:value-of select="concat('#', @href)"/>
                </xsl:attribute>
                <xsl:value-of select="@navtitle"/>
              </xsl:element>
            </xsl:element>            
          </xsl:for-each>
      </ul>
      <div class="tab-content">
        <xsl:for-each select="./topicref">
          <xsl:variable name="DivClass">
            <xsl:choose>
              <xsl:when test="position()=1">
                <xsl:value-of select="'tab-pane fade in active show'"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="'tab-pane fade'"/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:variable>

          <div class="{$DivClass} tab-insert" data-id="{@href}" id="{@href}" data-url="{concat(@href, '.xml')}">&#160;</div>
        </xsl:for-each>
      </div>
    </div>
  </xsl:template>

  <xsl:template match="topicgroup[@outputclass='stack']" mode="noli">
    <div class="stack-container">
      <div class="panel-group" id="accordion">
        <xsl:for-each select="./topicref">
          <div class="panel panel-default">
            <div class="panel-heading">
              <h4 class="panel-title">
                <a data-toggle="collapse" data-parent="#accordion" href="{concat('#', @href)}">
                  <xsl:value-of select="@navtitle"/>
                </a>
              </h4>
            </div>
            <div class="load-accordion panel-collapse collapse" id="{@href}" data-url="{concat(@href, '.xml')}">
              <div class="panel-body">
                <div id="{concat('accordion-', @href)}" class="accordion-insert" data-id="{@href}">
                  &#160;
                </div>
              </div>
            </div>
          </div>
        </xsl:for-each>        
      </div>
    </div>
  </xsl:template>

  <xsl:template match="topicref" mode="noli">
    <xsl:if test="@navtitle != ''">
      <xsl:choose>
        <xsl:when test="following-sibling::topicgroup[@outputclass='stack']">
          <div>
            <h2 class="accordion-header">
              <xsl:value-of select="@navtitle"/>
            </h2>
          </div>
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates select="."/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:if>
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
            <xsl:attribute name="href">
              <xsl:choose>
                <xsl:when test="contains(@href, '#')">
                  <xsl:variable name="xID" select="substring-before(@href, '#')"/>
                  <xsl:variable name="Anchor" select="substring-after(@href, '#')"/>
                  <xsl:variable name="newLink" select="concat($xID, '.xml')" />
                  <xsl:value-of select="concat($newLink, '#', $Anchor)"/>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:variable name="xID" select="substring-before(@href, '#')"/>
                  <xsl:variable name="newLink" select="concat(@href, '.xml')" />
                  <xsl:value-of select="$newLink"/>
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
                <xsl:value-of select="normalize-space(concat(./@href, '.xml'))"/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:element>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:if test="topicref[not(@toc = 'no') and not(@processing-role= 'resource-only') and not(@type='glossentry') and not(@outputclass='frontmatter') and not(@outputclass= 'backmatter')]">
        <xsl:element name="ol">
          <xsl:attribute name="class">
            <xsl:value-of select="'toc'"/>
          </xsl:attribute>
          <xsl:apply-templates select="topicref[not(@toc = 'no') and not(@processing-role= 'resource-only') and not(@type='glossentry') and not(@outputclass='frontmatter') and not(@outputclass= 'backmatter')]"/>
        </xsl:element>
      </xsl:if>
    </xsl:element>
  </xsl:template>

  <xsl:template match="topicref" mode="toc">
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
            <xsl:attribute name="href">
              <xsl:choose>
                <xsl:when test="contains(@href, '#')">
                  <xsl:variable name="xID" select="substring-before(@href, '#')"/>
                  <xsl:variable name="Anchor" select="substring-after(@href, '#')"/>
                  <xsl:variable name="newLink" select="concat($xID, '.xml')" />
                  <xsl:value-of select="concat($newLink, '#', $Anchor)"/>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:variable name="xID" select="substring-before(@href, '#')"/>
                  <xsl:variable name="newLink" select="concat(@href, '.xml')" />
                  <xsl:value-of select="$newLink"/>
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
                <xsl:value-of select="normalize-space(concat(./@href, '.xml'))"/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:element>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:if test="./topicmeta/shortdesc != ''">
        <xsl:apply-templates select="./topicmeta/shortdesc"/>
      </xsl:if>
      <xsl:if test="topicref[not(@toc = 'no') and not(@processing-role= 'resource-only') and not(@type='glossentry') and not(@outputclass='frontmatter') and not(@outputclass= 'backmatter')]">
        <xsl:element name="ol">
          <xsl:attribute name="class">
            <xsl:value-of select="'toc'"/>
          </xsl:attribute>
          <xsl:apply-templates select="topicref[not(@toc = 'no') and not(@processing-role= 'resource-only') and not(@type='glossentry') and not(@outputclass='frontmatter') and not(@outputclass= 'backmatter')]" mode="toc"/>
        </xsl:element>
      </xsl:if>
    </xsl:element>
  </xsl:template>

  <xsl:template match="chapter" mode="toc">
    <xsl:element name="li">
      <xsl:attribute name="class">
        <xsl:value-of select="'chapter'"/>
      </xsl:attribute>
      <xsl:element name="a">
        <xsl:attribute name="href">
          <xsl:choose>
            <xsl:when test="contains(@href, '#')">
              <xsl:variable name="xID" select="substring-before(@href, '#')"/>
              <xsl:variable name="Anchor" select="substring-after(@href, '#')"/>
              <xsl:variable name="newLink" select="concat($xID, '.xml')" />
              <xsl:value-of select="concat($newLink, '#', $Anchor)"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:variable name="xID" select="substring-before(@href, '#')"/>
              <xsl:variable name="newLink" select="concat(@href, '.xml')" />
              <xsl:value-of select="$newLink"/>
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
            <xsl:value-of select="normalize-space(concat(./@href, '.xml'))"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:element>
      <xsl:if test="./topicmeta/shortdesc != ''">
        <xsl:apply-templates select="./topicmeta/shortdesc"/>
      </xsl:if>
      <xsl:if test="topicref[not(@toc = 'no') and not(@processing-role= 'resource-only') and not(@type='glossentry') and not(@outputclass='frontmatter') and not(@outputclass= 'backmatter')]">
        <xsl:element name="ol">
          <xsl:attribute name="class">
            <xsl:value-of select="'toc'"/>
          </xsl:attribute>
          <xsl:apply-templates select="topicref[not(@toc = 'no') and not(@processing-role= 'resource-only') and not(@type='glossentry') and not(@outputclass='frontmatter') and not(@outputclass= 'backmatter')]" mode="toc"/>
        </xsl:element>
      </xsl:if>
    </xsl:element>
  </xsl:template>

  <!-- DITA Concept Template -->
  <xsl:template match="concept">
    <div class="anchor-offset" id="{@id}">
      <xsl:apply-templates select="./title"/>
      <xsl:apply-templates select="./shortdesc"/>
      <xsl:call-template name="prerequisites"/>
      <xsl:apply-templates select="./conbody"/>
      <xsl:call-template name="footnotes"/>
      <xsl:apply-templates select="./related-links" />
    </div>
  </xsl:template>

  <!-- DITA Concept Composite Template -->
  <xsl:template match="concept" mode="isComposite">
    <xsl:param name="sectionNumber" />
    <xsl:variable name="localFootnotes" select=".//fn"/>
    <xsl:apply-templates select="./title" mode="sectionTitle">
      <xsl:with-param name="sectionNumber" select="$sectionNumber" />
    </xsl:apply-templates>
    <xsl:apply-templates select="./shortdesc"/>
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
    <div class="body conbody">
      <xsl:apply-templates />
    </div>
  </xsl:template>

  <!-- DITA Reference Template -->
  <xsl:template match="reference">
    <div class="anchor-offset" id="{@id}">
      <xsl:apply-templates select="./title"/>
      <xsl:apply-templates select="./shortdesc"/>
      <xsl:call-template name="prerequisites"/>
      <xsl:apply-templates select="./refbody"/>
      <xsl:call-template name="footnotes"/>
      <xsl:apply-templates select="./related-links" />
    </div>
  </xsl:template>

  <!-- DITA Reference Composite Template -->
  <xsl:template match="reference" mode="isComposite">
    <xsl:param name="sectionNumber" />
    <xsl:variable name="localFootnotes" select=".//fn"/>
    <xsl:apply-templates select="./title" mode="sectionTitle">
      <xsl:with-param name="sectionNumber" select="$sectionNumber" />
    </xsl:apply-templates>
    <xsl:apply-templates select="./shortdesc"/>
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
    <div class="body refbody">
      <xsl:apply-templates />
    </div>
  </xsl:template>

  <!-- DITA Task Template -->
  <xsl:template match="task">
    <div class="anchor-offset" id="{@id}">
      <xsl:apply-templates select="./title"/>
      <xsl:apply-templates select="./shortdesc"/>
      <xsl:call-template name="prerequisites"/>
      <xsl:apply-templates select="./taskbody"/>
      <xsl:call-template name="footnotes"/>
      <xsl:apply-templates select="./related-links" />
    </div>
  </xsl:template>

  <!-- DITA Task Composite Template -->
  <xsl:template match="task" mode="isComposite">
    <xsl:param name="sectionNumber" />
    <xsl:variable name="localFootnotes" select=".//fn"/>
    <xsl:apply-templates select="./title" mode="sectionTitle">
      <xsl:with-param name="sectionNumber" select="$sectionNumber" />
    </xsl:apply-templates>
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
    <div class="anchor-offset" id="{@id}">
      <xsl:apply-templates select="./title"/>
      <xsl:apply-templates select="./shortdesc"/>
      <xsl:call-template name="prerequisites"/>
      <xsl:apply-templates select="./body"/>
      <xsl:call-template name="footnotes"/>
      <xsl:apply-templates select="./related-links" />
    </div>
  </xsl:template>

  <!-- DITA Topic Composite Template -->
  <xsl:template match="topic" mode="isComposite">
    <xsl:param name="sectionNumber" />
    <xsl:variable name="localFootnotes" select=".//fn"/>
    <xsl:apply-templates select="./title" mode="sectionTitle">
      <xsl:with-param name="sectionNumber" select="$sectionNumber" />
    </xsl:apply-templates>
    <xsl:apply-templates select="./shortdesc"/>
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
  <xsl:template match="p-topic">
    <div class="anchor-offset" id="{@id}">
      <xsl:apply-templates select="./title"/>
      <xsl:apply-templates select="./shortdesc"/>
      <xsl:call-template name="prerequisites"/>
      <xsl:apply-templates select="./body"/>
      <xsl:call-template name="footnotes"/>
      <xsl:apply-templates select="./related-links" />
    </div>
  </xsl:template>

  <!-- DITA Topic Composite Template -->
  <xsl:template match="p-topic" mode="isComposite">
    <xsl:param name="sectionNumber" />
    <xsl:variable name="localFootnotes" select=".//fn"/>
    <xsl:apply-templates select="./title" mode="sectionTitle">
      <xsl:with-param name="sectionNumber" select="$sectionNumber" />
    </xsl:apply-templates>
    <xsl:apply-templates select="./shortdesc"/>
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
      <h3>Prerequisites</h3>
      <ul style="list-style-type:none;">
        <!--<xsl:apply-templates select=".//link[@importance='required']" />-->
        <xsl:for-each select=".//link[@importance='required']">
          <li class="related-link">
            <a href="{concat(@href, '.xml')}">
              <xsl:value-of select="linktext"/>
            </a>
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




  <!-- Task Body Template -->
  <xsl:template match="taskbody">
    <div class="body taskbody">
      <xsl:apply-templates />
    </div>
  </xsl:template>

  <!-- Task Body Template -->
  <xsl:template match="body">
    <div class="body taskbody">
      <xsl:apply-templates />
    </div>
  </xsl:template>

  <xsl:template match="context">
    <!--<h3>About this task</h3>-->
    <xsl:apply-templates />
    <!--<div class="spacer">&#160;</div>-->
  </xsl:template>

  <xsl:template match="prereq">
    <div class="prereq">
      <h3>Prerequisites</h3>
      <xsl:if test="//link[@importance='required']">
        <ul style="list-style-type:none;">
          <xsl:for-each select="//link[@importance='required']">
            <li class="related-link">
              <a href="{concat(@href, '.xml')}">
                <xsl:apply-templates select="linktext"/>
              </a>
            </li>
          </xsl:for-each>
        </ul>
      </xsl:if>
      <xsl:apply-templates />
    </div>
    <div class="spacer">&#160;</div>
  </xsl:template>

  <xsl:template match="postreq">
    <h3>What to do next</h3>
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="text()[normalize-space()][1]">
    <xsl:if test=". != ''">
      <xsl:value-of select="."/>
    </xsl:if>
  </xsl:template>



  <xsl:template match="xref[not(starts-with(@href, '#'))]">
    <xsl:text> </xsl:text>
    <xsl:element name="a">
      <xsl:attribute name="href">
        <xsl:choose>
          <xsl:when test="@format = 'email'">
            <xsl:text>mailto:</xsl:text>
            <xsl:value-of select="." />
          </xsl:when>
          <xsl:when test="@scope = 'external'">
            <xsl:value-of select="./@href"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:variable name="path" select="substring-before(concat(./@href, '#'), '#')"/>
            <xsl:value-of select="concat($path, '.xml')"/>
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
          <xsl:value-of select="concat(./@href, '.xml')"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:element>
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

  <xsl:template match="steps">
    <!--<h3>Procedure</h3>-->
    <ol class="ol">
      <xsl:for-each select="step">
        <li class="li">
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
    <!--<h3>Procedure</h3>-->
    <ul>
      <xsl:for-each select="step">
        <li class="li">
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

  <xsl:template match="substeps">
    <ol class="ol">
      <xsl:for-each select="substep">
        <li class="li">
          <xsl:apply-templates select="node()"/>
        </li>
      </xsl:for-each>
    </ol>
  </xsl:template>

  <xsl:template match="result">
    <h3>Results</h3>
    <xsl:if test="node()[string-length() != 0]">
      <p>
        <xsl:apply-templates select="node()[string-length() != 0]"/>
      </p>
    </xsl:if>
  </xsl:template>

  <xsl:template match="stepresult">
    <div class="itemgroup stepresult">
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
  <xsl:template match="cmd">
    <xsl:apply-templates select="node()"/>
  </xsl:template>

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
    <span class="uicontrol">
      <xsl:apply-templates />
    </span>
  </xsl:template>
  <xsl:template match="wintitle">
    <span class="wintitle">
      <xsl:apply-templates />
    </span>
  </xsl:template>
  <xsl:template match="shortcut">
    <span class="shortcut">
      <xsl:apply-templates />
    </span>
  </xsl:template>

  <!-- programming-domain.ent domain: codeblock | codeph | var | kwd | synph | oper | delim | sep | repsep |
                                    option | parmname | apiname-->

  <xsl:template match="codeblock">
    <xsl:if test="node()[string-length() != 0]">
      <pre class="codeblock">
        <code class="codeblock">
          <xsl:apply-templates select="node()" />
        </code>
      </pre>
    </xsl:if>
  </xsl:template>

  <xsl:template match="codeph">
    <xsl:if test="node()[string-length() != 0]">
      <code class="codeph">
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
      <code class="userinput">
        <xsl:value-of select="node()"/>
      </code>
    </xsl:if>
  </xsl:template>
  <xsl:template match="systemoutput">
    <xsl:if test="node()[string-length() != 0]">
      <code class="systemoutput">
        <xsl:value-of select="node()"/>
      </code>
    </xsl:if>
  </xsl:template>
  <xsl:template match="cmdname">
    <xsl:if test="node()[string-length() != 0]">
      <code class="cmdname">
        <xsl:apply-templates select="node()" />
      </code>
    </xsl:if>
  </xsl:template>

  <xsl:template match="filepath">
    <xsl:if test="node()[string-length() != 0]">
      <code class="filepath">
        <xsl:apply-templates select="node()" />
      </code>
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
    <p class="info">
      <xsl:apply-templates />
    </p>
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
    <xsl:apply-templates select="learningSummarybody"/>
  </xsl:template>

  <xsl:template match="learningSummarybody">
    <xsl:apply-templates select="lcObjectives"/>
  </xsl:template>

  <!-- Specific Node Templates -->
  <xsl:template match="title">
    <xsl:if test=". != ''">
      <h1>
        <xsl:apply-templates />
      </h1>
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
    <xsl:if test=". != ''">
      <h2>
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
    <ul class="">
      <xsl:apply-templates/>
    </ul>
  </xsl:template>

  <xsl:template match="li">
    <li>
      <xsl:apply-templates/>
    </li>
  </xsl:template>
  <xsl:template match="ol">
    <ol class="">
      <xsl:apply-templates/>
    </ol>
  </xsl:template>

  <xsl:template match="lcObjectives/title">
    <xsl:if test=". != ''">
      <h2>
        <xsl:apply-templates/>
      </h2>
    </xsl:if>
  </xsl:template>

  <xsl:template match="shortdesc">
    <p class="shortdesc">
      <xsl:apply-templates/>
    </p>
  </xsl:template>

  <xsl:template match="fig">
    <xsl:variable name="currentFigure" select="."/>
    <figure>
      <xsl:apply-templates select="image"/>
      <xsl:if test="./title != ''">
        <figcaption>
          <strong>
            <em>
              <xsl:for-each select="$allFigures">
                <xsl:if test="generate-id(./title) = generate-id($currentFigure/title)">
                  <xsl:text>Figure </xsl:text>
                  <xsl:value-of select="position()"/>
                  <xsl:text>: </xsl:text>
                </xsl:if>
              </xsl:for-each>
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
    <xsl:apply-templates select="node()" />
  </xsl:template>

  <xsl:template match="section/title">
    <h2 class="scroll-to">
      <a class="go-to-top" href="#top">
        <i class="material-icons">keyboard_arrow_upward</i>
      </a>
      <xsl:apply-templates/>
    </h2>
  </xsl:template>

  <xsl:template match="p">
    <!--<xsl:if test="not(./cite)">
      <p>
        <xsl:apply-templates select="node()"/>
      </p>
    </xsl:if>-->
    <p>
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
    <xsl:choose>
      <xsl:when test="@type = 'danger'">
        <div class="note dangertitle">
          <xsl:call-template name="getNoteIcon">
            <xsl:with-param name="type" select="$type"/>
          </xsl:call-template>
          <xsl:text>DANGER </xsl:text>
        </div>
        <div class="danger">
          <xsl:apply-templates/>
        </div>
      </xsl:when>
      <xsl:when test="@type = 'caution'">
        <div class="note cautiontitle">
          <xsl:call-template name="getNoteIcon">
            <xsl:with-param name="type" select="$type"/>
          </xsl:call-template>
          <xsl:text>CAUTION: </xsl:text>
        </div>
        <div class="caution">
          <xsl:apply-templates/>
        </div>
      </xsl:when>
      <xsl:otherwise>
        <div class="note {$type}">
          <xsl:choose>
            <xsl:when test="normalize-space($title)">
              <span class="{$type}title">
                <xsl:call-template name="getNoteIcon">
                  <xsl:with-param name="type" select="$type"/>
                </xsl:call-template>
                <xsl:value-of select="concat($title, ': ')"/>
              </span>
              <xsl:text> </xsl:text>
            </xsl:when>
            <xsl:otherwise>
              <span class="notetitle">
                <xsl:call-template name="getNoteIcon">
                  <xsl:with-param name="type" select="''"/>
                </xsl:call-template>
                <xsl:value-of select="concat('Note', ': ')"/>
              </span>
            </xsl:otherwise>
          </xsl:choose>
          <xsl:apply-templates/>
        </div>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>


  <xsl:template name="getNoteIcon">
    <xsl:param name="type"/>
    <xsl:choose>
      <xsl:when test="$type = ''">
        <i class="material-icons">library_books</i>
      </xsl:when>
      <xsl:when test="$type = 'attention'">
        <i class="material-icons icon-{$type}">library_books</i>
      </xsl:when>
      <xsl:when test="$type = 'caution'">
        <i class="material-icons {$type}-symbol">warning</i>
      </xsl:when>
      <xsl:when test="$type = 'danger'">
        <i class="material-icons {$type}-symbol">warning</i>
      </xsl:when>
      <xsl:when test="$type = 'fastpath'">
        <i class="material-icons {$type}-symbol">library_books</i>
      </xsl:when>
      <xsl:when test="$type = 'important'">
        <i class="material-icons {$type}-symbol">error</i>
      </xsl:when>
      <xsl:when test="$type = 'note'">
        <i class="material-icons {$type}-symbol">library_books</i>
      </xsl:when>
      <xsl:when test="$type = 'notice'">
        <i class="material-icons {$type}-symbol">library_books</i>
      </xsl:when>
      <xsl:when test="$type = 'other'">
        <i class="material-icons {$type}-symbol">library_books</i>
      </xsl:when>
      <xsl:when test="$type = 'remember'">
        <i class="material-icons {$type}-symbol">library_books</i>
      </xsl:when>
      <xsl:when test="$type = 'restriction'">
        <i class="material-icons {$type}-symbol">not_interested</i>
      </xsl:when>
      <xsl:when test="$type = 'tip'">
        <i class="material-icons {$type}-symbol">info</i>
      </xsl:when>
      <xsl:when test="$type = 'trouble'">
        <i class="material-icons {$type}-symbol">build</i>
      </xsl:when>
      <xsl:when test="$type = 'warning'">
        <i class="material-icons {$type}-symbol">error</i>
      </xsl:when>
    </xsl:choose>

  </xsl:template>

  <!-- description list templates -->
  <xsl:template match="dl">
    <dl>
      <xsl:apply-templates />
    </dl>
  </xsl:template>

  <xsl:template match="dlentry">
    <xsl:apply-templates />
  </xsl:template>

  <xsl:template match="dt">
    <dt>
      <strong>
        <xsl:apply-templates/>
      </strong>
    </dt>
  </xsl:template>

  <xsl:template match="dd">
    <dd>
      <xsl:apply-templates/>
    </dd>
  </xsl:template>

  <!-- end description list templates -->

  <!-- table templates -->
  <xsl:template match="table">
    <xsl:variable name="current" select="."/>
    <div class="table-wrap">
      <xsl:element name="table">
        <xsl:if test="./title != ''">
          <h4 class="custom-h4 table-title">
            <!-- table counter here -->
            <xsl:for-each select="$allTables">
              <xsl:if test="generate-id() = generate-id($current/title)">
                <xsl:text>Table </xsl:text>
                <xsl:value-of select="position()"/>
                <xsl:text>: </xsl:text>
              </xsl:if>
            </xsl:for-each>
            <xsl:apply-templates select="./title" />
          </h4>
        </xsl:if>
        <xsl:apply-templates select="./tgroup"/>
      </xsl:element>
    </div>
  </xsl:template>

  <xsl:template match="properties">
    <div class="table-wrap">
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
    <div class="table-wrap">
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
    <xsl:apply-templates select="thead"/>
    <xsl:apply-templates select="tbody">
      <xsl:with-param name="colSpan" select="./@cols"/>
    </xsl:apply-templates>
  </xsl:template>

  <xsl:template match="thead">
    <thead align="left" style="display: table-header-group;">
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

  <xsl:template match="entry" mode="table-head">
    <xsl:variable name="namest" select="substring(@namest, 4, 2)"/>
    <xsl:variable name="nameend" select="substring(@nameend, 4, 2)"/>
    <th>
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
    </th>
  </xsl:template>
  <!-- end table templates -->

  <!-- simpletable templates -->
  <xsl:template match="simpletable">
    <div class="table-wrap">
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

  <!--<xsl:template match="sl[@outputclass='twocol']">
    <xsl:variable name="count" select="ceiling(count(sli) div 2)"/>
    <div class="row">
      <xsl:for-each select="sli[position() = 1 or position() = $count + 1]">
        <div class="col-md-6">
          <ul style="list-style-type:none;">
            <xsl:apply-templates />
          </ul>
        </div>
      </xsl:for-each>
    </div>
  </xsl:template>-->
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
    <xsl:call-template name="build-minitoc"/>
    <xsl:call-template name="build-related-links"/>
  </xsl:template>

  <xsl:template name="build-minitoc">
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
  </xsl:template>

  <xsl:template name="build-related-links">
    <div class='related-information'>
      <xsl:if test="//link[@role='friend']">
        <strong>Related information</strong>
      </xsl:if>
      <xsl:for-each select="//link[@role='friend']">
        <div class="related-link">
          <a href="{concat(@href, '.xml')}">
            <xsl:apply-templates select="linktext"/>
          </a>
        </div>
      </xsl:for-each>
    </div>
    <div class="spacer">&#160;</div>
  </xsl:template>

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

  <xsl:template match="p/image">
    <xsl:choose>
      <xsl:when test="contains(@href, '.svg') or contains(@href, '.svgz')">
        <p class="img-wrap">
          <object id="@id" data="assets/{./@href}" type="image/svg+xml">
            <img src="assets/{./@href}" alt="" />
          </object>
        </p>
      </xsl:when>
      <xsl:otherwise>
        <img src="assets/{./@href}" alt="" />
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
          <img src="assets/{./@href}" alt="" />
        </p>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>



  <!-- identity transform -->
  <xsl:template match="@* | node()">
    <xsl:copy>
      <xsl:apply-templates select="@* | node()"/>
    </xsl:copy>
  </xsl:template>
</xsl:stylesheet>
