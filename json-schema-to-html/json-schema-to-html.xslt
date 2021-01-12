<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:db="http://docbook.org/ns/docbook" xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:gen="https://data.gov.cz/otevřené-formální-normy/generátor" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#" xmlns:skos="http://www.w3.org/2004/02/skos/core#" xmlns:dc="http://purl.org/dc/elements/1.1/" version="3.0" expand-text="yes">
	<xsl:template match="db:article" mode="abstrakt">
		<xsl:apply-templates select="db:info/db:abstract"/>
	</xsl:template>
	<xsl:template match="db:abstract" mode="abstrakt">
		<section id="abstract" class="introductory">
			<h2>Abstrakt</h2>
			<p>
				<xsl:copy-of select="node()"/>
			</p>
		</section>
	</xsl:template>
	<xsl:template match="text()" mode="abstrakt"/>
	<xsl:template match="db:section[@id='příklady']" mode="příklady" />
<!--		<section id="příklady">
			<h2>
				<dfn>Příklady</dfn>
			</h2>
			<xsl:for-each select="db:example">
				<section>
					<h3>
						<xsl:value-of select="db:title"/>
					</h3>
					<p>
						<xsl:value-of select="db:annotation"/>
					</p>
					<aside class="example">
						<xsl:attribute name="title" select="db:title"/>
						<pre class="json">
							<xsl:value-of select="db:programlisting"/>
						</pre>
					</aside>
				</section>
			</xsl:for-each>
		</section>
	</xsl:template>-->
	<xsl:template match="text()" mode="příklady"/>
	<xsl:function name="gen:generujDokumentaciPrvků">
		<xsl:param name="schema"/>
		<xsl:param name="context"/>
		<xsl:variable name="source">
			<xsl:element name="source" xmlns="http://www.w3.org/2005/xpath-functions">
				<xsl:sequence select="fn:json-to-xml(fn:unparsed-text($context), map{ 'escape': false()})"/>
				<xsl:sequence select="fn:json-to-xml(fn:unparsed-text($schema), map{ 'escape': false()})"/>
			</xsl:element>
		</xsl:variable>
		<section id="json">
			<h2>
				<dfn>JSON struktura</dfn>
			</h2>
			<p>V této sekci je popsána struktura JSON distribuce datové sady. Struktura je též popsána v <a href="{fn:replace($schema, '^.*/([^/]+)$', '$1')}">JSON schématu</a>.</p>
			<xsl:sequence select="gen:generujJSONPřehled($source)"/>
			<xsl:sequence select="gen:generujJSONSpecifikaci($source)"/>
		</section>
		<section id="rdf">
			<h2>
				<dfn>RDF struktura</dfn>
			</h2>
			<p>V této sekci je popsána struktura RDF distribuce datové sady.</p>
			<xsl:sequence select="gen:generujRDFPřehled($source)"/>
			<xsl:sequence select="gen:generujSPARQLUkázky($source)"/>
		</section>
	</xsl:function>
	<xsl:function name="gen:generujJSONPřehled" as="element()">
		<xsl:param name="source" as="document-node()"/>
		<section id="json-přehled">
			<h3>Přehled JSON struktury</h3>
			<xsl:apply-templates select="$source" mode="jsonpřehled"/>
		</section>
	</xsl:function>
	<xsl:template match="fn:map[@key='@context']" mode="jsonpřehled"/>
	<xsl:template match="text()" mode="jsonpřehled"/>
	<xsl:template match="fn:map[fn:string[@key='$schema']]" mode="jsonpřehled">
		<xsl:choose>
			<xsl:when test="fn:map[@key='properties'][fn:map[@key='type']/fn:string[@key='default']='číselník']">
				<xsl:text>Datová sada je tvořena seznamem položek číselníku </xsl:text>
				<xsl:value-of select="gen:generujNázevČíselníku(.)"/>
				<xsl:text> odpovídajících datové struktuře </xsl:text>
				<a><xsl:value-of select="gen:generujNázevPrvkuVSémantickémSlovníkuPojmů(fn:map/fn:map/fn:map[fn:string[@key='type'] = 'object'])"/></a>
				<xsl:text>. Položky jsou uvedeny v poli </xsl:text>
				<code>položky</code>.
        <ul>
					<xsl:for-each select=".//fn:map[fn:string[@key='type'] = 'object'][fn:map[@key='properties']/fn:map/@key != 'cs' and fn:map[@key='properties']/fn:map/@key != 'en'][fn:map[@key='properties']/fn:map[@key='type'] or ./ancestor::fn:map[@key = 'definitions']]">
						<li>
							<a><xsl:value-of select="gen:generujNázevTypuPrvkuVSémantickémSlovníkuPojmů(.)"/></a>
							<xsl:text> sestává z následujících nepovinných vlastností:</xsl:text>
							<ul>
								<xsl:for-each select="./fn:map/fn:map">
									<xsl:sequence select="gen:generujVlastnostProJSONPřehled(.)"/>
								</xsl:for-each>
							</ul>
						</li>
					</xsl:for-each>
				</ul>
			</xsl:when>
			<xsl:when test="fn:map/fn:map/fn:map[fn:string[@key='type'] = 'object'][fn:map[@key='properties']/fn:map[@key='type']]">
				<xsl:text>Datová sada je tvořena seznamem prvků odpovídajících datové struktuře </xsl:text>
				<a><xsl:value-of select="gen:generujNázevPrvkuVSémantickémSlovníkuPojmů(fn:map/fn:map/fn:map[fn:string[@key='type'] = 'object'])"/></a>
				<xsl:text>. Prvky jsou uvedeny v poli </xsl:text>
				<code>položky</code>.
        <ul>
					<xsl:for-each select=".//fn:map[fn:string[@key='type'] = 'object'][fn:map[@key='properties']/fn:map/@key != 'cs' and fn:map[@key='properties']/fn:map/@key != 'en'][fn:map[@key='properties']/fn:map[@key='type'] or ./ancestor::fn:map[@key = 'definitions']]">
						<li>
							<a><xsl:value-of select="gen:generujNázevTypuPrvkuVSémantickémSlovníkuPojmů(.)"/></a>
							<xsl:text> sestává z následujících nepovinných vlastností:</xsl:text>
							<ul>
								<xsl:for-each select="./fn:map/fn:map">
									<xsl:sequence select="gen:generujVlastnostProJSONPřehled(.)"/>
								</xsl:for-each>
							</ul>
						</li>
					</xsl:for-each>
				</ul>
			</xsl:when>
			<xsl:when test="fn:map/fn:map/fn:map[fn:string[@key='type'] = 'object'][not(fn:map[@key='properties']/fn:map[@key='type'])]">
				<xsl:text>Datová sada je tvořena seznamem prvků uvedených v poli </xsl:text>
				<code>položky</code>
				<xsl:text>. Každý prvek v poli sestává z následujících nepovinných vlastností:</xsl:text>
				<ul>
					<xsl:for-each select="fn:map/fn:map/fn:map[fn:string[@key='type'] = 'object']/fn:map/fn:map">
						<xsl:sequence select="gen:generujVlastnostProJSONPřehled(.)"/>
					</xsl:for-each>
				</ul>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>CHYBA: Nepodporovaná konstrukce pro specifikaci položek.</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<xsl:function name="gen:generujVlastnostProJSONPřehled" as="element()">
		<xsl:param name="item" as="element()"/>
		<li>
			<code>
				<a>
					<xsl:value-of select="$item/@key"/>
				</a>
			</code>
			<xsl:text> : </xsl:text>
			<xsl:sequence select="gen:generujJSONPopisTypuVlastnosti($item)"/>
		</li>
	</xsl:function>
	<xsl:function name="gen:generujJSONSpecifikaci" as="element()">
		<xsl:param name="source" as="document-node()"/>
		<section id="json-specifikace">
			<h3>Detailní specifikace prvků JSON struktury</h3>
			<xsl:apply-templates select="$source" mode="jsonspecifikace"/>
		</section>
	</xsl:function>
	<xsl:template match="fn:map[@key='@context']" mode="jsonspecifikace">

  </xsl:template>
	<xsl:template match="text()" mode="jsonspecifikace">

  </xsl:template>
	<xsl:template match="fn:map[fn:string[@key='$schema']]" mode="jsonspecifikace">
		<xsl:text>V této části jsou specifikovány jednotlivé prvky JSON struktury.</xsl:text>
		<xsl:for-each select=".//fn:map[fn:string[@key='type'] = 'object'][fn:map[@key='properties']/fn:map/@key != 'cs' and fn:map[@key='properties']/fn:map/@key != 'en'][fn:map[@key='properties']/fn:map[@key='type'] or ./ancestor::fn:map[@key = 'definitions']]">
			<section>
				<xsl:variable name="nazevTypuPrvku" select="gen:generujNázevTypuPrvkuVSémantickémSlovníkuPojmů(.)"/>
				<h4>
					<dfn>
						<xsl:value-of select="$nazevTypuPrvku"/>
					</dfn>
				</h4>
				<dl>
					<dt>Popis</dt>
					<dd>
						<xsl:value-of select="gen:generujPopisPrvkuVSémantickémSlovníkuPojmů(.)"/>
					</dd>
					<xsl:variable name="legislativa" select="gen:generujOdkazyNaZakonyProLidi(.)" />
					<xsl:if test="exists($legislativa)">
						<dt>Definující ustanovení právních předpisů</dt>
						<dd>
							<xsl:sequence select="$legislativa"/>
						</dd>
					</xsl:if>
					<dt>Význam</dt>
					<dd>
						Typ {$nazevTypuPrvku} je definován v sémantickém slovníku pojmů jako <xsl:sequence select="gen:generujOdkazNaPrvekVSémantickémSlovníkuPojmů(.)" />.
					</dd>
				</dl>				
				<xsl:sequence select="gen:generujVlastnostiProJSONSpecifikaci(.)"/>
				<xsl:if test="fn:string[fn:contains(@key, 'ref')]">
					<xsl:variable name="ref-item" select="fn:substring(fn:string[fn:contains(@key, 'ref')], 15)"/>
    		  viz <a>
						<xsl:value-of select="/fn:source/fn:map/fn:map[@key='definitions']/fn:map[@key=$ref-item]/fn:string[@key='title']"/>
					</a>
				</xsl:if>
			</section>
		</xsl:for-each>
		<xsl:if test="fn:map/fn:map/fn:map[fn:string[@key='type'] = 'object'][not(fn:map[@key='properties']/fn:map[@key='type'])]">
			<section>
				<h4>Prvky</h4>
				<xsl:sequence select="gen:generujVlastnostiProJSONSpecifikaci(fn:map/fn:map/fn:map[fn:string[@key='type'] = 'object'])"/>
			</section>
		</xsl:if>
		<xsl:if test="/fn:source/fn:map/fn:map[@key='definitions']/fn:map[fn:string[@key='type'] != 'object' and fn:string[@key='type'] != 'array']">
			<section>
				<h4>Sdílené prvky</h4>
				<xsl:for-each select="/fn:source/fn:map/fn:map[@key='definitions']/fn:map[fn:string[@key='type'] != 'object' and fn:string[@key='type'] != 'array']">
					<xsl:sequence select="gen:generujVlastnostProJSONSpecifikaci(.)"/>
				</xsl:for-each>
			</section>
		</xsl:if>
		<xsl:if test=".//fn:map[@key='cs' or @key='en' or @key='type' or @key='id']">
			<section>
				<h4>Obecné prvky</h4>
				<p>Jedná se o JSON prvky, které jsou použity na různých místech JSON reprezentace datové sady v různých situacích</p>
				<xsl:if test=".//fn:map[@key='cs' or @key='en']">
					<section>
						<h5>
							<dfn>Vícejazyčný řetězec</dfn>
						</h5>
						<dl>
							<dt>Typ</dt>
							<dd>
								<pre class="json">
									<xsl:value-of select="'{&quot;cs&quot;: &quot;...&quot;, &quot;en&quot;: &quot;...&quot;, ...}'"/>
								</pre>
							</dd>
							<dt>Popis</dt>
							<dd>Typ je použit pro vlastnosti, jejichž hodnotou jsou řetězce v různých jazycích.</dd>
						</dl>
					</section>
				</xsl:if>
				<xsl:if test=".//fn:map[@key='type']">
					<section>
						<h5>Vlastnost <code>
								<dfn>type</dfn>
							</code>
						</h5>
						<dl>
							<dt>Typ</dt>
							<dd>
								<a href="https://data.gov.cz/otevřené-formální-normy/základní-datové-typy/#řetězec">Řetězec</a>
							</dd>
							<dt>Popis</dt>
							<dd>Vlastnost je použita pro označení sémantického typu daného prvku v JSON reprezentaci datové sady. Sémantický typ je identifikován v podobě lokálního IRI. Aby jej bylo možné využít, je nutné JSON reprezentaci interpretovat jako JSON-LD reprezentaci s pomocí kontextu uvedeného v JSON-LD reprezentaci (<code>@context</code>). Při této interpretaci lze získat globální IRI sémantického typu. Jeho dereferencováním lze získat úplnou definici významu.</dd>
						</dl>
					</section>
				</xsl:if>
				<xsl:if test=".//fn:map[@key='id']">
					<section>
						<h5>Vlastnost <code>
								<dfn>id</dfn>
							</code>
						</h5>
						<dl>
							<dt>Typ</dt>
							<dd>
								<a href="https://data.gov.cz/otevřené-formální-normy/základní-datové-typy/#řetězec">Řetězec</a>
							</dd>
							<dt>Jméno</dt>
							<dd>Identifikátor prvku</dd>
							<dt>Popis</dt>
							<dd>Vlastnost přiřazuje prvku identifikátor entity, kterou v JSON reprezentaci datové sady reprezentuje. Identifikátor entity je uveden v podobě relativního nebo absolutního <a href="https://data.gov.cz/otevřené-formální-normy/propojená-data/draft/#IRI">IRI</a>. V případě relativního <a href="https://data.gov.cz/otevřené-formální-normy/propojená-data/draft/#IRI">IRI</a> je pro získání absolutního <a href="https://data.gov.cz/otevřené-formální-normy/propojená-data/draft/#IRI">IRI</a> interpretovat JSON reprezentaci jako JSON-LD reprezentaci s pomocí  kontextu uvedeného v JSON-LD reprezentaci (<code>@context</code>). Dereferencováním získaného absolutního <a href="https://data.gov.cz/otevřené-formální-normy/propojená-data/draft/#IRI">IRI</a> lze získat úplnou podobu identifikované entity dostupnou v daném zdroji.</dd>
						</dl>
					</section>
				</xsl:if>
			</section>
		</xsl:if>
	</xsl:template>
	<xsl:function name="gen:generujVlastnostiProJSONSpecifikaci" as="element()*">
		<xsl:param name="item" as="element()"/>
		<xsl:for-each select="$item/fn:map/fn:map[@key!='type' and @key!='id']">
			<xsl:sequence select="gen:generujVlastnostProJSONSpecifikaci(.)"/>
		</xsl:for-each>
		<xsl:if test="$item/fn:map[@key='items'][fn:string[@key='type']!='object']">
			<xsl:for-each select="$item/fn:map[@key='items'][fn:string[@key='type']='string']">
				<xsl:sequence select="gen:generujVlastnostProJSONSpecifikaci(.)"/>
			</xsl:for-each>
		</xsl:if>
	</xsl:function>
	<xsl:function name="gen:generujVlastnostProJSONSpecifikaci" as="element()">
		<xsl:param name="item" as="element()"/>
		<section>
			<xsl:choose>
				<xsl:when test="($item/fn:string[@key='$ref']) and $item/ancestor::fn:source//fn:map[@key='definitions']/fn:map[@key=fn:substring($item/fn:string[@key='$ref'], 15)][fn:string[@key='type'] != 'object' and fn:string[@key='type'] != 'array']">
					<h5>
						<xsl:text>Vlastnost </xsl:text>
						<code>
							<xsl:value-of select="$item/@key"/>
						</code>
					</h5>
					<p>
						<xsl:text>Viz specifikace prvku </xsl:text>
						<a>
							<code>
								<xsl:value-of select="$item/@key"/>
							</code>
						</a>
					</p>
				</xsl:when>
				<xsl:otherwise>
					<h5>
						<xsl:text>Vlastnost </xsl:text>
						<code>
							<dfn>
								<xsl:value-of select="$item/@key"/>
							</dfn>
						</code>
					</h5>
					<dl>
						<dt>
      			  Typ
      		  </dt>
						<dd>
							<xsl:sequence select="gen:generujJSONPopisTypuVlastnosti($item)"/>
						</dd>
						<dt>
      			  Popis
      		  </dt>
						<dd>
							<xsl:value-of select="gen:generujPopisPrvkuVSémantickémSlovníkuPojmů($item)"/>
						</dd>
						<dt>
      			  Příklad
      		  </dt>
						<dd>
							<xsl:choose>
								<xsl:when test="not($item/fn:array[@key='examples']/fn:*) and $item/fn:map[@key='items'][fn:string[@key='type']='object']">
									<xsl:text>viz </xsl:text>
									<xsl:variable name="nazev" select="gen:generujNázevPrvkuVSémantickémSlovníkuPojmů($item/fn:map)"/>
									<xsl:choose>
										<xsl:when test="fn:contains($nazev, 'CHYBA:')">
											<xsl:for-each select="gen:generujOborHodnotPrvkuVSémantickémSlovníkuPojmů($item/fn:map)">
												<a><xsl:sequence select="gen:generujJménoPrvkuSIRIVSémantickémSlovníkuPojmů(.)"/></a>
											</xsl:for-each>
										</xsl:when>
										<xsl:otherwise>
											<a><xsl:value-of select="$nazev"/></a>
										</xsl:otherwise>
									</xsl:choose>
								</xsl:when>
								<xsl:when test="not($item/fn:array[@key='examples']/fn:*) and $item[fn:string[@key='type']='object']">
									<xsl:text>viz </xsl:text>
									<xsl:variable name="nazev" select="gen:generujNázevTypuPrvkuVSémantickémSlovníkuPojmů($item)"/>
									<xsl:choose>
										<xsl:when test="fn:contains($nazev, 'CHYBA:')">
											<xsl:for-each select="gen:generujOborHodnotPrvkuVSémantickémSlovníkuPojmů($item)">
												<a><xsl:sequence select="gen:generujJménoPrvkuSIRIVSémantickémSlovníkuPojmů(.)"/></a>
											</xsl:for-each>
										</xsl:when>
										<xsl:otherwise>
											<a><xsl:value-of select="$nazev"/></a>
										</xsl:otherwise>
									</xsl:choose>
								</xsl:when>
								<xsl:when test="$item/fn:array[@key='examples']/fn:*">
									<xsl:for-each select="$item/fn:array[@key='examples']/fn:*">
										<code>
											<xsl:value-of select="fn:replace(fn:xml-to-json(.), '\\/', '/')"/>
										</code><br/>
									</xsl:for-each>
								</xsl:when>
								<xsl:otherwise>
									<xsl:text>Neuveden</xsl:text>
								</xsl:otherwise>
							</xsl:choose>
						</dd>
						<xsl:variable name="legislativa" select="gen:generujOdkazyNaZakonyProLidi($item)" />
						<xsl:if test="exists($legislativa)">
							<dt>
								Definující ustanovení právních předpisů
							</dt>
							<dd>
								<xsl:sequence select="$legislativa"/>
							</dd>
						</xsl:if>
						<dt>
      			  Význam
      		  </dt>
						<dd>
							<!--<xsl:sequence select="gen:generujReferenciNaPrvekVSémantickémSlovníkuPojmů($item/@key, $item/ancestor::fn:source)" />-->
							<xsl:variable name="type" select="gen:generujTypPrvkuVSémantickémSlovníkuPojmů($item)"/>
							<xsl:choose>
								<xsl:when test="$type = 'typ-vlastnosti'">
									<p>
										<xsl:text>Vlastnost </xsl:text>
										<code>
											<xsl:value-of select="$item/@key"/>
										</code>
										<xsl:text> je definována v sémantickém slovníku pojmů jako </xsl:text>
										<xsl:sequence select="gen:generujOdkazNaPrvekVSémantickémSlovníkuPojmů($item)"/>
										<xsl:text> následovně:</xsl:text>
									</p>
									<p>
										<xsl:for-each select="gen:generujDoménuPrvkuVSémantickémSlovníkuPojmů($item)">
											<xsl:sequence select="gen:generujOdkazNaPrvekSIRIVSémantickémSlovníkuPojmů(.)"/>
											<xsl:text> ➡ </xsl:text>
											<strong>
												<xsl:sequence select="gen:generujOdkazNaPrvekVSémantickémSlovníkuPojmů($item)"/>
											</strong>
										</xsl:for-each>
									</p>
								</xsl:when>
								<xsl:when test="$type = 'typ-vztahu'">
									<p>
										<xsl:text>Vlastnost </xsl:text>
										<code>
											<xsl:value-of select="$item/@key"/>
										</code>
										<xsl:text> je definována v sémantickém slovníku pojmů jako </xsl:text>
										<xsl:sequence select="gen:generujOdkazNaPrvekVSémantickémSlovníkuPojmů($item)"/>
										<xsl:text> následovně:</xsl:text>
									</p>
									<p>
										<xsl:for-each select="gen:generujDoménuPrvkuVSémantickémSlovníkuPojmů($item)">
											<xsl:sequence select="gen:generujOdkazNaPrvekSIRIVSémantickémSlovníkuPojmů(.)"/>
											<xsl:for-each select="gen:generujOborHodnotPrvkuVSémantickémSlovníkuPojmů($item)">
												<xsl:text> ➡ </xsl:text>
												<strong>
													<xsl:sequence select="gen:generujOdkazNaPrvekVSémantickémSlovníkuPojmů($item)"/>
												</strong>
												<xsl:text> ➡ </xsl:text>
												<xsl:sequence select="gen:generujOdkazNaPrvekSIRIVSémantickémSlovníkuPojmů(.)"/>
											</xsl:for-each>
										</xsl:for-each>
									</p>
								</xsl:when>
							</xsl:choose>
						</dd>
					</dl>
					<xsl:if test="($item/fn:map[@key='items']/fn:string[@key='type'] = 'object') and not($item/fn:map[@key='items']/fn:map[@key='properties']/fn:map[@key = 'type'])">
						<xsl:sequence select="gen:generujVlastnostiProJSONSpecifikaci($item/fn:map[@key='items'])"/>
					</xsl:if>
					<xsl:if test="($item/fn:string[@key='type'] = 'object') and not($item/fn:map[@key='properties']/fn:map[@key = 'type']) and not($item/fn:map[@key='properties']/fn:map[@key = 'cs' or @key = 'en'])">
						<xsl:sequence select="gen:generujVlastnostiProJSONSpecifikaci($item)"/>
					</xsl:if>
				</xsl:otherwise>
			</xsl:choose>
		</section>
	</xsl:function>
	<xsl:function name="gen:generujJSONPopisTypuVlastnosti">
		<xsl:param name="item" as="element()"/>
		<xsl:choose>
			<xsl:when test="($item/fn:string[@key='type'] = 'array') and ($item/fn:map[@key='items']/fn:string[@key='type'] = 'object') and ($item/fn:map[@key='items']/fn:map[@key='properties']/fn:map[@key = 'type'])">
				<xsl:text> seznam prvků dle datové struktury </xsl:text>
				<xsl:variable name="nazev" select="gen:generujNázevPrvkuVSémantickémSlovníkuPojmů($item/fn:map)"/>
				<xsl:choose>
					<xsl:when test="fn:contains($nazev, 'CHYBA:')">
						<xsl:for-each select="gen:generujOborHodnotPrvkuVSémantickémSlovníkuPojmů($item)">
							<a><xsl:sequence select="gen:generujJménoPrvkuSIRIVSémantickémSlovníkuPojmů(.)"/></a>
						</xsl:for-each>
					</xsl:when>
					<xsl:otherwise>
						<a><xsl:value-of select="$nazev"/></a>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:when test="($item/fn:string[@key='type'] = 'array') and ($item/fn:map[@key='items']/fn:string[@key='$ref'])">
				<xsl:text> seznam prvků dle datové struktury </xsl:text>
				<xsl:variable name="ref-item-name" select="fn:substring($item/fn:map[@key='items']/fn:string[@key='$ref'], 15)"/>
				<xsl:variable name="ref-item" select="$item/ancestor::fn:source//fn:map[@key='definitions']/fn:map[@key=$ref-item-name]"/>
				<xsl:variable name="nazev" select="gen:generujNázevPrvkuVSémantickémSlovníkuPojmů($ref-item)"/>
				<xsl:choose>
					<xsl:when test="fn:contains($nazev, 'CHYBA:')">
						<xsl:for-each select="gen:generujOborHodnotPrvkuVSémantickémSlovníkuPojmů($ref-item)">
							<a><xsl:sequence select="gen:generujJménoPrvkuSIRIVSémantickémSlovníkuPojmů(.)"/></a>
						</xsl:for-each>
					</xsl:when>
					<xsl:otherwise>
						<a><xsl:value-of select="$nazev"/></a>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:when test="($item/fn:string[@key='type'] = 'array') and ($item/fn:map[@key='items']/fn:string[@key='type'] = 'object') and not($item/fn:map[@key='items']/fn:map[@key='properties']/fn:map[@key = 'type'])">
				<xsl:text> seznam prvků sestávajících z následujících nepovinných vlastností:</xsl:text>
				<ul>
					<xsl:for-each select="$item/fn:map/fn:map/fn:map">
						<xsl:sequence select="gen:generujVlastnostProJSONPřehled(.)"/>
					</xsl:for-each>
				</ul>
			</xsl:when>
			<xsl:when test="($item/fn:string[@key='type'] = 'array') and ($item/fn:map[@key='items']/fn:string[@key='type'] = 'string') and (fn:matches($item/fn:map[@key='items']/fn:string[@key='pattern']/text(), '^\^[^/]+/'))">
				<xsl:text>Seznam </xsl:text>
				<a href="https://data.gov.cz/otevřené-formální-normy/propojená-data/draft/#IRI">IRI</a>
				<xsl:if test="$item/fn:map[@key='items']/fn:string[@key='pattern']">
					<xsl:text> dle regulárního výrazu </xsl:text>
					<code>
						<xsl:value-of select="$item/fn:map[@key='items']/fn:string[@key='pattern']"/>
					</code>
				</xsl:if>
			</xsl:when>
			<xsl:when test="$item/fn:string[@key='type'] = 'array' and $item/fn:map/fn:string[@key='title']">
				<xsl:text> seznam prvků typu </xsl:text>
				<a>
					<xsl:value-of select="$item/fn:map/fn:string[@key='title']/text()"/>
				</a>
			</xsl:when>
			<xsl:when test="($item/fn:string[@key='type'] = 'string') and (fn:matches($item/fn:string[@key='pattern']/text(), '^\^[^/]+/'))">
				<a href="https://data.gov.cz/otevřené-formální-normy/propojená-data/draft/#IRI">IRI</a>
				<xsl:if test="$item/fn:string[@key='pattern']">
					<xsl:text> dle regulárního výrazu </xsl:text>
					<code>
						<xsl:value-of select="$item/fn:string[@key='pattern']"/>
					</code>
				</xsl:if>
			</xsl:when>
			<xsl:when test="$item/fn:string[@key='type'] = 'string'">
				<a href="https://data.gov.cz/otevřené-formální-normy/základní-datové-typy/#řetězec">Řetězec</a>
				<xsl:if test="$item/fn:string[@key='pattern']">
					<xsl:text> dle regulárního výrazu </xsl:text>
					<code>
						<xsl:value-of select="$item/fn:string[@key='pattern']"/>
					</code>
				</xsl:if>
			</xsl:when>
			<xsl:when test="$item/fn:string[@key='type'] = 'boolean'">
				<a href="https://data.gov.cz/otevřené-formální-normy/základní-datové-typy/#boolean">Boolean</a>
			</xsl:when>
			<xsl:when test="$item/fn:string[@key='type'] = 'integer'">
				<a href="https://data.gov.cz/otevřené-formální-normy/základní-datové-typy/#celé-číslo">Celé číslo</a>
			</xsl:when>
			<xsl:when test="$item/fn:string[@key='type'] = 'object' and $item/fn:map[@key='properties']/fn:map[@key='cs' or @key='en']">
				<a>Vícejazyčný řetězec</a>
			</xsl:when>
			<xsl:when test="$item/fn:string[@key='$ref']">
				<xsl:variable name="ref-item-name" select="fn:substring($item/fn:string[@key='$ref'], 15)"/>
				<xsl:variable name="ref-item" select="$item/ancestor::fn:source//fn:map[@key='definitions']/fn:map[@key=$ref-item-name]"/>
				<xsl:sequence select="gen:generujJSONPopisTypuVlastnosti($ref-item)"/>
			</xsl:when>
			<xsl:when test="($item/fn:string[@key='type'] = 'object') and ($item/fn:map[@key='properties']/fn:map[@key = 'type'] or $item/ancestor::fn:map[@key = 'definitions'])">
				<xsl:text> prvek dle datové struktury </xsl:text>
				<xsl:variable name="nazev" select="gen:generujNázevTypuPrvkuVSémantickémSlovníkuPojmů($item)"/>
				<xsl:choose>
					<xsl:when test="fn:contains($nazev, 'CHYBA:')">
						<xsl:for-each select="gen:generujOborHodnotPrvkuVSémantickémSlovníkuPojmů($item)">
							<a><xsl:sequence select="gen:generujJménoPrvkuSIRIVSémantickémSlovníkuPojmů(.)"/></a>
						</xsl:for-each>
					</xsl:when>
					<xsl:otherwise>
						<a><xsl:value-of select="$nazev"/></a>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:when test="($item/fn:string[@key='type'] = 'object') and not($item/fn:map[@key='properties']/fn:map[@key = 'type'])">
				<xsl:text>prvek sestávající z následujících nepovinných vlastností:</xsl:text>
				<ul>
					<xsl:for-each select="$item/fn:map/fn:map">
						<xsl:sequence select="gen:generujVlastnostProJSONPřehled(.)"/>
					</xsl:for-each>
				</ul>
			</xsl:when>
			<xsl:when test="$item/fn:string[@key='type'] = 'object'">
				<xsl:text>prvek dle datové struktury </xsl:text>
				<a><xsl:value-of select="gen:generujNázevTypuPrvkuVSémantickémSlovníkuPojmů($item)"/></a>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>CHYBA: Neznámý typ specifikace</xsl:text>
				<xsl:sequence select="$item"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:function>
	<xsl:function name="gen:generujRDFPřehled" as="element()">
		<xsl:param name="source" as="document-node()"/>
		<section id="lod-přehled">
			<h3>Přehled RDF struktury</h3>
			<p>V této sekci je uveden přehled struktury RDF distribuce datové sady.</p>
			<xsl:apply-templates select="$source" mode="rdfpřehled"/>
		</section>
	</xsl:function>
	<xsl:template match="fn:map[@key='@context']" mode="rdfpřehled"/>
	<xsl:template match="text()" mode="rdfpřehled"/>
	<xsl:template match="fn:map[fn:string[@key='$schema']]" mode="rdfpřehled">
		<section id="lod-přehled-třídy">
			<h4>RDF třídy</h4>
			<ul>
				<xsl:for-each select=".//fn:map[fn:string[@key='type'] = 'object'][fn:map[@key='properties']/fn:map/@key != 'cs' and fn:map[@key='properties']/fn:map/@key != 'en'][fn:map[@key='properties']/fn:map[@key='type'] or ./ancestor::fn:map[@key = 'definitions']]">
					<li>
						<xsl:variable name="iriZKontextu" select="gen:generujIRIPrvkuVKontextu(.)" />
						<xsl:variable name="iriVSémantickémSlovníkuPojmů" select="gen:generujIRIPrvkuVSémantickémSlovníkuPojmů(.)" />
						<xsl:choose>
							<xsl:when test="$iriZKontextu = $iriVSémantickémSlovníkuPojmů">
								<a href="{$iriVSémantickémSlovníkuPojmů}" class="ssplink"><xsl:sequence select="gen:generujNázevPrvkuVSémantickémSlovníkuPojmů(.)"/></a> (<a href="{$iriVSémantickémSlovníkuPojmů}" class="ssplink"><xsl:sequence select="gen:generujQNamePrvkuVSémantickémSlovníkuPojmů(.)"/></a>)
							</xsl:when>
							<xsl:otherwise>
								<a href="{$iriVSémantickémSlovníkuPojmů}" class="ssplink"><xsl:sequence select="gen:generujNázevPrvkuVSémantickémSlovníkuPojmů(.)"/></a> (<a href="{$iriZKontextu}" class="ssplink"><xsl:sequence select="gen:generujQNamePrvkuVSémantickémSlovníkuPojmů(.)"/></a>)							
							</xsl:otherwise>
						</xsl:choose>
						<dl>
							<dt>Popis</dt>
							<dd>
								<xsl:sequence select="gen:generujPopisPrvkuVSémantickémSlovníkuPojmů(.)"/>
							</dd>
							<xsl:if test="./fn:map[@key='properties']/fn:map[@key='id']/fn:array[@key='examples']">
								<xsl:variable name="context" select="./ancestor::fn:source/fn:map/fn:map[@key='@context']"/>
								<xsl:variable name="example" select="./fn:map[@key='properties']/fn:map[@key='id']/fn:array[@key='examples'][1]" />
								<xsl:variable name="iri">
									<xsl:choose>
										<xsl:when test="fn:starts-with($example, 'http')">{$example}</xsl:when>
										<xsl:otherwise>{fn:concat($context/fn:string[@key='@base']/text(), $example)}</xsl:otherwise>
									</xsl:choose>
								
								</xsl:variable>
								<dt>Příklad</dt>
								<dd>
									<a href="{$iri}">{$iri}</a>
								</dd>
							</xsl:if>
						</dl>
					</li>
				</xsl:for-each>
			</ul>
		</section>
		<section id="lod-přehled-vlastnosti">
			<h4>RDF vlastnosti</h4>
			<xsl:variable name="vlastnosti">
				<xsl:for-each select=".//fn:map[fn:string[@key='type'] = 'object']/fn:map[@key='properties']/fn:map[@key != 'cs' and @key != 'en' and @key != 'type' and @key != 'id']">{gen:generujIRIPrvkuVKontextu(.)},{gen:generujIRIPrvkuVSémantickémSlovníkuPojmů(.)} </xsl:for-each>
			</xsl:variable>
			<xsl:variable name="context" select="./ancestor::fn:source/fn:map/fn:map[@key='@context']"/>
			<ul>
				<xsl:for-each select="fn:distinct-values(fn:tokenize(fn:normalize-space($vlastnosti), '\s'))">
					<li>
						<xsl:variable name="iriZKontextu" select="fn:tokenize(., ',')[1]" />
						<xsl:variable name="iriVSémantickémSlovníkuPojmů" select="fn:tokenize(., ',')[2]" />
						<xsl:choose>
							<xsl:when test="$iriVSémantickémSlovníkuPojmů=''">
								<a href="{$iriZKontextu}" class="ssplink"><xsl:sequence select="gen:generujQNameZIRI($iriZKontextu, $context)"/></a>
							</xsl:when>
							<xsl:otherwise>
								<a href="{$iriVSémantickémSlovníkuPojmů}" class="ssplink"><xsl:sequence select="gen:generujJménoPrvkuSIRIVSémantickémSlovníkuPojmů($iriVSémantickémSlovníkuPojmů)"/></a> (<a href="{$iriZKontextu}" class="ssplink"><xsl:sequence select="gen:generujQNameZIRI($iriZKontextu, $context)"/></a>)
								<dl>
									<dt>Popis</dt>
									<dd>
										<xsl:sequence select="gen:generujPopisPrvkuSIRIVSémantickémSlovníkuPojmů($iriVSémantickémSlovníkuPojmů)"/>
									</dd>
									<dt>Doména</dt>
									<dd>
										<xsl:for-each select="gen:generujDoménuPrvkuSIRIVSémantickémSlovníkuPojmů($iriVSémantickémSlovníkuPojmů)">
											<a href="{.}" class="ssplink"><xsl:sequence select="gen:generujQNameZIRI(., $context)"/></a>
										</xsl:for-each>
									</dd>
									<dt>Obor hodnot</dt>
									<dd>
										<xsl:for-each select="gen:generujOborHodnotPrvkuSIRIVSémantickémSlovníkuPojmů($iriVSémantickémSlovníkuPojmů)">
											<a href="{.}" class="ssplink"><xsl:sequence select="gen:generujQNameZIRI(., $context)"/></a>
										</xsl:for-each>
									</dd>
								</dl>
							</xsl:otherwise>
						</xsl:choose>
					</li>
				</xsl:for-each>
			</ul>
		</section>
	</xsl:template>
	<xsl:function name="gen:generujSPARQLUkázky" as="element()">
		<xsl:param name="source" as="document-node()"/>
		<section id="ukázky-lod">
			<h2>
				<dfn>Ukázky práce s RDF distribucí</dfn>
			</h2>
			<p>V této sekci jsou uvedeny příklady SPARQL dotazů pro práci s RDF distribucí datové sady.</p>
			<xsl:apply-templates select="$source" mode="ukázkylod"/>
		</section>
	</xsl:function>
	<xsl:template match="fn:map[@key='@context']" mode="ukázkylod">

  </xsl:template>
	<xsl:template match="text()" mode="ukázkylod">

  </xsl:template>
	<xsl:template match="fn:map[fn:string[@key='$schema']]" mode="ukázkylod">
