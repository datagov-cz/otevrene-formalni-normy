<xsl:stylesheet
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:db="http://docbook.org/ns/docbook"
  xmlns:fn="http://www.w3.org/2005/xpath-functions"
  xmlns:gen="https://data.gov.cz/otevřené-formální-normy/generátor"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  version="3.0" expand-text="yes">

  <xsl:template match="db:article" mode="abstrakt">
    <xsl:apply-templates select="db:info/db:abstract" />
  </xsl:template>
  
  <xsl:template match="db:abstract" mode="abstrakt">
        <section id="abstract" class="introductory">
            <h2>Abstrakt</h2>
            <p>
              <xsl:copy-of select="node()" />
            </p>
        </section>
  </xsl:template>
  
  <xsl:template match="text()" mode="abstrakt" />
  
  <xsl:template match="db:section[@id='příklady']" mode="příklady">
    <section id="priklady">
		<h2>Příklady</h2>
		<xsl:for-each select="db:example">
		  <section>
			  <h3><xsl:value-of select="db:title"/></h3>
			  <p><xsl:value-of select="db:annotation"/></p>
			  <aside class="example">
				<xsl:attribute name="title" select="db:title" />
				<pre class="json">
				  <xsl:value-of select="db:programlisting"/>
				</pre>
			  </aside>
		  </section>
		</xsl:for-each>
	</section>
  </xsl:template>  
  
  <xsl:template match="text()" mode="příklady" />

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
              <xsl:sequence select="gen:generujVlastnostiProPřehled(.)" />
            </xsl:for-each>
			<xsl:if test="fn:string[fn:contains(@key, 'ref')]">
			  <xsl:variable name="ref-item" select="fn:substring(fn:string[fn:contains(@key, 'ref')], 15)" />
			  viz <a><xsl:value-of select="/fn:map/fn:map[@key='definitions']/fn:map[@key=$ref-item]/fn:string[@key='title']"/></a>
			</xsl:if>
          </ul>
        </li>
      </xsl:for-each>
    </ul>
  </xsl:template>
  
  <xsl:function name="gen:generujVlastnostiProPřehled" as="element()">
    <xsl:param name="item" as="element()" />
	<li>
	  <code><xsl:value-of select="$item/@key" /></code> : <a><xsl:value-of select="$item/fn:string[@key='title']/text()" /></a>
	  <xsl:if test="$item/fn:string[@key='type'] = 'array'">
	    (seznam instancí typu <a><xsl:value-of select="$item/fn:map/fn:string[@key='title']/text()" /></a>)
	  </xsl:if>
	</li>
  </xsl:function>

  <xsl:function name="gen:generujSpecifikaci" as="element()">
    <xsl:param name="json" as="xs:string" />
    <section id="specifikace">
      <h2>Specifikace</h2>
      <xsl:apply-templates select="fn:json-to-xml(fn:unparsed-text($json), map{ 'escape': false()})" mode="specifikace" />
    </section>
  </xsl:function>

  <xsl:template match="fn:map" mode="specifikace">
    V této části jsou definovány jednotlivé typy objektů a jejich vlastnosti.
    Pro každou vlastnost je uveden její klíč používaný v JSON reprezentaci, její název, datový typ, popis a příklad.
    <xsl:for-each select=".//fn:map[fn:string[@key='type'] = 'object']">
      <section>
        <xsl:attribute name="id" select="fn:string[@key='title']/text()" />
        <h3><dfn><xsl:value-of select="fn:string[@key='title']/text()" /></dfn></h3>
        <p>
		  <xsl:variable name="description" select="fn:string[@key='description']" />
		  <xsl:choose>
			<xsl:when test="fn:contains($description, 'Odpovídá otevřené formální normě pro ')">
			  <xsl:value-of select="fn:substring-before($description, 'Odpovídá otevřené formální normě pro ')" />
			  <xsl:variable name="ofnwithlink" select="fn:substring-after($description, 'Odpovídá otevřené formální normě pro ')" />
			  Odpovídá
		      <a>
			    <xsl:attribute name="href" select="fn:substring-before(fn:substring-after($ofnwithlink, ' (viz '), ')')" />
				otevřené formální normě pro 
				<xsl:value-of select="fn:substring-before($ofnwithlink, ' (')" />
			  </a>.
		    </xsl:when>
			<xsl:otherwise>
			  <xsl:value-of select="fn:string[@key='description']" />
			</xsl:otherwise>
		  </xsl:choose>
		</p>
        <xsl:for-each select="./fn:map/fn:map">
          <xsl:sequence select="gen:generujVlastnostiProSpecifikaci(.)" />
        </xsl:for-each>
		<xsl:if test="fn:string[fn:contains(@key, 'ref')]">
		  <xsl:variable name="ref-item" select="fn:substring(fn:string[fn:contains(@key, 'ref')], 15)" />
		  viz <a><xsl:value-of select="/fn:map/fn:map[@key='definitions']/fn:map[@key=$ref-item]/fn:string[@key='title']"/></a>
		</xsl:if>
      </section>
    </xsl:for-each>
  </xsl:template>
  
  <xsl:function name="gen:generujVlastnostiProSpecifikaci" as="element()*">
    <xsl:param name="item" as="element()" />
	<section>
		<xsl:attribute name="id" select="$item/fn:string[@key='title']/text()" />
		<h4>
		  <xsl:choose>
			<xsl:when test="$item/fn:string[@key='type'] = 'object'">
			  <xsl:value-of select="$item/fn:string[@key='title']/text()" />
			</xsl:when>
			<xsl:otherwise>
			  <dfn><xsl:value-of select="$item/fn:string[@key='title']/text()" /></dfn>
			</xsl:otherwise>
		  </xsl:choose>
		</h4>
		<dl>
		  <dt>
			  Vlastnost
		  </dt>
		  <dd>
			  <code><xsl:value-of select="$item/@key" /></code>
		  </dd>
		  <dt>
			  Typ
		  </dt>
		  <dd>
			  <xsl:if test="$item/fn:string[@key='type'] = 'string'"><a href="https://opendata.gov.cz/datovy-typ:řetezec">Řetězec</a></xsl:if>
			  <xsl:if test="$item/fn:string[@key='type'] = 'boolean'"><a href="https://opendata.gov.cz/datovy-typ:anone">Boolean</a></xsl:if>
			  <xsl:if test="$item/fn:string[@key='type'] = 'integer'"><a href="https://opendata.gov.cz/datovy-typ:celé-císlo">Celé číslo</a></xsl:if>
			  <xsl:if test="$item/fn:string[@key='type'] = 'object'"><a><xsl:value-of select="$item/fn:string[@key='title']" /></a></xsl:if>
			  <xsl:if test="$item/fn:string[@key='type'] = 'array'"> Pole typu <a><xsl:value-of select="$item/fn:map/fn:string[@key='title']/text()" /></a></xsl:if>
			  <xsl:if test="$item/fn:string[@key='pattern']"> dle vzoru <code><xsl:value-of select="$item/fn:string[@key='pattern']" /></code></xsl:if>
		  </dd>
		  <dt>
			  Jméno
		  </dt>
		  <dd>
			  <xsl:value-of select="$item/fn:string[@key='title']/text()" />
		  </dd>
		  <dt>
			  Popis
		  </dt>
		  <dd>
			  <xsl:value-of select="$item/fn:string[@key='description']/text()" />
		  </dd>
		  <dt>
			  Příklad
		  </dt>
		  <dd>
			  <xsl:for-each select="$item/fn:array[@key='examples']/fn:*">
				<code><xsl:value-of select="." /></code>
			  </xsl:for-each>
		  </dd>
		</dl>
	</section>
	<xsl:if test="$item/fn:map[@key='items'][fn:string[@key='type']!='object']">
	  <xsl:for-each select="$item/fn:map[@key='items'][fn:string[@key='type']='string']">
	    <xsl:variable name="subitem" select="." />
	<section>
		<xsl:attribute name="id" select="$subitem/fn:string[@key='title']/text()" />
		<h4>
		  <xsl:choose>
			<xsl:when test="$subitem/fn:string[@key='type'] = 'object'">
			  <xsl:value-of select="$subitem/fn:string[@key='title']/text()" />
			</xsl:when>
			<xsl:otherwise>
			  <dfn><xsl:value-of select="$subitem/fn:string[@key='title']/text()" /></dfn>
			</xsl:otherwise>
		  </xsl:choose>
		</h4>
		<dl>
		  <dt>
			  Vlastnost
		  </dt>
		  <dd>
			  <code><xsl:value-of select="$subitem/@key" /></code>
		  </dd>
		  <dt>
			  Typ
		  </dt>
		  <dd>
			  <xsl:if test="$subitem/fn:string[@key='type'] = 'string'"><a href="https://opendata.gov.cz/datovy-typ:řetezec">Řetězec</a></xsl:if>
			  <xsl:if test="$subitem/fn:string[@key='type'] = 'boolean'"><a href="https://opendata.gov.cz/datovy-typ:anone">Boolean</a></xsl:if>
			  <xsl:if test="$subitem/fn:string[@key='type'] = 'integer'"><a href="https://opendata.gov.cz/datovy-typ:celé-císlo">Celé číslo</a></xsl:if>
			  <xsl:if test="$subitem/fn:string[@key='type'] = 'object'"><a><xsl:value-of select="$subitem/fn:string[@key='title']" /></a></xsl:if>
			  <xsl:if test="$subitem/fn:string[@key='type'] = 'array'"> Pole typu <a><xsl:value-of select="$subitem/fn:map/fn:string[@key='title']/text()" /></a></xsl:if>
			  <xsl:if test="$subitem/fn:string[@key='pattern']"> dle vzoru <code><xsl:value-of select="$subitem/fn:string[@key='pattern']" /></code></xsl:if>
		  </dd>
		  <dt>
			  Jméno
		  </dt>
		  <dd>
			  <xsl:value-of select="$subitem/fn:string[@key='title']/text()" />
		  </dd>
		  <dt>
			  Popis
		  </dt>
		  <dd>
			  <xsl:value-of select="$subitem/fn:string[@key='description']/text()" />
		  </dd>
		  <dt>
			  Příklad
		  </dt>
		  <dd>
			  <xsl:for-each select="$subitem/fn:array[@key='examples']/fn:map">
				<code><xsl:value-of select="fn:xml-to-json(.)" /></code>
			  </xsl:for-each>
		  </dd>
		</dl>
	</section>
	  </xsl:for-each>
	</xsl:if>
  </xsl:function>

</xsl:stylesheet>