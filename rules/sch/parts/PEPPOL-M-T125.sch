<?xml version="1.0" encoding="UTF-8"?>
<pattern xmlns="http://purl.oclc.org/dsdl/schematron">
	<!-- Air service types (IATA SSIM), code list AirServiceTypeCode. Used as the type of
	     means of transport when the transport mode code is 4, air transport. -->
	<let name="clAirServiceTypeCode" value="tokenize('A B C D E F G H I J K L M N O P Q R S T U V W X', '\s')"/>

	<rule context="cbc:CustomizationID">
		<assert id="PEPPOL-T125-R001"
		  test="(normalize-space(.) = 'urn:fdc:peppol.eu:logistics:trns:waybill:1')"
		  flag="fatal">CustomizationID SHALL have the value 'urn:fdc:peppol.eu:logistics:trns:waybill:1'.</assert>
	</rule>
	<rule context="cbc:ProfileID">
		<assert id="PEPPOL-T125-R002"
		   test="(normalize-space(.) = 'urn:fdc:peppol.eu:logistics:bis:waybill_only:1')"
		  flag="fatal">ProfileID SHALL have the value 'urn:fdc:peppol.eu:logistics:bis:waybill_only:1'.</assert>
	</rule>
	
	<rule context="cac:Shipment/cac:Consignment">
		<assert id="PEPPOL-T125-R003" test="not(cbc:TotalTransportHandlingUnitQuantity) or number(cbc:TotalTransportHandlingUnitQuantity) &gt;= 0" flag="warning">[PEPPOL-T125-R003] Total transport handling unit quantity SHALL not be negative</assert>
		<assert id="PEPPOL-T125-R004" test="not(cbc:TotalTransportHandlingUnitQuantity) or not(cac:TransportHandlingUnit) or number(cbc:TotalTransportHandlingUnitQuantity) = count(cac:TransportHandlingUnit)" flag="warning">[PEPPOL-T125-R004] Shipment transport handling unit quantity SHALL match the number of the transport handling units specified</assert>
		<assert id="PEPPOL-T125-R005" test="not(cbc:GrossWeightMeasure) or not(cac:TransportHandlingUnit/cac:MeasurementDimension[normalize-space(cbc:AttributeID) = 'AAB']/cbc:Measure) or (cbc:GrossWeightMeasure/@unitCode) &gt; (cac:TransportHandlingUnit/cac:MeasurementDimension[normalize-space(cbc:AttributeID) = 'AAB']/cbc:Measure/@unitCode) or (cbc:GrossWeightMeasure/@unitCode) &lt; (cac:TransportHandlingUnit/cac:MeasurementDimension[normalize-space(cbc:AttributeID) = 'AAB']/cbc:Measure/@unitCode) or number(cbc:GrossWeightMeasure) = sum(cac:TransportHandlingUnit/cac:MeasurementDimension[normalize-space(cbc:AttributeID) = 'AAB']/cbc:Measure)" flag="warning">[PEPPOL-T125-R005] Shipment  gross weight measure SHALL match the gross weight of the transport handling units specified</assert>
		<let name="THUGrossVolume" value="round(sum(cac:TransportHandlingUnit/cac:MeasurementDimension[normalize-space(cbc:AttributeID) = 'AAW']/cbc:Measure) * 1000)"/>
		<assert id="PEPPOL-T125-R006"
		   test="not(cbc:GrossVolumeMeasure) or (cbc:GrossVolumeMeasure/@unitCode) &gt; (cac:TransportHandlingUnit/cac:MeasurementDimension[normalize-space(cbc:AttributeID) = 'AAW']/cbc:Measure/@unitCode) or (cbc:GrossVolumeMeasure/@unitCode) &lt; (cac:TransportHandlingUnit/cac:MeasurementDimension[normalize-space(cbc:AttributeID) = 'AAW']/cbc:Measure/@unitCode) or ((cbc:GrossVolumeMeasure)/xs:decimal(.) * 1000) &gt;= $THUGrossVolume" flag="warning">
			[PEPPOL-T125-R006] Gross Volume Measure value must be greater than or equal to the sum of the MeasurementDimension/Measure values with AttributeID 'AAW'.
		</assert>
		<assert id="PEPPOL-T125-R008" test="(cbc:GrossWeightMeasure) or (cbc:GrossVolumeMeasure) or (cbc:LoadingLengthMeasure)" flag="warning">[PEPPOL-T125-R008] Either gross weight, gross volume or loading length must be specified</assert>
		<assert id="PEPPOL-T125-R010" test ="not(cac:PaymentTerms) or cac:PaymentTerms/cbc:ID or cac:PaymentTerms/cbc:Note"	flag="warning">[PEPPOL-T125-R010] When Payment terms is specified, either the ID or the note must be specified</assert>			
	</rule>
	
	<rule context="cac:Shipment/Delivery">
		<assert id="PEPPOL-T125-R007" test="not(cac:DeliveryTerms) or (cac:DeliveryTerms/cbc:ID) or (cac:DeliveryTerms/cbc:SpecialTerms)" flag="fatal">[PEPPOL-T125-R007] Either ID or special terms need to be specified in Delivery terms</assert>
	</rule>

	<rule context="cac:EstimatedDeliveryPeriod">
		<assert id="PEPPOL-T125-R011" test="cbc:EndDate or cbc:StartDate" flag="fatal">[PEPPOL-T125-R011] Start date or end date must be spefied in a period</assert>
		<assert id="PEPPOL-T125-R012" test="not(cbc:EndDate) or translate(cbc:StartDate,'-','') &lt;= translate(cbc:EndDate,'-','')" flag="fatal">[PEPPOL-T125-R012] Start date must be earlier or equal to end date</assert>
		<assert id="PEPPOL-T125-R013" test="not(cbc:EndTime) or ((cbc:EndTime) and (cbc:StartTime)) or ((cbc:EndDate) and (cbc:EndTime) and not(cbc:StartDate) and not(cbc:StartTime))" flag="fatal">[PEPPOL-T125-R013] EndTime cannot be specified without StartTime</assert>
		<assert id="PEPPOL-T125-R014" test="not(cbc:EndTime) or (cbc:EndTime) and (cbc:EndDate)" flag="fatal">[PEPPOL-T125-R014] EndTime cannot be specified without EndDate</assert>
		<assert id="PEPPOL-T125-R015" test="not(cbc:StartDate) or not(cbc:StartTime) or not(cbc:EndDate) or not(cbc:EndTime) or dateTime((cbc:EndDate),(cbc:EndTime)) &gt;= dateTime((cbc:StartDate),(cbc:StartTime)) " flag="fatal">[PEPPOL-T125-R015] StartTime must be before EndTime</assert>
		<assert id="PEPPOL-T125-R016" test= "not(cbc:StartTime) or count(timezone-from-time(cbc:StartTime)) &gt; 0" flag="fatal">[PEPPOL-T125-R016] StartTime cannot be specified without timezone</assert>
		<assert id="PEPPOL-T125-R017" test= "not(cbc:EndTime) or count(timezone-from-time(cbc:EndTime)) &gt; 0" flag="fatal">[PEPPOL-T125-R017] EndTime cannot be specified without time zone</assert>
	</rule>

	<rule context="cac:EstimatedDespatchPeriod">
		<assert id="PEPPOL-T125-R021" test="cbc:EndDate or cbc:StartDate" flag="fatal">[PEPPOL-T125-R021] Start date or end date must be spefied in a period</assert>
		<assert id="PEPPOL-T125-R022" test="not(cbc:EndDate) or translate(cbc:StartDate,'-','') &lt;= translate(cbc:EndDate,'-','')" flag="fatal">[PEPPOL-T125-R022] Start date must be earlier or equal to end date</assert>
		<assert id="PEPPOL-T125-R023" test="not(cbc:EndTime) or ((cbc:EndTime) and (cbc:StartTime)) or ((cbc:EndDate) and (cbc:EndTime) and not(cbc:StartDate) and not(cbc:StartTime))" flag="fatal">[PEPPOL-T125-R023] EndTime cannot be specified without StartTime</assert>
		<assert id="PEPPOL-T125-R024" test="not(cbc:EndTime) or (cbc:EndTime) and (cbc:EndDate)" flag="fatal">[PEPPOL-T125-R024] EndTime cannot be specified without EndDate</assert>
		<assert id="PEPPOL-T125-R025" test="not(cbc:StartDate) or not(cbc:StartTime) or not(cbc:EndDate) or not(cbc:EndTime) or dateTime((cbc:EndDate),(cbc:EndTime)) &gt;= dateTime((cbc:StartDate),(cbc:StartTime)) " flag="fatal">[PEPPOL-T125-R025] StartTime must be before EndTime</assert>
		<assert id="PEPPOL-T125-R026" test= "not(cbc:StartTime) or count(timezone-from-time(cbc:StartTime)) &gt; 0" flag="fatal">[PEPPOL-T125-R026] StartTime cannot be specified without timezone</assert>
		<assert id="PEPPOL-T125-R027" test= "not(cbc:EndTime) or count(timezone-from-time(cbc:EndTime)) &gt; 0" flag="fatal">[PEPPOL-T125-R027] EndTime cannot be specified without time zone</assert>
	</rule>
	
	<rule context="cac:ShipmentStage">
		<assert id= "PEPPOL-T125-R050" test= "(cbc:TransportModeCode = 4 and cac:TransportMeans/cac:AirTransport/cbc:AircraftID) or (cbc:TransportModeCode = 3 and cac:TransportMeans/cac:RoadTransport/cbc:LicensePlateID) or (cbc:TransportModeCode = 2 and cac:TransportMeans/cac:RailTransport/cbc:TrainID) or (cbc:TransportModeCode = 1 and cac:TransportMeans/cac:MaritimeTransport/cbc:VesselID) or not(cac:TransportMeans)" flag="warning">[PEPPOL-T125-R050] Id for the transport means needs to be specified if Transport Means group is provided.</assert>
		<assert id= "PEPPOL-T125-R051" test= "not(cac:TransportMeans) or (count(cac:TransportMeans/cac:AirTransport) + count(cac:TransportMeans/cac:RoadTransport) + count(cac:TransportMeans/cac:RailTransport) + count(cac:TransportMeans/cac:MaritimeTransport) = 1)" flag="warning">[PEPPOL-T125-R051] Only one type of transport means can be specified</assert>
		<assert id="PEPPOL-T125-R052" test="not(normalize-space(cbc:TransportModeCode) = '4') or not(cbc:TransportMeansTypeCode) or (every $type in cbc:TransportMeansTypeCode satisfies (some $code in $clAirServiceTypeCode satisfies $code = normalize-space($type)))" flag="fatal">[PEPPOL-T125-R052] For air transport, transport mode code 4, the transport means type code MUST be an air service type code, for example 'J' for a passenger flight carrying cargo or 'F' for a freighter.</assert>
		<assert id="PEPPOL-T125-R053" test="normalize-space(cbc:TransportModeCode) = '4' or not(cbc:TransportMeansTypeCode) or (every $type in cbc:TransportMeansTypeCode satisfies not(some $code in $clAirServiceTypeCode satisfies $code = normalize-space($type)))" flag="fatal">[PEPPOL-T125-R053] An air service type code MUST only be used as transport means type code when the transport mode code is 4, air transport.</assert>
	</rule>
	
	<rule context="ubl:Waybill">
		<assert id= "PEPPOL-T125-R018" test= "count(timezone-from-time(cbc:IssueTime)) &gt; 0" flag="fatal">IssueTime cannot be specified without time zone. </assert>
		<assert id= "PEPPOL-T125-R040" test= "not(cbc:Name = 'CMR') or cac:Shipment/cac:Consignment/cbc:GrossWeightMeasure" flag="fatal"> [PEPPOL-T125-R040] In a Waybill the grossweight needs to be speficied. </assert>
		<assert id= "PEPPOL-T125-R033" test="not(cac:FreightForwarderParty) or cac:FreightForwarderParty/cac:PartyName or cac:FreightForwarderParty/cac:PartyIdentification" flag="fatal"> [PEPPOL-T125-R033] Party must include either a party name or a party identification.</assert>
	</rule>

	<rule context="ubl:Waybill/cac:ConsignorParty">
		<assert id="PEPPOL-T125-R031" test="cac:PartyName or cac:PartyIdentification" flag="fatal">[PEPPOL-T125-R031] Party must include either a party name or a party identification.</assert>
	</rule>
	
	<rule context="ubl:Waybill/cac:CarrierParty">
		<assert id="PEPPOL-T125-R032" test="cac:PartyName or cac:PartyIdentification" flag="fatal">[PEPPOL-T125-R032] Party must include either a party name or a party identification.</assert>
	</rule>
	
	<rule context="ubl:Waybill/cac:Shipment/cac:Consignment/cac:ConsigneeParty">
		<assert id="PEPPOL-T125-R034" test="cac:PartyName or cac:PartyIdentification" flag="fatal">[PEPPOL-T125-R034] Party must include either a party name or a party identification.</assert>
	</rule>
	

	<rule context="cac:MainCarriageShipmentStage">
		<assert id="PEPPOL-T125-R052" test="not(normalize-space(cbc:TransportModeCode) = '4') or not(cbc:TransportMeansTypeCode) or (every $type in cbc:TransportMeansTypeCode satisfies (some $code in $clAirServiceTypeCode satisfies $code = normalize-space($type)))" flag="fatal">[PEPPOL-T125-R052] For air transport, transport mode code 4, the transport means type code MUST be an air service type code, for example 'J' for a passenger flight carrying cargo or 'F' for a freighter.</assert>
		<assert id="PEPPOL-T125-R053" test="normalize-space(cbc:TransportModeCode) = '4' or not(cbc:TransportMeansTypeCode) or (every $type in cbc:TransportMeansTypeCode satisfies not(some $code in $clAirServiceTypeCode satisfies $code = normalize-space($type)))" flag="fatal">[PEPPOL-T125-R053] An air service type code MUST only be used as transport means type code when the transport mode code is 4, air transport.</assert>
	</rule>

</pattern>