<!--		<xsl:for-each select=".//fn:map[fn:string[@key='type'] = 'object'][fn:map[@key='properties']/fn:map/@key != 'cs' and fn:map[@key='properties']/fn:map/@key != 'en'][fn:map[@key='properties']/fn:map[@key='type'] or ./ancestor::fn:map[@key = 'definitions']]">-->
<!--		<xsl:for-each select=".//fn:map[fn:string[@key='type'] = 'object'][fn:map[@key='properties']/fn:map/@key != 'cs' and fn:map[@key='properties']/fn:map/@key != 'en'][fn:map[@key='properties']/fn:map[@key='type']]">-->
		<xsl:for-each select=".//fn:map[fn:string[@key='type'] = 'object'][@key='items' or parent::*[@key='položky']][fn:map[@key='properties']/fn:map/@key != 'cs' and fn:map[@key='properties']/fn:map/@key != 'en']">
			<section>
				<xsl:variable name="isReversed">
					<xsl:variable name="parent" select=".." />
					<xsl:choose>
						<xsl:when test="not(parent::*[@key='položky']) and ancestor::fn:source/fn:map/fn:map[@key='@context']/fn:map[@key=$parent/@key]/fn:string[@key='@reverse']"><xsl:value-of select="fn:true()" /></xsl:when>
						<xsl:otherwise><xsl:value-of select="fn:false()" /></xsl:otherwise>
					</xsl:choose>
				</xsl:variable>
				<xsl:variable name="typeLink">
					<xsl:variable name="materializedTypeLink" select="gen:generujOdkazNaPrvekVSémantickémSlovníkuPojmů(.)" />
					<xsl:choose>
						<xsl:when test="fn:starts-with($materializedTypeLink, 'CHYBA')">
							<xsl:choose>
								<xsl:when test="not(parent::*[@key='položky']) and $isReversed=fn:false()">
									<xsl:sequence select="gen:generujOdkazNaPrvekSIRIVSémantickémSlovníkuPojmů(gen:generujOborHodnotPrvkuVSémantickémSlovníkuPojmů(..))"/>
								</xsl:when>
								<xsl:when test="not(parent::*[@key='položky']) and $isReversed=fn:true()">
									<xsl:sequence select="gen:generujOdkazNaPrvekSIRIVSémantickémSlovníkuPojmů(gen:generujDoménuPrvkuVSémantickémSlovníkuPojmů(..))"/>
								</xsl:when>
								<xsl:when test="parent::*[@key='položky']">
									<xsl:sequence select="gen:generujOdkazNaPrvekSIRIVSémantickémSlovníkuPojmů(gen:generujDoménuPrvkuVSémantickémSlovníkuPojmů(fn:map[@key='properties']/fn:map[1]))"/>
								</xsl:when>
							</xsl:choose>
						</xsl:when>
						<xsl:otherwise>
							<xsl:sequence select="$materializedTypeLink" />
						</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>
				<xsl:variable name="typeName">
					<xsl:variable name="materializedTypeName" select="gen:generujNázevPrvkuVSémantickémSlovníkuPojmů(.)" />
					<xsl:choose>
						<xsl:when test="fn:starts-with($materializedTypeName, 'CHYBA')">
							<xsl:choose>
								<xsl:when test="not(parent::*[@key='položky']) and $isReversed=fn:false()">
									<xsl:value-of select="gen:generujJménoPrvkuSIRIVSémantickémSlovníkuPojmů(gen:generujOborHodnotPrvkuVSémantickémSlovníkuPojmů(..))"/>
								</xsl:when>
								<xsl:when test="not(parent::*[@key='položky']) and $isReversed=fn:true()">
									<xsl:value-of select="gen:generujJménoPrvkuSIRIVSémantickémSlovníkuPojmů(gen:generujDoménuPrvkuVSémantickémSlovníkuPojmů(..))"/>
								</xsl:when>
								<xsl:when test="parent::*[@key='položky']">
									<xsl:value-of select="gen:generujJménoPrvkuSIRIVSémantickémSlovníkuPojmů(gen:generujDoménuPrvkuVSémantickémSlovníkuPojmů(fn:map[@key='properties']/fn:map[1]))"/>
								</xsl:when>
							</xsl:choose>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="$materializedTypeName" />
						</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>
				<xsl:variable name="mainVariable">
					<xsl:variable name="materializedTypeName" select="gen:generujNázevPrvkuVSémantickémSlovníkuPojmů(.)" />
					<xsl:choose>
						<xsl:when test="fn:starts-with($materializedTypeName, 'CHYBA')">
							<xsl:choose>
								<xsl:when test="not(parent::*[@key='položky']) and $isReversed=fn:false()">
									<xsl:value-of select="gen:generujPromennouProSPARQLZLabelu(gen:generujLocalNameZIRI(gen:generujOborHodnotPrvkuVSémantickémSlovníkuPojmů(..)))"/>
								</xsl:when>
								<xsl:when test="not(parent::*[@key='položky']) and $isReversed=fn:true()">
									<xsl:value-of select="gen:generujPromennouProSPARQLZLabelu(gen:generujLocalNameZIRI(gen:generujDoménuPrvkuVSémantickémSlovníkuPojmů(..)))"/>
								</xsl:when>
								<xsl:when test="parent::*[@key='položky']">
									<xsl:value-of select="gen:generujPromennouProSPARQLZLabelu(gen:generujLocalNameZIRI(gen:generujDoménuPrvkuVSémantickémSlovníkuPojmů(fn:map[@key='properties']/fn:map[1])))"/>
								</xsl:when>
							</xsl:choose>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="gen:generujPromennouProSPARQLZLabelu(gen:generujLocalNamePrvkuVSémantickémSlovníkuPojmů(.))" />
						</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>
				<xsl:variable name="typeIsMaterialized">
					<xsl:variable name="materializedTypeName" select="gen:generujNázevPrvkuVSémantickémSlovníkuPojmů(.)" />
					<xsl:choose>
						<xsl:when test="fn:starts-with($materializedTypeName, 'CHYBA')">
							<xsl:value-of select="fn:false()"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="fn:true()"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>
				<xsl:variable name="sparqlEndpointURL" select="fn:concat(fn:substring-before(./ancestor::fn:source/fn:map/fn:map[@key='@context']/fn:string[@key='@base'], 'zdroj/'), 'sparql')"/>
				<h3>Ukázky SPARQL dotazů nad typem {$typeLink}</h3>
				
				<p>Následující SPARQL dotaz vrací seznam všech instancí typu <xsl:sequence select="$typeLink" />. Pro každou instanci vrací hodnoty všech datových vlastností (textové, datumové, atd.) a objektových vlastností, kde je instance v pozici subjektu či objektu a které mají horní kardinalitu druhého prvku rovnu 1. V případě volitelných vlastností používá klauzuli OPTIONAL. Dotaz je typu SELECT, tudíž vrací tabulku.</p>
				<aside class="example">
					<xsl:attribute name="title"><xsl:text>Instance typu {$typeName}</xsl:text><xsl:if test="./parent::fn:map[fn:string[@key='type'] = 'array']/../..[@key]"><xsl:text> přiřazené k instanci typu </xsl:text><xsl:value-of select="gen:generujNázevTypuPrvkuVSémantickémSlovníkuPojmů(./parent::fn:map[fn:string[@key='type'] = 'array']/../..[@key])"/><xsl:text> prostřednictvím </xsl:text><xsl:value-of select="gen:generujNázevTypuPrvkuVSémantickémSlovníkuPojmů(./parent::fn:map[fn:string[@key='type'] = 'array'])"/></xsl:if></xsl:attribute>
					<xsl:variable name="query">
						<xsl:text>{fn:distinct-values(gen:generujPrefixyProSPARQL(.))}

