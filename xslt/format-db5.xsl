<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet version="1.0"
	xmlns="http://docbook.org/ns/docbook"
	xmlns:d="http://docbook.org/ns/docbook"
	xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
	xmlns:cc="http://creativecommons.org/ns#"
	xmlns:tm="http://ns.crustytoothpaste.net/text-markup"
	xmlns:tr="http://ns.crustytoothpaste.net/troff"
	xmlns:_t="http://ns.crustytoothpaste.net/troff"
	xmlns:_tm="http://ns.crustytoothpaste.net/text-markup"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:dc="http://purl.org/dc/elements/1.1/"
	xmlns:xmp="http://ns.adobe.com/xap/1.0/"
	xmlns:xl="http://www.w3.org/1999/xlink"
	exclude-result-prefixes="tm tr d _t _tm">
	<xsl:output method="xml" encoding="UTF-8"/>

	<xsl:template name="process-bold">
		<xsl:choose>
			<xsl:when test="ancestor-or-self::*[@tr:font-weight][1][@tr:font-weight='bold']">
				<d:emphasis role="strong">
					<xsl:apply-templates/>
				</d:emphasis>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="process-italic">
		<xsl:choose>
			<xsl:when test="ancestor-or-self::*[@tr:font-variant][1][@tr:font-variant='italic']">
				<d:emphasis>
					<xsl:call-template name="process-bold"/>
				</d:emphasis>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="process-bold"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="tr:inline">
		<xsl:call-template name="process-italic"/>
	</xsl:template>

	<xsl:template match="tr:main|tr:block">
		<xsl:apply-templates/>
	</xsl:template>

	<xsl:template match="node()|@*">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()"/>
		</xsl:copy>
	</xsl:template>

	<!-- tm -> db5 -->
	<xsl:template match="node()|@*" mode="rdf"/>
	<xsl:template match="node()|@*" mode="body"/>
	<xsl:template match="node()|@*" mode="info"/>

	<xsl:template match="tm:title"/>

	<xsl:template match="tm:title" mode="info">
		<xsl:apply-templates select="node()"/>
	</xsl:template>

	<xsl:template name="info">
		<info>
			<title><xsl:apply-templates select="tm:title" mode="info"/></title>
			<xsl:apply-templates select="tm:meta" mode="info"/>
		</info>
	</xsl:template>

	<xsl:template match="tm:section">
		<section>
			<xsl:call-template name="info" />
			<xsl:apply-templates select="*"/>
		</section>
	</xsl:template>

	<xsl:template match="tm:inline[@type = 'emphasis']">
		<emphasis><xsl:apply-templates/></emphasis>
	</xsl:template>

	<xsl:template match="tm:inline[@type = 'strong']">
		<emphasis role="strong"><xsl:apply-templates/></emphasis>
	</xsl:template>

	<xsl:template match="tm:inline[@type = 'monospace']">
		<literal><xsl:apply-templates/></literal>
	</xsl:template>


	<xsl:template match="tm:para">
		<para>
			<xsl:apply-templates/>
		</para>
	</xsl:template>

	<!-- What's this for? -->
	<xsl:template match="tm:para[count(node()) = 0]"/>

	<xsl:template match="tm:root">
		<article version="5.0">
			<xsl:call-template name="info" />
			<xsl:apply-templates/>
		</article>
	</xsl:template>

	<xsl:template match="tm:meta" mode="info">
		<rdf:RDF>
			<rdf:Description rdf:about="">
				<xsl:apply-templates mode="rdf"/>
				<xsl:if test="tm:generator">
					<xmp:CreatorTool>
						<xsl:attribute name="content">
							<xsl:value-of select="tm:generator/@name"/>
							<xsl:text> version </xsl:text>
							<xsl:value-of select="tm:generator/@version"/>
						</xsl:attribute>
					</xmp:CreatorTool>
				</xsl:if>
			</rdf:Description>
			<xsl:copy-of select="rdf:RDF/*"/>
			<xsl:apply-templates select="tm:*" mode="info"/>
		</rdf:RDF>
	</xsl:template>

	<xsl:template match="tm:itemizedlist">
		<itemizedlist>
			<xsl:apply-templates/>
		</itemizedlist>
	</xsl:template>

	<xsl:template match="tm:orderedlist">
		<orderedlist>
			<xsl:apply-templates/>
		</orderedlist>
	</xsl:template>

	<xsl:template match="tm:listitem">
		<listitem>
			<xsl:choose>
				<xsl:when test="tm:*">
					<xsl:apply-templates/>
				</xsl:when>
				<xsl:otherwise>
					<para>
						<xsl:apply-templates/>
					</para>
				</xsl:otherwise>
			</xsl:choose>
		</listitem>
	</xsl:template>

	<xsl:template name="tm-simple-link">
		<link>
			<xsl:copy-of select="@xl:*"/>
			<xsl:apply-templates/>
		</link>
	</xsl:template>

	<xsl:template match="tm:link[not(@xl:type) and @xl:href]">
		<xsl:call-template name="tm-simple-link"/>
	</xsl:template>

	<xsl:template match="tm:link[@xl:type='simple']">
		<xsl:call-template name="tm-simple-link"/>
	</xsl:template>

	<xsl:template match="tm:verbatim">
		<literallayout xml:space="preserve"><xsl:apply-templates /></literallayout>
	</xsl:template>

	<xsl:template match="tm:image">
		<inlinemediaobject>
			<xsl:if test="@description">
				<xsl:attribute name="alt">
					<xsl:value-of select="@description"/>
				</xsl:attribute>
			</xsl:if>
			<imageobject>
				<imagedata>
					<xsl:attribute name="fileref">
						<xsl:value-of select="@uri"/>
					</xsl:attribute>
				</imagedata>
			</imageobject>
		</inlinemediaobject>
	</xsl:template>

	<xsl:template match="tm:para">
		<xsl:if test="string-length(normalize-space(.)) > 0">
			<para>
				<xsl:apply-templates/>
			</para>
		</xsl:if>
	</xsl:template>

	<xsl:template match="tm:inline">
		<xsl:variable name="tagname">
			<xsl:choose>
				<xsl:when test="@type='strong'">emphasis</xsl:when>
				<xsl:when test="@type='emphasis'">emphasis</xsl:when>
				<xsl:when test="@type='quote'">quote</xsl:when>
				<xsl:when test="@type='monospace'">literal</xsl:when>
				<xsl:when test="@type='superscript'">superscript</xsl:when>
				<xsl:when test="@type='subscript'">subscript</xsl:when>
				<xsl:otherwise>span</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:element namespace="http://docbook.org/ns/docbook" name="{$tagname}">
			<xsl:if test="@type='strong'">
				<xsl:attribute name="role">strong</xsl:attribute>
			</xsl:if>
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

	<xsl:template match="tm:author" mode="info">
		<personname>
			<xsl:apply-templates select="." mode="raw"/>
		</personname>
		<xsl:if test="tm:email">
			<email><xsl:apply-templates select="tm:email//text()"/></email>
		</xsl:if>
	</xsl:template>

	<xsl:template match="tm:section" name="section">
		<section>
			<xsl:apply-templates select="tm:title"/>
			<xsl:apply-templates select="tm:meta" mode="info"/>
			<xsl:apply-templates
				select="tm:*[local-name()!='title' and local-name()!='meta']"/>
		</section>
	</xsl:template>
</xsl:stylesheet>
