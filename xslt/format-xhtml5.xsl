<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet version="1.0"
	xmlns="http://www.w3.org/1999/xhtml"
	xmlns:xh="http://www.w3.org/1999/xhtml"
	xmlns:tr="http://ns.crustytoothpaste.net/troff"
	xmlns:tm="http://ns.crustytoothpaste.net/text-markup"
	xmlns:dc="http://purl.org/dc/elements/1.1/"
	xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xl="http://www.w3.org/1999/xlink"
	exclude-result-prefixes="xh tr tm xsl">
	<xsl:import href="rdf-metadata.xsl"/>
	<xsl:output method="xml" encoding="UTF-8"/>

	<xsl:template match="node()|@*">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()"/>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="node()|@*" mode="rdf"/>
	<xsl:template match="node()|@*" mode="body"/>

	<xsl:template name="insert-id-fixup">
		<script>
			//<![CDATA[
			// Make id attributes for browsers that don't understand xml:id.
			(function () {
				var id_fixup = function () {
					var xml_ns = "http://www.w3.org/XML/1998/namespace";
					if (document.getElementById("content"))
						return;
					var treewalker = document.createTreeWalker(
						document.body,
						NodeFilter.SHOW_ELEMENT,
						{
							acceptNode: function(node) {
								return node.getAttributeNS(xml_ns, "id") ?
									NodeFilter.FILTER_ACCEPT : NodeFilter.FILTER_SKIP;
							}
						},
						false
					);
					while (treewalker.nextNode()) {
						var cur = treewalker.currentNode;
						var value = cur.getAttributeNS(xml_ns, "id");
						// Only one ID attribute can be present, and for this browser it's
						// the HTML one.
						cur.removeAttributeNS(xml_ns, "id");
						cur.setAttributeNS(null, "id", value);

					}
				};
				window.addEventListener("load", id_fixup, false);
			})();
			//]]>
		</script>
	</xsl:template>

	<xsl:template match="tm:root">
		<html>
			<head>
				<title><xsl:apply-templates select="tm:title"/></title>
				<link rel="stylesheet" href="default.css"/>
				<xsl:call-template name="insert-id-fixup"/>
				<xsl:apply-templates select="tm:meta"/>
			</head>
			<body class="article" name="body">
				<xsl:call-template name="body-header"/>
			</body>
		</html>
	</xsl:template>

	<xsl:template match="tm:meta">
		<xsl:if test="tm:generator">
			<meta name="generator">
				<xsl:attribute name="content">
					<xsl:value-of select="tm:generator/@name"/>
					<xsl:text> version </xsl:text>
					<xsl:value-of select="tm:generator/@version"/>
				</xsl:attribute>
			</meta>
		</xsl:if>
		<xsl:call-template name="rdf-metadata-generate-rdf" />
	</xsl:template>

	<xsl:template match="tm:title">
		<xsl:apply-templates select=".//text()"/>
	</xsl:template>

	<xsl:template match="tm:itemizedlist">
		<ul>
			<xsl:apply-templates/>
		</ul>
	</xsl:template>

	<xsl:template match="tm:orderedlist">
		<ol>
			<xsl:apply-templates/>
		</ol>
	</xsl:template>

	<xsl:template match="tm:listitem">
		<xsl:choose>
			<xsl:when test="normalize-space(text()[position()=1]) = '' and
				(tm:orderedlist or tm:itemizedlist)">
				<xsl:apply-templates/>
			</xsl:when>
			<xsl:otherwise>
				<li>
					<xsl:apply-templates/>
				</li>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="tm-simple-link">
		<a>
			<xsl:attribute name="href">
				<xsl:value-of select="@xl:href"/>
			</xsl:attribute>
			<xsl:apply-templates/>
		</a>
	</xsl:template>

	<xsl:template match="tm:link[not(@xl:type) and @xl:href]">
		<xsl:call-template name="tm-simple-link"/>
	</xsl:template>

	<xsl:template match="tm:link[@xl:type='simple']">
		<xsl:call-template name="tm-simple-link"/>
	</xsl:template>

	<xsl:template match="tm:verbatim">
		<xsl:choose>
			<xsl:when test="@type = 'monospace'">
				<pre xml:space="preserve"><xsl:apply-templates /></pre>
			</xsl:when>
			<xsl:otherwise>
				<p xml:space="preserve"
					style="white-space: pre"><xsl:apply-templates /></p>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="tm:blockquote">
		<blockquote>
			<xsl:apply-templates select="@*|*[not(tm:meta)]"/>
			<xsl:if test="tm:meta">
				<div class="source-meta">
					― <xsl:apply-templates select="tm:meta/tm:attribution"/><xsl:if
						test="tm:meta/tm:source">, <xsl:apply-templates
							select="tm:meta/tm:source"/>
					</xsl:if>
				</div>
			</xsl:if>
		</blockquote>
	</xsl:template>

	<xsl:template match="tm:sidebar">
		<div class="sidebar">
			<xsl:apply-templates />
		</div>
	</xsl:template>

	<xsl:template match="tm:image">
		<img>
			<xsl:apply-templates select="@xml:id"/>
			<xsl:attribute name="src">
				<xsl:value-of select="@uri"/>
			</xsl:attribute>
			<xsl:attribute name="alt">
				<xsl:value-of select="@description"/>
			</xsl:attribute>
		</img>
	</xsl:template>

	<xsl:template match="tm:para">
		<xsl:if test="string-length(normalize-space(.)) > 0 or @*">
			<p>
				<xsl:apply-templates/>
			</p>
		</xsl:if>
	</xsl:template>

	<xsl:template match="tr:inline">
		<xsl:choose>
			<xsl:when test="@tr:font-weight = 'bold'">
				<strong><xsl:call-template name="tr-inline-emphasis"/></strong>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="tr-inline-emphasis"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="tr-inline-emphasis">
		<xsl:choose>
			<xsl:when test="@tr:font-style='italic' or @tr:font-variant='italic'
					or @tr:font-style='oblique' or @tr:font-variant='oblique'">
				<em><xsl:apply-templates/></em>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="tm:inline">
		<xsl:variable name="tagname">
			<xsl:choose>
				<xsl:when test="@type='strong'">strong</xsl:when>
				<xsl:when test="@type='emphasis'">em</xsl:when>
				<xsl:when test="@type='quote'">q</xsl:when>
				<xsl:when test="@type='monospace'">tt</xsl:when>
				<xsl:when test="@type='superscript'">sup</xsl:when>
				<xsl:when test="@type='subscript'">sub</xsl:when>
				<xsl:otherwise>span</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:element namespace="http://www.w3.org/1999/xhtml" name="{$tagname}">
			<xsl:apply-templates/>
		</xsl:element>
	</xsl:template>

	<xsl:template match="tm:author" mode="raw">
		<xsl:choose>
			<xsl:when test="tm:firstname|tm:middlename|tm:lastname">
				<xsl:apply-templates select="tm:firstname//text()"/>
				<xsl:if test="tm:middlename">
					<xsl:text> </xsl:text>
					<xsl:apply-templates select="tm:middlename//text()"/>
				</xsl:if>
				<xsl:if test="tm:lastname">
					<xsl:text> </xsl:text>
					<xsl:apply-templates select="tm:lastname//text()"/>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates select="./text()"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="tm:author" mode="rdf">
		<dc:creator><xsl:apply-templates select="." mode="raw"/></dc:creator>
	</xsl:template>

	<xsl:template match="tm:author" mode="body">
		<span xml:id="author">
			<xsl:apply-templates select="." mode="raw"/>
			<xsl:if test="tm:email">
				<xsl:text> </xsl:text>
				&lt;<xsl:apply-templates select="tm:email//text()"/>&gt;
			</xsl:if>
		</span>
		<br/>
	</xsl:template>

	<xsl:template name="body-header">
		<div xml:id="header">
			<h1><xsl:apply-templates select="tm:title"/></h1>
			<xsl:apply-templates select="/tm:root/tm:meta/*" mode="body"/>
		</div>
		<div xml:id="content">
			<xsl:apply-templates
				select="tm:*[local-name()!='title' and local-name()!='meta']"/>
		</div>
	</xsl:template>

	<xsl:template match="tm:section" name="section">
		<xsl:param name="level" select="count(ancestor-or-self::tm:section)+1"/>
		<div>
			<xsl:apply-templates select="@*"/>
			<xsl:element namespace="http://www.w3.org/1999/xhtml" name="h{$level}">
				<xsl:apply-templates select="tm:title"/>
			</xsl:element>
			<xsl:apply-templates
				select="tm:*[local-name()!='title' and local-name()!='meta']"/>
		</div>
	</xsl:template>
</xsl:stylesheet>