SELECT *
WHERE {{</xsl:text>
						<xsl:if test="$typeIsMaterialized=true()"><xsl:text>
  ?{$mainVariable} a {gen:generujQNamePrvkuVSémantickémSlovníkuPojmů(.)} .</xsl:text></xsl:if>
						<xsl:text>{fn:distinct-values(gen:generujVlastnostiProSPARQL(., $mainVariable, 1))}</xsl:text>
						<xsl:text>
}}
LIMIT 100</xsl:text>
					</xsl:variable>
					<p>
						<!--<a target="_blank">
							<xsl:attribute name="href" select="fn:concat($sparqlEndpointURL, '?query=', fn:encode-for-uri($query), '&#38;', 'format=text%2Fhtml', '&#38;', 'timeout=0')"/>Spustit dotaz (HTML)</a>
						<xsl:text> | </xsl:text>
						<a target="_blank">
							<xsl:attribute name="href" select="fn:concat($sparqlEndpointURL, '?query=', fn:encode-for-uri($query), '&#38;', 'format=text%2Fcsv', '&#38;', 'timeout=0')"/>Spustit dotaz (CSV)</a>-->
						<a target="_blank">
							<xsl:attribute name="href" select="fn:concat('https://yasgui.triply.cc/#query=', fn:encode-for-uri($query), '&#38;endpoint=', $sparqlEndpointURL, '&#38;requestMethod=POST&#38;tabTitle=RPP&#38;headers=%7B%7D&#38;contentTypeConstruct=text%2Fturtle%2C*%2F*%3Bq%3D0.9&#38;contentTypeSelect=application%2Fsparql-results%2Bjson%2C*%2F*%3Bq%3D0.9&#38;outputFormat=table')"/>Spustit dotaz</a>
					</p>
					<pre class="sparql">
						<xsl:value-of select="$query"/>
					</pre>
				</aside>
				<xsl:variable name="prvek" select="."/>
				<xsl:for-each select="$prvek/fn:map/fn:map[@key!='type' and @key!='id' and (fn:array[@key='examples']/* or fn:map/fn:array[@key='examples']/*) and fn:string[@key='type']!='array']">
					<xsl:for-each select="(.[not(fn:string[@key='type']='object') or fn:map[@key='properties']/fn:map[@key='id' or @key='cs' or @key='en']], .[fn:string[@key='type']='object' and not(fn:map[@key='properties']/fn:map[@key='id' or @key='cs' or @key='en'])]/fn:map[@key='properties']/fn:map)">
						<xsl:variable name="vlastnost" select="gen:generujOdkazNaPrvekVSémantickémSlovníkuPojmů(.)"/>
						<xsl:choose>
							<xsl:when test="fn:starts-with($vlastnost, 'CHYBA')">
								<p>Následující SPARQL dotaz vrací instance typu <xsl:sequence select="$typeLink" />, pro které jejich vlastnost {gen:generujQNamePrvkuVSémantickémSlovníkuPojmů(.)} nabývá určité zadané hodnoty. Dotaz je typu SELECT, tudíž vrací tabulku.</p>
							</xsl:when>
							<xsl:otherwise>
								<p>Následující SPARQL dotaz vrací instance typu <xsl:sequence select="$typeLink" />, pro které jejich vlastnost <xsl:sequence select="$vlastnost" /> nabývá určité zadané hodnoty. Dotaz je typu SELECT, tudíž vrací tabulku.</p>
							</xsl:otherwise>
						</xsl:choose>
						<aside class="example">
							<xsl:attribute name="title">
								<xsl:text>Instance typu {$typeName} s danou hodnotou vlastnosti </xsl:text>
								<xsl:choose>
									<xsl:when test="fn:starts-with($vlastnost, 'CHYBA')">{gen:generujQNamePrvkuVSémantickémSlovníkuPojmů(.)}</xsl:when>
									<xsl:otherwise><xsl:sequence select="$vlastnost" /></xsl:otherwise>
								</xsl:choose>
							</xsl:attribute>
							<xsl:variable name="query">
								<xsl:text>{fn:distinct-values(gen:generujPrefixyProSPARQL($prvek))}
	
