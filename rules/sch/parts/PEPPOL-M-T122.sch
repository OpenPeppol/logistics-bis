<?xml version="1.0" encoding="UTF-8"?>
<pattern xmlns="http://purl.oclc.org/dsdl/schematron">

	<rule context="cbc:CustomizationID">
		<assert id="PEPPOL-T122-R001" 
				test="starts-with(normalize-space(.), 'urn:fdc:peppol.eu:logistics:trns:weight_statement:1')"
				flag="fatal">Specification identifier SHALL start with the value 'urn:fdc:peppol.eu:logistics:trns:weight_statement:1'.</assert>
	</rule>
	<rule context="cbc:ProfileID">
		<assert id="PEPPOL-T122-R002"
		  test="some $p in tokenize('urn:fdc:peppol.eu:logistics:bis:weight_statement:1', '\s') satisfies $p = normalize-space(.)"
		  flag="fatal">ProfileID SHALL have the value 'urn:fdc:peppol.eu:logistics:bis:weight_statement:1'.</assert>
	</rule>
	
	<rule context="cac:GoodsItem">
		<assert id="PEPPOL-T122-R003" test="(cac:Item/cac:StandardItemIdentification/cbc:ID) or  (cac:Item/cac:SellersItemIdentification/cbc:ID)" flag="fatal">Each item in a Weight Statement SHALL be identifiable by either "item sellers identifier" or "item standard identifier"</assert>
	</rule>
	
	<rule context="cac:WeighingParty">
		<assert id="PEPPOL-T122-R010" test="(cac:PhysicalLocation/cbc:Name) or (cac:PhysicalLocation/cbc:ID)" flag="fatal">The Weighing party's Physical location SHALL contain the Name or an Identifier. </assert>
		<assert id="PEPPOL-T122-R013" test="(cac:PartyName/cbc:Name) or (cac:PartyIdentification/cbc:ID)" flag="fatal">The Weighing party SHALL contain the Name or an Identifier. </assert>
	</rule>

	<rule context="cac:SenderParty">
		<assert id="PEPPOL-T122-R011" test="(cac:PartyName/cbc:Name) or (cac:PartyIdentification/cbc:ID)" flag="fatal">The Sender party SHALL contain the Name or an Identifier. </assert>
	</rule>

	<rule context="cac:ReceiverParty">
		<assert id="PEPPOL-T122-R012" test="(cac:PartyName/cbc:Name) or (cac:PartyIdentification/cbc:ID)" flag="fatal">The Receiver party SHALL contain the Name or an Identifier. </assert>
	</rule>

	<rule context="cac:ShipperParty">
		<assert id="PEPPOL-T122-R014" test="(cac:PartyName/cbc:Name) or (cac:PartyIdentification/cbc:ID)" flag="fatal">The Shipper party SHALL contain the Name or an Identifier. </assert>
	</rule>
	
</pattern>
