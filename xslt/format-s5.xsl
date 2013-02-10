<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet version="1.0"
	xmlns="http://www.w3.org/1999/xhtml"
	xmlns:xh="http://www.w3.org/1999/xhtml"
	xmlns:tr="http://ns.crustytoothpaste.net/troff"
	xmlns:tm="http://ns.crustytoothpaste.net/text-markup"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
	xmlns:dc="http://purl.org/dc/elements/1.1/"
	exclude-result-prefixes="xh tr tm xsl rdf dc">
	<xsl:include href="format-xhtml5.xsl"/>
	<xsl:output method="xml" encoding="UTF-8"
		doctype-public="-//W3C//DTD XHTML 1.0 Strict//EN"
		doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd" />

	<xsl:param name="theme">default</xsl:param>

	<xsl:template match="node()|@*">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()"/>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="node()|@*" mode="rdf"/>
	<xsl:template match="node()|@*" mode="body"/>

	<xsl:template match="tm:root">
		<html>
			<head>
				<title><xsl:apply-templates select="tm:title"/></title>
				<meta name="version" content="S5 1.1"/>
				<meta http-equiv="Content-Type"
					content="application/xhtml+xml; charset=UTF-8"/>
				<link rel="stylesheet"
					href="ui/{$theme}/slides.css"
					type="text/css"
					media="projection"
					id="slideProj" />
				<link rel="stylesheet"
					href="ui/{$theme}/outline.css"
					type="text/css"
					media="screen"
					id="outlineStyle" />
				<link rel="stylesheet"
					href="ui/{$theme}/print.css"
					type="text/css"
					media="print"
					id="slidePrint" />
				<link rel="stylesheet"
					href="ui/{$theme}/opera.css"
					type="text/css"
					media="projection"
					id="operaFix" />
				<!--
					We need to insert a newline here because we can't serve the data as
					XHTML due to Debian bug #699642 and the HTML is misparsed if the
					script tag uses a self-closing tag instead of a start-end pair.
					-->
				<script src="ui/{$theme}/slides.js" type="text/javascript">&#xa;</script>
			</head>
			<body>
				<xsl:call-template name="body"/>
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
		<xsl:if test="tm:author">
			<meta name="author">
				<xsl:attribute name="content">
					<xsl:apply-templates select="tm:author" mode="raw"/>
				</xsl:attribute>
			</meta>
		</xsl:if>
	</xsl:template>

	<xsl:template name="slide-header"/>
	<xsl:template name="slide-footer"/>

	<xsl:template name="body">
		<div class="layout">
			<div id="controls"/>
			<div id="currentSlide"></div>
			<div id="header"><xsl:call-template name="slide-header"/></div>
			<div id="footer"><xsl:call-template name="slide-footer"/></div>
		</div>
		<div class="presentation">
			<!-- Automatically create a title slide. -->
			<div class="slide">
				<h1><xsl:apply-templates select="/tm:root/tm:title"/></h1>
				<xsl:if test="/tm:root/tm:subtitle">
					<h2><xsl:apply-templates select="/tm:root/tm:subtitle"/></h2>
				</xsl:if>
				<xsl:if test="/tm:root/tm:meta/tm:author">
					<h3><xsl:apply-templates select="/tm:root/tm:meta/tm:author"
							mode="raw"/></h3>
				</xsl:if>
			</div>
			<xsl:apply-templates select="tm:section[@type='slide']"/>
		</div>
	</xsl:template>

	<xsl:template match="tm:section">
		<xsl:call-template name="section">
			<xsl:param name="level" select="count(ancestor-or-self::tm:section)+2"/>
		</xsl:call-template>
	</xsl:template>

	<xsl:template match="tm:section[@type='slide']">
		<div class="slide">
			<h1><xsl:apply-templates select="tm:title"/></h1>
			<xsl:if test="tm:subtitle">
				<h2><xsl:apply-templates select="tm:subtitle"/></h2>
			</xsl:if>
			<div class="slidecontent">
				<xsl:apply-templates
					select="tm:*[not(local-name()='section' and @type='handout') and
						not(local-name()='title')]"/>
			</div>
			<xsl:if test="tm:section[@type='handout']">
				<div class="handout">
					<xsl:apply-templates select="tm:section[@type='handout']"/>
				</div>
			</xsl:if>
		</div>
	</xsl:template>
</xsl:stylesheet>
