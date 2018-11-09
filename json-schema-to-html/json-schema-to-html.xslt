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

  <xsl:function name="gen:generujDokumentaciPrvků">
    <xsl:param name="schema" />
    <xsl:param name="context" />
    <xsl:variable name="source">
	    <xsl:element name="source" xmlns="http://www.w3.org/2005/xpath-functions">
	      <xsl:sequence select="fn:json-to-xml(fn:unparsed-text($context), map{ 'escape': false()})" />
		    <xsl:sequence select="fn:json-to-xml(fn:unparsed-text($schema), map{ 'escape': false()})" />
	    </xsl:element>
	  </xsl:variable>
    <section id="json">
      <h2><dfn>JSON struktura</dfn></h2>
      <xsl:sequence select="gen:generujPřehled($source)" />
      <xsl:sequence select="gen:generujSpecifikaci($source)" />
    </section>
    <section id="lod">
      <h2><dfn>LOD struktura</dfn></h2>
      <xsl:sequence select="gen:generujUkázkyLOD($source)" />
    </section>
  </xsl:function>

  <xsl:function name="gen:generujPřehled" as="element()">
    <xsl:param name="source" as="document-node()" />
    <section id="json-přehled">
      <h3>Přehled JSON struktury</h3>
  	  <xsl:apply-templates select="$source" mode="přehled" />
    </section>
  </xsl:function>

  <xsl:function name="gen:generujUkázkyLOD" as="element()">
    <xsl:param name="source" as="document-node()" />
    <section id="ukázky-lod">
  		<h2><dfn>Ukázky práce s LOD reprezentací datové sady</dfn></h2>
  	  <xsl:apply-templates select="$source" mode="ukázkylod" />
    </section>
  </xsl:function>

  <xsl:template match="fn:map[@key='@context']" mode="přehled">

  </xsl:template>

  <xsl:template match="text()" mode="přehled">

  </xsl:template>

  <xsl:template match="fn:map[fn:string[@key='$schema']]" mode="přehled">
    <xsl:choose>
      <xsl:when test="fn:map/fn:map/fn:map[fn:string[@key='type'] = 'object'][fn:map[@key='properties']/fn:map[@key='type']]">
        <xsl:text>Datová sada je tvořena seznamem instancí typu </xsl:text>
        <a>
          <xsl:value-of select="gen:generujNázevPrvkuVSémantickémSlovníkuPojmů(fn:map/fn:map/fn:map[fn:string[@key='type'] = 'object'])" />
          <!--<xsl:value-of select="fn:map/fn:map/fn:map[fn:string[@key='type'] = 'object']/fn:string[@key='title']" />-->
        </a>
        <xsl:text> uvedených v poli </xsl:text>
        <code>položky</code>.
        <ul>
          <xsl:for-each select=".//fn:map[fn:string[@key='type'] = 'object'][fn:map[@key='properties']/fn:map/@key != 'cs' and fn:map[@key='properties']/fn:map/@key != 'en'][fn:map[@key='properties']/fn:map[@key='type'] or ../../fn:map[@key = 'definitions']]">
            <li>
              <xsl:text>Instance typu </xsl:text>
              <a>
                <xsl:value-of select="gen:generujNázevTypuPrvkuVSémantickémSlovníkuPojmů(.)" />
              </a>
              <xsl:text> má následující nepovinné vlastnosti:</xsl:text>
              <ul>
                <xsl:for-each select="./fn:map/fn:map">
                  <xsl:sequence select="gen:generujVlastnostProPřehled(.)" />
                </xsl:for-each>
              </ul>
            </li>
          </xsl:for-each>
        </ul>
      </xsl:when>
      <xsl:when test="fn:map/fn:map/fn:map[fn:string[@key='type'] = 'object'][not(fn:map[@key='properties']/fn:map[@key='type'])]">
        <xsl:text>Datová sada je tvořena seznamem instancí uvedených v poli </xsl:text>
        <code>položky</code>
        <xsl:text>. Každá instance v poli má následující nepovinné vlastnosti:</xsl:text>
        <ul>
          <xsl:for-each select="fn:map/fn:map/fn:map[fn:string[@key='type'] = 'object']/fn:map/fn:map">
            <xsl:sequence select="gen:generujVlastnostProPřehled(.)" />
          </xsl:for-each>
        </ul>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>CHYBA: Nepodporovaná konstrukce pro specifikaci položek.</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:function name="gen:generujVlastnostProPřehled" as="element()">
    <xsl:param name="item" as="element()" />
  	<li>
      <code>
        <a><xsl:value-of select="$item/@key" /></a>
      </code>
      <xsl:text> : </xsl:text>
      <xsl:sequence select="gen:generujPopisTypuVlastnosti($item)" />
  	</li>
  </xsl:function>

  <xsl:function name="gen:generujSpecifikaci" as="element()">
    <xsl:param name="source" as="document-node()" />
    <section id="json-specifikace">
      <h3>Detailní specifikace prvků JSON struktury</h3>
  	  <xsl:apply-templates select="$source" mode="specifikace" />
    </section>
  </xsl:function>

  <xsl:template match="fn:map[@key='@context']" mode="specifikace">

  </xsl:template>

  <xsl:template match="text()" mode="specifikace">

  </xsl:template>

  <xsl:template match="fn:map[fn:string[@key='$schema']]" mode="specifikace">
    <xsl:text>V této části jsou specifikovány jednotlivé prvky JSON struktury.</xsl:text>
    <section>
      <xsl:if test=".//fn:map[@key='cs' or @key='en' or @key='type' or @key='id']">
        <h4>Obecné prvky</h4>
      </xsl:if>
      <xsl:if test=".//fn:map[@key='cs' or @key='en']">
        <section>
          <h5><dfn>Vícejazyčný řetězec</dfn></h5>
          <dl>
            <dt>Typ</dt>
            <dd>
              <pre class="json">
                <xsl:value-of select="'{&quot;cs&quot;: &quot;...&quot;, &quot;en&quot;: &quot;...&quot;, ...}'" />
              </pre>
            </dd>
            <dt>Popis</dt>
            <dd>Vyjádření textových hodnot vlastností, jejichž hodnotou je množina řetězců, z nichž každý je vyjádřením textové hodnoty v jiném jazyku.</dd>
          </dl>
        </section>
      </xsl:if>
      <xsl:if test=".//fn:map[@key='type']">
        <section>
          <h5>Vlastnost <code><dfn>type</dfn></code></h5>
          <dl>
            <dt>Typ</dt>
            <dd><a href="https://opendata.gov.cz/datovy-typ:%C5%99etezec">Řetězec</a></dd>
            <dt>Popis</dt>
            <dd>Lokální identifikátor typu v rámci JSON souboru. Pro získání globálního unikátního identifikátoru je nutné interpretovat soubor jako JSON-LD soubor, tj. využít jeho kontext (klíč @context). Tam je definováno mapování identifikátoru typu na globálně unikátní IRI typu. Toto IRI typu je použito též v LOD reprezentaci datové sady pro identifikaci typu, viz <a>LOD struktura</a>.</dd>
          </dl>
        </section>
      </xsl:if>
      <xsl:if test=".//fn:map[@key='id']">
        <section>
          <h5>Vlastnost <code><dfn>id</dfn></code></h5>
          <dl>
            <dt>Typ</dt>
            <dd><a href="https://opendata.gov.cz/datovy-typ:%C5%99etezec">Řetězec</a></dd>
            <dt>Jméno</dt>
            <dd>Identifikátor instance</dd>
            <dt>Popis</dt>
            <dd>Lokální identifikátor instance v rámci kolekce datových sad z daného datového zdroje. Pro získání globálního unikátního identifikátoru je nutné interpretovat soubor jako JSON-LD soubor, tj. využít jeho kontext (klíč @context). Tam je definováno base IRI, které dohromady s identifikátorem typu tvoří IRI instance. Toto IRI je použito též v LOD reprezentaci datové sady pro identifikaci instance, viz <a>LOD struktura</a>.</dd>
          </dl>
        </section>
      </xsl:if>
    </section>
    <xsl:for-each select=".//fn:map[fn:string[@key='type'] = 'object'][fn:map[@key='properties']/fn:map/@key != 'cs' and fn:map[@key='properties']/fn:map/@key != 'en'][fn:map[@key='properties']/fn:map[@key='type'] or ../../fn:map[@key = 'definitions']]">
      <section>
        <h4>
          <dfn>
            <xsl:value-of select="gen:generujNázevTypuPrvkuVSémantickémSlovníkuPojmů(.)" />
          </dfn>
        </h4>
        <p>
          <xsl:value-of select="gen:generujPopisPrvkuVSémantickémSlovníkuPojmů(.)" />
		    </p>
        <p>
          <xsl:text>Sémantika prvku je v sémantickém slovníku pojmů definována sémantickým typem objektu </xsl:text>
          <xsl:sequence select="gen:generujOdkazNaPrvekVSémantickémSlovníkuPojmů(.)" />
          <xsl:text>.</xsl:text>
    		</p>
        <xsl:sequence select="gen:generujOdkazyNaZakonyProLidi(.)" />
        <xsl:sequence select="gen:generujVlastnostiProSpecifikaci(.)" />
    		<xsl:if test="fn:string[fn:contains(@key, 'ref')]">
    		  <xsl:variable name="ref-item" select="fn:substring(fn:string[fn:contains(@key, 'ref')], 15)" />
    		  viz <a><xsl:value-of select="/fn:source/fn:map/fn:map[@key='definitions']/fn:map[@key=$ref-item]/fn:string[@key='title']"/></a>
    		</xsl:if>
      </section>
    </xsl:for-each>
    <xsl:if test="fn:map/fn:map/fn:map[fn:string[@key='type'] = 'object'][not(fn:map[@key='properties']/fn:map[@key='type'])]">
      <section>
        <h4>Prvky</h4>
        <xsl:sequence select="gen:generujVlastnostiProSpecifikaci(fn:map/fn:map/fn:map[fn:string[@key='type'] = 'object'])" />
      </section>
    </xsl:if>
    <xsl:if test="/fn:source/fn:map/fn:map[@key='definitions']/fn:map[fn:string[@key='type'] != 'object' and fn:string[@key='type'] != 'array']">
      <section>
        <h4>Sdílené prvky</h4>
        <xsl:for-each select="/fn:source/fn:map/fn:map[@key='definitions']/fn:map[fn:string[@key='type'] != 'object' and fn:string[@key='type'] != 'array']">
          <xsl:sequence select="gen:generujVlastnostProSpecifikaci(.)" />
        </xsl:for-each>
      </section>
    </xsl:if>
  </xsl:template>


  <xsl:function name="gen:generujVlastnostiProSpecifikaci" as="element()*">
    <xsl:param name="item" as="element()" />
    <xsl:for-each select="$item/fn:map/fn:map[@key!='type' and @key!='id']">
      <xsl:sequence select="gen:generujVlastnostProSpecifikaci(.)" />
    </xsl:for-each>
  	<xsl:if test="$item/fn:map[@key='items'][fn:string[@key='type']!='object']">
  	  <xsl:for-each select="$item/fn:map[@key='items'][fn:string[@key='type']='string']">
  	    <xsl:sequence select="gen:generujVlastnostProSpecifikaci(.)" />
  	  </xsl:for-each>
  	</xsl:if>
  </xsl:function>

  <xsl:function name="gen:generujVlastnostProSpecifikaci" as="element()">
    <xsl:param name="item" as="element()" />
    <section>
      <xsl:choose>
        <xsl:when test="($item/fn:string[@key='$ref']) and $item/ancestor::fn:source//fn:map[@key='definitions']/fn:map[@key=fn:substring($item/fn:string[@key='$ref'], 15)][fn:string[@key='type'] != 'object' and fn:string[@key='type'] != 'array']">
          <h5>
            <xsl:text>Vlastnost </xsl:text>
            <code>
              <xsl:value-of select="$item/@key" />
            </code>
      		</h5>
          <p>
            <xsl:text>Viz specifikace prvku </xsl:text>
            <a>
              <code>
                <xsl:value-of select="$item/@key" />
              </code>
            </a>
          </p>
        </xsl:when>
        <xsl:otherwise>
          <h5>
            <xsl:text>Vlastnost </xsl:text>
            <code>
              <dfn>
                <xsl:value-of select="$item/@key" />
              </dfn>
            </code>
      		</h5>
      		<dl>
      		  <dt>
      			  Typ
      		  </dt>
      		  <dd>
              <xsl:sequence select="gen:generujPopisTypuVlastnosti($item)" />
      		  </dd>
      		  <dt>
      			  Popis
      		  </dt>
      		  <dd>
              <xsl:value-of select="gen:generujPopisPrvkuVSémantickémSlovníkuPojmů($item)" />
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
      			  Sémantika vlastnosti definovaná sémantickým slovníkem pojmů
      		  </dt>
      		  <dd>
      			  <!--<xsl:sequence select="gen:generujReferenciNaPrvekVSémantickémSlovníkuPojmů($item/@key, $item/ancestor::fn:source)" />-->
              <xsl:variable name="type" select="gen:generujTypPrvkuVSémantickémSlovníkuPojmů($item)" />
              <xsl:choose>
                <xsl:when test="$type = 'typ-vlastnosti'">
                  <p>
                    <xsl:text>Sémantika vlastnosti </xsl:text>
                    <code><xsl:value-of select="$item/@key" /></code>
                    <xsl:text> je v sémantickém slovníku pojmů definována sémantickým typem vlastnosti </xsl:text>
                    <xsl:sequence select="gen:generujOdkazNaPrvekVSémantickémSlovníkuPojmů($item)" />
                    <xsl:text> následovně:</xsl:text>
                  </p>
                  <p>
                    <xsl:for-each select="gen:generujDoménuPrvkuVSémantickémSlovníkuPojmů($item)">
                      <xsl:sequence select="gen:generujOdkazNaPrvekSIRIVSémantickémSlovníkuPojmů(.)" />
                      <xsl:text> ➡ </xsl:text>
                      <strong><xsl:sequence select="gen:generujOdkazNaPrvekVSémantickémSlovníkuPojmů($item)" /></strong>
                    </xsl:for-each>
                  </p>
                </xsl:when>
                <xsl:when test="$type = 'typ-vztahu'">
                  <p>
                    <xsl:text>Sémantika vlastnosti </xsl:text>
                    <code><xsl:value-of select="$item/@key" /></code>
                    <xsl:text> je v sémantickém slovníku pojmů definována sémantickým typem vztahu </xsl:text>
                    <xsl:sequence select="gen:generujOdkazNaPrvekVSémantickémSlovníkuPojmů($item)" />
                    <xsl:text> následovně:</xsl:text>
                  </p>
                  <p>
                    <xsl:for-each select="gen:generujDoménuPrvkuVSémantickémSlovníkuPojmů($item)">
                      <xsl:sequence select="gen:generujOdkazNaPrvekSIRIVSémantickémSlovníkuPojmů(.)" />
                      <xsl:for-each select="gen:generujOborHodnotPrvkuVSémantickémSlovníkuPojmů($item)">
                        <xsl:text> ➡ </xsl:text>
                        <strong><xsl:sequence select="gen:generujOdkazNaPrvekVSémantickémSlovníkuPojmů($item)" /></strong>
                        <xsl:text> ➡ </xsl:text>
                        <xsl:sequence select="gen:generujOdkazNaPrvekSIRIVSémantickémSlovníkuPojmů(.)" />
                      </xsl:for-each>
                    </xsl:for-each>
                  </p>
                </xsl:when>
              </xsl:choose>
              <xsl:sequence select="gen:generujOdkazyNaZakonyProLidi($item)" />
      		  </dd>
      		</dl>
          <xsl:if test="($item/fn:map[@key='items']/fn:string[@key='type'] = 'object') and not($item/fn:map[@key='items']/fn:map[@key='properties']/fn:map[@key = 'type'])">
            <xsl:sequence select="gen:generujVlastnostiProSpecifikaci($item/fn:map[@key='items'])" />
          </xsl:if>
          <xsl:if test="($item/fn:string[@key='type'] = 'object') and not($item/fn:map[@key='properties']/fn:map[@key = 'type']) and not($item/fn:map[@key='properties']/fn:map[@key = 'cs' or @key = 'en'])">
            <xsl:sequence select="gen:generujVlastnostiProSpecifikaci($item)" />
          </xsl:if>
        </xsl:otherwise>
      </xsl:choose>
  	</section>
  </xsl:function>

  <xsl:template match="fn:map[@key='@context']" mode="ukázkylod">

  </xsl:template>

  <xsl:template match="text()" mode="ukázkylod">

  </xsl:template>

  <xsl:template match="fn:map[fn:string[@key='$schema']]" mode="ukázkylod">
    <xsl:for-each select=".//fn:map[fn:string[@key='type'] = 'object'][fn:map[@key='properties']/fn:map/@key != 'cs' and fn:map[@key='properties']/fn:map/@key != 'en'][fn:map[@key='properties']/fn:map[@key='type'] or ../../fn:map[@key = 'definitions']]">
      <section>
        <h3>
          <xsl:text>Ukázky SPARQL dotazů nad typem </xsl:text>
          <xsl:value-of select="gen:generujNázevTypuPrvkuVSémantickémSlovníkuPojmů(.)" />
        </h3>
        <aside class="example">
  				<xsl:attribute name="title">
            <xsl:text>Seznam instancí typu </xsl:text>
            <xsl:value-of select="gen:generujNázevTypuPrvkuVSémantickémSlovníkuPojmů(.)" />
            <xsl:if test="./parent::fn:map[fn:string[@key='type'] = 'array']/../..[@key]">
              <xsl:text> přiřazených k instanci typu </xsl:text>
              <xsl:value-of select="gen:generujNázevTypuPrvkuVSémantickémSlovníkuPojmů(./parent::fn:map[fn:string[@key='type'] = 'array']/../..[@key])" />
              <xsl:text> prostřednictvím </xsl:text>
              <xsl:value-of select="gen:generujNázevTypuPrvkuVSémantickémSlovníkuPojmů(./parent::fn:map[fn:string[@key='type'] = 'array'])" />
            </xsl:if>
          </xsl:attribute>
          <xsl:variable name="query">{fn:distinct-values(gen:generujPrefixyProSPARQL(.))}
