<?xml version="1.0" encoding="UTF-8"?>
<pattern xmlns="http://purl.oclc.org/dsdl/schematron">

	<rule context="cbc:CustomizationID">
		<assert id="PEPPOL-T127-R001"
		  test="(normalize-space(.) = 'urn:fdc:peppol.eu:logistics:trns:transportation_status:1')"
		  flag="fatal">Specification identifier SHALL start with the value 'urn:fdc:peppol.eu:logistics:trns:transportation_status:1'.</assert>
	</rule>

	<rule context="cbc:ProfileID">
		<assert id="PEPPOL-T127-R002"
		  test="some $p in tokenize('urn:fdc:peppol.eu:logistics:bis:transportation_status_w_request:1 urn:fdc:peppol.eu:logistics:bis:transportation_status_only:1 urn:fdc:peppol.eu:logistics:bis:advanced_transport_execution_plan:1', '\s') satisfies $p = normalize-space(.)"
	 	  flag="fatal">ProfileID SHALL have the value 'urn:fdc:peppol.eu:logistics:bis:transportation_status_w_request:1' or 'urn:fdc:peppol.eu:logistics:bis:transportation_status_only:1' or 'urn:fdc:peppol.eu:logistics:bis:advanced_transport_execution_plan:1'.</assert>
	</rule>
	
	<rule context="ubl:TransportationStatus/cbc:IssueTime">
		<assert id="PEPPOL-T127-R018" test="count(timezone-from-time(.)) &gt; 0" flag="fatal"> [PEPPOL-T127-R018] IssueTime MUST include timezone information.</assert>
	</rule>
	
	<rule context="ubl:TransportationStatus/cac:SenderParty">
		<assert id="PEPPOL-T127-R031" test="cac:PartyName or cac:PartyIdentification" flag="fatal"> [PEPPOL-T127-R031] Party must include either a party name or a party identification.</assert>
	</rule>
	
	<rule context="ubl:TransportationStatus/cac:ReceiverParty">
		<assert id="PEPPOL-T127-R032" test="cac:PartyName or cac:PartyIdentification" flag="fatal"> [PEPPOL-T127-R032] Party must include either a party name or a party identification.</assert>
	</rule>

</pattern>

