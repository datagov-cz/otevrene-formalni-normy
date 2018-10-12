<xsl:stylesheet
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:db="http://docbook.org/ns/docbook"
  xmlns:fn="http://www.w3.org/2005/xpath-functions"
  xmlns:gen="https://data.gov.cz/otevřené-formální-normy/generátor"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  version="3.0" expand-text="yes">

  <xsl:template match="db:abstract">
        <section id="abstract" class="introductory">
            <h2>Abstrakt</h2>
            <p>
              <xsl:value-of select="text()" />
            </p>
        </section>
  </xsl:template>

  <xsl:function name="gen:generujPřehled" as="element()">
    <xsl:param name="json" as="xs:string" />
    <section id="přehled">
      <h2>Přehled</h2>
      <xsl:apply-templates select="fn:json-to-xml(fn:unparsed-text($json))" mode="přehled" />
    </section>
  </xsl:function>

  <xsl:template match="fn:map" mode="přehled">
    Datová sada je tvořena seznamem instancí typu <a><xsl:value-of select="fn:map/fn:map/fn:map[fn:string[@key='type'] = 'object']/fn:string[@key='title']" /></a> uvedených v poli <code>položky</code>.
    <ul>
      <xsl:for-each select=".//fn:map[fn:string[@key='type'] = 'object']">
        <li>
          <a><xsl:value-of select="fn:string[@key='title']/text()" /></a> obsahuje následující nepovinné vlastnosti:
          <ul>
            <xsl:for-each select="./fn:map/fn:map">
              <li>
                <code><xsl:value-of select="@key" /></code> : <a><xsl:value-of select="fn:string[@key='title']/text()" /></a>
                <xsl:if test="./fn:string[@key='type'] = 'array'">
                  (seznam instancí typu <a><xsl:value-of select="fn:map/fn:string[@key='title']/text()" /></a>)
                </xsl:if>
              </li>
            </xsl:for-each>
          </ul>
        </li>
      </xsl:for-each>
    </ul>
  </xsl:template>

  <xsl:function name="gen:generujSpecifikaci" as="element()">
    <xsl:param name="json" as="xs:string" />
    <section id="specifikace">
      <h2>Specifikace</h2>
      <xsl:apply-templates select="fn:json-to-xml(fn:unparsed-text($json))" mode="specifikace" />
    </section>
  </xsl:function>

  <xsl:template match="fn:map" mode="specifikace">
    V této části jsou definovány jednotlivé typy objektů a jejich vlastnosti.
    Pro každou vlastnost je uveden její klíč používaný v JSON reprezentaci, její název, datový typ, popis a příklad.
    <xsl:for-each select=".//fn:map[fn:string[@key='type'] = 'object']">
      <section>
        <xsl:attribute name="id" select="fn:string[@key='title']/text()" />
        <h3><dfn><xsl:value-of select="fn:string[@key='title']/text()" /></dfn></h3>
        <p><xsl:value-of select="fn:string[@key='description']/text()" /></p>
        <section>
          <xsl:attribute name="id" select="fn:concat('vlastnosti-', fn:string[@key='title']/text())" />
          <h4>Vlasnosti typu <xsl:value-of select="fn:string[@key='title']/text()" /></h4>
          <xsl:for-each select="./fn:map/fn:map">
            <section>
              <xsl:attribute name="id" select="fn:string[@key='title']/text()" />
              <h5>
                <xsl:choose>
                  <xsl:when test="fn:string[@key='type'] = 'object'">
                    <xsl:value-of select="fn:string[@key='title']/text()" />
                  </xsl:when>
                  <xsl:otherwise>
                    <dfn><xsl:value-of select="fn:string[@key='title']/text()" /></dfn>
                  </xsl:otherwise>
                </xsl:choose>
              </h5>
              <dl>
                <dt>
                    Vlastnost
                </dt>
                <dd>
                    <code><xsl:value-of select="@key" /></code>
                </dd>
                <dt>
                    Typ
                </dt>
                <dd>
                    <xsl:value-of select="fn:string[@key='type']/text()" />
                    <xsl:if test="fn:string[@key='type'] = 'array'"> of <a><xsl:value-of select="fn:map/fn:string[@key='title']/text()" /></a>
              </xsl:if>
                </dd>
                <dt>
                    Jméno
                </dt>
                <dd>
                    <xsl:value-of select="fn:string[@key='title']/text()" />
                </dd>
                <dt>
                    Popis
                </dt>
                <dd>
                    <xsl:value-of select="fn:string[@key='description']/text()" />
                </dd>
                <dt>
                    Příklad
                </dt>
                <dd>
                    <code>TODO</code>
                </dd>
              </dl>
            </section>
          </xsl:for-each>
        </section>
      </section>
    </xsl:for-each>
  </xsl:template>

</xsl:stylesheet>