SELECT *
WHERE {{
  ?{gen:generujPromennouProSPARQLZLocalNamePrvkuVSémantickémSlovníkuPojmů(gen:generujLocalNamePrvkuVSémantickémSlovníkuPojmů(.))} a {gen:generujQNamePrvkuVSémantickémSlovníkuPojmů(.)} .
{fn:distinct-values(gen:generujVlastnostiProSPARQL(., gen:generujPromennouProSPARQLZLocalNamePrvkuVSémantickémSlovníkuPojmů(gen:generujLocalNamePrvkuVSémantickémSlovníkuPojmů(.))))}
}}
LIMIT 100
          </xsl:variable>
  				<pre class="sparql">
            <xsl:value-of select="$query" />
  				</pre>
          <a>
            <xsl:attribute name="href" select="fn:concat('https://rpp.opendata.cz/sparql?query=', fn:encode-for-uri($query), '&#38;', 'format=text%2Fhtml', '&#38;', 'timeout=0')"/>
            spustit
          </a>
			  </aside>
        <xsl:variable name="prvek" select="." />
        <xsl:for-each select="$prvek/fn:map/fn:map[@key!='type' and @key!='id' and fn:array[@key='examples']/*]">
          <aside class="example">
    				<xsl:attribute name="title">
              <xsl:text>Seznam instancí typu </xsl:text>
              <xsl:value-of select="gen:generujNázevTypuPrvkuVSémantickémSlovníkuPojmů($prvek)" />
              <xsl:text> s danou hodnotou </xsl:text>
              <xsl:value-of select="gen:generujNázevTypuPrvkuVSémantickémSlovníkuPojmů(.)" />
            </xsl:attribute>
            <xsl:variable name="query">{fn:distinct-values(gen:generujPrefixyProSPARQL($prvek))}