SELECT *
WHERE {{</xsl:text>
								<xsl:if test="$typeIsMaterialized=true()"><xsl:text>
  ?{$mainVariable} a {gen:generujQNamePrvkuVSémantickémSlovníkuPojmů($prvek)} .</xsl:text></xsl:if>
								<xsl:text>{fn:distinct-values(gen:generujVlastnostiProSPARQL($prvek, $mainVariable, 1))}{gen:generujFiltrovacíHodnotuProSPARQL(.)}
}}
LIMIT 100</xsl:text>
							</xsl:variable>
							<p>
								<!--<a target="_blank">
									<xsl:attribute name="href" select="fn:concat($sparqlEndpointURL, '?query=', fn:encode-for-uri($query), '&#38;', 'format=text%2Fhtml', '&#38;', 'timeout=0')"/>Spustit dotaz (HTML)</a>
								<xsl:text> | </xsl:text>
								<a target="_blank">
									<xsl:attribute name="href" select="fn:concat($sparqlEndpointURL, '?query=', fn:encode-for-uri($query), '&#38;', 'format=text%2Fcsv', '&#38;', 'timeout=0')"/>Spustit dotaz (CSV)</a>-->
								<a target="_blank">
									<xsl:attribute name="href" select="fn:concat('https://yasgui.triply.cc/#query=', fn:encode-for-uri($query), '&#38;endpoint=', $sparqlEndpointURL, '&#38;requestMethod=POST&#38;tabTitle=RPP&#38;headers=%7B%7D&#38;contentTypeConstruct=text%2Fturtle%2C*%2F*%3Bq%3D0.9&#38;contentTypeSelect=application%2Fsparql-results%2Bjson%2C*%2F*%3Bq%3D0.9&#38;outputFormat=table')"/>Spustit dotaz</a>
							</p>
							<pre class="sparql">
								<xsl:value-of select="$query"/>
							</pre>
						</aside>
					</xsl:for-each>
				</xsl:for-each>
				<xsl:if test="$prvek/parent::fn:map[fn:string[@key='type'] = 'array' and @key!='položky']">
					<xsl:variable name="iri" select="gen:generujIRIPrvkuVSémantickémSlovníkuPojmů($prvek/..)" />
					<xsl:variable name="domain" select="gen:generujDoménuPrvkuSIRIVSémantickémSlovníkuPojmů($iri)" />
					<xsl:variable name="range" select="gen:generujOborHodnotPrvkuSIRIVSémantickémSlovníkuPojmů($iri)" />
					<xsl:variable name="this" select="$prvek/.." />
					<p>Následující SPARQL dotaz vrací instance typu <xsl:sequence select="$typeLink" />, pro které jejich vlastnost <xsl:sequence select="gen:generujOdkazNaPrvekSIRIVSémantickémSlovníkuPojmů($iri)"/> nabývá určité zadané hodnoty. Dotaz je typu SELECT, tudíž vrací tabulku.</p>
							<aside class="example">
								<xsl:attribute name="title"><xsl:text>Instance typu {$typeName} s danou hodnotou vlastnosti </xsl:text><xsl:value-of select="gen:generujOdkazNaPrvekSIRIVSémantickémSlovníkuPojmů($iri)"/></xsl:attribute>
								<xsl:variable name="query">
									<xsl:text>{fn:distinct-values(gen:generujPrefixyProSPARQL($prvek))}
		
SELECT *
WHERE {{</xsl:text>
									<xsl:if test="$typeIsMaterialized=true()"><xsl:text>
  ?{$mainVariable} a {gen:generujQNamePrvkuVSémantickémSlovníkuPojmů($prvek)} .</xsl:text></xsl:if>
									<xsl:text>{fn:distinct-values(gen:generujVlastnostiProSPARQL($prvek, $mainVariable, 1))}</xsl:text>
									<xsl:text>
  FILTER (?{gen:generujPromennouProSPARQLZLabelu(gen:generujLocalNamePrvkuVSémantickémSlovníkuPojmů($prvek/..))} = &lt;{$prvek/ancestor::fn:source/fn:map/fn:map[@key='@context']/fn:string[@key='@base']/text()}{$prvek/../../fn:map[@key='id']/fn:array[@key='examples'][1]}&gt;)
}}
LIMIT 100</xsl:text>
								</xsl:variable>
								<p>
									<!--<a target="_blank">
										<xsl:attribute name="href" select="fn:concat($sparqlEndpointURL, '?query=', fn:encode-for-uri($query), '&#38;', 'format=text%2Fhtml', '&#38;', 'timeout=0')"/>Spustit dotaz (HTML)</a>
									<xsl:text> | </xsl:text>
									<a target="_blank">
										<xsl:attribute name="href" select="fn:concat($sparqlEndpointURL, '?query=', fn:encode-for-uri($query), '&#38;', 'format=text%2Fcsv', '&#38;', 'timeout=0')"/>Spustit dotaz (CSV)</a>-->
									<a target="_blank">
										<xsl:attribute name="href" select="fn:concat('https://yasgui.triply.cc/#query=', fn:encode-for-uri($query), '&#38;endpoint=', $sparqlEndpointURL, '&#38;requestMethod=POST&#38;tabTitle=RPP&#38;headers=%7B%7D&#38;contentTypeConstruct=text%2Fturtle%2C*%2F*%3Bq%3D0.9&#38;contentTypeSelect=application%2Fsparql-results%2Bjson%2C*%2F*%3Bq%3D0.9&#38;outputFormat=table')"/>Spustit dotaz</a>
								</p>
								<pre class="sparql">
									<xsl:value-of select="$query"/>
								</pre>
							</aside>
				</xsl:if>
				<xsl:for-each select="$prvek/fn:map/fn:map[@key!='type' and @key!='id' and (fn:array[@key='examples']/* or fn:map/fn:array[@key='examples']/*) and fn:string[@key='type']='array' and fn:map[@key='items'][fn:contains(fn:string[@key='pattern'], '/')]]">
					<xsl:variable name="iri" select="gen:generujIRIPrvkuVSémantickémSlovníkuPojmů(.)" />
					<xsl:variable name="domain" select="gen:generujDoménuPrvkuSIRIVSémantickémSlovníkuPojmů($iri)" />
					<xsl:variable name="range" select="gen:generujOborHodnotPrvkuSIRIVSémantickémSlovníkuPojmů($iri)" />
					<xsl:variable name="this" select="." />
					<p>Následující SPARQL dotaz vrací instance typu <xsl:sequence select="$typeLink" />, pro které jejich vlastnost <xsl:sequence select="gen:generujOdkazNaPrvekSIRIVSémantickémSlovníkuPojmů($iri)"/> nabývá určité zadané hodnoty. Dotaz je typu SELECT, tudíž vrací tabulku.</p>
							<aside class="example">
								<xsl:attribute name="title"><xsl:text>Instance typu {$typeName} s danou hodnotou vlastnosti </xsl:text><xsl:value-of select="gen:generujOdkazNaPrvekSIRIVSémantickémSlovníkuPojmů($iri)"/></xsl:attribute>
								<xsl:variable name="query">
									<xsl:text>{fn:distinct-values(gen:generujPrefixyProSPARQL($prvek))}
		
