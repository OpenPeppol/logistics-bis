<?xml version="1.0" encoding="UTF-8"?>
<pattern xmlns="http://purl.oclc.org/dsdl/schematron">

	<rule context="cbc:CustomizationID">
		<assert id="PEPPOL-T123-R001" test="(normalize-space(.) = 'urn:fdc:peppol.eu:logistics:trns:transport_execution_plan_request:1')" 
				flag="fatal">CustomizationID SHALL have the value 'urn:fdc:peppol.eu:logistics:trns:transport_execution_plan_request:1'.</assert>
	</rule>

	<rule context="cbc:ProfileID">
		<assert id="PEPPOL-T123-R002"
		  test="some $p in tokenize('urn:fdc:peppol.eu:logistics:bis:transport_execution_plan_w_request:1 urn:fdc:peppol.eu:logistics:bis:advanced_transport_execution_plan:1', '\s') satisfies $p = normalize-space(.)"
	 	  flag="fatal">ProfileID SHALL have the value 'urn:fdc:peppol.eu:logistics:bis:transport_execution_plan_w_request:1' or 'urn:fdc:peppol.eu:logistics:bis:advanced_transport_execution_plan:1'.</assert>
	</rule>

	<rule context="cac:Consignment">
		<assert id="PEPPOL-T123-R003" test="not(cbc:TotalTransportHandlingUnitQuantity) or number(cbc:TotalTransportHandlingUnitQuantity) &gt;= 0" flag="warning">[PEPPOL-T123-R003] Total transport handling unit quantity SHALL not be negative</assert>
		<assert id="PEPPOL-T123-R004" test="not(cbc:TotalTransportHandlingUnitQuantity) or not(cac:TransportHandlingUnit) or number(cbc:TotalTransportHandlingUnitQuantity) = count(cac:TransportHandlingUnit)" flag="warning">[PEPPOL-T123-R004] Shipment transport handling unit quantity SHALL match the number of the transport handling units specified</assert>
		<assert id="PEPPOL-T123-R005" test="not(cbc:GrossWeightMeasure) or not(cac:TransportHandlingUnit/cac:MeasurementDimension[normalize-space(cbc:AttributeID) = 'AAB']/cbc:Measure) or (cbc:GrossWeightMeasure/@unitCode) &gt; (cac:TransportHandlingUnit/cac:MeasurementDimension[normalize-space(cbc:AttributeID) = 'AAB']/cbc:Measure/@unitCode) or (cbc:GrossWeightMeasure/@unitCode) &lt; (cac:TransportHandlingUnit/cac:MeasurementDimension[normalize-space(cbc:AttributeID) = 'AAB']/cbc:Measure/@unitCode) or number(cbc:GrossWeightMeasure) = sum(cac:TransportHandlingUnit/cac:MeasurementDimension[normalize-space(cbc:AttributeID) = 'AAB']/cbc:Measure)" flag="warning">[PEPPOL-T123-R005] Shipment  gross weight measure SHALL match the gross weight of the transport handling units specified</assert>
		<let name="THUGrossVolume" value="round(sum(cac:TransportHandlingUnit/cac:MeasurementDimension[normalize-space(cbc:AttributeID) = 'AAW']/cbc:Measure) * 1000)"/>
		<assert id="PEPPOL-T123-R006"
		   test="not(cbc:GrossVolumeMeasure) or (cbc:GrossVolumeMeasure/@unitCode) &gt; (cac:TransportHandlingUnit/cac:MeasurementDimension[normalize-space(cbc:AttributeID) = 'AAW']/cbc:Measure/@unitCode) or (cbc:GrossVolumeMeasure/@unitCode) &lt; (cac:TransportHandlingUnit/cac:MeasurementDimension[normalize-space(cbc:AttributeID) = 'AAW']/cbc:Measure/@unitCode) or ((cbc:GrossVolumeMeasure)/xs:decimal(.) * 1000) &gt;= $THUGrossVolume" flag="warning">
			[PEPPOL-T123-R006] Gross Volume Measure value must be greater than or equal to the sum of the MeasurementDimension/Measure values with AttributeID 'AAW'.
		</assert>
		<assert id="PEPPOL-T123-R007" test="not(cac:DeliveryTerms) or ((cac:DeliveryTerms/cbc:ID) or (cac:DeliveryTerms/cbc:SpecialTerms))" flag="warning">[PEPPOL-T123-R007] Either ID or special terms need to be specified in Delivery terms</assert>
		<assert id="PEPPOL-T123-R008" test="(cbc:GrossWeightMeasure) or (cbc:GrossVolumeMeasure) or (cbc:LoadingLengthMeasure)" flag="warning">[PEPPOL-T123-R008] Either gross weight, gross volume or loading length must be specified</assert>
		<assert id="PEPPOL-T123-R010" test="not(cac:PaymentTerms) or cac:PaymentTerms/cbc:ID or cac:PaymentTerms/cbc:Note"	flag="warning">[PEPPOL-T123-R010] When Payment terms is specified, either the ID or the note must be specified</assert>
	</rule>
	
	<rule context="cac:Period">
		<assert id="PEPPOL-T123-R011" test="cbc:EndDate or cbc:StartDate" flag="fatal">[PEPPOL-T123-R011] Start date or end date must be spefied in a period</assert>
		<assert id="PEPPOL-T123-R012" test="not(cbc:EndDate) or translate(cbc:StartDate,'-','') &lt;= translate(cbc:EndDate,'-','')" flag="fatal">[PEPPOL-T123-R012] Start date must be earlier or equal to end date</assert>
		<assert id="PEPPOL-T123-R013" test="not(cbc:EndTime) or ((cbc:EndTime) and (cbc:StartTime)) or ((cbc:EndDate) and (cbc:EndTime) and not(cbc:StartDate) and not(cbc:StartTime))" flag="fatal">[PEPPOL-T123-R013] EndTime cannot be specified without StartTime</assert>
		<assert id="PEPPOL-T123-R014" test="not(cbc:EndTime) or (cbc:EndTime) and (cbc:EndDate)" flag="fatal">[PEPPOL-T123-R014] EndTime cannot be specified without EndDate</assert>
		<assert id="PEPPOL-T123-R015" test="not(cbc:StartDate) or not(cbc:StartTime) or not(cbc:EndDate) or not(cbc:EndTime) or dateTime((cbc:EndDate),(cbc:EndTime)) &gt;= dateTime((cbc:StartDate),(cbc:StartTime)) " flag="fatal">[PEPPOL-T123-R015] StartTime must be before EndTime</assert>
		<assert id="PEPPOL-T123-R016" test="not(cbc:StartTime) or count(timezone-from-time(cbc:StartTime)) &gt; 0" flag="fatal"> [PEPPOL-T123-R016] IssueTime MUST include timezone information.</assert>
		<assert id="PEPPOL-T123-R017" test="not(cbc:EndTime) or count(timezone-from-time(cbc:EndTime)) &gt; 0" flag="fatal"> [PEPPOL-T123-R017] IssueTime MUST include timezone information.</assert>
	</rule>

	<rule context="ubl:TransportExecutionPlanRequest/cbc:IssueTime">
		<assert id="PEPPOL-T123-R018" test="count(timezone-from-time(.)) &gt; 0" flag="fatal"> [PEPPOL-T123-R018] IssueTime MUST include timezone information.</assert>
	</rule>

	<rule context="ubl:TransportExecutionPlanRequest/cac:TransportUserParty">
		<assert id="PEPPOL-T123-R031" test="cac:PartyName or cac:PartyIdentification" flag="fatal"> [PEPPOL-T123-R031] Party must include either a party name or a party identification.</assert>
	</rule>
	<rule context="ubl:TransportExecutionPlanRequest/cac:TransportServiceProviderParty">
		<assert id="PEPPOL-T123-R032" test="cac:PartyName or cac:PartyIdentification" flag="fatal"> [PEPPOL-T123-R032] Party must include either a party name or a party identification.</assert>
	</rule>
	<rule context="ubl:TransportExecutionPlanRequest">
		<assert id="PEPPOL-T123-R021" test="not(cac:MainTransportationService/cbc:TransportServiceCode = ('4', '22', '23', '24')) 
				or cac:Consignment/cac:RequestedPickupTransportEvent or cac:Consignment/cac:RequestedDeliveryTransportEvent"	
				flag="fatal">[PEPPOL-T123-R021] At least one of Requested Pickup Transport Event or Requested Delivery Transport Event has to be specified for cac:MainTransportationService/cac:TransportServiceCode "4", "22", "23" and "24"</assert>
		<assert id="PEPPOL-T123-R033" test="not(cac:PayeeParty) or cac:PayeeParty/cac:PartyName or cac:PayeeParty/cac:PartyIdentification" flag="fatal"> [PEPPOL-T123-R033] Party must include either a party name or a party identification.</assert>
	</rule>
	<rule context="ubl:TransportExecutionPlanRequest/cac:Consignment/cac:ConsigneeParty">
		<assert id="PEPPOL-T123-R034" test="cac:PartyName or cac:PartyIdentification" flag="fatal"> [PEPPOL-T123-R034] Party must include either a party name or a party identification.</assert>
	</rule>
	<rule context="ubl:TransportExecutionPlanRequest/cac:Consignment/cac:ConsignorParty">
		<assert id="PEPPOL-T123-R035" test="cac:PartyName or cac:PartyIdentification" flag="fatal"> [PEPPOL-T123-R035] Party must include either a party name or a party identification.</assert>
	</rule>

</pattern>