SELECT *
WHERE {{
  ?{gen:generujPromennouProSPARQLZLocalNamePrvkuVSémantickémSlovníkuPojmů(gen:generujLocalNamePrvkuVSémantickémSlovníkuPojmů($prvek))} a {gen:generujQNamePrvkuVSémantickémSlovníkuPojmů($prvek)} .
  {fn:distinct-values(gen:generujVlastnostiProSPARQL($prvek, gen:generujPromennouProSPARQLZLocalNamePrvkuVSémantickémSlovníkuPojmů(gen:generujLocalNamePrvkuVSémantickémSlovníkuPojmů($prvek))))}
  FILTER (?{gen:generujPromennouProSPARQLZLocalNamePrvkuVSémantickémSlovníkuPojmů(gen:generujLocalNamePrvkuVSémantickémSlovníkuPojmů(.))} = '{fn:array[@key='examples'][1]}')
}}
LIMIT 100
            </xsl:variable>
    				<pre class="sparql">
              <xsl:value-of select="$query" />
    				</pre>
            <a>
              <xsl:attribute name="href" select="fn:concat('https://rpp.opendata.cz/sparql?query=', fn:encode-for-uri($query), '&#38;', 'format=text%2Fhtml', '&#38;', 'timeout=0')"/>
              spustit
            </a>
  			  </aside>
        </xsl:for-each>
      </section>
    </xsl:for-each>
  </xsl:template>

  <xsl:function name="gen:generujVlastnostiProSPARQL" as="xs:string*">
    <xsl:param name="item" as="element()" />
    <xsl:param name="variableName" as="xs:string" />
    <xsl:for-each select="$item/fn:map/fn:map[@key!='type' and @key!='id']">
      <xsl:sequence select="gen:generujVlastnostProSPARQL(., $variableName, 'normal')" />
    </xsl:for-each>
    <xsl:if test="$item/parent::fn:map[fn:string[@key='type'] = 'array']">
      <xsl:sequence select="gen:generujVlastnostProSPARQL($item/parent::fn:map[fn:string[@key='type'] = 'array'], $variableName, 'reversed')" />
    </xsl:if>
  </xsl:function>

  <xsl:function name="gen:generujPrefixyProSPARQL" as="xs:string*">
    <xsl:param name="item" as="element()" />
    <xsl:for-each select="$item/fn:map/fn:map[@key!='type' and @key!='id']">
      <xsl:sequence select="gen:generujPrefixProSPARQL(.)" />
    </xsl:for-each>
  	<xsl:if test="$item/parent::fn:map[fn:string[@key='type'] = 'array']">
      <xsl:sequence select="gen:generujPrefixProSPARQL($item/parent::fn:map[fn:string[@key='type'] = 'array'])" />
    </xsl:if>
  </xsl:function>

  <xsl:function name="gen:generujVlastnostProSPARQL" as="xs:string*">
    <xsl:param name="item" as="element()" />
    <xsl:param name="variableName" as="xs:string" />
    <xsl:param name="mode" as="xs:string"/>
    <xsl:variable name="jsonAlias" select="($item/@key, $item/fn:map[@key='properties']/fn:map[@key='type']/fn:string[@key='default']/text())[. != 'items'][1]" />
    <xsl:variable name="context" select="$item/ancestor::fn:source/fn:map/fn:map[@key='@context']" />
  	<xsl:variable name="qName" select="($context/fn:string[@key = $jsonAlias]/text(), $context/fn:map[@key = $jsonAlias]/fn:string[@key='@id' or @key='@reverse']/text())[1]" />
  	<xsl:variable name="prefix" select="fn:substring-before($qName, ':')" />
  	<xsl:variable name="localName" select="fn:substring-after($qName, ':')" />
    <xsl:variable name="contextItem" select="$context/fn:map[@key = $jsonAlias]" />
    <xsl:choose>
      <xsl:when test="$mode = 'normal'">
        <xsl:choose>
          <xsl:when test="$contextItem[not(fn:string[@key='@reverse'])][fn:string[@key='@type'] = 'xsd:string']">
            <xsl:text>  OPTIONAL {{ ?{$variableName} {$qName} ?{gen:generujPromennouProSPARQLZLocalNamePrvkuVSémantickémSlovníkuPojmů($localName)} . }}
