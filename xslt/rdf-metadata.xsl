<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet version="1.0"
	xmlns:tr="http://ns.crustytoothpaste.net/troff"
	xmlns:tm="http://ns.crustytoothpaste.net/text-markup"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	exclude-result-prefixes="tr tm xsl">
	<xsl:output method="xml" encoding="UTF-8"/>

	<xsl:template name="rdf-metadata-generate-rdf">
		<!--
				 XMP only allows us to have rdf:Description elements that contain an
				 empty rdf:about attribute.  We want to include other metadata, but
				 that isn't RDF, so split it out into its own piece.

				 We also move the namespace declarations to the x:xmpmeta and
				 descendant elements, so that the XMP is self-contained and can be read
				 by a byte-reading parser.
		-->
		<xsl:processing-instruction
			name="xpacket">begin="&#xfeff;" id="W5M0MpCehiHzreSzNTczkc9d"</xsl:processing-instruction>
		<x:xmpmeta xmlns:x="adobe:ns:meta/">
			<rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#">
				<rdf:Description rdf:about=""
					xmlns:dc="http://purl.org/dc/elements/1.1/">
					<xsl:apply-templates mode="rdf"/>
				</rdf:Description>
				<xsl:copy-of select="rdf:RDF/rdf:Description[@rdf:about='']"/>
			</rdf:RDF>
		</x:xmpmeta>
		<xsl:processing-instruction
			name="xpacket">end="r"</xsl:processing-instruction>
		<rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
			xmlns:dc="http://purl.org/dc/elements/1.1/">
			<xsl:for-each select="//tm:blockquote[@xml:id and tm:meta]">
				<rdf:Description>
					<xsl:attribute name="rdf:about">
						<xsl:text>#</xsl:text><xsl:value-of select="@xml:id"/>
					</xsl:attribute>
					<xsl:if test="tm:meta/tm:attribution">
						<dc:creator><xsl:apply-templates
								select="tm:meta/tm:attribution/text()"/></dc:creator>
					</xsl:if>
					<xsl:if test="tm:meta/tm:source">
						<dc:source><xsl:apply-templates
								select="tm:meta/tm:source/text()"/></dc:source>
					</xsl:if>
				</rdf:Description>
			</xsl:for-each>
			<xsl:copy-of select="rdf:RDF/*[not(rdf:Description[@rdf:about=''])]"/>
		</rdf:RDF>
	</xsl:template>
</xsl:stylesheet>
