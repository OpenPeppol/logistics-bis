<schema xmlns="http://purl.oclc.org/dsdl/schematron"
        xmlns:u="utils"
        xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
        xmlns:xi="http://www.w3.org/2001/XInclude"
        schemaVersion="iso"
        queryBinding="xslt2">

    <title>Rules for Manifest</title>

	  <ns uri="urn:oasis:names:specification:ubl:schema:xsd:CommonBasicComponents-2"
       prefix="cbc"/>
    <ns uri="urn:oasis:names:specification:ubl:schema:xsd:CommonAggregateComponents-2"
       prefix="cac"/>
    <ns uri="urn:oasis:names:specification:ubl:schema:xsd:Manifest-2"
       prefix="ubl"/>
    <ns uri="http://www.w3.org/2001/XMLSchema" prefix="xs"/>
    <ns uri="utils" prefix="u"/>
    
    

    <function xmlns="http://www.w3.org/1999/XSL/Transform"
             name="u:gln"
             as="xs:boolean">
      <param name="val"/>
      <variable name="length" select="string-length($val) - 1"/>
      <variable name="digits"
                select="reverse(for $i in string-to-codepoints(substring($val, 0, $length + 1)) return $i - 48)"/>
      <variable name="weightedSum"
                select="sum(for $i in (0 to $length - 1) return $digits[$i + 1] * (1 + ((($i + 1) mod 2) * 2)))"/>
      <sequence select="(10 - ($weightedSum mod 10)) mod 10 = number(substring($val, $length + 1, 1))"/>
   </function>
    <function xmlns="http://www.w3.org/1999/XSL/Transform"
             name="u:mod11"
             as="xs:boolean">
      <param name="val"/>
      <variable name="length" select="string-length($val) - 1"/>
      <variable name="digits"
                select="reverse(for $i in string-to-codepoints(substring($val, 0, $length + 1)) return $i - 48)"/>
      <variable name="weightedSum"
                select="sum(for $i in (0 to $length - 1) return $digits[$i + 1] * (($i mod 6) + 2))"/>
      <sequence select="number($val) &gt; 0 and (11 - ($weightedSum mod 11)) mod 11 = number(substring($val, $length + 1, 1))"/>
   </function>
	  <function xmlns="http://www.w3.org/1999/XSL/Transform"
             name="u:checkCodiceIPA"
             as="xs:boolean">
      <param name="arg" as="xs:string?"/>
      <variable name="allowed-characters">ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789</variable>
      <sequence select="if ( (string-length(translate($arg, $allowed-characters, '')) = 0) and (string-length($arg) = 6) ) then true() else false()"/>
  </function>
	  <function xmlns="http://www.w3.org/1999/XSL/Transform"
             name="u:addPIVA"
             as="xs:integer">
      <param name="arg" as="xs:string"/>
      <param name="pari" as="xs:integer"/>
      <variable name="tappo"
                select="if (not($arg castable as xs:integer)) then 0 else 1"/>
      <variable name="mapper"
                select="if ($tappo = 0) then 0 else                    ( if ($pari = 1)                     then ( xs:integer(substring('0246813579', ( xs:integer(substring($arg,1,1)) +1 ) ,1)) )                     else ( xs:integer(substring($arg,1,1) ) )                   )"/>
      <sequence select="if ($tappo = 0) then $mapper else ( xs:integer($mapper) + u:addPIVA(substring(xs:string($arg),2), (if($pari=0) then 1 else 0) ) )"/>
  </function>
	  <function xmlns="http://www.w3.org/1999/XSL/Transform"
             name="u:checkCF"
             as="xs:boolean">
      <param name="arg" as="xs:string?"/>
      <sequence select="   if ( (string-length($arg) = 16) or (string-length($arg) = 11) )      then    (    if ((string-length($arg) = 16))     then    (     if (u:checkCF16($arg))      then     (      true()     )     else     (      false()     )    )    else    (     if(($arg castable as xs:integer)) then true() else false()       )   )   else   (    false()   )   "/>
  </function>
	  <function xmlns="http://www.w3.org/1999/XSL/Transform"
             name="u:checkCF16"
             as="xs:boolean">
      <param name="arg" as="xs:string?"/>
      <variable name="allowed-characters">ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz</variable>
      <sequence select="     if (  (string-length(translate(substring($arg,1,6), $allowed-characters, '')) = 0) and         (substring($arg,7,2) castable as xs:integer) and        (string-length(translate(substring($arg,9,1), $allowed-characters, '')) = 0) and        (substring($arg,10,2) castable as xs:integer) and         (substring($arg,12,3) castable as xs:string) and        (substring($arg,15,1) castable as xs:integer) and         (string-length(translate(substring($arg,16,1), $allowed-characters, '')) = 0)      )      then true()     else false()     "/>
  </function>
	  <function xmlns="http://www.w3.org/1999/XSL/Transform"
             name="u:checkPIVA"
             as="xs:integer">
      <param name="arg" as="xs:string?"/>
      <sequence select="     if (not($arg castable as xs:integer))       then 1      else ( u:addPIVA($arg,xs:integer(0)) mod 10 )"/>
  </function>
	  <function xmlns="http://www.w3.org/1999/XSL/Transform"
             name="u:checkPIVAseIT"
             as="xs:boolean">
      <param name="arg" as="xs:string"/>
      <variable name="paese" select="substring($arg,1,2)"/>
      <variable name="codice" select="substring($arg,3)"/>
      <sequence select="       if ( $paese = 'IT' or $paese = 'it' )    then    (     if ( ( string-length($codice) = 11 ) and ( if (u:checkPIVA($codice)!=0) then false() else true() ))     then      (      true()     )     else     (      false()     )    )    else    (     true()    )      "/>
  </function>
	  <function xmlns="http://www.w3.org/1999/XSL/Transform"
             name="u:mod97-0208"
             as="xs:boolean">
      <param name="val"/>
      <variable name="checkdigits" select="substring($val,9,2)"/>
      <variable name="calculated_digits"
                select="xs:string(97 - (xs:integer(substring($val,1,8)) mod 97))"/>
      <sequence select="number($checkdigits) = number($calculated_digits)"/>
  </function>
	  <function xmlns="http://www.w3.org/1999/XSL/Transform"
             name="u:abn"
             as="xs:boolean">
      <param name="val"/>
      <sequence select="( ((string-to-codepoints(substring($val,1,1)) - 49) * 10) + ((string-to-codepoints(substring($val,2,1)) - 48) * 1) + ((string-to-codepoints(substring($val,3,1)) - 48) * 3) + ((string-to-codepoints(substring($val,4,1)) - 48) * 5) + ((string-to-codepoints(substring($val,5,1)) - 48) * 7) + ((string-to-codepoints(substring($val,6,1)) - 48) * 9) + ((string-to-codepoints(substring($val,7,1)) - 48) * 11) + ((string-to-codepoints(substring($val,8,1)) - 48) * 13) + ((string-to-codepoints(substring($val,9,1)) - 48) * 15) + ((string-to-codepoints(substring($val,10,1)) - 48) * 17) + ((string-to-codepoints(substring($val,11,1)) - 48) * 19)) mod 89 = 0 "/>
   </function>
    <function xmlns="http://www.w3.org/1999/XSL/Transform"
             name="u:checkSEOrgnr"
             as="xs:boolean">
	
	     <param name="number" as="xs:string"/>
	     <choose>
		
		       <when test="not(matches($number, '^\d+$'))">
			         <sequence select="false()"/>
		       </when>
		       <otherwise>
			
			         <variable name="mainPart" select="substring($number, 1, 9)"/>
			         <variable name="checkDigit" select="substring($number, 10, 1)"/>
			         <variable name="sum" as="xs:integer">
			            <sequence select="xs:integer(sum(       for $pos in 1 to string-length($mainPart) return         if ($pos mod 2 = 1)         then (number(substring($mainPart, string-length($mainPart) - $pos + 1, 1)) * 2) mod 10 +           (number(substring($mainPart, string-length($mainPart) - $pos + 1, 1)) * 2) idiv 10         else number(substring($mainPart, string-length($mainPart) - $pos + 1, 1))      ))"/>
			         </variable>
			         <variable name="calculatedCheckDigit" select="(10 - $sum mod 10) mod 10"/>
			         <sequence select="$calculatedCheckDigit = number($checkDigit)"/>
		       </otherwise>
	     </choose>
   </function>
    <function xmlns="http://www.w3.org/1999/XSL/Transform"
             name="u:check-lux-0240"
             as="xs:boolean">
      <param name="val" as="xs:string"/>
      <choose>
         <when test="not(matches($val, '^[0-9]{11}$'))">
            <sequence select="false()"/>
         </when>
         <otherwise>
            <variable name="typecode" select="xs:integer(substring($val, 5, 2))"/>
            <choose>
               <when test="not($typecode ge 20 and $typecode le 99)">
                  <sequence select="false()"/>
               </when>
               <otherwise>
                  <variable name="digits"
                            select="for $c in string-to-codepoints($val) return $c - 48"/>
                  <variable name="weights" select="(5, 4, 3, 2, 7, 6, 5, 4, 3, 2)"/>
                  <variable name="wsum"
                            select="sum(for $i in 1 to 10 return $digits[$i] * $weights[$i])"/>
                  <variable name="remainder" select="$wsum mod 11"/>
                  <variable name="exp11" select="if ($remainder = 0) then 0 else 11 - $remainder"/>
                  <variable name="exp12"
                            select="if ($remainder = 0) then 1 else if ($remainder = 1) then 0 else 12 - $remainder"/>
                  <variable name="checkdigit" select="$digits[11]"/>
                  <variable name="valid"
                            select="if ($typecode = 24) then ($checkdigit = $exp11 or $checkdigit = $exp12) else $checkdigit = $exp11"/>
                  <sequence select="$valid"/>
               </otherwise>
            </choose>
         </otherwise>
      </choose>
   </function>
    <function xmlns="http://www.w3.org/1999/XSL/Transform"
             name="u:mod89-LU_VAT"
             as="xs:boolean">
      <param name="val" as="xs:string"/>
      <variable name="normalized" select="upper-case(normalize-space($val))"/>
      <variable name="base" select="substring($normalized, 3, 6)"/>
      <variable name="checkdigits" select="substring($normalized, 9, 2)"/>
      <variable name="calculated"
                select="format-integer(xs:integer($base) mod 89, '00')"/>
      <sequence select="$checkdigits = $calculated"/>
  </function>
    

    <pattern>
 
		    <rule context="//*[not(*) and not(normalize-space())]">
			      <assert id="PEPPOL-COMMON-R001" test="false()" flag="fatal">[PEPPOL-COMMON-R001]-Document MUST not contain empty elements.</assert>
		    </rule> 
   
   </pattern>
    <pattern>

      <rule context="/*">
        <assert id="PEPPOL-COMMON-R003"
                 test="not(@*:schemaLocation)"
                 flag="warning">[PEPPOL-COMMON-R003]-Document SHOULD not contain schema location.</assert>

      </rule>

      <rule context="cbc:IssueDate | cbc:DueDate | cbc:TaxPointDate | cbc:StartDate | cbc:EndDate | cbc:ActualDeliveryDate">
        <assert id="PEPPOL-COMMON-R030"
                 test="(string(.) castable as xs:date) and (string-length(.) = 10)"
                 flag="fatal">[PEPPOL-COMMON-R030]-A date must be formatted YYYY-MM-DD.</assert>
      </rule>

    
      <rule context="cbc:EndpointID[@schemeID = '0088'] | cac:PartyIdentification/cbc:ID[@schemeID = '0088'] | cbc:CompanyID[@schemeID = '0088']">
         <assert id="PEPPOL-COMMON-R040"
                 test="matches(normalize-space(), '^[0-9]{13}$') and u:gln(normalize-space())"
                 flag="fatal">[PEPPOL-COMMON-R040]-GLN13
        must have a valid format according to GS1 rules.</assert>
      </rule>
      <rule context="cbc:EndpointID[@schemeID = '0192'] | cac:PartyIdentification/cbc:ID[@schemeID = '0192'] | cbc:CompanyID[@schemeID = '0192']">
         <assert id="PEPPOL-COMMON-R041"
                 test="matches(normalize-space(), '^[0-9]{9}$') and u:mod11(normalize-space())"
                 flag="fatal">[PEPPOL-COMMON-R041]-Norwegian organization number MUST be stated in the correct format.</assert>
      </rule>
      <rule context="cbc:EndpointID[@schemeID = '0184'] | cac:PartyIdentification/cbc:ID[@schemeID = '0184'] | cbc:CompanyID[@schemeID = '0184']">
         <assert id="PEPPOL-COMMON-R042"
                 test="(string-length(string()) = 10 and substring(string(), 1, 2) = 'DK' and string-length(translate(substring(string(), 3, 8), '1234567890', '')) = 0)                or               (string-length(string()) = 8) and (string-length(translate(substring(string(), 1, 8),'1234567890', '')) = 0)"
                 flag="fatal">[PEPPOL-COMMON-R042]-Danish organization number (CVR) MUST be stated in the correct format.</assert>
      </rule>
      <rule context="cbc:EndpointID[@schemeID = '0096'] | cac:PartyIdentification/cbc:ID[@schemeID = '0096'] | cbc:CompanyID[@schemeID = '0096']">
         <assert id="PEPPOL-COMMON-R052"
                 test="(string-length(string()) = 10) and (string-length(translate(substring(string(), 1, 10),'1234567890', '')) = 0)"
                 flag="fatal">[PEPPOL-COMMON-R052]-Danish chamber of commerce number (P) MUST be stated in the correct format.</assert>
      </rule>
      <rule context="cbc:EndpointID[@schemeID = '0198'] | cac:PartyIdentification/cbc:ID[@schemeID = '0198'] | cbc:CompanyID[@schemeID = '0198']">
         <assert id="PEPPOL-COMMON-R053"
                 test="(string-length(string()) = 10 and substring(string(), 1, 2) = 'DK' and string-length(translate(substring(string(), 3, 8), '1234567890', '')) = 0)"
                 flag="fatal">[PEPPOL-COMMON-R053]-Danish ERSTORG number (SE) MUST be stated in the correct format.</assert>
      </rule>
      <rule context="cbc:EndpointID[@schemeID = '0208'] | cac:PartyIdentification/cbc:ID[@schemeID = '0208'] | cbc:CompanyID[@schemeID = '0208']">
         <assert id="PEPPOL-COMMON-R043"
                 test="matches(normalize-space(), '^[0-9]{10}$') and u:mod97-0208(normalize-space())"
                 flag="fatal">[PEPPOL-COMMON-R043]-Belgian enterprise number MUST be stated in the correct format.</assert>
      </rule>
      <rule context="cbc:EndpointID[@schemeID = '0201'] | cac:PartyIdentification/cbc:ID[@schemeID = '0201'] | cbc:CompanyID[@schemeID = '0201']">
         <assert id="PEPPOL-COMMON-R044"
                 test="u:checkCodiceIPA(normalize-space())"
                 flag="warning">[PEPPOL-COMMON-R044]-IPA Code (Codice Univoco Unità Organizzativa) SHOULD be stated in the correct format</assert>
      </rule>
      <rule context="cbc:EndpointID[@schemeID = '0210'] | cac:PartyIdentification/cbc:ID[@schemeID = '0210'] | cbc:CompanyID[@schemeID = '0210']">
         <assert id="PEPPOL-COMMON-R045"
                 test="u:checkCF(normalize-space())"
                 flag="warning">[PEPPOL-COMMON-R045]-Tax Code (Codice Fiscale) SHOULD be stated in the correct format</assert>
      </rule>
      <rule context="cbc:EndpointID[@schemeID = '9907']">
         <assert id="PEPPOL-COMMON-R046"
                 test="u:checkCF(normalize-space())"
                 flag="warning">[PEPPOL-COMMON-R046]-Tax Code (Codice Fiscale) SHOULD be stated in the correct format</assert>
      </rule>
      <rule context="cbc:EndpointID[@schemeID = '0211'] | cac:PartyIdentification/cbc:ID[@schemeID = '0211'] | cbc:CompanyID[@schemeID = '0211']">
         <assert id="PEPPOL-COMMON-R047"
                 test="u:checkPIVAseIT(normalize-space())"
                 flag="warning">[PEPPOL-COMMON-R047]-Italian VAT Code (Partita Iva) SHOULD be stated in the correct format</assert>
      </rule>
    
      <rule context="cbc:EndpointID[@schemeID = '0007'] | cac:PartyIdentification/cbc:ID[@schemeID = '0007'] | cbc:CompanyID[@schemeID = '0007']">
         <assert id="PEPPOL-COMMON-R049"
                 test="string-length(normalize-space()) = 10 and string(number(normalize-space())) != 'NaN' and u:checkSEOrgnr(normalize-space())"
                 flag="fatal">[PEPPOL-COMMON-R049]-Swedish organization number MUST be stated in the correct format.</assert>
      </rule>
      <rule context="cbc:EndpointID[@schemeID = '0151'] | cac:PartyIdentification/cbc:ID[@schemeID = '0151'] | cbc:CompanyID[@schemeID = '0151']">
         <assert id="PEPPOL-COMMON-R050"
                 test="matches(normalize-space(), '^[0-9]{11}$') and u:abn(normalize-space())"
                 flag="fatal">[PEPPOL-COMMON-R050]-Australian Business Number (ABN) MUST be stated in the correct format.</assert>
      </rule>
        <rule context="cbc:EndpointID[@schemeID = '0106'] | cac:PartyIdentification/cbc:ID[@schemeID = '0106'] | cbc:CompanyID[@schemeID = '0106']">
         <assert id="PEPPOL-COMMON-R054"
                 test="matches(normalize-space(), '^[0-9]{8}$')"
                 flag="fatal">[PEPPOL-COMMON-R054]-Dutch Chamber of Commerce (KVK) numbers (0106) MUST be stated in the correct format (12345678).</assert>
      </rule>
      <rule context="cbc:EndpointID[@schemeID = '0190'] | cac:PartyIdentification/cbc:ID[@schemeID = '0190'] | cbc:CompanyID[@schemeID = '0190']">
         <assert id="PEPPOL-COMMON-R055"
                 test="matches(normalize-space(), '^[0-9]{20}$')"
                 flag="fatal">[PEPPOL-COMMON-R055]-Dutch organization identification numbers (0190) MUST be stated in the correct format (12345678901234567890).</assert>
      </rule>
      <rule context="cbc:EndpointID[@schemeID = '9944'] | cac:PartyIdentification/cbc:ID[@schemeID = '9944'] | cbc:CompanyID[@schemeID = '9944']">
         <assert id="PEPPOL-COMMON-R056-1"
                 test="matches(normalize-space(), '^NL[0-9]{9}B[0-9]{2}$')"
                 flag="fatal">[PEPPOL-COMMON-R056-1]-Dutch VAT numbers (9944) MUST be stated in the correct format (NL123456789B12).</assert>
      </rule>
    
      <rule context="cac:PartyTaxScheme                    [normalize-space(cac:TaxScheme/cbc:ID) = 'VAT']                    /cbc:CompanyID                    [starts-with(normalize-space(.), 'NL')]">
         <assert id="PEPPOL-COMMON-R056-2"
                 test="matches(normalize-space(.), '^NL[0-9]{9}B[0-9]{2}$')"
                 flag="fatal">[PEPPOL-COMMON-R056-2]-Dutch VAT numbers MUST have the format (NL123456789B12).</assert>
      </rule>
      <rule context="cbc:EndpointID[@schemeID = '0217'] | cac:PartyIdentification/cbc:ID[@schemeID = '0217'] | cbc:CompanyID[@schemeID = '0217']">
         <assert id="PEPPOL-COMMON-R057"
                 test="matches(normalize-space(), '^[0-9]{12}$')"
                 flag="fatal">[PEPPOL-COMMON-R057]-Dutch Chamber of Commerce Establishment numbers (0217) MUST be stated in the correct format (123456789012).</assert>
      </rule>
    
      <rule context="cbc:EndpointID[@schemeID = '0240'] | cac:PartyIdentification/cbc:ID[@schemeID = '0240'] | cbc:CompanyID[@schemeID = '0240']">
         <assert id="PEPPOL-COMMON-R059"
                 test="u:check-lux-0240(normalize-space(.))"
                 flag="warning">[PEPPOL-COMMON-R059]-Luxembourg Register of Legal Persons number (Matricule) MUST be stated in the correct format.</assert>
      </rule>
    
      <rule context="cac:PartyTaxScheme                    [normalize-space(cac:TaxScheme/cbc:ID) = 'VAT']                    /cbc:CompanyID                    [starts-with(upper-case(normalize-space(.)), 'LU')]">
         <assert id="PEPPOL-COMMON-R058"
                 flag="warning"
                 test="matches(upper-case(normalize-space(.)), '^LU[0-9]{8}$') and u:mod89-LU_VAT(.)">
        [PEPPOL-COMMON-R058]-Luxembourg VAT number MUST be stated in the correct format.
      </assert>	
	     </rule>
   </pattern>
    
    <pattern>
	
	     <let name="clAirServiceTypeCode"
           value="tokenize('J S G B Q R L F A H V', '\s')"/>

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
		       <assert id="PEPPOL-T125-R003"
                 test="not(cbc:TotalTransportHandlingUnitQuantity) or number(cbc:TotalTransportHandlingUnitQuantity) &gt;= 0"
                 flag="warning">[PEPPOL-T125-R003] Total transport handling unit quantity SHALL not be negative</assert>
		       <assert id="PEPPOL-T125-R004"
                 test="not(cbc:TotalTransportHandlingUnitQuantity) or not(cac:TransportHandlingUnit) or number(cbc:TotalTransportHandlingUnitQuantity) = count(cac:TransportHandlingUnit)"
                 flag="warning">[PEPPOL-T125-R004] Shipment transport handling unit quantity SHALL match the number of the transport handling units specified</assert>
		       <assert id="PEPPOL-T125-R005"
                 test="not(cbc:GrossWeightMeasure) or not(cac:TransportHandlingUnit/cac:MeasurementDimension[normalize-space(cbc:AttributeID) = 'AAB']/cbc:Measure) or (cbc:GrossWeightMeasure/@unitCode) &gt; (cac:TransportHandlingUnit/cac:MeasurementDimension[normalize-space(cbc:AttributeID) = 'AAB']/cbc:Measure/@unitCode) or (cbc:GrossWeightMeasure/@unitCode) &lt; (cac:TransportHandlingUnit/cac:MeasurementDimension[normalize-space(cbc:AttributeID) = 'AAB']/cbc:Measure/@unitCode) or number(cbc:GrossWeightMeasure) = sum(cac:TransportHandlingUnit/cac:MeasurementDimension[normalize-space(cbc:AttributeID) = 'AAB']/cbc:Measure)"
                 flag="warning">[PEPPOL-T125-R005] Shipment  gross weight measure SHALL match the gross weight of the transport handling units specified</assert>
		       <let name="THUGrossVolume"
              value="round(sum(cac:TransportHandlingUnit/cac:MeasurementDimension[normalize-space(cbc:AttributeID) = 'AAW']/cbc:Measure) * 1000)"/>
		       <assert id="PEPPOL-T125-R006"
                 test="not(cbc:GrossVolumeMeasure) or (cbc:GrossVolumeMeasure/@unitCode) &gt; (cac:TransportHandlingUnit/cac:MeasurementDimension[normalize-space(cbc:AttributeID) = 'AAW']/cbc:Measure/@unitCode) or (cbc:GrossVolumeMeasure/@unitCode) &lt; (cac:TransportHandlingUnit/cac:MeasurementDimension[normalize-space(cbc:AttributeID) = 'AAW']/cbc:Measure/@unitCode) or ((cbc:GrossVolumeMeasure)/xs:decimal(.) * 1000) &gt;= $THUGrossVolume"
                 flag="warning">
			[PEPPOL-T125-R006] Gross Volume Measure value must be greater than or equal to the sum of the MeasurementDimension/Measure values with AttributeID 'AAW'.
		</assert>
		       <assert id="PEPPOL-T125-R008"
                 test="(cbc:GrossWeightMeasure) or (cbc:GrossVolumeMeasure) or (cbc:LoadingLengthMeasure)"
                 flag="warning">[PEPPOL-T125-R008] Either gross weight, gross volume or loading length must be specified</assert>
		       <assert id="PEPPOL-T125-R010"
                 test="not(cac:PaymentTerms) or cac:PaymentTerms/cbc:ID or cac:PaymentTerms/cbc:Note"
                 flag="warning">[PEPPOL-T125-R010] When Payment terms is specified, either the ID or the note must be specified</assert>			
	     </rule>
	
	     <rule context="cac:Shipment/Delivery">
		       <assert id="PEPPOL-T125-R007"
                 test="not(cac:DeliveryTerms) or (cac:DeliveryTerms/cbc:ID) or (cac:DeliveryTerms/cbc:SpecialTerms)"
                 flag="fatal">[PEPPOL-T125-R007] Either ID or special terms need to be specified in Delivery terms</assert>
	     </rule>

	     <rule context="cac:EstimatedDeliveryPeriod">
		       <assert id="PEPPOL-T125-R011"
                 test="cbc:EndDate or cbc:StartDate"
                 flag="fatal">[PEPPOL-T125-R011] Start date or end date must be spefied in a period</assert>
		       <assert id="PEPPOL-T125-R012"
                 test="not(cbc:EndDate) or translate(cbc:StartDate,'-','') &lt;= translate(cbc:EndDate,'-','')"
                 flag="fatal">[PEPPOL-T125-R012] Start date must be earlier or equal to end date</assert>
		       <assert id="PEPPOL-T125-R013"
                 test="not(cbc:EndTime) or ((cbc:EndTime) and (cbc:StartTime)) or ((cbc:EndDate) and (cbc:EndTime) and not(cbc:StartDate) and not(cbc:StartTime))"
                 flag="fatal">[PEPPOL-T125-R013] EndTime cannot be specified without StartTime</assert>
		       <assert id="PEPPOL-T125-R014"
                 test="not(cbc:EndTime) or (cbc:EndTime) and (cbc:EndDate)"
                 flag="fatal">[PEPPOL-T125-R014] EndTime cannot be specified without EndDate</assert>
		       <assert id="PEPPOL-T125-R015"
                 test="not(cbc:StartDate) or not(cbc:StartTime) or not(cbc:EndDate) or not(cbc:EndTime) or dateTime((cbc:EndDate),(cbc:EndTime)) &gt;= dateTime((cbc:StartDate),(cbc:StartTime)) "
                 flag="fatal">[PEPPOL-T125-R015] StartTime must be before EndTime</assert>
		       <assert id="PEPPOL-T125-R016"
                 test="not(cbc:StartTime) or count(timezone-from-time(cbc:StartTime)) &gt; 0"
                 flag="fatal">[PEPPOL-T125-R016] StartTime cannot be specified without timezone</assert>
		       <assert id="PEPPOL-T125-R017"
                 test="not(cbc:EndTime) or count(timezone-from-time(cbc:EndTime)) &gt; 0"
                 flag="fatal">[PEPPOL-T125-R017] EndTime cannot be specified without time zone</assert>
	     </rule>

	     <rule context="cac:EstimatedDespatchPeriod">
		       <assert id="PEPPOL-T125-R021"
                 test="cbc:EndDate or cbc:StartDate"
                 flag="fatal">[PEPPOL-T125-R021] Start date or end date must be spefied in a period</assert>
		       <assert id="PEPPOL-T125-R022"
                 test="not(cbc:EndDate) or translate(cbc:StartDate,'-','') &lt;= translate(cbc:EndDate,'-','')"
                 flag="fatal">[PEPPOL-T125-R022] Start date must be earlier or equal to end date</assert>
		       <assert id="PEPPOL-T125-R023"
                 test="not(cbc:EndTime) or ((cbc:EndTime) and (cbc:StartTime)) or ((cbc:EndDate) and (cbc:EndTime) and not(cbc:StartDate) and not(cbc:StartTime))"
                 flag="fatal">[PEPPOL-T125-R023] EndTime cannot be specified without StartTime</assert>
		       <assert id="PEPPOL-T125-R024"
                 test="not(cbc:EndTime) or (cbc:EndTime) and (cbc:EndDate)"
                 flag="fatal">[PEPPOL-T125-R024] EndTime cannot be specified without EndDate</assert>
		       <assert id="PEPPOL-T125-R025"
                 test="not(cbc:StartDate) or not(cbc:StartTime) or not(cbc:EndDate) or not(cbc:EndTime) or dateTime((cbc:EndDate),(cbc:EndTime)) &gt;= dateTime((cbc:StartDate),(cbc:StartTime)) "
                 flag="fatal">[PEPPOL-T125-R025] StartTime must be before EndTime</assert>
		       <assert id="PEPPOL-T125-R026"
                 test="not(cbc:StartTime) or count(timezone-from-time(cbc:StartTime)) &gt; 0"
                 flag="fatal">[PEPPOL-T125-R026] StartTime cannot be specified without timezone</assert>
		       <assert id="PEPPOL-T125-R027"
                 test="not(cbc:EndTime) or count(timezone-from-time(cbc:EndTime)) &gt; 0"
                 flag="fatal">[PEPPOL-T125-R027] EndTime cannot be specified without time zone</assert>
	     </rule>
	
	     <rule context="cac:ShipmentStage">
		       <assert id="PEPPOL-T125-R050"
                 test="(cbc:TransportModeCode = 4 and cac:TransportMeans/cac:AirTransport/cbc:AircraftID) or (cbc:TransportModeCode = 3 and cac:TransportMeans/cac:RoadTransport/cbc:LicensePlateID) or (cbc:TransportModeCode = 2 and cac:TransportMeans/cac:RailTransport/cbc:TrainID) or (cbc:TransportModeCode = 1 and cac:TransportMeans/cac:MaritimeTransport/cbc:VesselID) or not(cac:TransportMeans)"
                 flag="warning">[PEPPOL-T125-R050] Id for the transport means needs to be specified if Transport Means group is provided.</assert>
		       <assert id="PEPPOL-T125-R051"
                 test="not(cac:TransportMeans) or (count(cac:TransportMeans/cac:AirTransport) + count(cac:TransportMeans/cac:RoadTransport) + count(cac:TransportMeans/cac:RailTransport) + count(cac:TransportMeans/cac:MaritimeTransport) = 1)"
                 flag="warning">[PEPPOL-T125-R051] Only one type of transport means can be specified</assert>
		       <assert id="PEPPOL-T125-R052"
                 test="not(normalize-space(cbc:TransportModeCode) = '4') or not(cbc:TransportMeansTypeCode) or (every $type in cbc:TransportMeansTypeCode satisfies (some $code in $clAirServiceTypeCode satisfies $code = normalize-space($type)))"
                 flag="fatal">[PEPPOL-T125-R052] For air transport, transport mode code 4, the transport means type code MUST be an air service type code, for example 'J' for a passenger flight carrying cargo or 'F' for a freighter.</assert>
		       <assert id="PEPPOL-T125-R053"
                 test="normalize-space(cbc:TransportModeCode) = '4' or not(cbc:TransportMeansTypeCode) or (every $type in cbc:TransportMeansTypeCode satisfies not(some $code in $clAirServiceTypeCode satisfies $code = normalize-space($type)))"
                 flag="fatal">[PEPPOL-T125-R053] An air service type code MUST only be used as transport means type code when the transport mode code is 4, air transport.</assert>
	     </rule>
	
	     <rule context="ubl:Waybill">
		       <assert id="PEPPOL-T125-R018"
                 test="count(timezone-from-time(cbc:IssueTime)) &gt; 0"
                 flag="fatal">IssueTime cannot be specified without time zone. </assert>
		       <assert id="PEPPOL-T125-R040"
                 test="not(cbc:Name = 'CMR') or cac:Shipment/cac:Consignment/cbc:GrossWeightMeasure"
                 flag="fatal"> [PEPPOL-T125-R040] In a Waybill the grossweight needs to be speficied. </assert>
		       <assert id="PEPPOL-T125-R033"
                 test="not(cac:FreightForwarderParty) or cac:FreightForwarderParty/cac:PartyName or cac:FreightForwarderParty/cac:PartyIdentification"
                 flag="fatal"> [PEPPOL-T125-R033] Party must include either a party name or a party identification.</assert>
	     </rule>

	     <rule context="ubl:Waybill/cac:ConsignorParty">
		       <assert id="PEPPOL-T125-R031"
                 test="cac:PartyName or cac:PartyIdentification"
                 flag="fatal">[PEPPOL-T125-R031] Party must include either a party name or a party identification.</assert>
	     </rule>
	
	     <rule context="ubl:Waybill/cac:CarrierParty">
		       <assert id="PEPPOL-T125-R032"
                 test="cac:PartyName or cac:PartyIdentification"
                 flag="fatal">[PEPPOL-T125-R032] Party must include either a party name or a party identification.</assert>
	     </rule>
	
	     <rule context="ubl:Waybill/cac:Shipment/cac:Consignment/cac:ConsigneeParty">
		       <assert id="PEPPOL-T125-R034"
                 test="cac:PartyName or cac:PartyIdentification"
                 flag="fatal">[PEPPOL-T125-R034] Party must include either a party name or a party identification.</assert>
	     </rule>
	

	     <rule context="cac:MainCarriageShipmentStage">
		       <assert id="PEPPOL-T125-R052"
                 test="not(normalize-space(cbc:TransportModeCode) = '4') or not(cbc:TransportMeansTypeCode) or (every $type in cbc:TransportMeansTypeCode satisfies (some $code in $clAirServiceTypeCode satisfies $code = normalize-space($type)))"
                 flag="fatal">[PEPPOL-T125-R052] For air transport, transport mode code 4, the transport means type code MUST be an air service type code, for example 'J' for a passenger flight carrying cargo or 'F' for a freighter.</assert>
		       <assert id="PEPPOL-T125-R053"
                 test="normalize-space(cbc:TransportModeCode) = '4' or not(cbc:TransportMeansTypeCode) or (every $type in cbc:TransportMeansTypeCode satisfies not(some $code in $clAirServiceTypeCode satisfies $code = normalize-space($type)))"
                 flag="fatal">[PEPPOL-T125-R053] An air service type code MUST only be used as transport means type code when the transport mode code is 4, air transport.</assert>
	     </rule>

   </pattern>    

</schema>