</xsl:text>
          </xsl:when>
          <xsl:when test="$contextItem[not(fn:string[@key='@reverse'])][fn:string[@key='@container'] = '@language']">
            <xsl:text>  OPTIONAL {{ ?{$variableName} {$qName} ?{gen:generujPromennouProSPARQLZLocalNamePrvkuVSémantickémSlovníkuPojmů($localName)} . FILTER (LANG(?{gen:generujPromennouProSPARQLZLocalNamePrvkuVSémantickémSlovníkuPojmů($localName)}) = "cs") }}
</xsl:text>
          </xsl:when>
          <xsl:when test="$contextItem[not(fn:string[@key='@reverse'])][fn:string[@key='@type'] = 'xsd:date']">
            <xsl:text>  OPTIONAL {{ ?{$variableName} {$qName} ?{gen:generujPromennouProSPARQLZLocalNamePrvkuVSémantickémSlovníkuPojmů($localName)} . }}
</xsl:text>
          </xsl:when>
          <xsl:when test="$contextItem[not(fn:string[@key='@reverse'])][fn:string[@key='@type'] = 'xsd:integer']">
            <xsl:text>  OPTIONAL {{ ?{$variableName} {$qName} ?{gen:generujPromennouProSPARQLZLocalNamePrvkuVSémantickémSlovníkuPojmů($localName)} . }}
</xsl:text>
          </xsl:when>
          <xsl:when test="$contextItem[not(fn:string[@key='@reverse'])][fn:string[@key='@type'] = '@id']">
            <xsl:text>  OPTIONAL {{ ?{$variableName} {$qName} ?{gen:generujPromennouProSPARQLZLocalNamePrvkuVSémantickémSlovníkuPojmů($localName)} . }}
</xsl:text>
          </xsl:when>
          <xsl:when test="$contextItem[fn:string[@key='@reverse']][not(fn:string[@key='@container'])][fn:string[@key='@type'] = '@id']">
            <xsl:text>  OPTIONAL {{ ?{gen:generujPromennouProSPARQLZLocalNamePrvkuVSémantickémSlovníkuPojmů($localName)} {$qName} ?{$variableName} . }}
</xsl:text>
          </xsl:when>
        </xsl:choose>
      </xsl:when>
      <xsl:when test="$mode = 'reversed'">
        <xsl:choose>
          <xsl:when test="$contextItem[fn:string[@key='@reverse']][fn:string[@key='@container'] = '@set']">
            <xsl:text>  ?{$variableName} {$qName} ?{gen:generujPromennouProSPARQLZLocalNamePrvkuVSémantickémSlovníkuPojmů($localName)} .
</xsl:text>
          </xsl:when>
          <xsl:when test="$contextItem[fn:string[@key='@id']][fn:string[@key='@container'] = '@set']">
            <xsl:text>  ?{gen:generujPromennouProSPARQLZLocalNamePrvkuVSémantickémSlovníkuPojmů($localName)} {$qName} ?{$variableName} .
</xsl:text>
          </xsl:when>
        </xsl:choose>
      </xsl:when>
    </xsl:choose>
  </xsl:function>

  <xsl:function name="gen:generujPromennouProSPARQLZLocalNamePrvkuVSémantickémSlovníkuPojmů" as="xs:string*">
    <xsl:param name="localName" as="xs:string" />
    <xsl:variable name="tokens">
      <xsl:for-each select="fn:tokenize($localName, '-')">
        <xsl:variable name="token" select="fn:translate(., 'ěščřžýáíéúůóťď', 'escrzyaieuuotd')" />
        <xsl:value-of select="fn:concat(fn:upper-case(fn:substring($token, 1, 1)), fn:substring($token, 2))" />
      </xsl:for-each>
    </xsl:variable>
    <xsl:value-of select="fn:string-join($tokens)" />
  </xsl:function>

  <xsl:function name="gen:generujPrefixProSPARQL" as="xs:string*">
    <xsl:param name="item" as="element()" />
    <xsl:text>  PREFIX {gen:generujPrefixPrvkuVSémantickémSlovníkuPojmů($item)}: &lt;{gen:generujPrefixIRIPrvkuVSémantickémSlovníkuPojmů($item)}&gt;