SELECT *
WHERE {{</xsl:text>
									<xsl:if test="$typeIsMaterialized=true()"><xsl:text>
  ?{$mainVariable} a {gen:generujQNamePrvkuVSémantickémSlovníkuPojmů($prvek)} .</xsl:text></xsl:if>
									<xsl:text>{fn:distinct-values(gen:generujVlastnostiProSPARQL($prvek, $mainVariable, 1))}</xsl:text>
									<xsl:choose>
										<xsl:when test="$prvek/ancestor::fn:source/fn:map/fn:map[@key='@context']/fn:map[@key=$this/@key]/fn:string[@key='@id']">
											<xsl:text>
  ?{$mainVariable} {gen:generujQNamePrvkuVSémantickémSlovníkuPojmů(.)} ?{gen:generujPromennouProSPARQLZLabelu(gen:generujLocalNamePrvkuVSémantickémSlovníkuPojmů(.))} .</xsl:text>
										</xsl:when>
										<xsl:when test="$prvek/ancestor::fn:source/fn:map/fn:map[@key='@context']/fn:map[@key=$this/@key]/fn:string[@key='@reverse']">
											<xsl:text>
  ?{gen:generujPromennouProSPARQLZLabelu(gen:generujLocalNamePrvkuVSémantickémSlovníkuPojmů(.))} {gen:generujQNamePrvkuVSémantickémSlovníkuPojmů(.)} ?{$mainVariable} .</xsl:text>
										</xsl:when>
									</xsl:choose>
									<xsl:text>{gen:generujFiltrovacíHodnotuProSPARQL(.)}
}}
LIMIT 100</xsl:text>
								</xsl:variable>
								<p>
									<!--<a target="_blank">
										<xsl:attribute name="href" select="fn:concat($sparqlEndpointURL, '?query=', fn:encode-for-uri($query), '&#38;', 'format=text%2Fhtml', '&#38;', 'timeout=0')"/>Spustit dotaz (HTML)</a>
									<xsl:text> | </xsl:text>
									<a target="_blank">
										<xsl:attribute name="href" select="fn:concat($sparqlEndpointURL, '?query=', fn:encode-for-uri($query), '&#38;', 'format=text%2Fcsv', '&#38;', 'timeout=0')"/>Spustit dotaz (CSV)</a>-->
									<a target="_blank">
										<xsl:attribute name="href" select="fn:concat('https://yasgui.triply.cc/#query=', fn:encode-for-uri($query), '&#38;endpoint=', $sparqlEndpointURL, '&#38;requestMethod=POST&#38;tabTitle=RPP&#38;headers=%7B%7D&#38;contentTypeConstruct=text%2Fturtle%2C*%2F*%3Bq%3D0.9&#38;contentTypeSelect=application%2Fsparql-results%2Bjson%2C*%2F*%3Bq%3D0.9&#38;outputFormat=table')"/>Spustit dotaz</a>
								</p>
								<pre class="sparql">
									<xsl:value-of select="$query"/>
								</pre>
							</aside>
				</xsl:for-each>
			</section>
		</xsl:for-each>
	</xsl:template>
	<xsl:function name="gen:generujVlastnostiProSPARQL" as="xs:string*">
		<xsl:param name="item" as="element()"/>
		<xsl:param name="variableName" as="xs:string"/>
		<xsl:param name="nestingLevel" as="xs:integer"/>
		<xsl:for-each select="$item/fn:map/fn:map[@key!='type' and @key!='id']">
			<xsl:variable name="fragment" select="gen:generujVlastnostProSPARQL(., $variableName, 'normal', $nestingLevel)"/>
			<xsl:if test="fn:matches($fragment, '[^\s]')">
				<xsl:value-of select="fn:concat('&#10;', $fragment)"/>
			</xsl:if>
		</xsl:for-each>
		<xsl:if test="$item/parent::fn:map[fn:string[@key='type'] = 'array']">
			<xsl:variable name="fragment" select="gen:generujVlastnostProSPARQL($item/parent::fn:map[fn:string[@key='type'] = 'array'], $variableName, 'reversed', $nestingLevel)"/>
			<xsl:if test="fn:matches($fragment, '[^\s]')">
				<xsl:value-of select="fn:concat('&#10;', $fragment)"/>
			</xsl:if>
		</xsl:if>
	</xsl:function>
	<xsl:function name="gen:generujPrefixyProSPARQL" as="xs:string*">
		<xsl:param name="item" as="element()"/>
		<xsl:variable name="fragment" select="gen:generujPrefixProSPARQL($item)"/>
		<xsl:if test="fn:matches($fragment, '[^\s]')">
			<xsl:value-of select="fn:concat('&#10;', $fragment)"/>
		</xsl:if>
		<xsl:for-each select="$item/fn:map/fn:map[@key!='type' and @key!='id']">
			<xsl:variable name="fragment" select="gen:generujPrefixProSPARQL(.)"/>
			<xsl:if test="fn:matches($fragment, '[^\s]')">
				<xsl:value-of select="fn:concat('&#10;', $fragment)"/>
			</xsl:if>
		</xsl:for-each>
		<xsl:if test="$item/parent::fn:map[fn:string[@key='type'] = 'array']/../..[@key]">
			<xsl:variable name="fragment" select="gen:generujPrefixProSPARQL($item/parent::fn:map[fn:string[@key='type'] = 'array'])"/>
			<xsl:if test="fn:matches($fragment, '[^\s]')">
				<xsl:value-of select="fn:concat('&#10;', $fragment)"/>
			</xsl:if>
		</xsl:if>
	</xsl:function>
	<xsl:function name="gen:generujFiltrovacíHodnotuProSPARQL" as="xs:string*">
		<xsl:param name="item" as="element()"/>
		<xsl:variable name="jsonAlias" select="($item/@key, $item/fn:map[@key='properties']/fn:map[@key='type']/fn:string[@key='default']/text())[. != 'items'][1]"/>
		<xsl:variable name="context" select="$item/ancestor::fn:source/fn:map/fn:map[@key='@context']"/>
		<xsl:variable name="contextItem" select="$context/fn:map[@key = $jsonAlias]"/>
		<xsl:choose>
			<xsl:when test="$contextItem/fn:string[@key='@type'] = '@id'">
				<xsl:variable name="iri" select="$item/fn:array[@key='examples'][1]" />
				<xsl:choose>
					<xsl:when test="fn:starts-with($iri, 'http')">
  FILTER (?{gen:generujPromennouProSPARQLZLabelu(gen:generujLocalNamePrvkuVSémantickémSlovníkuPojmů($item))} = {fn:concat('&lt;', $iri, '&gt;')})</xsl:when>
					<xsl:otherwise>
  FILTER (?{gen:generujPromennouProSPARQLZLabelu(gen:generujLocalNamePrvkuVSémantickémSlovníkuPojmů($item))} = {fn:concat('&lt;', $context/fn:string[@key='@base']/text(), $item/fn:array[@key='examples'][1], '&gt;')})</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:when test="$contextItem/fn:string[@key='@type'] = 'xsd:date'">
  FILTER (?{gen:generujPromennouProSPARQLZLabelu(gen:generujLocalNamePrvkuVSémantickémSlovníkuPojmů($item))} = {fn:concat('&quot;', $item/fn:array[@key='examples'][1], '&quot;^^xsd:date')})</xsl:when>
			<xsl:when test="$contextItem/fn:string[@key='@type'] = 'xsd:boolean'">
  FILTER (?{gen:generujPromennouProSPARQLZLabelu(gen:generujLocalNamePrvkuVSémantickémSlovníkuPojmů($item))} = {$item/fn:array[@key='examples'][1]})</xsl:when>
			<xsl:when test="$contextItem/fn:string[@key='@container'] = '@language'">
  FILTER (STR(?{gen:generujPromennouProSPARQLZLabelu(gen:generujLocalNamePrvkuVSémantickémSlovníkuPojmů($item))}) = {fn:concat('&quot;', $item/fn:array[@key='examples'][1]/fn:map/fn:string[@key='cs'], '&quot;')})</xsl:when>
			<xsl:otherwise>
  FILTER (STR(?{gen:generujPromennouProSPARQLZLabelu(gen:generujLocalNamePrvkuVSémantickémSlovníkuPojmů($item))}) = {fn:concat('&quot;', $item/fn:array[@key='examples'][1], '&quot;')})</xsl:otherwise>
		</xsl:choose>
	</xsl:function>
	<xsl:function name="gen:generujVlastnostProSPARQL" as="xs:string*">
		<xsl:param name="item" as="element()"/>
		<xsl:param name="variableName" as="xs:string"/>
		<xsl:param name="mode" as="xs:string"/>
		<xsl:param name="nestingLevel" as="xs:integer" />
		<xsl:variable name="jsonAlias" select="($item/@key, $item/fn:map[@key='properties']/fn:map[@key='type']/fn:string[@key='default']/text())[. != 'items'][1]"/>
		<xsl:variable name="context" select="$item/ancestor::fn:source/fn:map/fn:map[@key='@context']"/>
		<xsl:variable name="qName" select="($context/fn:string[@key = $jsonAlias]/text(), $context/fn:map[@key = $jsonAlias]/fn:string[@key='@id' or @key='@reverse']/text())[1]"/>
		<xsl:variable name="prefix" select="fn:substring-before($qName, ':')"/>
		<xsl:variable name="localName" select="fn:substring-after($qName, ':')"/>
		<xsl:variable name="contextItem" select="$context/fn:map[@key = $jsonAlias]"/>
		<xsl:variable name="whitespace"><xsl:for-each select="(1 to $nestingLevel)"><xsl:text>  </xsl:text></xsl:for-each></xsl:variable>
		<xsl:variable name="fragment"><xsl:choose>
				<xsl:when test="$mode = 'normal'">
					<xsl:choose>
						<xsl:when test="$item/fn:string[@key='type']='object' and not($item/fn:map[@key='properties']/fn:map[@key='id' or @key='cs' or @key='en'])">OPTIONAL {{
{$whitespace}  ?{$variableName} {$qName} ?{gen:generujPromennouProSPARQLZLabelu($item/@key)} .{fn:distinct-values(gen:generujVlastnostiProSPARQL($item, gen:generujPromennouProSPARQLZLabelu($item/@key), $nestingLevel+1))}
{$whitespace}}}</xsl:when>
						<xsl:when test="$contextItem[not(fn:string[@key='@reverse'])][fn:string[@key='@type'] = 'xsd:string']">OPTIONAL {{ ?{$variableName} {$qName} ?{gen:generujPromennouProSPARQLZLabelu($localName)} . }}</xsl:when>
						<xsl:when test="$contextItem[not(fn:string[@key='@reverse'])][fn:string[@key='@container'] = '@language']">OPTIONAL {{ ?{$variableName} {$qName} ?{gen:generujPromennouProSPARQLZLabelu($localName)} . FILTER (LANG(?{gen:generujPromennouProSPARQLZLabelu($localName)}) = "cs") }}</xsl:when>
						<xsl:when test="$contextItem[not(fn:string[@key='@reverse'])][fn:string[@key='@type'] = 'xsd:date']">OPTIONAL {{ ?{$variableName} {$qName} ?{gen:generujPromennouProSPARQLZLabelu($localName)} . }}</xsl:when>
						<xsl:when test="$contextItem[not(fn:string[@key='@reverse'])][fn:string[@key='@type'] = 'xsd:integer']">OPTIONAL {{ ?{$variableName} {$qName} ?{gen:generujPromennouProSPARQLZLabelu($localName)} . }}</xsl:when>
						<xsl:when test="$contextItem[not(fn:string[@key='@reverse'])][fn:string[@key='@type'] = 'xsd:boolean']">OPTIONAL {{ ?{$variableName} {$qName} ?{gen:generujPromennouProSPARQLZLabelu($localName)} . }}</xsl:when>
						<xsl:when test="$contextItem[not(fn:string[@key='@reverse'])][not(fn:string[@key='@container'])][fn:string[@key='@type'] = '@id']">OPTIONAL {{ ?{$variableName} {$qName} ?{gen:generujPromennouProSPARQLZLabelu($localName)} . }}</xsl:when>
						<xsl:when test="$contextItem[fn:string[@key='@reverse']][not(fn:string[@key='@container'])][fn:string[@key='@type'] = '@id']">OPTIONAL {{ ?{gen:generujPromennouProSPARQLZLabelu($localName)} {$qName} ?{$variableName} . }}</xsl:when>
					</xsl:choose>
				</xsl:when>
				<xsl:when test="$mode = 'reversed'">
					<xsl:choose>
						<xsl:when test="$contextItem[fn:string[@key='@reverse']][fn:string[@key='@container'] = '@set' and $qName!='@graph']">?{$variableName} {$qName} ?{gen:generujPromennouProSPARQLZLabelu($localName)} .</xsl:when>
						<xsl:when test="$contextItem[fn:string[@key='@id']][fn:string[@key='@container'] = '@set' and $qName!='@graph']">?{gen:generujPromennouProSPARQLZLabelu($localName)} {$qName} ?{$variableName} .</xsl:when>
					</xsl:choose>
				</xsl:when>
			</xsl:choose>
		</xsl:variable>
		<xsl:if test="fn:string-length($fragment)>0">
			<xsl:value-of select="fn:concat($whitespace, $fragment)" />
		</xsl:if>
	</xsl:function>
	<xsl:function name="gen:generujPromennouProSPARQLZLabelu" as="xs:string*">
		<xsl:param name="label" as="xs:string"/>
		<xsl:variable name="tokens">
			<xsl:for-each select="fn:tokenize($label, '-')">
				<xsl:variable name="token" select="fn:translate(., 'ěščřžýáíéúůóťďň', 'escrzyaieuuotdn')"/>
				<xsl:value-of select="fn:concat(fn:upper-case(fn:substring($token, 1, 1)), fn:substring($token, 2))"/>
			</xsl:for-each>
		</xsl:variable>
		<xsl:value-of select="fn:string-join($tokens)"/>
	</xsl:function>
	<xsl:function name="gen:generujPrefixProSPARQL" as="xs:string*">
		<xsl:param name="item" as="element()"/>
		<xsl:variable name="prefix" select="gen:generujPrefixPrvkuVSémantickémSlovníkuPojmů($item)"/>
		<xsl:if test="fn:string-length($prefix)>0">
			<xsl:text>PREFIX {gen:generujPrefixPrvkuVSémantickémSlovníkuPojmů($item)}: &lt;{gen:generujPrefixIRIPrvkuVSémantickémSlovníkuPojmů($item)}&gt;</xsl:text>
		</xsl:if>
	</xsl:function>
	<xsl:function name="gen:generujLegislativuPrvkuVSémantickémSlovníkuPojmů" as="xs:string*">
		<xsl:param name="item" as="element()"/>
		<xsl:for-each select="(gen:generujHodnotuVlastnostiPrvkuVSémantickémSlovníkuPojmů($item, 'dc:relation', false(), false(), false()),gen:generujHodnotuVlastnostiPrvkuVSémantickémSlovníkuPojmů($item, 'dc:source', false(), false(), false()))">
			<xsl:value-of select="."/>
		</xsl:for-each>
	</xsl:function>
	<xsl:function name="gen:generujNázevPrvkuVSémantickémSlovníkuPojmů" as="xs:string">
		<xsl:param name="item" as="element()"/>
		<xsl:value-of select="gen:generujHodnotuVlastnostiPrvkuVSémantickémSlovníkuPojmů($item, 'skos:prefLabel', false(), true(), false())"/>
	</xsl:function>
	<xsl:function name="gen:generujNázevTypuPrvkuVSémantickémSlovníkuPojmů" as="xs:string">
		<xsl:param name="item" as="element()"/>
		<xsl:value-of select="gen:generujHodnotuVlastnostiPrvkuVSémantickémSlovníkuPojmů($item, 'skos:prefLabel', false(), true(), true())"/>
	</xsl:function>
	<xsl:function name="gen:generujTypPrvkuVSémantickémSlovníkuPojmů" as="xs:string*">
		<xsl:param name="item" as="element()"/>
		<xsl:value-of select="
