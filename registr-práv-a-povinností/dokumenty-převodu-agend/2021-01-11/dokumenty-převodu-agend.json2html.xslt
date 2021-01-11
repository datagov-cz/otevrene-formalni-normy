<xsl:stylesheet
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:db="http://docbook.org/ns/docbook"
  xmlns:fn="http://www.w3.org/2005/xpath-functions"
  xmlns:gen="https://data.gov.cz/otevřené-formální-normy/generátor"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  version="3.0" expand-text="yes">

  <xsl:import href="../../../json-schema-to-html/json-schema-to-html.xslt" />

  <xsl:template match="db:article">
<html lang="cs">
  <head>
    <title>Registr práv a povinností - dokumenty převodu agend</title>
    <meta content="width=device-width,initial-scale=1" name="viewport" />
    <meta name="theme-color" content="#057fa5" />
    <meta name="msapplication-TileColor" content="#057fa5" />
    <meta name="msapplication-TileImage" content="../../../static/favicons/ms-icon-144x144.png" />
    <link rel="apple-touch-icon" sizes="57x57" href="../../../static/favicons/apple-icon-57x57.png" />
    <link rel="apple-touch-icon" sizes="60x60" href="../../../static/favicons/apple-icon-60x60.png" />
    <link rel="apple-touch-icon" sizes="72x72" href="../../../static/favicons/apple-icon-72x72.png" />
    <link rel="apple-touch-icon" sizes="76x76" href="../../../static/favicons/apple-icon-76x76.png" />
    <link rel="apple-touch-icon" sizes="114x114" href="../../../static/favicons/apple-icon-114x114.png" />
    <link rel="apple-touch-icon" sizes="120x120" href="../../../static/favicons/apple-icon-120x120.png" />
    <link rel="apple-touch-icon" sizes="144x144" href="../../../static/favicons/apple-icon-144x144.png" />
    <link rel="apple-touch-icon" sizes="152x152" href="../../../static/favicons/apple-icon-152x152.png" />
    <link rel="apple-touch-icon" sizes="180x180" href="../../../static/favicons/apple-icon-180x180.png" />
    <link rel="icon" type="image/png" sizes="192x192"  href="../../../static/favicons/android-icon-192x192.png" />
    <link rel="icon" type="image/png" sizes="32x32" href="../../../static/favicons/favicon-32x32.png" />
    <link rel="icon" type="image/png" sizes="96x96" href="../../../static/favicons/favicon-96x96.png" />
    <link rel="manifest" href="../../../static/favicons/manifest.json" />
    <link rel="stylesheet" type="text/css" href="../../../static/css/ssp.css" />
    <script class="remove" src="../../../static/js/respec-odcz.js" />
    <script class="remove" src="dokumenty-převodu-agend.config.js" />
  </head>
  <body>
    <xsl:apply-templates mode="abstrakt" />
    <xsl:sequence select="gen:generujDokumentaciPrvků('../registr-práv-a-povinností/dokumenty-převodu-agend/2021-01-11/dokumenty-převodu-agend.schema.json', '../registr-práv-a-povinností/dokumenty-převodu-agend/2021-01-11/dokumenty-převodu-agend.context.jsonld')"/>
    <xsl:apply-templates mode="příklady" />
  </body>
</html>
  </xsl:template>

</xsl:stylesheet>