<xsl:stylesheet
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:db="http://docbook.org/ns/docbook"
  xmlns:fn="http://www.w3.org/2005/xpath-functions"
  xmlns:gen="https://data.gov.cz/otevřené-formální-normy/generátor"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
  xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
  xmlns:skos="http://www.w3.org/2004/02/skos/core#"
  xmlns:dc="http://purl.org/dc/elements/1.1/"
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
    <section id="příklady">
		<h2><dfn>Příklady</dfn></h2>
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
    <xsl:param name="schema" as="xs:string" />
	<xsl:param name="context" as="xs:string" />
    <section id="specifikace">
      <h2>Specifikace</h2>
	  <xsl:variable name="source">
	    <xsl:element name="source" xmlns="http://www.w3.org/2005/xpath-functions">
	      <xsl:sequence select="fn:json-to-xml(fn:unparsed-text($context), map{ 'escape': false()})" />
		  <xsl:sequence select="fn:json-to-xml(fn:unparsed-text($schema), map{ 'escape': false()})" />
	    </xsl:element>
	  </xsl:variable>
	  <xsl:apply-templates select="$source" mode="specifikace" />
      <!--<xsl:apply-templates select="fn:json-to-xml(fn:unparsed-text($schema), map{ 'escape': false()})" mode="specifikace" />-->
    </section>
  </xsl:function>

  <xsl:template match="fn:map[@key='@context']" mode="specifikace">
    
  </xsl:template>
  
  <xsl:template match="text()" mode="specifikace">
    
  </xsl:template>

  <xsl:template match="fn:map[fn:string[@key='$schema']]" mode="specifikace">
    V této části jsou definovány jednotlivé typy objektů a jejich vlastnosti.
    Pro každou vlastnost je uveden její klíč používaný v JSON reprezentaci, její název, datový typ, popis a příklad.
    <xsl:for-each select=".//fn:map[fn:string[@key='type'] = 'object']">
      <section>
        <!--<xsl:attribute name="id" select="fn:string[@key='title']/text()" />-->
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
		<xsl:try>
			<xsl:sequence select="gen:generujReferenciNaPrvekVSémantickémSlovníkuPojmů(./fn:map[@key='properties']/fn:map[@key='type']/fn:string[@key='default']/text(), /fn:source)" />
			<xsl:catch></xsl:catch>
		</xsl:try>
        <xsl:for-each select="./fn:map/fn:map">
          <xsl:sequence select="gen:generujVlastnostiProSpecifikaci(.)" />
        </xsl:for-each>
		<xsl:if test="fn:string[fn:contains(@key, 'ref')]">
		  <xsl:variable name="ref-item" select="fn:substring(fn:string[fn:contains(@key, 'ref')], 15)" />
		  viz <a><xsl:value-of select="/fn:source/fn:map/fn:map[@key='definitions']/fn:map[@key=$ref-item]/fn:string[@key='title']"/></a>
		</xsl:if>
      </section>
    </xsl:for-each>
  </xsl:template>
  
  <xsl:function name="gen:generujVlastnostiProSpecifikaci" as="element()*">
    <xsl:param name="item" as="element()" />
	<xsl:sequence select="gen:generujVlastnostProSpecifikaci($item)" />
	<xsl:if test="$item/fn:map[@key='items'][fn:string[@key='type']!='object']">
	  <xsl:for-each select="$item/fn:map[@key='items'][fn:string[@key='type']='string']">
	    <xsl:sequence select="gen:generujVlastnostProSpecifikaci(.)" />
	  </xsl:for-each>
	</xsl:if>
  </xsl:function>
  
  <xsl:function name="gen:generujVlastnostProSpecifikaci" as="element()">
    <xsl:param name="item" as="element()" />
	<section>
		<!--<xsl:attribute name="id" select="$item/fn:string[@key='title']/text()" />-->
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
			  <xsl:if test="$item/@key = 'type'">
				<br /><br />
				<xsl:text>Hodnotou je vždy </xsl:text>
				<code><xsl:value-of select="$item/fn:string[@key='default']/text()" /></code>
				<xsl:text>. </xsl:text>
			  </xsl:if>
		  </dd>
		  <dt>
			  Příklad
		  </dt>
		  <dd>
				<xsl:choose>
					<xsl:when test="$item/fn:array[@key='examples']/fn:*">
						<xsl:for-each select="$item/fn:array[@key='examples']/fn:*">
							<code><xsl:value-of select="fn:replace(fn:xml-to-json(.), '\\/', '/')" /></code>
						</xsl:for-each>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text>Přímo pro tento prvek není příklad uveden. Detailní příklady lze nalézt v sekci </xsl:text>
						<a>Příklady</a>
						<xsl:text> této otevřené formální normy.</xsl:text>
					</xsl:otherwise>
				</xsl:choose>
		  </dd>
		  <dt>
			  Sémantický slovník pojmů
		  </dt>
		  <dd>
			  <xsl:sequence select="gen:generujReferenciNaPrvekVSémantickémSlovníkuPojmů($item/@key, $item/ancestor::fn:source)" />
		  </dd>
		</dl>
	</section>
  </xsl:function>
  
  <xsl:function name="gen:generujReferenciNaPrvekVSémantickémSlovníkuPojmů" as="element()*">
    <xsl:param name="semVocTypeAlias" as="xs:string" />
	<xsl:param name="source" as="element()" />
	<xsl:choose>
		<xsl:when test="$semVocTypeAlias and $semVocTypeAlias!='cs' and $semVocTypeAlias!='type' and $semVocTypeAlias!='id'">
		  <p>
			<xsl:variable name="semVocTypeQName" select="($source/fn:map/fn:map[@key='@context']/fn:string[@key = $semVocTypeAlias]/text(), $source/fn:map/fn:map[@key='@context']/fn:map[@key = $semVocTypeAlias]/fn:string[@key='@id' or @key='@reverse']/text())[1]" />
			<xsl:variable name="prefix" select="fn:substring-before($semVocTypeQName, ':')" />
			<xsl:variable name="localName" select="fn:substring-after($semVocTypeQName, ':')" />
			<xsl:variable name="iriPrefix" select="$source/fn:map/fn:map[@key='@context']/fn:string[@key = $prefix]/text()" />
			<xsl:variable name="semVocTypeIRI" select="fn:concat($iriPrefix, $localName)" />
			<xsl:variable name="position" select="0"/>
			<xsl:try>
				<xsl:variable name="semVocTypeXMLDocumentIRI" select="fn:concat('https://xn--slovnk-7va.gov.cz/sparql?query=define%20sql%3Adescribe-mode%20%22CBD%22%20%20DESCRIBE%20%3C',fn:encode-for-uri($semVocTypeIRI), '%3E', '&#38;', 'output=application%2Frdf%2Bxml')" />
				<xsl:variable name="semVocTypeXMLDocument" select="fn:doc($semVocTypeXMLDocumentIRI)" />
				<xsl:variable name="position" select="1"/>
				<xsl:text>V sémantickém slovníku pojmů odpovídá prvek typu </xsl:text>
				<xsl:choose>
					<xsl:when test="$semVocTypeXMLDocument//rdfs:label">
						<a>
							<xsl:attribute name="href" select="$semVocTypeIRI" />
							<xsl:value-of select="$semVocTypeXMLDocument//rdfs:label" />
						</a>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="$semVocTypeIRI" />. <a>CHYBA: Jméno typu se nepodařilo načíst.</a>
					</xsl:otherwise>
				</xsl:choose>
				<xsl:variable name="semVocGlossaryIRI" select="$semVocTypeXMLDocument//skos:inScheme/attribute::rdf:resource" />
				<xsl:variable name="semVocGlossaryXMLDocumentIRI" select="fn:concat('https://xn--slovnk-7va.gov.cz/sparql?query=define%20sql%3Adescribe-mode%20%22CBD%22%20%20DESCRIBE%20%3C',fn:encode-for-uri($semVocGlossaryIRI), '%3E', '&#38;', 'output=application%2Frdf%2Bxml')" />
				<xsl:variable name="semVocGlossaryXMLDocument" select="fn:doc($semVocGlossaryXMLDocumentIRI)" />
				<xsl:variable name="position" select="2"/>
				<xsl:text> definovanému v </xsl:text>
				<xsl:choose>
					<xsl:when test="$semVocGlossaryXMLDocument//rdfs:label">
						<a>
							<xsl:attribute name="href" select="$semVocGlossaryIRI" />
							<xsl:value-of select="$semVocGlossaryXMLDocument//rdfs:label" />
						</a>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="$semVocGlossaryIRI" />. <a>CHYBA: Jméno glosáře se nepodařilo načíst.</a>
					</xsl:otherwise>
				</xsl:choose>
				<xsl:text>.</xsl:text>
				<xsl:catch>
					<xsl:choose>
						<xsl:when test="$position = 0">
							<a>CHYBA: V sémantickém slovníku pojmů odpovídá prvek typu <xsl:value-of select="$semVocTypeIRI" />, jehož definici se nepodařilo načíst.</a>
						</xsl:when>
						<xsl:when test="$position = 1">
							. <a>CHYBA: Prvek je definovaném v glosáři, jehož definici se nepodařilo načíst.</a>
						</xsl:when>
					</xsl:choose>
				</xsl:catch>
			</xsl:try>
		  </p>
		</xsl:when>
		<xsl:when test="$semVocTypeAlias and $semVocTypeAlias='type'">
			<p>
				<xsl:text>Tento prvek reprezentuje RDF vlastnost </xsl:text>
				<a href="http://www.w3.org/1999/02/22-rdf-syntax-ns#type">rdf:type</a>
				<xsl:text>. Neodpovídá tedy žádnému prvku v sémantickém slovníku pojmů, ale je prostředkem pro typování entit reprezentovaných v JSON-LD dokumentu.</xsl:text>
			</p>
		</xsl:when>
		<xsl:when test="$semVocTypeAlias and $semVocTypeAlias='id'">
			<p>
				<xsl:text>Tento prvek neodpovídá žádnému prvku v sémantickém slovníku pojmů. Slouží k uvedení unikátního IRI zdroje, kterým je daná entita reprezentována v RDF reprezentaci, mimo jiné tedy i pro reprezentaci entity na úrovni sémantického slovníku pojmů.</xsl:text>
			</p>
		</xsl:when>
		<xsl:otherwise>
			<p>
				<xsl:text>Tento prvek má pouze strukturální význam v JSON reprezentaci. Nemá žádný sémantický význam.</xsl:text>
			</p>
		</xsl:otherwise>
	</xsl:choose>
  </xsl:function>
 

</xsl:stylesheet>