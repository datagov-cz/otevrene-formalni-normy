<xsl:stylesheet
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:fn="http://www.w3.org/2005/xpath-functions"
  xmlns:gen="https://data.gov.cz/otevřené-formální-normy/generátor"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
  xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
  xmlns:skos="http://www.w3.org/2004/02/skos/core#"
  xmlns:dc="http://purl.org/dc/elements/1.1/"
  xmlns:sp="http://www.w3.org/2005/sparql-results#" version="3.0" expand-text="yes">
  
  <xsl:output method="html" encoding="UTF-8" indent="yes"/>
  

  <xsl:template match="@*|*|text()">
    <xsl:copy>
      <xsl:apply-templates select="@*|*|text()"/>
    </xsl:copy>
  </xsl:template>
  
  
  <!--
    Constructs a definition list of terms.
    The terms are specified with their IRIs. The list of IRIs is given in @iris where individual IRIs are separated by ' ' (space).
    When @prefix is non-empty, it is used as the IRI prefix and @iris contains only local IRIs.      
  -->
  <xsl:template match="gen:glossary">
    <xsl:variable name="prefix" select="@prefix" />
    <xsl:for-each select="fn:tokenize(@iris, ' ')">
      <xsl:variable name="iri" select="fn:concat($prefix, .)" />
      <dl>
        <dt><xsl:sequence select="gen:getLink($iri, '')" /></dt>
        <dd>
          <xsl:value-of select="gen:getDefinition($iri)" />
          <xsl:variable name="legislationIRIsSource" select="gen:getObjectPropertyValue($iri, 'http://purl.org/dc/elements/1.1/source')"/>
          <xsl:variable name="legislationIRIsRelation" select="gen:getObjectPropertyValue($iri, 'http://purl.org/dc/elements/1.1/relation')"/>
          <xsl:if test="fn:count($legislationIRIsSource)>0 or fn:count($legislationIRIsRelation)>0">
            <ul>
              <xsl:for-each select="$legislationIRIsSource">
                <li><xsl:sequence select="gen:getLinkZakonyProLidi(.)"/></li>
              </xsl:for-each>
              <xsl:for-each select="$legislationIRIsRelation">
                <li><xsl:sequence select="gen:getLinkZakonyProLidi(.)"/></li>
              </xsl:for-each>
            </ul>
          </xsl:if>
        </dd>
      </dl>
    </xsl:for-each>
  </xsl:template>
  
  <xsl:template match="gen:link">
    <xsl:sequence select="gen:getLink(@iri, ./text())" />
  </xsl:template>
  
  <xsl:function name="gen:getLink">
    <xsl:param name="iri" as="xs:string"/>
    <xsl:param name="title" as="xs:string?"/>
    <a class="ssplink">
      <xsl:attribute name="href">
        <xsl:value-of select="$iri" />
      </xsl:attribute>
      <xsl:choose>
        <xsl:when test="$title">{$title}</xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="gen:getDatatypePropertyValue($iri, 'http://www.w3.org/2004/02/skos/core#prefLabel', 'cs')" />
        </xsl:otherwise>
      </xsl:choose>
    </a>
  </xsl:function>
  
  <xsl:template match="gen:definition">
    <xsl:value-of select="gen:getDefinition(@iri)" />
  </xsl:template>
  
  <xsl:function name="gen:getDefinition">
		<xsl:param name="iri" as="xs:string"/>
    <xsl:variable name="definition" select="gen:getDatatypePropertyValue($iri, 'http://www.w3.org/2004/02/skos/core#definition', 'cs')" />
    <xsl:choose>
      <xsl:when test="$definition">{$definition}</xsl:when>
      <xsl:otherwise>
        <xsl:variable name="description" select="gen:getDatatypePropertyValue($iri, 'http://purl.org/dc/elements/1.1/description', 'cs')" />
        <xsl:choose>
          <xsl:when test="$description">{$description}</xsl:when>
          <xsl:otherwise>CHYBA: Nepodařilo se nalézt definici ani popis prvku {$iri}.</xsl:otherwise>
        </xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>
  
  <xsl:template match="gen:legislation">
    <xsl:variable name="legislationIRIsSource" select="gen:getObjectPropertyValue(@iri, 'http://purl.org/dc/elements/1.1/source')"/>
    <xsl:variable name="legislationIRIsRelation" select="gen:getObjectPropertyValue(@iri, 'http://purl.org/dc/elements/1.1/relation')"/>
    <xsl:if test="fn:count($legislationIRIsSource)>0">
      <xsl:for-each select="$legislationIRIsSource">
        <xsl:sequence select="gen:getLinkZakonyProLidi(.)"/>
        <xsl:if test="fn:position() &lt; fn:last()"><xsl:text>, </xsl:text></xsl:if>
      </xsl:for-each>
    </xsl:if>
    <xsl:if test="fn:count($legislationIRIsRelation)>0">
      <xsl:if test="fn:count($legislationIRIsSource)>0"><xsl:text>, </xsl:text></xsl:if>
      <xsl:for-each select="$legislationIRIsRelation">
        <xsl:sequence select="gen:getLinkZakonyProLidi(.)"/>
        <xsl:if test="fn:position() &lt; fn:last()"><xsl:text>, </xsl:text></xsl:if>
      </xsl:for-each>
    </xsl:if>
  </xsl:template>
  
  <xsl:template match="gen:semanticDefinition">
    <xsl:sequence select="gen:getSemanticDefinition(@iri)" />
  </xsl:template>

  <xsl:function name="gen:getSemanticDefinition">
		<xsl:param name="iri" as="xs:string"/>
    <xsl:variable name="resourceTypes" select="gen:getObjectPropertyValue($iri, 'http://www.w3.org/1999/02/22-rdf-syntax-ns#type')" />
    <!--<xsl:for-each select="$resourceTypes">-->
      <xsl:if test="($resourceTypes = 'http://www.w3.org/2002/07/owl#ObjectProperty') or ($resourceTypes = 'http://www.w3.org/2002/07/owl#DatatypeProperty')">
        <xsl:variable name="domain" select="gen:getDomain($iri)" />
        <xsl:choose>
          <xsl:when test="fn:count($domain)=1">
            <a class="ssplink">
              <xsl:attribute name="href">
                <xsl:value-of select="$domain" />
              </xsl:attribute>
              <xsl:value-of select="gen:getDatatypePropertyValue($domain, 'http://www.w3.org/2004/02/skos/core#prefLabel', 'cs')" />
            </a>
          </xsl:when>
          <xsl:otherwise>
            <xsl:for-each select="$domain">
              <a class="ssplink">
                <xsl:attribute name="href">
                  <xsl:value-of select="." />
                </xsl:attribute>
                <xsl:value-of select="gen:getDatatypePropertyValue(., 'http://www.w3.org/2004/02/skos/core#prefLabel', 'cs')" />
              </a>
              <xsl:if test="position()&lt;last()">
                <xsl:value-of> ∪ </xsl:value-of>
              </xsl:if>
            </xsl:for-each>
          </xsl:otherwise>
        </xsl:choose>
        <xsl:text> → </xsl:text>
      </xsl:if>
      <a class="ssplink">
        <xsl:attribute name="href">
          <xsl:value-of select="$iri" />
        </xsl:attribute>
        <xsl:value-of select="gen:getDatatypePropertyValue($iri, 'http://www.w3.org/2004/02/skos/core#prefLabel', 'cs')" />
      </a>
      <xsl:if test="$resourceTypes = 'http://www.w3.org/2002/07/owl#ObjectProperty'">
        <xsl:text> → </xsl:text>
        <xsl:variable name="range" select="gen:getRange($iri)" />
        <xsl:choose>
          <xsl:when test="fn:count($range)=1">
            <a class="ssplink">
              <xsl:attribute name="href">
                <xsl:value-of select="$range" />
              </xsl:attribute>
              <xsl:value-of select="gen:getDatatypePropertyValue($range, 'http://www.w3.org/2004/02/skos/core#prefLabel', 'cs')" />
            </a>
          </xsl:when>
          <xsl:otherwise>
            <xsl:for-each select="$range">
              <a class="ssplink">
                <xsl:attribute name="href">
                  <xsl:value-of select="." />
                </xsl:attribute>
                <xsl:value-of select="gen:getDatatypePropertyValue(., 'http://www.w3.org/2004/02/skos/core#prefLabel', 'cs')" />
              </a>
              <xsl:if test="position()&lt;last()">
                <xsl:value-of> ∪ </xsl:value-of>
              </xsl:if>
            </xsl:for-each>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:if>
    <!--</xsl:for-each>-->
  </xsl:function>
  
  <xsl:function name="gen:getDatatypePropertyValue">
		<xsl:param name="iri" as="xs:string"/>
    <xsl:param name="property-iri" as="xs:string"/>
    <xsl:param name="lang" as="xs:string"/>
    
    <xsl:variable name="semVocXMLDocumentIRI" select="fn:concat('https://xn--slovnk-7va.gov.cz/sparql?default-graph-uri=', '&#38;', 'query=CONSTRUCT+WHERE+%7B%0D%0A++%3C', fn:encode-for-uri($iri), '%3E+%3C', fn:encode-for-uri($property-iri), '%3E+%3Fvalue+.%0D%0A++FILTER%28LANG%28%3Fvalue%29%3D%22', $lang, '%22%29%0D%0A%7D', '&#38;', 'output=application%2Frdf%2Bxml')"/>
    
		<xsl:try>
			<xsl:variable name="semVocXMLDocument" select="fn:doc($semVocXMLDocumentIRI)"/>
      <!--<xsl:value-of select="$semVocXMLDocument//rdf:Description[@rdf:about=$iri]/.[fn:name() = $property-iri]/text()" />-->
      <xsl:choose>
        <xsl:when test="$semVocXMLDocument//rdf:Description[@rdf:about=$iri]/*">
          <xsl:value-of select="$semVocXMLDocument//rdf:Description[@rdf:about=$iri]/*/text()" />
        </xsl:when>
        <xsl:otherwise></xsl:otherwise>
      </xsl:choose>
			<xsl:catch>
			 <xsl:value-of xmlns:err="http://www.w3.org/2005/xqt-errors">CHYBA: {$err:description} Hodnotu vlastnosti {$property-iri} prvku {$iri} se nepodařilo načíst.</xsl:value-of>
			</xsl:catch>
		</xsl:try>
	</xsl:function>
  
  <xsl:function name="gen:getObjectPropertyValue">
		<xsl:param name="iri" as="xs:string"/>
    <xsl:param name="property-iri" as="xs:string"/>
    
    <xsl:variable name="semVocXMLDocumentIRI" select="fn:concat('https://xn--slovnk-7va.gov.cz/sparql?default-graph-uri=', '&#38;', 'query=CONSTRUCT+WHERE+%7B%0D%0A++%3C', fn:encode-for-uri($iri), '%3E+%3C', fn:encode-for-uri($property-iri), '%3E+%3Fvalue+.%0D%0A%7D', '&#38;', 'output=application%2Frdf%2Bxml')"/>

		<xsl:try>
			<xsl:variable name="semVocXMLDocument" select="fn:doc($semVocXMLDocumentIRI)"/>
      <!--<xsl:value-of select="$semVocXMLDocument//rdf:Description[@rdf:about=$iri]/.[fn:name() = $property-iri]/text()" />-->
      <xsl:choose>
        <xsl:when test="$semVocXMLDocument//rdf:Description[@rdf:about=$iri]/*/@rdf:resource">
          <xsl:sequence select="$semVocXMLDocument//rdf:Description[@rdf:about=$iri]/*/@rdf:resource" />
        </xsl:when>
        <xsl:otherwise></xsl:otherwise>
      </xsl:choose>
			<xsl:catch>
			 <xsl:value-of xmlns:err="http://www.w3.org/2005/xqt-errors">CHYBA: {$err:description} Hodnotu vlastnosti {$property-iri} prvku {$iri} se nepodařilo načíst.</xsl:value-of>
			</xsl:catch>
		</xsl:try>
    
	</xsl:function>
  
  <xsl:function name="gen:getDomain">
		<xsl:param name="iri" as="xs:string"/>
    
    <xsl:variable name="semVocXMLDocumentIRI" select="fn:concat('https://xn--slovnk-7va.gov.cz/sparql?default-graph-uri=', '&#38;', 'query=SELECT+%3Fmember%0D%0AWHERE+%7B%0D%0A++%3C', fn:encode-for-uri($iri), '%3E+%3Chttp%3A%2F%2Fwww.w3.org%2F2000%2F01%2Frdf-schema%23domain%3E%2Fowl%3AunionOf*%2F%28rdf%3Arest%2Frdf%3Afirst%2Fowl%3AunionOf%29*%2Frdf%3Afirst*+%3Fmember+.%0D%0A++FILTER%28%21isBlank%28%3Fmember%29%29%0D%0A%7D', '&#38;', 'output=application/sparql-results+xml')"/>

		<xsl:try>
			<xsl:variable name="semVocXMLDocument" select="fn:doc($semVocXMLDocumentIRI)"/>
      <xsl:sequence select="$semVocXMLDocument//sp:binding/sp:uri/text()" />
			<xsl:catch>
			 <xsl:value-of xmlns:err="http://www.w3.org/2005/xqt-errors">CHYBA: {$err:description} A domain of {$iri} was not found.</xsl:value-of>
			</xsl:catch>
		</xsl:try>
    
	</xsl:function>
  
  <xsl:function name="gen:getRange">
		<xsl:param name="iri" as="xs:string"/>
    
    <xsl:variable name="semVocXMLDocumentIRI" select="fn:concat('https://xn--slovnk-7va.gov.cz/sparql?default-graph-uri=', '&#38;', 'query=SELECT+%3Fmember%0D%0AWHERE+%7B%0D%0A++%3C', fn:encode-for-uri($iri), '%3E+%3Chttp%3A%2F%2Fwww.w3.org%2F2000%2F01%2Frdf-schema%23range%3E%2Fowl%3AunionOf*%2F%28rdf%3Arest%2Frdf%3Afirst%2Fowl%3AunionOf%29*%2Frdf%3Afirst*+%3Fmember+.%0D%0A++FILTER%28%21isBlank%28%3Fmember%29%29%0D%0A%7D', '&#38;', 'output=application/sparql-results+xml')"/>

		<xsl:try>
			<xsl:variable name="semVocXMLDocument" select="fn:doc($semVocXMLDocumentIRI)"/>
      <xsl:sequence select="$semVocXMLDocument//sp:binding/sp:uri/text()" />
			<xsl:catch>
			 <xsl:value-of xmlns:err="http://www.w3.org/2005/xqt-errors">ERROR: {$err:description} A range of {$iri} was not found.</xsl:value-of>
			</xsl:catch>
		</xsl:try>
    
	</xsl:function>
  
  <xsl:function name="gen:getLinkZakonyProLidi" as="element()*">
		<xsl:param name="legislationIRI" as="xs:string"/>
		<a>
			<xsl:choose>
				<xsl:when test="fn:matches($legislationIRI, '^https://esbirka.opendata.cz/zdroj/předpis/([0-9]+)/([0-9]+)$')">
					<xsl:attribute name="href" select="fn:replace($legislationIRI, '^https://esbirka.opendata.cz/zdroj/předpis/([0-9]+)/([0-9]+)$', 'https://zakonyprolidi.cz/cs/$2-$1')"/>
					<xsl:value-of select="fn:replace($legislationIRI, '^https://esbirka.opendata.cz/zdroj/předpis/([0-9]+)/([0-9]+)$', 'Zákon č. $1/$2 Sb.')"/>
				</xsl:when>
				<xsl:when test="fn:matches($legislationIRI, '^https://esbirka.opendata.cz/zdroj/předpis/([0-9]+)/([0-9]+)/sekce/([0-9]+[a-z]*)$')">
					<xsl:attribute name="href" select="fn:replace($legislationIRI, '^https://esbirka.opendata.cz/zdroj/předpis/([0-9]+)/([0-9]+)/sekce/([0-9]+[a-z]*)$', 'https://zakonyprolidi.cz/cs/$2-$1#p$3')"/>
					<xsl:value-of select="fn:replace($legislationIRI, '^https://esbirka.opendata.cz/zdroj/předpis/([0-9]+)/([0-9]+)/sekce/([0-9]+[a-z]*)$', '§ $3 zákona č. $1/$2 Sb.')"/>
				</xsl:when>
				<xsl:when test="fn:matches($legislationIRI, '^https://esbirka.opendata.cz/zdroj/předpis/([0-9]+)/([0-9]+)/sekce/([0-9]+[a-z]*)/([0-9]+[a-z]*)$')">
					<xsl:attribute name="href" select="fn:replace($legislationIRI, '^https://esbirka.opendata.cz/zdroj/předpis/([0-9]+)/([0-9]+)/sekce/([0-9]+[a-z]*)/([0-9]+[a-z]*)$', 'https://zakonyprolidi.cz/cs/$2-$1#p$3-$4')"/>
					<xsl:value-of select="fn:replace($legislationIRI, '^https://esbirka.opendata.cz/zdroj/předpis/([0-9]+)/([0-9]+)/sekce/([0-9]+[a-z]*)/([0-9]+[a-z]*)$', '§ $3 odst. $4 zákona č. $1/$2 Sb.')"/>
				</xsl:when>
				<xsl:when test="fn:matches($legislationIRI, '^https://esbirka.opendata.cz/zdroj/předpis/([0-9]+)/([0-9]+)/sekce/([0-9]+[a-z]*)/([0-9]+[a-z]*)/([a-z]+)$')">
					<xsl:attribute name="href" select="fn:replace($legislationIRI, '^https://esbirka.opendata.cz/zdroj/předpis/([0-9]+)/([0-9]+)/sekce/([0-9]+[a-z]*)/([0-9]+[a-z]*)/([a-z]+)$', 'https://zakonyprolidi.cz/cs/$2-$1#p$3-$4-$5')"/>
					<xsl:value-of select="fn:replace($legislationIRI, '^https://esbirka.opendata.cz/zdroj/předpis/([0-9]+)/([0-9]+)/sekce/([0-9]+[a-z]*)/([0-9]+[a-z]*)/([a-z]+)$', '§ $3 odst. $4 písm. $5) zákona č. $1/$2 Sb.')"/>
				</xsl:when>
				<xsl:when test="fn:matches($legislationIRI, '^https://esbirka.opendata.cz/zdroj/předpis/([0-9]+)/([0-9]+)/sekce/([0-9]+[a-z]*)/([a-z]+)$')">
					<xsl:attribute name="href" select="fn:replace($legislationIRI, '^https://esbirka.opendata.cz/zdroj/předpis/([0-9]+)/([0-9]+)/sekce/([0-9]+[a-z]*)/([a-z]+)$', 'https://zakonyprolidi.cz/cs/$2-$1#p$3-1-$4')"/>
					<xsl:value-of select="fn:replace($legislationIRI, '^https://esbirka.opendata.cz/zdroj/předpis/([0-9]+)/([0-9]+)/sekce/([0-9]+[a-z]*)/([a-z]+)$', '§ $3 písm. $4) zákona č. $1/$2 Sb.')"/>
				</xsl:when>
				<xsl:when test="fn:matches($legislationIRI, '^https://esbirka.opendata.cz/zdroj/předpis/([0-9]+)/([0-9]+)/sekce/([0-9]+[a-z]*)/([0-9]+[a-z]*)/([a-z]+)/([0-9]+[a-z]*)$')">
					<xsl:attribute name="href" select="fn:replace($legislationIRI, '^https://esbirka.opendata.cz/zdroj/předpis/([0-9]+)/([0-9]+)/sekce/([0-9]+[a-z]*)/([0-9]+[a-z]*)/([a-z]+)/([0-9]+[a-z]*)$', 'https://zakonyprolidi.cz/cs/$2-$1#p$3-$4-$5-$6')"/>
					<xsl:value-of select="fn:replace($legislationIRI, '^https://esbirka.opendata.cz/zdroj/předpis/([0-9]+)/([0-9]+)/sekce/([0-9]+[a-z]*)/([0-9]+[a-z]*)/([a-z]+)/([0-9]+[a-z]*)$', '§ $3 odst. $4 písm. $5) bod $6. zákona č. $1/$2 Sb.')"/>
				</xsl:when>
				<xsl:when test="fn:matches($legislationIRI, '^https://esbirka.opendata.cz/zdroj/předpis/([0-9]+)/([0-9]+)/sekce/([0-9]+[a-z]*)/([a-z]+)/([0-9]+[a-z]*)$')">
					<xsl:attribute name="href" select="fn:replace($legislationIRI, '^https://esbirka.opendata.cz/zdroj/předpis/([0-9]+)/([0-9]+)/sekce/([0-9]+[a-z]*)/([a-z]+)/([0-9]+[a-z]*)$', 'https://zakonyprolidi.cz/cs/$2-$1#p$3-1-$4-$5')"/>
					<xsl:value-of select="fn:replace($legislationIRI, '^https://esbirka.opendata.cz/zdroj/předpis/([0-9]+)/([0-9]+)/sekce/([0-9]+[a-z]*)/([a-z]+)/([0-9]+[a-z]*)$', '§ $3 písm. $4) bod $5. zákona č. $1/$2 Sb.')"/>
				</xsl:when>
				<xsl:otherwise></xsl:otherwise>
			</xsl:choose>
		</a>
	</xsl:function>
  
</xsl:stylesheet>