fn:substring-after(gen:generujHodnotuVlastnostiPrvkuVSémantickémSlovníkuPojmů($item, 'rdf:type', false(), false(), false())[fn:starts-with(., 'https://slovník.gov.cz/základní/pojem/')][1], 'https://slovník.gov.cz/základní/pojem/')"/>
	</xsl:function>
	<xsl:function name="gen:generujDoménuPrvkuVSémantickémSlovníkuPojmů" as="xs:string*">
		<xsl:param name="item" as="element()"/>
		<xsl:for-each select="gen:generujHodnotuVlastnostiPrvkuVSémantickémSlovníkuPojmů($item, 'rdfs:domain', false(), false(), false())">
			<xsl:value-of select="."/>
		</xsl:for-each>
	</xsl:function>
	<xsl:function name="gen:generujOborHodnotPrvkuVSémantickémSlovníkuPojmů" as="xs:string*">
		<xsl:param name="item" as="element()"/>
		<xsl:for-each select="gen:generujHodnotuVlastnostiPrvkuVSémantickémSlovníkuPojmů($item, 'rdfs:range', false(), false(), false())">
			<xsl:value-of select="."/>
		</xsl:for-each>
	</xsl:function>
	<xsl:function name="gen:generujOdkazNaPrvekVSémantickémSlovníkuPojmů" as="node()">
		<xsl:param name="item" as="element()"/>
		<xsl:sequence select="gen:generujHodnotuVlastnostiPrvkuVSémantickémSlovníkuPojmů($item, 'skos:prefLabel', true(), true(), false())[1]"/>
	</xsl:function>
	<xsl:function name="gen:generujPopisPrvkuVSémantickémSlovníkuPojmů" as="xs:string*">
		<xsl:param name="item" as="element()"/>
		<xsl:variable name="popis" select="gen:generujHodnotuVlastnostiPrvkuVSémantickémSlovníkuPojmů($item, 'skos:definition', false(), true(), false())[1]"/>
		<xsl:choose>
			<xsl:when test="fn:contains($popis[1], 'CHYBA: ')">
				<xsl:value-of select="gen:generujHodnotuVlastnostiPrvkuVSémantickémSlovníkuPojmů($item, 'skos:scopeNote', false(), true(), false())[1]"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$popis"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:function>
	<xsl:function name="gen:generujHodnotuVlastnostiPrvkuVSémantickémSlovníkuPojmů" as="node()*">
		<xsl:param name="item" as="element()"/>
		<xsl:param name="property" as="xs:string"/>
		<xsl:param name="asLink" as="xs:boolean"/>
		<xsl:param name="isDatatype" as="xs:boolean"/>
		<xsl:param name="asType" as="xs:boolean"/>
		<xsl:variable name="jsonAlias" select="($item/fn:map[$asType and @key='properties']/fn:map[@key='type']/fn:string[@key='default']/text(), $item/@key, $item/fn:map[@key='properties']/fn:map[@key='type']/fn:string[@key='default']/text())[. != 'items'][1]"/>
		<xsl:variable name="context" select="$item/ancestor::fn:source/fn:map/fn:map[@key='@context']"/>
		<xsl:variable name="qName" select="($context/fn:string[@key = $jsonAlias]/text(), $context/fn:map[@key = $jsonAlias]/fn:string[@key='@id' or @key='@reverse']/text())[1]"/>
		<xsl:variable name="prefix" select="fn:substring-before($qName, ':')"/>
		<xsl:variable name="localName" select="fn:substring-after($qName, ':')"/>
		<xsl:variable name="iriPrefix" select="$context/fn:string[@key = $prefix]/text()"/>
		<xsl:variable name="iri" select="fn:concat($iriPrefix, $localName)"/>
		<xsl:variable name="semVocTypeXMLDocumentIRI" select="fn:concat('https://xn--slovnk-7va.gov.cz/sparql?', '&#38;', 'query=define%20sql%3Adescribe-mode%20%22CBD%22%20%20DESCRIBE%20%3C',fn:encode-for-uri($iri), '%3E', '&#38;', 'output=application%2Frdf%2Bxml')"/>
		<xsl:try>
			<xsl:variable name="semVocTypeXMLDocument" select="fn:doc($semVocTypeXMLDocumentIRI)"/>
			<xsl:choose>
				<xsl:when test="$isDatatype and $semVocTypeXMLDocument//.[fn:name() = $property]">
					<xsl:choose>
						<xsl:when test="$asLink">
							<xsl:for-each select="$semVocTypeXMLDocument//.[fn:name() = $property]">
								<a class="ssplink">
									<xsl:attribute name="href" select="$iri"/>
									<xsl:value-of select="text()"/>
								</a>
							</xsl:for-each>
						</xsl:when>
						<xsl:otherwise>
							<xsl:for-each select="$semVocTypeXMLDocument//.[fn:name() = $property]">
								<xsl:value-of select="text()"/>
							</xsl:for-each>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:when>
				<xsl:when test="not($isDatatype) and $semVocTypeXMLDocument//.[fn:name() = $property]/@rdf:resource">
					<xsl:choose>
						<xsl:when test="$asLink">
							<xsl:for-each select="$semVocTypeXMLDocument//.[fn:name() = $property]">
								<a class="ssplink">
									<xsl:attribute name="href" select="$iri"/>
									<xsl:value-of select="./@rdf:resource"/>
								</a>
							</xsl:for-each>
						</xsl:when>
						<xsl:otherwise>
							<xsl:for-each select="$semVocTypeXMLDocument//.[fn:name() = $property]">
								<xsl:value-of select="./@rdf:resource"/>
							</xsl:for-each>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:when>
				<xsl:otherwise>
					<xsl:variable name="parentObject" select="$item/../..[fn:string[@key='type']='object']"/>
					<xsl:variable name="parentjsonAlias" select="$parentObject/fn:map[@key='properties']/fn:map[@key='type']/fn:string[@key='default']/text()"/>
					<xsl:variable name="parentqName" select="($context/fn:string[@key = $parentjsonAlias]/text(), $context/fn:map[@key = $parentjsonAlias]/fn:string[@key='@id' or @key='@reverse']/text())[1]"/>
					<xsl:variable name="parentprefix" select="fn:substring-before($parentqName, ':')"/>
					<xsl:variable name="parentlocalName" select="fn:substring-after($parentqName, ':')"/>
					<xsl:variable name="parentiriPrefix" select="$context/fn:string[@key = $parentprefix]/text()"/>
					<xsl:variable name="parentiri" select="fn:concat($parentiriPrefix, $parentlocalName)"/>
					<xsl:variable name="semVocTypeXMLDocumentIRI" select="fn:concat('https://xn--slovnk-7va.gov.cz/sparql?', '&#38;', 'query=PREFIX%20rdfs%3A%20%3Chttp%3A%2F%2Fwww.w3.org%2F2000%2F01%2Frdf-schema%23%3E%0A%0ACONSTRUCT%20%7B%0A%20%20%3Ftypvlastnosti%20rdfs%3AsubClassOf%20%3C',fn:encode-for-uri($iri), '%3E%20.%0A%7D%20WHERE%20%7B%0A%20%20%3Ftypvlastnosti%20rdfs%3Adomain%20%3C',fn:encode-for-uri($parentiri), '%3E%20%3B%0A%20%20%20%20rdfs%3AsubClassOf%20%3C',fn:encode-for-uri($iri), '%3E%20.%0A%7D', '&#38;', 'output=application%2Frdf%2Bxml')"/>
					<xsl:try>
						<xsl:variable name="semVocTypeXMLDocument" select="fn:doc($semVocTypeXMLDocumentIRI)"/>
						<xsl:variable name="hodnota" select="gen:generujHodnotuVlastnostiPrvkuSIRIVSémantickémSlovníkuPojmů($semVocTypeXMLDocument//rdf:Description/@rdf:about, $property, $asLink, $isDatatype)"/>
						<xsl:choose>
							<xsl:when test="fn:contains($hodnota[1], 'CHYBA: ')">
								<xsl:choose>
									<xsl:when test="$asLink">
										<a>CHYBA: V sémantickém slovníku pojmů odpovídá prvek typu {$parentiri}, neboť specializuje typ {$semVocTypeXMLDocument//rdf:Description/@rdf:about}. Hodnota vlastnosti {$property} pro něj ale ve slovníku uvedena.</a>
									</xsl:when>
									<xsl:otherwise>CHYBA: V sémantickém slovníku pojmů odpovídá prvek typu {$parentiri}, neboť specializuje typ {$semVocTypeXMLDocument//rdf:Description/@rdf:about}. Hodnota vlastnosti {$property} pro něj ale ve slovníku uvedena.</xsl:otherwise>
								</xsl:choose>
							</xsl:when>
							<xsl:otherwise>
								<xsl:sequence select="$hodnota"/>
							</xsl:otherwise>
						</xsl:choose>
						<xsl:catch>
							<xsl:choose>
								<xsl:when test="$asLink">
									<a><xsl:text xmlns:err="http://www.w3.org/2005/xqt-errors">CHYBA: {$err:description} V sémantickém slovníku pojmů odpovídá prvek typu {$parentiri}, jehož definici se nepodařilo načíst.</xsl:text></a>
								</xsl:when>
								<xsl:otherwise xmlns:err="http://www.w3.org/2005/xqt-errors">CHYBA: {$err:description} V sémantickém slovníku pojmů odpovídá prvek typu {$parentiri}, jehož definici se nepodařilo načíst.</xsl:otherwise>
							</xsl:choose>
						</xsl:catch>
					</xsl:try>
				</xsl:otherwise>
			</xsl:choose>
			<xsl:catch>
				<xsl:choose>
					<xsl:when test="$asLink">
						<a><xsl:text xmlns:err="http://www.w3.org/2005/xqt-errors">CHYBA: {$err:description} V sémantickém slovníku pojmů odpovídá prvek typu {$iri}, jehož definici se nepodařilo načíst.</xsl:text></a>
					</xsl:when>
					<xsl:otherwise xmlns:err="http://www.w3.org/2005/xqt-errors">CHYBA: {$err:description} V sémantickém slovníku pojmů odpovídá prvek typu {$iri}, jehož definici se nepodařilo načíst.</xsl:otherwise>
				</xsl:choose>
			</xsl:catch>
		</xsl:try>
	</xsl:function>
	<xsl:function name="gen:generujQNamePrvkuVSémantickémSlovníkuPojmů" as="xs:string">
		<xsl:param name="item" as="element()"/>
		<xsl:variable name="jsonAlias" select="($item/@key, $item/fn:map[@key='properties']/fn:map[@key='type']/fn:string[@key='default']/text())[. != 'items'][1]"/>
		<xsl:variable name="context" select="$item/ancestor::fn:source/fn:map/fn:map[@key='@context']"/>
		<xsl:variable name="qName" select="($context/fn:string[@key = $jsonAlias]/text(), $context/fn:map[@key = $jsonAlias]/fn:string[@key='@id' or @key='@reverse']/text())[1]"/>
		<xsl:variable name="prefix" select="fn:substring-before($qName, ':')"/>
		<xsl:variable name="localName" select="fn:substring-after($qName, ':')"/>
		<xsl:variable name="iriPrefix" select="$context/fn:string[@key = $prefix]/text()"/>
		<xsl:variable name="iri" select="fn:concat($iriPrefix, $localName)"/>
		<xsl:value-of select="$qName"/>
	</xsl:function>
	<xsl:function name="gen:generujLocalNamePrvkuVSémantickémSlovníkuPojmů" as="xs:string">
		<xsl:param name="item" as="element()"/>
		<xsl:variable name="jsonAlias" select="($item/@key, $item/fn:map[@key='properties']/fn:map[@key='type']/fn:string[@key='default']/text())[. != 'items'][1]"/>
		<xsl:variable name="context" select="$item/ancestor::fn:source/fn:map/fn:map[@key='@context']"/>
		<xsl:variable name="qName" select="($context/fn:string[@key = $jsonAlias]/text(), $context/fn:map[@key = $jsonAlias]/fn:string[@key='@id' or @key='@reverse']/text())[1]"/>
		<xsl:variable name="prefix" select="fn:substring-before($qName, ':')"/>
		<xsl:variable name="localName" select="fn:substring-after($qName, ':')"/>
		<xsl:variable name="iriPrefix" select="$context/fn:string[@key = $prefix]/text()"/>
		<xsl:variable name="iri" select="fn:concat($iriPrefix, $localName)"/>
		<xsl:value-of select="$localName"/>
	</xsl:function>
	<xsl:function name="gen:generujPrefixPrvkuVSémantickémSlovníkuPojmů" as="xs:string">
		<xsl:param name="item" as="element()"/>
		<xsl:variable name="jsonAlias" select="($item/@key, $item/fn:map[@key='properties']/fn:map[@key='type']/fn:string[@key='default']/text())[. != 'items'][1]"/>
		<xsl:variable name="context" select="$item/ancestor::fn:source/fn:map/fn:map[@key='@context']"/>
		<xsl:variable name="qName" select="($context/fn:string[@key = $jsonAlias]/text(), $context/fn:map[@key = $jsonAlias]/fn:string[@key='@id' or @key='@reverse']/text())[1]"/>
		<xsl:variable name="prefix" select="fn:substring-before($qName, ':')"/>
		<xsl:variable name="localName" select="fn:substring-after($qName, ':')"/>
		<xsl:variable name="iriPrefix" select="$context/fn:string[@key = $prefix]/text()"/>
		<xsl:variable name="iri" select="fn:concat($iriPrefix, $localName)"/>
		<xsl:value-of select="$prefix"/>
	</xsl:function>
	<xsl:function name="gen:generujPrefixIRIPrvkuVSémantickémSlovníkuPojmů" as="xs:string">
		<xsl:param name="item" as="element()"/>
		<xsl:variable name="jsonAlias" select="($item/@key, $item/fn:map[@key='properties']/fn:map[@key='type']/fn:string[@key='default']/text())[. != 'items'][1]"/>
		<xsl:variable name="context" select="$item/ancestor::fn:source/fn:map/fn:map[@key='@context']"/>
		<xsl:variable name="qName" select="($context/fn:string[@key = $jsonAlias]/text(), $context/fn:map[@key = $jsonAlias]/fn:string[@key='@id' or @key='@reverse']/text())[1]"/>
		<xsl:variable name="prefix" select="fn:substring-before($qName, ':')"/>
		<xsl:variable name="localName" select="fn:substring-after($qName, ':')"/>
		<xsl:variable name="iriPrefix" select="$context/fn:string[@key = $prefix]/text()"/>
		<xsl:variable name="iri" select="fn:concat($iriPrefix, $localName)"/>
		<xsl:value-of select="$iriPrefix"/>
	</xsl:function>
	<xsl:function name="gen:generujIRIPrvkuVSémantickémSlovníkuPojmů" as="xs:string">
		<xsl:param name="item" as="element()"/>
		<xsl:variable name="jsonAlias" select="($item/@key, $item/fn:map[@key='properties']/fn:map[@key='type']/fn:string[@key='default']/text())[. != 'items'][1]"/>
		<xsl:variable name="context" select="$item/ancestor::fn:source/fn:map/fn:map[@key='@context']"/>
		<xsl:variable name="qName" select="($context/fn:string[@key = $jsonAlias]/text(), $context/fn:map[@key = $jsonAlias]/fn:string[@key='@id' or @key='@reverse']/text())[1]"/>
		<xsl:variable name="prefix" select="fn:substring-before($qName, ':')"/>
		<xsl:variable name="localName" select="fn:substring-after($qName, ':')"/>
		<xsl:variable name="iriPrefix" select="$context/fn:string[@key = $prefix]/text()"/>
		<xsl:variable name="iri" select="fn:concat($iriPrefix, $localName)"/>
		<xsl:variable name="semVocTypeXMLDocumentIRI" select="fn:concat('https://xn--slovnk-7va.gov.cz/sparql?', '&#38;', 'query=define%20sql%3Adescribe-mode%20%22CBD%22%20%20DESCRIBE%20%3C',fn:encode-for-uri($iri), '%3E', '&#38;', 'output=application%2Frdf%2Bxml')"/>
		<xsl:variable name="semVocTypeXMLDocument" select="fn:doc($semVocTypeXMLDocumentIRI)"/>
		<xsl:choose>
			<xsl:when test="$semVocTypeXMLDocument//skos:inScheme">
				<xsl:value-of select="$iri"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:variable name="parentObject" select="$item/../..[fn:string[@key='type']='object']"/>
				<xsl:variable name="parentjsonAlias" select="$parentObject/fn:map[@key='properties']/fn:map[@key='type']/fn:string[@key='default']/text()"/>
				<xsl:variable name="parentqName" select="($context/fn:string[@key = $parentjsonAlias]/text(), $context/fn:map[@key = $parentjsonAlias]/fn:string[@key='@id' or @key='@reverse']/text())[1]"/>
				<xsl:variable name="parentprefix" select="fn:substring-before($parentqName, ':')"/>
				<xsl:variable name="parentlocalName" select="fn:substring-after($parentqName, ':')"/>
				<xsl:variable name="parentiriPrefix" select="$context/fn:string[@key = $parentprefix]/text()"/>
				<xsl:variable name="parentiri" select="fn:concat($parentiriPrefix, $parentlocalName)"/>
				<xsl:variable name="semVocTypeXMLDocumentIRI" select="fn:concat('https://xn--slovnk-7va.gov.cz/sparql?', '&#38;', 'query=PREFIX%20rdfs%3A%20%3Chttp%3A%2F%2Fwww.w3.org%2F2000%2F01%2Frdf-schema%23%3E%0A%0ACONSTRUCT%20%7B%0A%20%20%3Ftypvlastnosti%20rdfs%3AsubClassOf%20%3C',fn:encode-for-uri($iri), '%3E%20.%0A%7D%20WHERE%20%7B%0A%20%20%3Ftypvlastnosti%20rdfs%3Adomain%20%3C',fn:encode-for-uri($parentiri), '%3E%20%3B%0A%20%20%20%20rdfs%3AsubClassOf%20%3C',fn:encode-for-uri($iri), '%3E%20.%0A%7D', '&#38;', 'output=application%2Frdf%2Bxml')"/>
				<xsl:variable name="semVocTypeXMLDocument" select="fn:doc($semVocTypeXMLDocumentIRI)"/>
				<xsl:value-of select="$semVocTypeXMLDocument//rdf:Description/@rdf:about"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:function>
	<xsl:function name="gen:generujIRIPrvkuVKontextu" as="xs:string">
		<xsl:param name="item" as="element()"/>
		<xsl:variable name="jsonAlias" select="($item/@key, $item/fn:map[@key='properties']/fn:map[@key='type']/fn:string[@key='default']/text())[. != 'items'][1]"/>
		<xsl:variable name="context" select="$item/ancestor::fn:source/fn:map/fn:map[@key='@context']"/>
		<xsl:variable name="qName" select="($context/fn:string[@key = $jsonAlias]/text(), $context/fn:map[@key = $jsonAlias]/fn:string[@key='@id' or @key='@reverse']/text())[1]"/>
		<xsl:variable name="prefix" select="fn:substring-before($qName, ':')"/>
		<xsl:variable name="localName" select="fn:substring-after($qName, ':')"/>
		<xsl:variable name="iriPrefix" select="$context/fn:string[@key = $prefix]/text()"/>
		<xsl:variable name="iri" select="fn:concat($iriPrefix, $localName)"/>
		<xsl:variable name="semVocTypeXMLDocumentIRI" select="fn:concat('https://xn--slovnk-7va.gov.cz/sparql?', '&#38;', 'query=define%20sql%3Adescribe-mode%20%22CBD%22%20%20DESCRIBE%20%3C',fn:encode-for-uri($iri), '%3E', '&#38;', 'output=application%2Frdf%2Bxml')"/>
		<xsl:variable name="semVocTypeXMLDocument" select="fn:doc($semVocTypeXMLDocumentIRI)"/>
		<xsl:value-of select="$iri"/>
	</xsl:function>
	<xsl:function name="gen:generujOdkazNaPrvekSIRIVSémantickémSlovníkuPojmů" as="node()*">
		<xsl:param name="iri" as="xs:string"/>
		<xsl:try>
			<xsl:variable name="semVocTypeXMLDocumentIRI" select="fn:concat('https://xn--slovnk-7va.gov.cz/sparql?', '&#38;', 'query=define%20sql%3Adescribe-mode%20%22CBD%22%20%20DESCRIBE%20%3C',fn:encode-for-uri($iri), '%3E', '&#38;', 'output=application%2Frdf%2Bxml')"/>
			<xsl:variable name="semVocTypeXMLDocument" select="fn:doc($semVocTypeXMLDocumentIRI)"/>
			<xsl:choose>
				<xsl:when test="$semVocTypeXMLDocument//skos:prefLabel">
					<xsl:for-each select="$semVocTypeXMLDocument//skos:prefLabel">
						<a class="ssplink">
							<xsl:attribute name="href" select="$iri"/>
							<xsl:value-of select="text()"/>
						</a>
					</xsl:for-each>
				</xsl:when>
				<xsl:otherwise>
					<a>CHYBA: V sémantickém slovníku pojmů odpovídá prvek typu {$iri}, pro nějž není hodnota vlastnosti skos:prefLabel ve slovníku uvedena.</a>
				</xsl:otherwise>
			</xsl:choose>
			<xsl:catch>
				<a><xsl:text xmlns:err="http://www.w3.org/2005/xqt-errors">CHYBA: {$err:description} V sémantickém slovníku pojmů odpovídá prvek typu {$iri}, jehož definici se nepodařilo načíst.</xsl:text></a>
			</xsl:catch>
		</xsl:try>
	</xsl:function>
	<xsl:function name="gen:generujJménoPrvkuSIRIVSémantickémSlovníkuPojmů" as="xs:string">
		<xsl:param name="iri" as="xs:string"/>
		<xsl:value-of select="gen:generujHodnotuVlastnostiPrvkuSIRIVSémantickémSlovníkuPojmů($iri, 'skos:prefLabel', false(), true())"/>
	</xsl:function>
	<xsl:function name="gen:generujPopisPrvkuSIRIVSémantickémSlovníkuPojmů" as="xs:string">
		<xsl:param name="iri" as="xs:string"/>
		<xsl:variable name="popis" select="gen:generujHodnotuVlastnostiPrvkuSIRIVSémantickémSlovníkuPojmů($iri, 'skos:definition', false(), true())[1]"/>
		<xsl:choose>
			<xsl:when test="fn:contains($popis[1], 'CHYBA: ')">
				<xsl:value-of select="gen:generujHodnotuVlastnostiPrvkuSIRIVSémantickémSlovníkuPojmů($iri, 'skos:scopeNote', false(), true())[1]"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$popis"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:function>
	<xsl:function name="gen:generujDoménuPrvkuSIRIVSémantickémSlovníkuPojmů" as="xs:string*">
		<xsl:param name="iri" as="xs:string"/>
		<xsl:for-each select="gen:generujHodnotuVlastnostiPrvkuSIRIVSémantickémSlovníkuPojmů($iri, 'rdfs:domain', false(), false())">
			<xsl:value-of select="."/>
		</xsl:for-each>
	</xsl:function>
	<xsl:function name="gen:generujOborHodnotPrvkuSIRIVSémantickémSlovníkuPojmů" as="xs:string*">
		<xsl:param name="iri" as="xs:string"/>
		<xsl:for-each select="gen:generujHodnotuVlastnostiPrvkuSIRIVSémantickémSlovníkuPojmů($iri, 'rdfs:range', false(), false())">
			<xsl:value-of select="."/>
		</xsl:for-each>
	</xsl:function>
	<xsl:function name="gen:generujHodnotuVlastnostiPrvkuSIRIVSémantickémSlovníkuPojmů" as="node()*">
		<xsl:param name="iri" as="xs:string"/>
		<xsl:param name="property" as="xs:string"/>
		<xsl:param name="asLink" as="xs:boolean"/>
		<xsl:param name="isDatatype" as="xs:boolean"/>
		<xsl:try>
			<xsl:variable name="semVocTypeXMLDocumentIRI" select="fn:concat('https://xn--slovnk-7va.gov.cz/sparql?', '&#38;', 'query=define%20sql%3Adescribe-mode%20%22CBD%22%20%20DESCRIBE%20%3C',fn:encode-for-uri($iri), '%3E', '&#38;', 'output=application%2Frdf%2Bxml')"/>
			<xsl:variable name="semVocTypeXMLDocument" select="fn:doc($semVocTypeXMLDocumentIRI)"/>
			<xsl:choose>
				<xsl:when test="$isDatatype and $semVocTypeXMLDocument//.[fn:name() = $property]">
					<xsl:choose>
						<xsl:when test="$asLink">
							<xsl:for-each select="$semVocTypeXMLDocument//.[fn:name() = $property]">
								<a class="ssplink">
									<xsl:attribute name="href" select="$iri"/>
									<xsl:value-of select="text()"/>
								</a>
							</xsl:for-each>
						</xsl:when>
						<xsl:otherwise>
							<xsl:for-each select="$semVocTypeXMLDocument//.[fn:name() = $property]">
								<xsl:value-of select="text()"/>
							</xsl:for-each>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:when>
				<xsl:when test="not($isDatatype) and $semVocTypeXMLDocument//.[fn:name() = $property]/@rdf:resource">
					<xsl:choose>
						<xsl:when test="$asLink">
							<xsl:for-each select="$semVocTypeXMLDocument//.[fn:name() = $property]">
								<a class="ssplink">
									<xsl:attribute name="href" select="$iri"/>
									<xsl:value-of select="./@rdf:resource"/>
								</a>
							</xsl:for-each>
						</xsl:when>
						<xsl:otherwise>
							<xsl:for-each select="$semVocTypeXMLDocument//.[fn:name() = $property]">
								<xsl:value-of select="./@rdf:resource"/>
							</xsl:for-each>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:when>
				<xsl:otherwise>
					<xsl:choose>
						<xsl:when test="$asLink">
							<a>CHYBA: Hodnota vlastnosti {$property} prvku {$iri} není slovníku uvedena.</a>
						</xsl:when>
						<xsl:otherwise>CHYBA: Hodnota vlastnosti {$property} prvku {$iri} není slovníku uvedena.</xsl:otherwise>
					</xsl:choose>
				</xsl:otherwise>
			</xsl:choose>
			<xsl:catch>
				<xsl:choose>
					<xsl:when test="$asLink">
						<a><xsl:text xmlns:err="http://www.w3.org/2005/xqt-errors">CHYBA: {$err:description} Definici prvku {$iri} se nepodařilo načíst.</xsl:text></a>
					</xsl:when>
					<xsl:otherwise xmlns:err="http://www.w3.org/2005/xqt-errors">CHYBA: {$err:description} Definici prvku {$iri} se nepodařilo načíst.</xsl:otherwise>
				</xsl:choose>
			</xsl:catch>
		</xsl:try>
	</xsl:function>
	<xsl:function name="gen:generujQNameZIRI" as="xs:string">
		<xsl:param name="iri" as="xs:string"/>
		<xsl:param name="context" as="element()"/>
		<xsl:variable name="iriPrefix" select="fn:replace($iri, '(^.+[/#])([^/#]+)$','$1')" />
		<xsl:variable name="localName" select="fn:replace($iri, '(^.+[/#])([^/#]+)$','$2')" />
		<xsl:variable name="prefix">
			<xsl:choose>
				<xsl:when test="$context/fn:string[text()=$iriPrefix]/@key">{$context/fn:string[text()=$iriPrefix]/@key}</xsl:when>
				<xsl:when test="$iriPrefix = 'http://www.w3.org/2000/01/rdf-schema#'">rdfs</xsl:when>
				<xsl:when test="$iriPrefix = 'http://www.w3.org/2004/02/skos/core#'">skos</xsl:when>
				<xsl:otherwise>ERROR ({$localName})</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="qName" select="fn:concat($prefix, ':', $localName)"/>
		<xsl:value-of select="$qName"/>
	</xsl:function>
	<xsl:function name="gen:generujLocalNameZIRI" as="xs:string">
		<xsl:param name="iri" as="xs:string"/>
		<xsl:variable name="localName" select="fn:replace($iri, '(^.+[/#])([^/#]+)$','$2')" />
		<xsl:value-of select="$localName"/>
	</xsl:function>
	<xsl:function name="gen:generujOdkazyNaZakonyProLidi" as="element()*">
		<xsl:param name="item" as="element()"/>
		<xsl:variable name="legislativa" select="gen:generujLegislativuPrvkuVSémantickémSlovníkuPojmů($item)[fn:starts-with(., 'https://esbirka.opendata.cz/zdroj/předpis')]"/>
		<xsl:if test="fn:exists($legislativa)">
			<ul>
				<xsl:for-each select="$legislativa">
					<li>
						<a>
							<xsl:choose>
								<xsl:when test="fn:matches(., '^https://esbirka.opendata.cz/zdroj/předpis/([0-9]+)/([0-9]+)$')">
									<xsl:attribute name="href" select="fn:replace(., '^https://esbirka.opendata.cz/zdroj/předpis/([0-9]+)/([0-9]+)$', 'https://zakonyprolidi.cz/cs/$2-$1')"/>
									<xsl:value-of select="fn:replace(., '^https://esbirka.opendata.cz/zdroj/předpis/([0-9]+)/([0-9]+)$', 'Zákon č. $1/$2 Sb.')"/>
								</xsl:when>
								<xsl:when test="fn:matches(., '^https://esbirka.opendata.cz/zdroj/předpis/([0-9]+)/([0-9]+)/sekce/([0-9]+[a-z]*)$')">
									<xsl:attribute name="href" select="fn:replace(., '^https://esbirka.opendata.cz/zdroj/předpis/([0-9]+)/([0-9]+)/sekce/([0-9]+[a-z]*)$', 'https://zakonyprolidi.cz/cs/$2-$1#p$3')"/>
									<xsl:value-of select="fn:replace(., '^https://esbirka.opendata.cz/zdroj/předpis/([0-9]+)/([0-9]+)/sekce/([0-9]+[a-z]*)$', '§ $3 zákona č. $1/$2 Sb.')"/>
								</xsl:when>
								<xsl:when test="fn:matches(., '^https://esbirka.opendata.cz/zdroj/předpis/([0-9]+)/([0-9]+)/sekce/([0-9]+[a-z]*)/([0-9]+[a-z]*)$')">
									<xsl:attribute name="href" select="fn:replace(., '^https://esbirka.opendata.cz/zdroj/předpis/([0-9]+)/([0-9]+)/sekce/([0-9]+[a-z]*)/([0-9]+[a-z]*)$', 'https://zakonyprolidi.cz/cs/$2-$1#p$3-$4')"/>
									<xsl:value-of select="fn:replace(., '^https://esbirka.opendata.cz/zdroj/předpis/([0-9]+)/([0-9]+)/sekce/([0-9]+[a-z]*)/([0-9]+[a-z]*)$', '§ $3 odst. $4 zákona č. $1/$2 Sb.')"/>
								</xsl:when>
								<xsl:when test="fn:matches(., '^https://esbirka.opendata.cz/zdroj/předpis/([0-9]+)/([0-9]+)/sekce/([0-9]+[a-z]*)/([0-9]+[a-z]*)/([a-z]+)$')">
									<xsl:attribute name="href" select="fn:replace(., '^https://esbirka.opendata.cz/zdroj/předpis/([0-9]+)/([0-9]+)/sekce/([0-9]+[a-z]*)/([0-9]+[a-z]*)/([a-z]+)$', 'https://zakonyprolidi.cz/cs/$2-$1#p$3-$4-$5')"/>
									<xsl:value-of select="fn:replace(., '^https://esbirka.opendata.cz/zdroj/předpis/([0-9]+)/([0-9]+)/sekce/([0-9]+[a-z]*)/([0-9]+[a-z]*)/([a-z]+)$', '§ $3 odst. $4 písm. $5) zákona č. $1/$2 Sb.')"/>
								</xsl:when>
								<xsl:when test="fn:matches(., '^https://esbirka.opendata.cz/zdroj/předpis/([0-9]+)/([0-9]+)/sekce/([0-9]+[a-z]*)/([a-z]+)$')">
									<xsl:attribute name="href" select="fn:replace(., '^https://esbirka.opendata.cz/zdroj/předpis/([0-9]+)/([0-9]+)/sekce/([0-9]+[a-z]*)/([a-z]+)$', 'https://zakonyprolidi.cz/cs/$2-$1#p$3-1-$4')"/>
									<xsl:value-of select="fn:replace(., '^https://esbirka.opendata.cz/zdroj/předpis/([0-9]+)/([0-9]+)/sekce/([0-9]+[a-z]*)/([a-z]+)$', '§ $3 písm. $4) zákona č. $1/$2 Sb.')"/>
								</xsl:when>
								<xsl:when test="fn:matches(., '^https://esbirka.opendata.cz/zdroj/předpis/([0-9]+)/([0-9]+)/sekce/([0-9]+[a-z]*)/([0-9]+[a-z]*)/([a-z]+)/([0-9]+[a-z]*)$')">
									<xsl:attribute name="href" select="fn:replace(., '^https://esbirka.opendata.cz/zdroj/předpis/([0-9]+)/([0-9]+)/sekce/([0-9]+[a-z]*)/([0-9]+[a-z]*)/([a-z]+)/([0-9]+[a-z]*)$', 'https://zakonyprolidi.cz/cs/$2-$1#p$3-$4-$5-$6')"/>
									<xsl:value-of select="fn:replace(., '^https://esbirka.opendata.cz/zdroj/předpis/([0-9]+)/([0-9]+)/sekce/([0-9]+[a-z]*)/([0-9]+[a-z]*)/([a-z]+)/([0-9]+[a-z]*)$', '§ $3 odst. $4 písm. $5) bod $6. zákona č. $1/$2 Sb.')"/>
								</xsl:when>
								<xsl:when test="fn:matches(., '^https://esbirka.opendata.cz/zdroj/předpis/([0-9]+)/([0-9]+)/sekce/([0-9]+[a-z]*)/([a-z]+)/([0-9]+[a-z]*)$')">
									<xsl:attribute name="href" select="fn:replace(., '^https://esbirka.opendata.cz/zdroj/předpis/([0-9]+)/([0-9]+)/sekce/([0-9]+[a-z]*)/([a-z]+)/([0-9]+[a-z]*)$', 'https://zakonyprolidi.cz/cs/$2-$1#p$3-1-$4-$5')"/>
									<xsl:value-of select="fn:replace(., '^https://esbirka.opendata.cz/zdroj/předpis/([0-9]+)/([0-9]+)/sekce/([0-9]+[a-z]*)/([a-z]+)/([0-9]+[a-z]*)$', '§ $3 písm. $4) bod $5. zákona č. $1/$2 Sb.')"/>
								</xsl:when>
								<xsl:otherwise>
									<xsl:text>CHYBA: Nerozpoznané IRI ustanovení právního předpisu </xsl:text>
									<xsl:value-of select="."/>
								</xsl:otherwise>
							</xsl:choose>
						</a>
					</li>
				</xsl:for-each>
			</ul>
		</xsl:if>
	</xsl:function>
	<xsl:function name="gen:generujNázevČíselníku" as="node()*">
		<xsl:param name="item" as="element()"/>
		<xsl:variable name="context" select="$item/ancestor::fn:source/fn:map/fn:map[@key='@context']"/>
		<xsl:variable name="base" select="$context/fn:string[@key = '@base']/text()"/>
		<xsl:variable name="sparqlep" select="fn:replace($base, 'zdroj/', 'sparql')"/>
		<xsl:variable name="iri" select="fn:concat($base, $item/fn:map[@key='properties']/fn:map[@key='id']/fn:string[@key='default'])"/>
		<xsl:try>
			<xsl:variable name="semVocTypeXMLDocumentIRI" select="fn:concat($sparqlep, '?query=PREFIX%20skos%3A%20%3Chttp%3A%2F%2Fwww.w3.org%2F2004%2F02%2Fskos%2Fcore%23%3E%0A%0ACONSTRUCT%20WHERE%20%7B%0A%20%20%3C',fn:encode-for-uri($iri), '%3E%20skos%3AprefLabel%20%3FprefLabel%20.%0A%20%20FILTER(LANG(%3FprefLabel)%20%3D%20%22cs%22)%0A%7D', '&#38;', 'output=application%2Frdf%2Bxml')"/>
			<xsl:variable name="semVocTypeXMLDocument" select="fn:doc($semVocTypeXMLDocumentIRI)"/>
			<xsl:value-of select="$semVocTypeXMLDocument//skos:prefLabel"/>
			<xsl:catch xmlns:err="http://www.w3.org/2005/xqt-errors">CHYBA: {$err:description} V sémantickém slovníku pojmů odpovídá prvek typu {$iri}, jehož definici se nepodařilo načíst.</xsl:catch>
		</xsl:try>
	</xsl:function>
</xsl:stylesheet>