</xsl:text>
  </xsl:function>

  <xsl:function name="gen:generujPopisTypuVlastnosti">
    <xsl:param name="item" as="element()" />
    <xsl:choose>
  	  <xsl:when test="($item/fn:string[@key='type'] = 'array') and ($item/fn:map[@key='items']/fn:string[@key='type'] = 'object') and ($item/fn:map[@key='items']/fn:map[@key='properties']/fn:map[@key = 'type'])">
        <xsl:text> seznam instancí typu </xsl:text>
        <xsl:variable name="nazev" select="gen:generujNázevPrvkuVSémantickémSlovníkuPojmů($item/fn:map)" />
        <xsl:choose>
          <xsl:when test="fn:contains($nazev, 'CHYBA:')">
            <xsl:for-each select="gen:generujOborHodnotPrvkuVSémantickémSlovníkuPojmů($item)">
              <a><xsl:sequence select="gen:generujJménoPrvkuSIRIVSémantickémSlovníkuPojmů(.)" /></a>
            </xsl:for-each>
          </xsl:when>
          <xsl:otherwise>
            <a><xsl:value-of select="$nazev" /></a>
          </xsl:otherwise>
        </xsl:choose>
  	  </xsl:when>
      <xsl:when test="($item/fn:string[@key='type'] = 'array') and ($item/fn:map[@key='items']/fn:string[@key='$ref'])">
        <xsl:text> seznam instancí typu </xsl:text>
        <xsl:variable name="ref-item-name" select="fn:substring($item/fn:map[@key='items']/fn:string[@key='$ref'], 15)" />
        <xsl:variable name="ref-item" select="$item/ancestor::fn:source//fn:map[@key='definitions']/fn:map[@key=$ref-item-name]" />
        <xsl:variable name="nazev" select="gen:generujNázevPrvkuVSémantickémSlovníkuPojmů($ref-item)" />
        <xsl:choose>
          <xsl:when test="fn:contains($nazev, 'CHYBA:')">
            <xsl:for-each select="gen:generujOborHodnotPrvkuVSémantickémSlovníkuPojmů($ref-item)">
              <a><xsl:sequence select="gen:generujJménoPrvkuSIRIVSémantickémSlovníkuPojmů(.)" /></a>
            </xsl:for-each>
          </xsl:when>
          <xsl:otherwise>
            <a><xsl:value-of select="$nazev" /></a>
          </xsl:otherwise>
        </xsl:choose>
  	  </xsl:when>
      <xsl:when test="($item/fn:string[@key='type'] = 'array') and ($item/fn:map[@key='items']/fn:string[@key='type'] = 'object') and not($item/fn:map[@key='items']/fn:map[@key='properties']/fn:map[@key = 'type'])">
        <xsl:text> seznam instancí se strukturou sestávající z následujících nepovinných prvků:</xsl:text>
        <ul>
          <xsl:for-each select="$item/fn:map/fn:map/fn:map">
            <xsl:sequence select="gen:generujVlastnostProPřehled(.)" />
          </xsl:for-each>
        </ul>
  	  </xsl:when>
      <xsl:when test="($item/fn:string[@key='type'] = 'array') and ($item/fn:map[@key='items']/fn:string[@key='type'] = 'string') and (fn:matches($item/fn:map[@key='items']/fn:string[@key='pattern']/text(), '^\^[^/]+/'))">
        <xsl:text>Seznam odkazů</xsl:text>
        <xsl:if test="$item/fn:map[@key='items']/fn:string[@key='pattern']">
          <xsl:text> dle vzoru </xsl:text>
          <code><xsl:value-of select="$item/fn:map[@key='items']/fn:string[@key='pattern']" /></code>
        </xsl:if>
  	  </xsl:when>
      <xsl:when test="$item/fn:string[@key='type'] = 'array' and $item/fn:map/fn:string[@key='title']">
        <xsl:text> seznam instancí typu </xsl:text>
        <a><xsl:value-of select="$item/fn:map/fn:string[@key='title']/text()" /></a>
      </xsl:when>
      <xsl:when test="$item/fn:string[@key='type'] = 'array' and $item/fn:map/fn:string[@key='title']">
        Pole typu <a><xsl:value-of select="$item/fn:map/fn:string[@key='title']/text()" /></a>
      </xsl:when>
      <xsl:when test="($item/fn:string[@key='type'] = 'string') and (fn:matches($item/fn:string[@key='pattern']/text(), '^\^[^/]+/'))">
        <xsl:text>Odkaz</xsl:text>
        <xsl:if test="$item/fn:string[@key='pattern']">
          <xsl:text> dle vzoru </xsl:text>
          <code><xsl:value-of select="$item/fn:string[@key='pattern']" /></code>
        </xsl:if>
      </xsl:when>
      <xsl:when test="$item/fn:string[@key='type'] = 'string'">
        <a href="https://opendata.gov.cz/datovy-typ:řetezec">Řetězec</a>
        <xsl:if test="$item/fn:string[@key='pattern']">
          <xsl:text> dle vzoru </xsl:text>
          <code><xsl:value-of select="$item/fn:string[@key='pattern']" /></code>
        </xsl:if>
      </xsl:when>
		  <xsl:when test="$item/fn:string[@key='type'] = 'boolean'">
        <a href="https://opendata.gov.cz/datovy-typ:anone">Boolean</a>
      </xsl:when>
		  <xsl:when test="$item/fn:string[@key='type'] = 'integer'">
        <a href="https://opendata.gov.cz/datovy-typ:celé-císlo">Celé číslo</a>
      </xsl:when>
      <xsl:when test="$item/fn:string[@key='type'] = 'object' and $item/fn:map[@key='properties']/fn:map[@key='cs' or @key='en']">
        <a>Vícejazyčný řetězec</a>
      </xsl:when>
      <xsl:when test="$item/fn:string[@key='$ref']">
			  <xsl:variable name="ref-item-name" select="fn:substring($item/fn:string[@key='$ref'], 15)" />
        <xsl:variable name="ref-item" select="$item/ancestor::fn:source//fn:map[@key='definitions']/fn:map[@key=$ref-item-name]" />
        <xsl:sequence select="gen:generujPopisTypuVlastnosti($ref-item)" />
			</xsl:when>
      <xsl:when test="($item/fn:string[@key='type'] = 'object') and ($item/fn:map[@key='properties']/fn:map[@key = 'type'])">
        <xsl:text>instance typu </xsl:text>
        <xsl:variable name="nazev" select="gen:generujNázevTypuPrvkuVSémantickémSlovníkuPojmů($item)" />
        <xsl:choose>
          <xsl:when test="fn:contains($nazev, 'CHYBA:')">
            <xsl:for-each select="gen:generujOborHodnotPrvkuVSémantickémSlovníkuPojmů($item)">
              <a><xsl:sequence select="gen:generujJménoPrvkuSIRIVSémantickémSlovníkuPojmů(.)" /></a>
            </xsl:for-each>
          </xsl:when>
          <xsl:otherwise>
            <a><xsl:value-of select="$nazev" /></a>
          </xsl:otherwise>
        </xsl:choose>
  	  </xsl:when>
      <xsl:when test="($item/fn:string[@key='type'] = 'object') and not($item/fn:map[@key='properties']/fn:map[@key = 'type'])">
        <xsl:text>instance se strukturou sestávající z následujících nepovinných prvků:</xsl:text>
        <ul>
          <xsl:for-each select="$item/fn:map/fn:map">
            <xsl:sequence select="gen:generujVlastnostProPřehled(.)" />
          </xsl:for-each>
        </ul>
  	  </xsl:when>
      <xsl:when test="$item/fn:string[@key='type'] = 'object'">
        instance typu <a><xsl:value-of select="gen:generujNázevTypuPrvkuVSémantickémSlovníkuPojmů($item)" /></a>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>CHYBA: Neznámý typ specifikace</xsl:text>
        <xsl:sequence select="$item" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>

  <xsl:function name="gen:generujLegislativuPrvkuVSémantickémSlovníkuPojmů" as="xs:string*">
    <xsl:param name="item" as="element()" />
    <xsl:for-each select="gen:generujHodnotuVlastnostiPrvkuVSémantickémSlovníkuPojmů($item, 'dc:relation', false(), false(), false())">
      <xsl:value-of select="." />
    </xsl:for-each>
  </xsl:function>

  <xsl:function name="gen:generujNázevPrvkuVSémantickémSlovníkuPojmů" as="xs:string">
    <xsl:param name="item" as="element()" />
    <xsl:value-of select="gen:generujHodnotuVlastnostiPrvkuVSémantickémSlovníkuPojmů($item, 'rdfs:label', false(), true(), false())" />
  </xsl:function>

  <xsl:function name="gen:generujNázevTypuPrvkuVSémantickémSlovníkuPojmů" as="xs:string">
    <xsl:param name="item" as="element()" />
    <xsl:value-of select="gen:generujHodnotuVlastnostiPrvkuVSémantickémSlovníkuPojmů($item, 'rdfs:label', false(), true(), true())" />
  </xsl:function>

  <xsl:function name="gen:generujTypPrvkuVSémantickémSlovníkuPojmů" as="xs:string*">
    <xsl:param name="item" as="element()" />
    <xsl:value-of select="
