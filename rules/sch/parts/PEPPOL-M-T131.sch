<?xml version="1.0" encoding="UTF-8"?>
<pattern xmlns="http://purl.oclc.org/dsdl/schematron">
	<!-- Business rules for Manifest (T131). Rule IDs follow the references in
	     structure/source/ubl-manifest.xml and structure/syntax/ubl-manifest.xml. -->

	<!-- Waybill document type codes (UNCL1001) accepted as reference to the Waybill covering a consignment:
	     700 Waybill, 703 House waybill, 710 Sea waybill, 740 Air waybill, 741 Master air waybill, 743 Substitute air waybill. -->
	<let name="clWaybillDocumentTypeCode" value="tokenize('700 703 710 740 741 743', '\s')"/>

	<rule context="cbc:CustomizationID">
		<assert id="PEPPOL-T131-R001"
		  test="(normalize-space(.) = 'urn:fdc:peppol.eu:logistics:trns:manifest:1')"
		  flag="fatal">CustomizationID SHALL have the value 'urn:fdc:peppol.eu:logistics:trns:manifest:1'.</assert>
	</rule>
	<rule context="cbc:ProfileID">
		<assert id="PEPPOL-T131-R002"
		   test="(normalize-space(.) = 'urn:fdc:peppol.eu:logistics:bis:manifest_w_application_response:1')"
		  flag="fatal">ProfileID SHALL have the value 'urn:fdc:peppol.eu:logistics:bis:manifest_w_application_response:1'.</assert>
	</rule>

	<rule context="ubl:Manifest">
		<assert id="PEPPOL-T131-R003" test="not(cbc:IssueTime) or count(timezone-from-time(cbc:IssueTime)) &gt; 0" flag="fatal">[PEPPOL-T131-R003] IssueTime cannot be specified without time zone.</assert>
	</rule>

	<rule context="ubl:Manifest/cac:ConsignorParty">
		<assert id="PEPPOL-T131-R006" test="cac:PartyName or cac:PartyIdentification" flag="fatal">[PEPPOL-T131-R006] Consignor party must include either a party name or a party identification.</assert>
	</rule>

	<rule context="ubl:Manifest/cac:ConsigneeParty">
		<assert id="PEPPOL-T131-R007" test="cac:PartyName or cac:PartyIdentification" flag="fatal">[PEPPOL-T131-R007] Consignee party must include either a party name or a party identification.</assert>
	</rule>

	<rule context="ubl:Manifest/cac:Shipment/cac:Consignment">
		<assert id="PEPPOL-T131-R009" test="cac:DocumentReference[some $code in $clWaybillDocumentTypeCode satisfies normalize-space(cbc:DocumentTypeCode) = $code]" flag="fatal">[PEPPOL-T131-R009] A consignment SHALL contain a document reference to the Waybill covering it, with document type code 700, 703, 710, 740, 741 or 743.</assert>
	</rule>

</pattern>