fn:substring-after(gen:generujHodnotuVlastnostiPrvkuVSémantickémSlovníkuPojmů($item, 'rdf:type', false(), false(), false())[fn:starts-with(., 'https://slovník.gov.cz/základní/pojem/')][1], 'https://slovník.gov.cz/základní/pojem/')" />
  </xsl:function>

  <xsl:function name="gen:generujDoménuPrvkuVSémantickémSlovníkuPojmů" as="xs:string*">
    <xsl:param name="item" as="element()" />
    <xsl:for-each select="gen:generujHodnotuVlastnostiPrvkuVSémantickémSlovníkuPojmů($item, 'rdfs:domain', false(), false(), false())">
      <xsl:value-of select="." />
    </xsl:for-each>
  </xsl:function>

  <xsl:function name="gen:generujOborHodnotPrvkuVSémantickémSlovníkuPojmů" as="xs:string*">
    <xsl:param name="item" as="element()" />
    <xsl:for-each select="gen:generujHodnotuVlastnostiPrvkuVSémantickémSlovníkuPojmů($item, 'rdfs:range', false(), false(), false())">
      <xsl:value-of select="." />
    </xsl:for-each>
  </xsl:function>

  <xsl:function name="gen:generujOdkazNaPrvekVSémantickémSlovníkuPojmů" as="element()">
    <xsl:param name="item" as="element()" />
    <xsl:sequence select="gen:generujHodnotuVlastnostiPrvkuVSémantickémSlovníkuPojmů($item, 'rdfs:label', true(), true(), false())[1]" />
  </xsl:function>

  <xsl:function name="gen:generujPopisPrvkuVSémantickémSlovníkuPojmů" as="xs:string">
    <xsl:param name="item" as="element()" />
    <xsl:variable name="popis" select="gen:generujHodnotuVlastnostiPrvkuVSémantickémSlovníkuPojmů($item, 'skos:definition', false(), true(), false())[1]" />
    <xsl:choose>
      <xsl:when test="fn:contains($popis[1], 'CHYBA: ')">
        <xsl:value-of select="gen:generujHodnotuVlastnostiPrvkuVSémantickémSlovníkuPojmů($item, 'dc:description', false(), true(), false())[1]" />
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$popis" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>

  <xsl:function name="gen:generujHodnotuVlastnostiPrvkuVSémantickémSlovníkuPojmů" as="node()*">
    <xsl:param name="item" as="element()" />
    <xsl:param name="property" as="xs:string" />
    <xsl:param name="asLink" as="xs:boolean" />
    <xsl:param name="isDatatype" as="xs:boolean" />
    <xsl:param name="asType" as="xs:boolean" />
    <xsl:variable name="jsonAlias" select="($item/fn:map[$asType and @key='properties']/fn:map[@key='type']/fn:string[@key='default']/text(), $item/@key, $item/fn:map[@key='properties']/fn:map[@key='type']/fn:string[@key='default']/text())[. != 'items'][1]" />
    <xsl:variable name="context" select="$item/ancestor::fn:source/fn:map/fn:map[@key='@context']" />
  	<xsl:variable name="qName" select="($context/fn:string[@key = $jsonAlias]/text(), $context/fn:map[@key = $jsonAlias]/fn:string[@key='@id' or @key='@reverse']/text())[1]" />
  	<xsl:variable name="prefix" select="fn:substring-before($qName, ':')" />
  	<xsl:variable name="localName" select="fn:substring-after($qName, ':')" />
  	<xsl:variable name="iriPrefix" select="$context/fn:string[@key = $prefix]/text()" />
  	<xsl:variable name="iri" select="fn:concat($iriPrefix, $localName)" />
  	<xsl:try>
  		<xsl:variable name="semVocTypeXMLDocumentIRI" select="fn:concat('https://xn--slovnk-7va.gov.cz/sparql?default-graph-uri=https%3A%2F%2Fslovn%C3%ADk.gov.cz%2Fisvs', '&#38;', 'query=define%20sql%3Adescribe-mode%20%22CBD%22%20%20DESCRIBE%20%3C',fn:encode-for-uri($iri), '%3E', '&#38;', 'output=application%2Frdf%2Bxml')" />
  		<xsl:variable name="semVocTypeXMLDocument" select="fn:doc($semVocTypeXMLDocumentIRI)" />
  		<xsl:choose>
  			<xsl:when test="$isDatatype and $semVocTypeXMLDocument//.[fn:name() = $property]">
          <xsl:choose>
            <xsl:when test="$asLink">
              <xsl:for-each select="$semVocTypeXMLDocument//.[fn:name() = $property]">
                <a class="ssplink">
                  <xsl:attribute name="href" select="$iri" />
                  <xsl:value-of select="text()" />
                </a>
              </xsl:for-each>
            </xsl:when>
            <xsl:otherwise>
              <xsl:for-each select="$semVocTypeXMLDocument//.[fn:name() = $property]">
                <xsl:value-of select="text()" />
              </xsl:for-each>
            </xsl:otherwise>
  				</xsl:choose>
  			</xsl:when>
        <xsl:when test="not($isDatatype) and $semVocTypeXMLDocument//.[fn:name() = $property]/@rdf:resource">
          <xsl:choose>
            <xsl:when test="$asLink">
              <xsl:for-each select="$semVocTypeXMLDocument//.[fn:name() = $property]">
                <a class="ssplink">
                  <xsl:attribute name="href" select="$iri" />
                  <xsl:value-of select="./@rdf:resource" />
                </a>
              </xsl:for-each>
            </xsl:when>
            <xsl:otherwise>
              <xsl:for-each select="$semVocTypeXMLDocument//.[fn:name() = $property]">
                <xsl:value-of select="./@rdf:resource" />
              </xsl:for-each>
            </xsl:otherwise>
  				</xsl:choose>
        </xsl:when>
  			<xsl:otherwise>
          <xsl:choose>
            <xsl:when test="$asLink">
              <a>CHYBA: V sémantickém slovníku pojmů odpovídá prvek typu <xsl:value-of select="$iri" />, pro nějž není hodnota vlastnosti <xsl:value-of select="$property" /> ve slovníku uvedena. <xsl:value-of select="$semVocTypeXMLDocumentIRI" /></a>
            </xsl:when>
            <xsl:otherwise>CHYBA: V sémantickém slovníku pojmů odpovídá prvek typu <xsl:value-of select="$iri" />, pro nějž není hodnota vlastnosti <xsl:value-of select="$property" /> ve slovníku uvedena. <xsl:value-of select="$semVocTypeXMLDocumentIRI" /></xsl:otherwise>
  				</xsl:choose>
  			</xsl:otherwise>
  		</xsl:choose>
  		<xsl:catch>
        <xsl:choose>
          <xsl:when test="$asLink">
            <a>CHYBA: V sémantickém slovníku pojmů odpovídá prvek typu <xsl:value-of select="$iri" />, jehož definici se nepodařilo načíst.</a>
          </xsl:when>
          <xsl:otherwise>CHYBA: V sémantickém slovníku pojmů odpovídá prvek typu <xsl:value-of select="$iri" />, jehož definici se nepodařilo načíst.</xsl:otherwise>
  			</xsl:choose>
  		</xsl:catch>
  	</xsl:try>
  </xsl:function>


  <xsl:function name="gen:generujQNamePrvkuVSémantickémSlovníkuPojmů" as="xs:string">
    <xsl:param name="item" as="element()" />
    <xsl:variable name="jsonAlias" select="($item/@key, $item/fn:map[@key='properties']/fn:map[@key='type']/fn:string[@key='default']/text())[. != 'items'][1]" />
    <xsl:variable name="context" select="$item/ancestor::fn:source/fn:map/fn:map[@key='@context']" />
  	<xsl:variable name="qName" select="($context/fn:string[@key = $jsonAlias]/text(), $context/fn:map[@key = $jsonAlias]/fn:string[@key='@id' or @key='@reverse']/text())[1]" />
  	<xsl:variable name="prefix" select="fn:substring-before($qName, ':')" />
  	<xsl:variable name="localName" select="fn:substring-after($qName, ':')" />
  	<xsl:variable name="iriPrefix" select="$context/fn:string[@key = $prefix]/text()" />
  	<xsl:variable name="iri" select="fn:concat($iriPrefix, $localName)" />
  	<xsl:value-of select="$qName" />
  </xsl:function>

  <xsl:function name="gen:generujLocalNamePrvkuVSémantickémSlovníkuPojmů" as="xs:string">
    <xsl:param name="item" as="element()" />
    <xsl:variable name="jsonAlias" select="($item/@key, $item/fn:map[@key='properties']/fn:map[@key='type']/fn:string[@key='default']/text())[. != 'items'][1]" />
    <xsl:variable name="context" select="$item/ancestor::fn:source/fn:map/fn:map[@key='@context']" />
  	<xsl:variable name="qName" select="($context/fn:string[@key = $jsonAlias]/text(), $context/fn:map[@key = $jsonAlias]/fn:string[@key='@id' or @key='@reverse']/text())[1]" />
  	<xsl:variable name="prefix" select="fn:substring-before($qName, ':')" />
  	<xsl:variable name="localName" select="fn:substring-after($qName, ':')" />
  	<xsl:variable name="iriPrefix" select="$context/fn:string[@key = $prefix]/text()" />
  	<xsl:variable name="iri" select="fn:concat($iriPrefix, $localName)" />
  	<xsl:value-of select="$localName" />
  </xsl:function>

  <xsl:function name="gen:generujPrefixPrvkuVSémantickémSlovníkuPojmů" as="xs:string">
    <xsl:param name="item" as="element()" />
    <xsl:variable name="jsonAlias" select="($item/@key, $item/fn:map[@key='properties']/fn:map[@key='type']/fn:string[@key='default']/text())[. != 'items'][1]" />
    <xsl:variable name="context" select="$item/ancestor::fn:source/fn:map/fn:map[@key='@context']" />
  	<xsl:variable name="qName" select="($context/fn:string[@key = $jsonAlias]/text(), $context/fn:map[@key = $jsonAlias]/fn:string[@key='@id' or @key='@reverse']/text())[1]" />
  	<xsl:variable name="prefix" select="fn:substring-before($qName, ':')" />
  	<xsl:variable name="localName" select="fn:substring-after($qName, ':')" />
  	<xsl:variable name="iriPrefix" select="$context/fn:string[@key = $prefix]/text()" />
  	<xsl:variable name="iri" select="fn:concat($iriPrefix, $localName)" />
  	<xsl:value-of select="$prefix" />
  </xsl:function>

  <xsl:function name="gen:generujPrefixIRIPrvkuVSémantickémSlovníkuPojmů" as="xs:string">
    <xsl:param name="item" as="element()" />
    <xsl:variable name="jsonAlias" select="($item/@key, $item/fn:map[@key='properties']/fn:map[@key='type']/fn:string[@key='default']/text())[. != 'items'][1]" />
    <xsl:variable name="context" select="$item/ancestor::fn:source/fn:map/fn:map[@key='@context']" />
  	<xsl:variable name="qName" select="($context/fn:string[@key = $jsonAlias]/text(), $context/fn:map[@key = $jsonAlias]/fn:string[@key='@id' or @key='@reverse']/text())[1]" />
  	<xsl:variable name="prefix" select="fn:substring-before($qName, ':')" />
  	<xsl:variable name="localName" select="fn:substring-after($qName, ':')" />
  	<xsl:variable name="iriPrefix" select="$context/fn:string[@key = $prefix]/text()" />
  	<xsl:variable name="iri" select="fn:concat($iriPrefix, $localName)" />
  	<xsl:value-of select="$iriPrefix" />
  </xsl:function>

  <xsl:function name="gen:generujOdkazNaPrvekSIRIVSémantickémSlovníkuPojmů" as="node()*">
    <xsl:param name="iri" as="xs:string" />
  	<xsl:try>
  		<xsl:variable name="semVocTypeXMLDocumentIRI" select="fn:concat('https://xn--slovnk-7va.gov.cz/sparql?default-graph-uri=https%3A%2F%2Fslovn%C3%ADk.gov.cz%2Fisvs', '&#38;', 'query=define%20sql%3Adescribe-mode%20%22CBD%22%20%20DESCRIBE%20%3C',fn:encode-for-uri($iri), '%3E', '&#38;', 'output=application%2Frdf%2Bxml')" />
  		<xsl:variable name="semVocTypeXMLDocument" select="fn:doc($semVocTypeXMLDocumentIRI)" />
  		<xsl:choose>
  			<xsl:when test="$semVocTypeXMLDocument//rdfs:label">
          <xsl:for-each select="$semVocTypeXMLDocument//rdfs:label">
            <a class="ssplink">
              <xsl:attribute name="href" select="$iri" />
              <xsl:value-of select="text()" />
            </a>
          </xsl:for-each>
  			</xsl:when>
  			<xsl:otherwise>
          <a>CHYBA: V sémantickém slovníku pojmů odpovídá prvek typu <xsl:value-of select="$iri" />, pro nějž není hodnota vlastnosti rdfs:label ve slovníku uvedena.</a>
  			</xsl:otherwise>
  		</xsl:choose>
  		<xsl:catch>
        <a>CHYBA: V sémantickém slovníku pojmů odpovídá prvek typu <xsl:value-of select="$iri" />, jehož definici se nepodařilo načíst.</a>
  		</xsl:catch>
  	</xsl:try>
  </xsl:function>

  <xsl:function name="gen:generujJménoPrvkuSIRIVSémantickémSlovníkuPojmů" as="node()*">
    <xsl:param name="iri" as="xs:string" />
  	<xsl:try>
  		<xsl:variable name="semVocTypeXMLDocumentIRI" select="fn:concat('https://xn--slovnk-7va.gov.cz/sparql?default-graph-uri=https%3A%2F%2Fslovn%C3%ADk.gov.cz%2Fisvs', '&#38;', 'query=define%20sql%3Adescribe-mode%20%22CBD%22%20%20DESCRIBE%20%3C',fn:encode-for-uri($iri), '%3E', '&#38;', 'output=application%2Frdf%2Bxml')" />
  		<xsl:variable name="semVocTypeXMLDocument" select="fn:doc($semVocTypeXMLDocumentIRI)" />
  		<xsl:choose>
  			<xsl:when test="$semVocTypeXMLDocument//rdfs:label">
          <xsl:for-each select="$semVocTypeXMLDocument//rdfs:label">
            <xsl:value-of select="text()" />
          </xsl:for-each>
  			</xsl:when>
  			<xsl:otherwise>
          <a>CHYBA: V sémantickém slovníku pojmů odpovídá prvek typu <xsl:value-of select="$iri" />, pro nějž není hodnota vlastnosti rdfs:label ve slovníku uvedena.</a>
  			</xsl:otherwise>
  		</xsl:choose>
  		<xsl:catch>
        <a>CHYBA: V sémantickém slovníku pojmů odpovídá prvek typu <xsl:value-of select="$iri" />, jehož definici se nepodařilo načíst.</a>
  		</xsl:catch>
  	</xsl:try>
  </xsl:function>

  <xsl:function name="gen:generujOdkazyNaZakonyProLidi" as="element()*">
    <xsl:param name="item" as="element()" />
    <xsl:variable name="legislativa" select="gen:generujLegislativuPrvkuVSémantickémSlovníkuPojmů($item)[fn:starts-with(., 'https://esbirka.opendata.cz/zdroj/předpis')]" />
    <xsl:if test="fn:exists($legislativa)">
      <p>
        Prvek je zaveden v následujících ustanoveních právních předpisů:
        <ul>
          <xsl:for-each select="$legislativa">
            <li>
              <a>
                <xsl:choose>
                  <xsl:when test="fn:matches(., '^https://esbirka.opendata.cz/zdroj/předpis/([0-9]+)/([0-9]+)$')">
                    <xsl:attribute name="href" select="fn:replace(., '^https://esbirka.opendata.cz/zdroj/předpis/([0-9]+)/([0-9]+)$', 'https://zakonyprolidi.cz/cs/$2-$1')" />
                    <xsl:value-of select="fn:replace(., '^https://esbirka.opendata.cz/zdroj/předpis/([0-9]+)/([0-9]+)$', 'Zákon č. $1/$2 Sb.')" />
                  </xsl:when>
                  <xsl:when test="fn:matches(., '^https://esbirka.opendata.cz/zdroj/předpis/([0-9]+)/([0-9]+)/sekce/([0-9]+[a-z]*)$')">
                    <xsl:attribute name="href" select="fn:replace(., '^https://esbirka.opendata.cz/zdroj/předpis/([0-9]+)/([0-9]+)/sekce/([0-9]+[a-z]*)$', 'https://zakonyprolidi.cz/cs/$2-$1#p$3')" />
                    <xsl:value-of select="fn:replace(., '^https://esbirka.opendata.cz/zdroj/předpis/([0-9]+)/([0-9]+)/sekce/([0-9]+[a-z]*)$', '§ $3 zákona č. $1/$2 Sb.')" />
                  </xsl:when>
                  <xsl:when test="fn:matches(., '^https://esbirka.opendata.cz/zdroj/předpis/([0-9]+)/([0-9]+)/sekce/([0-9]+[a-z]*)/([0-9]+[a-z]*)$')">
                    <xsl:attribute name="href" select="fn:replace(., '^https://esbirka.opendata.cz/zdroj/předpis/([0-9]+)/([0-9]+)/sekce/([0-9]+[a-z]*)/([0-9]+[a-z]*)$', 'https://zakonyprolidi.cz/cs/$2-$1#p$3-$4')" />
                    <xsl:value-of select="fn:replace(., '^https://esbirka.opendata.cz/zdroj/předpis/([0-9]+)/([0-9]+)/sekce/([0-9]+[a-z]*)/([0-9]+[a-z]*)$', '§ $3 odst. $4 zákona č. $1/$2 Sb.')" />
                  </xsl:when>
                  <xsl:when test="fn:matches(., '^https://esbirka.opendata.cz/zdroj/předpis/([0-9]+)/([0-9]+)/sekce/([0-9]+[a-z]*)/([0-9]+[a-z]*)/([a-z]+)$')">
                    <xsl:attribute name="href" select="fn:replace(., '^https://esbirka.opendata.cz/zdroj/předpis/([0-9]+)/([0-9]+)/sekce/([0-9]+[a-z]*)/([0-9]+[a-z]*)/([a-z]+)$', 'https://zakonyprolidi.cz/cs/$2-$1#p$3-$4-$5')" />
                    <xsl:value-of select="fn:replace(., '^https://esbirka.opendata.cz/zdroj/předpis/([0-9]+)/([0-9]+)/sekce/([0-9]+[a-z]*)/([0-9]+[a-z]*)/([a-z]+)$', '§ $3 odst. $4 písm. $5) zákona č. $1/$2 Sb.')" />
                  </xsl:when>
                  <xsl:when test="fn:matches(., '^https://esbirka.opendata.cz/zdroj/předpis/([0-9]+)/([0-9]+)/sekce/([0-9]+[a-z]*)/([a-z]+)$')">
                    <xsl:attribute name="href" select="fn:replace(., '^https://esbirka.opendata.cz/zdroj/předpis/([0-9]+)/([0-9]+)/sekce/([0-9]+[a-z]*)/([a-z]+)$', 'https://zakonyprolidi.cz/cs/$2-$1#p$3-1-$4')" />
                    <xsl:value-of select="fn:replace(., '^https://esbirka.opendata.cz/zdroj/předpis/([0-9]+)/([0-9]+)/sekce/([0-9]+[a-z]*)/([a-z]+)$', '§ $3 písm. $4) zákona č. $1/$2 Sb.')" />
                  </xsl:when>
                  <xsl:when test="fn:matches(., '^https://esbirka.opendata.cz/zdroj/předpis/([0-9]+)/([0-9]+)/sekce/([0-9]+[a-z]*)/([0-9]+[a-z]*)/([a-z]+)/([0-9]+[a-z]*)$')">
                    <xsl:attribute name="href" select="fn:replace(., '^https://esbirka.opendata.cz/zdroj/předpis/([0-9]+)/([0-9]+)/sekce/([0-9]+[a-z]*)/([0-9]+[a-z]*)/([a-z]+)/([0-9]+[a-z]*)$', 'https://zakonyprolidi.cz/cs/$2-$1#p$3-$4-$5-$6')" />
                    <xsl:value-of select="fn:replace(., '^https://esbirka.opendata.cz/zdroj/předpis/([0-9]+)/([0-9]+)/sekce/([0-9]+[a-z]*)/([0-9]+[a-z]*)/([a-z]+)/([0-9]+[a-z]*)$', '§ $3 odst. $4 písm. $5) bod $6. zákona č. $1/$2 Sb.')" />
                  </xsl:when>
                  <xsl:when test="fn:matches(., '^https://esbirka.opendata.cz/zdroj/předpis/([0-9]+)/([0-9]+)/sekce/([0-9]+[a-z]*)/([a-z]+)/([0-9]+[a-z]*)$')">
                    <xsl:attribute name="href" select="fn:replace(., '^https://esbirka.opendata.cz/zdroj/předpis/([0-9]+)/([0-9]+)/sekce/([0-9]+[a-z]*)/([a-z]+)/([0-9]+[a-z]*)$', 'https://zakonyprolidi.cz/cs/$2-$1#p$3-1-$4-$5')" />
                    <xsl:value-of select="fn:replace(., '^https://esbirka.opendata.cz/zdroj/předpis/([0-9]+)/([0-9]+)/sekce/([0-9]+[a-z]*)/([a-z]+)/([0-9]+[a-z]*)$', '§ $3 písm. $4) bod $5. zákona č. $1/$2 Sb.')" />
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:text>CHYBA: Nerozpoznané IRI ustanovení právního předpisu </xsl:text>
                    <xsl:value-of select="." />
                  </xsl:otherwise>
                </xsl:choose>
              </a>
            </li>
          </xsl:for-each>
        </ul>
      </p>
    </xsl:if>
  </xsl:function>


</xsl:stylesheet>