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
    <pattern xmlns:ns2="http://www.schematron-quickfix.com/validator/process">
      <let name="clISO3166"
           value="tokenize('1A AD AE AF AG AI AL AM AO AQ AR AS AT AU AW AX AZ BA BB BD BE BF BG BH BI BJ BL BM BN BO BQ BR BS BT BV BW BY BZ CA CC CD CF CG CH CI CK CL CM CN CO CR CU CV CW CX CY CZ DE DJ DK DM DO DZ EC EE EG EH ER ES ET FI FJ FK FM FO FR GA GB GD GE GF GG GH GI GL GM GN GP GQ GR GS GT GU GW GY HK HM HN HR HT HU ID IE IL IM IN IO IQ IR IS IT JE JM JO JP KE KG KH KI KM KN KP KR KW KY KZ LA LB LC LI LK LR LS LT LU LV LY MA MC MD ME MF MG MH MK ML MM MN MO MP MQ MR MS MT MU MV MW MX MY MZ NA NC NE NF NG NI NL NO NP NR NU NZ OM PA PE PF PG PH PK PL PM PN PR PS PT PW PY QA RE RO RS RU RW SA SB SC SD SE SG SH SI SJ SK SL SM SN SO SR SS ST SV SX SY SZ TC TD TF TG TH TJ TK TL TM TN TO TR TT TV TW TZ UA UG UM US UY UZ VA VC VE VG VI VN VU WF WS XI YE YT ZA ZM ZW', '\s')"/>
      <let name="clShipmentIDType" value="tokenize('GSIN', '\s')"/>
      <let name="clConsignmentIDType" value="tokenize('GINC', '\s')"/>
      <let name="clUNCL1001"
           value="tokenize('1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63 64 65 66 67 68 69 70 71 72 73 74 75 76 77 78 79 80 81 82 83 84 85 86 87 88 89 90 91 92 93 94 95 96 97 98 99 100 101 102 103 104 105 106 107 108 109 110 111 112 113 114 115 116 117 118 119 120 121 122 123 124 125 126 127 128 129 130 131 132 133 134 135 136 137 138 139 140 141 142 143 144 145 146 147 148 149 150 151 152 153 154 155 156 157 158 159 160 161 162 163 164 165 166 167 168 169 170 171 172 173 174 175 176 177 178 179 180 181 182 183 184 185 186 187 188 189 190 191 192 193 194 195 196 197 198 199 200 201 202 203 204 205 206 207 208 209 210 211 212 213 214 215 216 217 218 219 220 221 222 223 224 225 226 227 228 229 230 231 232 233 234 235 236 237 238 239 240 241 242 243 244 245 246 247 248 249 250 251 252 253 254 255 256 257 258 259 260 261 262 263 264 265 266 267 268 269 270 271 272 273 274 275 276 277 278 279 280 281 282 283 284 285 286 287 288 289 290 291 292 293 294 295 296 297 298 299 300 301 302 303 304 305 306 307 308 309 310 311 312 313 314 315 316 317 318 319 320 321 322 323 324 325 326 327 328 329 330 331 332 333 334 335 336 337 338 339 340 341 342 343 344 345 346 347 348 349 350 351 352 353 354 355 356 357 358 359 360 361 362 363 364 365 366 367 368 369 370 371 372 373 374 375 376 377 378 379 380 381 382 383 384 385 386 387 388 389 390 391 392 393 394 395 396 397 398 399 400 401 402 403 404 405 406 407 408 409 410 411 412 413 414 415 416 417 418 419 420 421 422 423 1999 424 425 426 427 428 429 430 431 432 433 434 435 436 437 438 439 440 441 442 443 444 445 446 447 448 449 450 451 452 453 454 455 456 457 458 459 460 461 462 463 464 465 466 467 468 469 470 481 482 483 484 485 486 487 488 489 490 491 493 494 495 496 497 498 499 520 521 522 523 524 525 526 527 528 529 530 531 532 533 534 535 536 537 538 539 550 551 552 553 554 575 576 577 578 579 580 581 582 583 584 585 586 587 588 589 610 621 622 623 624 625 626 627 628 629 630 631 632 633 634 635 636 637 638 639 640 641 642 643 644 645 646 647 648 649 650 651 652 653 654 655 656 657 658 659 700 701 702 703 704 705 706 707 708 709 710 711 712 713 714 715 716 717 718 719 720 721 722 723 724 725 726 727 728 729 730 731 732 733 734 735 736 737 738 739 740 741 742 743 744 745 746 747 748 749 750 751 760 761 763 764 765 766 770 775 780 781 782 783 784 785 786 787 788 789 790 791 792 793 794 795 796 797 798 799 810 811 812 820 821 822 823 824 825 830 833 840 841 850 851 852 853 855 856 860 861 862 863 864 865 870 890 895 896 901 910 911 913 914 915 916 917 925 926 927 929 930 931 932 933 934 935 936 937 938 940 941 950 951 952 953 954 955 960 961 962 963 964 965 966 970 971 972 974 975 976 977 978 979 990 991 995 996 998', '\s')"/>
      <let name="clICD"
           value="tokenize('0002 0003 0004 0005 0006 0007 0008 0009 0010 0011 0012 0013 0014 0015 0016 0017 0018 0019 0020 0021 0022 0023 0024 0025 0026 0027 0028 0029 0030 0031 0032 0033 0034 0035 0036 0037 0038 0039 0040 0041 0042 0043 0044 0045 0046 0047 0048 0049 0050 0051 0052 0053 0054 0055 0056 0057 0058 0059 0060 0061 0062 0063 0064 0065 0066 0067 0068 0069 0070 0071 0072 0073 0074 0075 0076 0077 0078 0079 0080 0081 0082 0083 0084 0085 0086 0087 0088 0089 0090 0091 0093 0094 0095 0096 0097 0098 0099 0100 0101 0102 0104 0105 0106 0107 0108 0109 0110 0111 0112 0113 0114 0115 0116 0117 0118 0119 0120 0121 0122 0123 0124 0125 0126 0127 0128 0129 0130 0131 0132 0133 0134 0135 0136 0137 0138 0139 0140 0141 0142 0143 0144 0145 0146 0147 0148 0149 0150 0151 0152 0153 0154 0155 0156 0157 0158 0159 0160 0161 0162 0163 0164 0165 0166 0167 0168 0169 0170 0171 0172 0173 0174 0175 0176 0177 0178 0179 0180 0183 0184 0185 0186 0187 0188 0189 0190 0191 0192 0193 0194 0195 0196 0197 0198 0199 0200 0201 0202 0203 0204 0205 0206 0207 0208 0209 0210 0211 0212 0213 0214 0215 0216 0217 0218 0219 0220 0221 0222 0223 0224 0225 0226 0227 0228 0229 0230 0231 0232 0233 0234 0235 0236 0237 0238 0239 0240 0241 0242 0243 0244 0245 0246 0247 0248', '\s')"/>
      <let name="cleas"
           value="tokenize('0002 0007 0009 0060 0088 0096 0097 0106 0130 0135 0142 0151 0158 0183 0184 0188 0190 0191 0192 0195 0196 0198 0199 0200 0201 0204 0208 0209 0210 0211 0216 0218 0221 0225 0230 0235 0240 0242 0244 0245 0246 0248 9910 9913 9914 9915 9918 9919 9920 9922 9923 9924 9925 9926 9927 9928 9929 9930 9931 9932 9933 9934 9935 9936 9937 9938 9939 9940 9941 9942 9943 9944 9945 9946 9947 9948 9949 9950 9951 9952 9953 9957 9959', '\s')"/>
      <rule context="/ubl:Manifest">
         <assert test="cbc:CustomizationID" flag="fatal" id="PEPPOL-T131-B00101">Element 'cbc:CustomizationID' MUST be provided.</assert>
         <assert test="cbc:ProfileID" flag="fatal" id="PEPPOL-T131-B00102">Element 'cbc:ProfileID' MUST be provided.</assert>
         <assert test="cbc:ID" flag="fatal" id="PEPPOL-T131-B00103">Element 'cbc:ID' MUST be provided.</assert>
         <assert test="cbc:IssueDate" flag="fatal" id="PEPPOL-T131-B00104">Element 'cbc:IssueDate' MUST be provided.</assert>
         <assert test="cbc:IssueTime" flag="fatal" id="PEPPOL-T131-B00105">Element 'cbc:IssueTime' MUST be provided.</assert>
         <assert test="cac:SendingLogisticsOperatorParty"
                 flag="fatal"
                 id="PEPPOL-T131-B00106">Element 'cac:SendingLogisticsOperatorParty' MUST be provided.</assert>
         <assert test="not(@*:schemaLocation)" flag="fatal" id="PEPPOL-T131-B00107">Document MUST not contain schema location.</assert>
      </rule>
      <rule context="/ubl:Manifest/cbc:CustomizationID"/>
      <rule context="/ubl:Manifest/cbc:ProfileID"/>
      <rule context="/ubl:Manifest/cbc:ID"/>
      <rule context="/ubl:Manifest/cbc:IssueDate"/>
      <rule context="/ubl:Manifest/cbc:IssueTime"/>
      <rule context="/ubl:Manifest/cbc:ManifestTypeCode"/>
      <rule context="/ubl:Manifest/cbc:ManifestTypeCode/*">
         <assert test="false()" flag="fatal" id="PEPPOL-T131-B00701">Document MUST NOT contain elements not part of the data model.</assert>
      </rule>
      <rule context="/ubl:Manifest/cbc:ManifestType"/>
      <rule context="/ubl:Manifest/cbc:ManifestType/*">
         <assert test="false()" flag="fatal" id="PEPPOL-T131-B00801">Document MUST NOT contain elements not part of the data model.</assert>
      </rule>
      <rule context="/ubl:Manifest/cbc:VersionID"/>
      <rule context="/ubl:Manifest/cbc:AdValoremIndicator"/>
      <rule context="/ubl:Manifest/cbc:DeclaredCarriageValueAmount">
         <assert test="@currencyID" flag="fatal" id="PEPPOL-T131-B01101">Attribute 'currencyID' MUST be present.</assert>
      </rule>
      <rule context="/ubl:Manifest/cac:SendingLogisticsOperatorParty">
         <assert test="cbc:EndpointID" flag="fatal" id="PEPPOL-T131-B01301">Element 'cbc:EndpointID' MUST be provided.</assert>
         <assert test="cac:PartyLegalEntity" flag="fatal" id="PEPPOL-T131-B01302">Element 'cac:PartyLegalEntity' MUST be provided.</assert>
      </rule>
      <rule context="/ubl:Manifest/cac:SendingLogisticsOperatorParty/cbc:EndpointID">
         <assert test="@schemeID" flag="fatal" id="PEPPOL-T131-B01401">Attribute 'schemeID' MUST be present.</assert>
         <assert test="not(@schemeID) or (some $code in $cleas satisfies $code = @schemeID)"
                 flag="fatal"
                 id="PEPPOL-T131-B01402">Value MUST be part of code list 'Electronic Address Scheme (EAS)'.</assert>
      </rule>
      <rule context="/ubl:Manifest/cac:SendingLogisticsOperatorParty/cac:PartyIdentification">
         <assert test="cbc:ID" flag="fatal" id="PEPPOL-T131-B01601">Element 'cbc:ID' MUST be provided.</assert>
      </rule>
      <rule context="/ubl:Manifest/cac:SendingLogisticsOperatorParty/cac:PartyIdentification/cbc:ID">
         <assert test="not(@schemeID) or (some $code in $clICD satisfies $code = @schemeID)"
                 flag="fatal"
                 id="PEPPOL-T131-B01701">Value MUST be part of code list 'ISO 6523 ICD list'.</assert>
      </rule>
      <rule context="/ubl:Manifest/cac:SendingLogisticsOperatorParty/cac:PartyName">
         <assert test="cbc:Name" flag="fatal" id="PEPPOL-T131-B01901">Element 'cbc:Name' MUST be provided.</assert>
      </rule>
      <rule context="/ubl:Manifest/cac:SendingLogisticsOperatorParty/cac:PartyName/cbc:Name"/>
      <rule context="/ubl:Manifest/cac:SendingLogisticsOperatorParty/cac:PostalAddress">
         <assert test="cac:Country" flag="fatal" id="PEPPOL-T131-B02101">Element 'cac:Country' MUST be provided.</assert>
      </rule>
      <rule context="/ubl:Manifest/cac:SendingLogisticsOperatorParty/cac:PostalAddress/cbc:StreetName"/>
      <rule context="/ubl:Manifest/cac:SendingLogisticsOperatorParty/cac:PostalAddress/cbc:AdditionalStreetName"/>
      <rule context="/ubl:Manifest/cac:SendingLogisticsOperatorParty/cac:PostalAddress/cbc:CityName"/>
      <rule context="/ubl:Manifest/cac:SendingLogisticsOperatorParty/cac:PostalAddress/cbc:PostalZone"/>
      <rule context="/ubl:Manifest/cac:SendingLogisticsOperatorParty/cac:PostalAddress/cbc:CountrySubentity"/>
      <rule context="/ubl:Manifest/cac:SendingLogisticsOperatorParty/cac:PostalAddress/cac:Country">
         <assert test="cbc:IdentificationCode" flag="fatal" id="PEPPOL-T131-B02701">Element 'cbc:IdentificationCode' MUST be provided.</assert>
      </rule>
      <rule context="/ubl:Manifest/cac:SendingLogisticsOperatorParty/cac:PostalAddress/cac:Country/cbc:IdentificationCode">
         <assert test="(some $code in $clISO3166 satisfies $code = normalize-space(text()))"
                 flag="fatal"
                 id="PEPPOL-T131-B02801">Value MUST be part of code list 'ISO 3166-1:Alpha2 Country codes'.</assert>
      </rule>
      <rule context="/ubl:Manifest/cac:SendingLogisticsOperatorParty/cac:PostalAddress/cac:Country/*">
         <assert test="false()" flag="fatal" id="PEPPOL-T131-B02702">Document MUST NOT contain elements not part of the data model.</assert>
      </rule>
      <rule context="/ubl:Manifest/cac:SendingLogisticsOperatorParty/cac:PostalAddress/*">
         <assert test="false()" flag="fatal" id="PEPPOL-T131-B02102">Document MUST NOT contain elements not part of the data model.</assert>
      </rule>
      <rule context="/ubl:Manifest/cac:SendingLogisticsOperatorParty/cac:PartyLegalEntity">
         <assert test="cbc:RegistrationName" flag="fatal" id="PEPPOL-T131-B02901">Element 'cbc:RegistrationName' MUST be provided.</assert>
      </rule>
      <rule context="/ubl:Manifest/cac:SendingLogisticsOperatorParty/cac:PartyLegalEntity/cbc:RegistrationName"/>
      <rule context="/ubl:Manifest/cac:SendingLogisticsOperatorParty/cac:PartyLegalEntity/cbc:CompanyID">
         <assert test="@schemeID" flag="fatal" id="PEPPOL-T131-B03101">Attribute 'schemeID' MUST be present.</assert>
         <assert test="not(@schemeID) or (some $code in $clICD satisfies $code = @schemeID)"
                 flag="fatal"
                 id="PEPPOL-T131-B03102">Value MUST be part of code list 'ISO 6523 ICD list'.</assert>
      </rule>
      <rule context="/ubl:Manifest/cac:SendingLogisticsOperatorParty/cac:PartyLegalEntity/*">
         <assert test="false()" flag="fatal" id="PEPPOL-T131-B02902">Document MUST NOT contain elements not part of the data model.</assert>
      </rule>
      <rule context="/ubl:Manifest/cac:SendingLogisticsOperatorParty/cac:Contact"/>
      <rule context="/ubl:Manifest/cac:SendingLogisticsOperatorParty/cac:Contact/cbc:Name"/>
      <rule context="/ubl:Manifest/cac:SendingLogisticsOperatorParty/cac:Contact/cbc:Telephone"/>
      <rule context="/ubl:Manifest/cac:SendingLogisticsOperatorParty/cac:Contact/cbc:ElectronicMail"/>
      <rule context="/ubl:Manifest/cac:SendingLogisticsOperatorParty/cac:Contact/*">
         <assert test="false()" flag="fatal" id="PEPPOL-T131-B03301">Document MUST NOT contain elements not part of the data model.</assert>
      </rule>
      <rule context="/ubl:Manifest/cac:SendingLogisticsOperatorParty/*">
         <assert test="false()" flag="fatal" id="PEPPOL-T131-B01303">Document MUST NOT contain elements not part of the data model.</assert>
      </rule>
      <rule context="/ubl:Manifest/cac:AuthorityParty">
         <assert test="cbc:EndpointID" flag="fatal" id="PEPPOL-T131-B03701">Element 'cbc:EndpointID' MUST be provided.</assert>
      </rule>
      <rule context="/ubl:Manifest/cac:AuthorityParty/cbc:EndpointID">
         <assert test="@schemeID" flag="fatal" id="PEPPOL-T131-B03801">Attribute 'schemeID' MUST be present.</assert>
         <assert test="not(@schemeID) or (some $code in $cleas satisfies $code = @schemeID)"
                 flag="fatal"
                 id="PEPPOL-T131-B03802">Value MUST be part of code list 'Electronic Address Scheme (EAS)'.</assert>
      </rule>
      <rule context="/ubl:Manifest/cac:AuthorityParty/cac:PartyIdentification">
         <assert test="cbc:ID" flag="fatal" id="PEPPOL-T131-B04001">Element 'cbc:ID' MUST be provided.</assert>
      </rule>
      <rule context="/ubl:Manifest/cac:AuthorityParty/cac:PartyIdentification/cbc:ID">
         <assert test="not(@schemeID) or (some $code in $clICD satisfies $code = @schemeID)"
                 flag="fatal"
                 id="PEPPOL-T131-B04101">Value MUST be part of code list 'ISO 6523 ICD list'.</assert>
      </rule>
      <rule context="/ubl:Manifest/cac:AuthorityParty/cac:PartyName">
         <assert test="cbc:Name" flag="fatal" id="PEPPOL-T131-B04301">Element 'cbc:Name' MUST be provided.</assert>
      </rule>
      <rule context="/ubl:Manifest/cac:AuthorityParty/cac:PartyName/cbc:Name"/>
      <rule context="/ubl:Manifest/cac:AuthorityParty/cac:PostalAddress">
         <assert test="cac:Country" flag="fatal" id="PEPPOL-T131-B04501">Element 'cac:Country' MUST be provided.</assert>
      </rule>
      <rule context="/ubl:Manifest/cac:AuthorityParty/cac:PostalAddress/cbc:StreetName"/>
      <rule context="/ubl:Manifest/cac:AuthorityParty/cac:PostalAddress/cbc:CityName"/>
      <rule context="/ubl:Manifest/cac:AuthorityParty/cac:PostalAddress/cbc:PostalZone"/>
      <rule context="/ubl:Manifest/cac:AuthorityParty/cac:PostalAddress/cac:Country">
         <assert test="cbc:IdentificationCode" flag="fatal" id="PEPPOL-T131-B04901">Element 'cbc:IdentificationCode' MUST be provided.</assert>
      </rule>
      <rule context="/ubl:Manifest/cac:AuthorityParty/cac:PostalAddress/cac:Country/cbc:IdentificationCode">
         <assert test="(some $code in $clISO3166 satisfies $code = normalize-space(text()))"
                 flag="fatal"
                 id="PEPPOL-T131-B05001">Value MUST be part of code list 'ISO 3166-1:Alpha2 Country codes'.</assert>
      </rule>
      <rule context="/ubl:Manifest/cac:AuthorityParty/cac:PostalAddress/cac:Country/*">
         <assert test="false()" flag="fatal" id="PEPPOL-T131-B04902">Document MUST NOT contain elements not part of the data model.</assert>
      </rule>
      <rule context="/ubl:Manifest/cac:AuthorityParty/cac:PostalAddress/*">
         <assert test="false()" flag="fatal" id="PEPPOL-T131-B04502">Document MUST NOT contain elements not part of the data model.</assert>
      </rule>
      <rule context="/ubl:Manifest/cac:AuthorityParty/cac:Contact"/>
      <rule context="/ubl:Manifest/cac:AuthorityParty/cac:Contact/cbc:Name"/>
      <rule context="/ubl:Manifest/cac:AuthorityParty/cac:Contact/cbc:Telephone"/>
      <rule context="/ubl:Manifest/cac:AuthorityParty/cac:Contact/cbc:ElectronicMail"/>
      <rule context="/ubl:Manifest/cac:AuthorityParty/cac:Contact/*">
         <assert test="false()" flag="fatal" id="PEPPOL-T131-B05101">Document MUST NOT contain elements not part of the data model.</assert>
      </rule>
      <rule context="/ubl:Manifest/cac:AuthorityParty/*">
         <assert test="false()" flag="fatal" id="PEPPOL-T131-B03702">Document MUST NOT contain elements not part of the data model.</assert>
      </rule>
      <rule context="/ubl:Manifest/cac:ConsignorParty">
         <assert test="cac:PartyLegalEntity" flag="fatal" id="PEPPOL-T131-B05501">Element 'cac:PartyLegalEntity' MUST be provided.</assert>
      </rule>
      <rule context="/ubl:Manifest/cac:ConsignorParty/cac:PartyIdentification">
         <assert test="cbc:ID" flag="fatal" id="PEPPOL-T131-B05601">Element 'cbc:ID' MUST be provided.</assert>
      </rule>
      <rule context="/ubl:Manifest/cac:ConsignorParty/cac:PartyIdentification/cbc:ID">
         <assert test="not(@schemeID) or (some $code in $clICD satisfies $code = @schemeID)"
                 flag="fatal"
                 id="PEPPOL-T131-B05701">Value MUST be part of code list 'ISO 6523 ICD list'.</assert>
      </rule>
      <rule context="/ubl:Manifest/cac:ConsignorParty/cac:PartyName">
         <assert test="cbc:Name" flag="fatal" id="PEPPOL-T131-B05901">Element 'cbc:Name' MUST be provided.</assert>
      </rule>
      <rule context="/ubl:Manifest/cac:ConsignorParty/cac:PartyName/cbc:Name"/>
      <rule context="/ubl:Manifest/cac:ConsignorParty/cac:PostalAddress">
         <assert test="cac:Country" flag="fatal" id="PEPPOL-T131-B06101">Element 'cac:Country' MUST be provided.</assert>
      </rule>
      <rule context="/ubl:Manifest/cac:ConsignorParty/cac:PostalAddress/cbc:StreetName"/>
      <rule context="/ubl:Manifest/cac:ConsignorParty/cac:PostalAddress/cbc:CityName"/>
      <rule context="/ubl:Manifest/cac:ConsignorParty/cac:PostalAddress/cbc:PostalZone"/>
      <rule context="/ubl:Manifest/cac:ConsignorParty/cac:PostalAddress/cac:Country">
         <assert test="cbc:IdentificationCode" flag="fatal" id="PEPPOL-T131-B06501">Element 'cbc:IdentificationCode' MUST be provided.</assert>
      </rule>
      <rule context="/ubl:Manifest/cac:ConsignorParty/cac:PostalAddress/cac:Country/cbc:IdentificationCode">
         <assert test="(some $code in $clISO3166 satisfies $code = normalize-space(text()))"
                 flag="fatal"
                 id="PEPPOL-T131-B06601">Value MUST be part of code list 'ISO 3166-1:Alpha2 Country codes'.</assert>
      </rule>
      <rule context="/ubl:Manifest/cac:ConsignorParty/cac:PostalAddress/cac:Country/*">
         <assert test="false()" flag="fatal" id="PEPPOL-T131-B06502">Document MUST NOT contain elements not part of the data model.</assert>
      </rule>
      <rule context="/ubl:Manifest/cac:ConsignorParty/cac:PostalAddress/*">
         <assert test="false()" flag="fatal" id="PEPPOL-T131-B06102">Document MUST NOT contain elements not part of the data model.</assert>
      </rule>
      <rule context="/ubl:Manifest/cac:ConsignorParty/cac:PartyLegalEntity">
         <assert test="cbc:RegistrationName" flag="fatal" id="PEPPOL-T131-B06701">Element 'cbc:RegistrationName' MUST be provided.</assert>
      </rule>
      <rule context="/ubl:Manifest/cac:ConsignorParty/cac:PartyLegalEntity/cbc:RegistrationName"/>
      <rule context="/ubl:Manifest/cac:ConsignorParty/cac:PartyLegalEntity/cbc:CompanyID">
         <assert test="@schemeID" flag="fatal" id="PEPPOL-T131-B06901">Attribute 'schemeID' MUST be present.</assert>
         <assert test="not(@schemeID) or (some $code in $clICD satisfies $code = @schemeID)"
                 flag="fatal"
                 id="PEPPOL-T131-B06902">Value MUST be part of code list 'ISO 6523 ICD list'.</assert>
      </rule>
      <rule context="/ubl:Manifest/cac:ConsignorParty/cac:PartyLegalEntity/*">
         <assert test="false()" flag="fatal" id="PEPPOL-T131-B06702">Document MUST NOT contain elements not part of the data model.</assert>
      </rule>
      <rule context="/ubl:Manifest/cac:ConsignorParty/cac:Contact"/>
      <rule context="/ubl:Manifest/cac:ConsignorParty/cac:Contact/cbc:Name"/>
      <rule context="/ubl:Manifest/cac:ConsignorParty/cac:Contact/cbc:Telephone"/>
      <rule context="/ubl:Manifest/cac:ConsignorParty/cac:Contact/cbc:ElectronicMail"/>
      <rule context="/ubl:Manifest/cac:ConsignorParty/cac:Contact/*">
         <assert test="false()" flag="fatal" id="PEPPOL-T131-B07101">Document MUST NOT contain elements not part of the data model.</assert>
      </rule>
      <rule context="/ubl:Manifest/cac:ConsignorParty/*">
         <assert test="false()" flag="fatal" id="PEPPOL-T131-B05502">Document MUST NOT contain elements not part of the data model.</assert>
      </rule>
      <rule context="/ubl:Manifest/cac:ConsigneeParty"/>
      <rule context="/ubl:Manifest/cac:ConsigneeParty/cac:PartyIdentification">
         <assert test="cbc:ID" flag="fatal" id="PEPPOL-T131-B07601">Element 'cbc:ID' MUST be provided.</assert>
      </rule>
      <rule context="/ubl:Manifest/cac:ConsigneeParty/cac:PartyIdentification/cbc:ID">
         <assert test="not(@schemeID) or (some $code in $clICD satisfies $code = @schemeID)"
                 flag="fatal"
                 id="PEPPOL-T131-B07701">Value MUST be part of code list 'ISO 6523 ICD list'.</assert>
      </rule>
      <rule context="/ubl:Manifest/cac:ConsigneeParty/cac:PartyName">
         <assert test="cbc:Name" flag="fatal" id="PEPPOL-T131-B07901">Element 'cbc:Name' MUST be provided.</assert>
      </rule>
      <rule context="/ubl:Manifest/cac:ConsigneeParty/cac:PartyName/cbc:Name"/>
      <rule context="/ubl:Manifest/cac:ConsigneeParty/cac:PostalAddress">
         <assert test="cac:Country" flag="fatal" id="PEPPOL-T131-B08101">Element 'cac:Country' MUST be provided.</assert>
      </rule>
      <rule context="/ubl:Manifest/cac:ConsigneeParty/cac:PostalAddress/cbc:StreetName"/>
      <rule context="/ubl:Manifest/cac:ConsigneeParty/cac:PostalAddress/cac:AddressLine">
         <assert test="cbc:Line" flag="fatal" id="PEPPOL-T131-B08301">Element 'cbc:Line' MUST be provided.</assert>
      </rule>
      <rule context="/ubl:Manifest/cac:ConsigneeParty/cac:PostalAddress/cac:AddressLine/cbc:Line"/>
      <rule context="/ubl:Manifest/cac:ConsigneeParty/cac:PostalAddress/cbc:CityName"/>
      <rule context="/ubl:Manifest/cac:ConsigneeParty/cac:PostalAddress/cbc:PostalZone"/>
      <rule context="/ubl:Manifest/cac:ConsigneeParty/cac:PostalAddress/cac:Country">
         <assert test="cbc:IdentificationCode" flag="fatal" id="PEPPOL-T131-B08701">Element 'cbc:IdentificationCode' MUST be provided.</assert>
      </rule>
      <rule context="/ubl:Manifest/cac:ConsigneeParty/cac:PostalAddress/cac:Country/cbc:IdentificationCode">
         <assert test="(some $code in $clISO3166 satisfies $code = normalize-space(text()))"
                 flag="fatal"
                 id="PEPPOL-T131-B08801">Value MUST be part of code list 'ISO 3166-1:Alpha2 Country codes'.</assert>
      </rule>
      <rule context="/ubl:Manifest/cac:ConsigneeParty/cac:PostalAddress/cac:Country/*">
         <assert test="false()" flag="fatal" id="PEPPOL-T131-B08702">Document MUST NOT contain elements not part of the data model.</assert>
      </rule>
      <rule context="/ubl:Manifest/cac:ConsigneeParty/cac:PostalAddress/*">
         <assert test="false()" flag="fatal" id="PEPPOL-T131-B08102">Document MUST NOT contain elements not part of the data model.</assert>
      </rule>
      <rule context="/ubl:Manifest/cac:ConsigneeParty/cac:Contact"/>
      <rule context="/ubl:Manifest/cac:ConsigneeParty/cac:Contact/cbc:Name"/>
      <rule context="/ubl:Manifest/cac:ConsigneeParty/cac:Contact/cbc:Telephone"/>
      <rule context="/ubl:Manifest/cac:ConsigneeParty/cac:Contact/cbc:ElectronicMail"/>
      <rule context="/ubl:Manifest/cac:ConsigneeParty/cac:Contact/*">
         <assert test="false()" flag="fatal" id="PEPPOL-T131-B08901">Document MUST NOT contain elements not part of the data model.</assert>
      </rule>
      <rule context="/ubl:Manifest/cac:ConsigneeParty/*">
         <assert test="false()" flag="fatal" id="PEPPOL-T131-B07501">Document MUST NOT contain elements not part of the data model.</assert>
      </rule>
      <rule context="/ubl:Manifest/cac:CrewPerson">
         <assert test="cac:IdentityDocumentReference"
                 flag="fatal"
                 id="PEPPOL-T131-B09301">Element 'cac:IdentityDocumentReference' MUST be provided.</assert>
      </rule>
      <rule context="/ubl:Manifest/cac:CrewPerson/cbc:FirstName"/>
      <rule context="/ubl:Manifest/cac:CrewPerson/cbc:FamilyName"/>
      <rule context="/ubl:Manifest/cac:CrewPerson/cbc:JobTitle"/>
      <rule context="/ubl:Manifest/cac:CrewPerson/cbc:NationalityCode">
         <assert test="(some $code in $clISO3166 satisfies $code = normalize-space(text()))"
                 flag="fatal"
                 id="PEPPOL-T131-B09701">Value MUST be part of code list 'ISO 3166-1:Alpha2 Country codes'.</assert>
      </rule>
      <rule context="/ubl:Manifest/cac:CrewPerson/cbc:NationalityCode/*">
         <assert test="false()" flag="fatal" id="PEPPOL-T131-B09702">Document MUST NOT contain elements not part of the data model.</assert>
      </rule>
      <rule context="/ubl:Manifest/cac:CrewPerson/cac:IdentityDocumentReference">
         <assert test="cbc:ID" flag="fatal" id="PEPPOL-T131-B09801">Element 'cbc:ID' MUST be provided.</assert>
         <assert test="cbc:DocumentType" flag="fatal" id="PEPPOL-T131-B09802">Element 'cbc:DocumentType' MUST be provided.</assert>
      </rule>
      <rule context="/ubl:Manifest/cac:CrewPerson/cac:IdentityDocumentReference/cbc:ID"/>
      <rule context="/ubl:Manifest/cac:CrewPerson/cac:IdentityDocumentReference/cbc:DocumentType"/>
      <rule context="/ubl:Manifest/cac:CrewPerson/cac:IdentityDocumentReference/*">
         <assert test="false()" flag="fatal" id="PEPPOL-T131-B09803">Document MUST NOT contain elements not part of the data model.</assert>
      </rule>
      <rule context="/ubl:Manifest/cac:CrewPerson/*">
         <assert test="false()" flag="fatal" id="PEPPOL-T131-B09302">Document MUST NOT contain elements not part of the data model.</assert>
      </rule>
      <rule context="/ubl:Manifest/cac:PassengerPerson">
         <assert test="cac:IdentityDocumentReference"
                 flag="fatal"
                 id="PEPPOL-T131-B10101">Element 'cac:IdentityDocumentReference' MUST be provided.</assert>
      </rule>
      <rule context="/ubl:Manifest/cac:PassengerPerson/cbc:FirstName"/>
      <rule context="/ubl:Manifest/cac:PassengerPerson/cbc:FamilyName"/>
      <rule context="/ubl:Manifest/cac:PassengerPerson/cbc:NationalityCode">
         <assert test="(some $code in $clISO3166 satisfies $code = normalize-space(text()))"
                 flag="fatal"
                 id="PEPPOL-T131-B10401">Value MUST be part of code list 'ISO 3166-1:Alpha2 Country codes'.</assert>
      </rule>
      <rule context="/ubl:Manifest/cac:PassengerPerson/cbc:NationalityCode/*">
         <assert test="false()" flag="fatal" id="PEPPOL-T131-B10402">Document MUST NOT contain elements not part of the data model.</assert>
      </rule>
      <rule context="/ubl:Manifest/cac:PassengerPerson/cac:IdentityDocumentReference">
         <assert test="cbc:ID" flag="fatal" id="PEPPOL-T131-B10501">Element 'cbc:ID' MUST be provided.</assert>
         <assert test="cbc:DocumentType" flag="fatal" id="PEPPOL-T131-B10502">Element 'cbc:DocumentType' MUST be provided.</assert>
      </rule>
      <rule context="/ubl:Manifest/cac:PassengerPerson/cac:IdentityDocumentReference/cbc:ID"/>
      <rule context="/ubl:Manifest/cac:PassengerPerson/cac:IdentityDocumentReference/cbc:DocumentType"/>
      <rule context="/ubl:Manifest/cac:PassengerPerson/cac:IdentityDocumentReference/*">
         <assert test="false()" flag="fatal" id="PEPPOL-T131-B10503">Document MUST NOT contain elements not part of the data model.</assert>
      </rule>
      <rule context="/ubl:Manifest/cac:PassengerPerson/*">
         <assert test="false()" flag="fatal" id="PEPPOL-T131-B10102">Document MUST NOT contain elements not part of the data model.</assert>
      </rule>
      <rule context="/ubl:Manifest/cac:Shipment">
         <assert test="cac:Consignment" flag="fatal" id="PEPPOL-T131-B10801">Element 'cac:Consignment' MUST be provided.</assert>
      </rule>
      <rule context="/ubl:Manifest/cac:Shipment/cbc:ID">
         <assert test="not(@schemeID) or (some $code in $clShipmentIDType satisfies $code = @schemeID)"
                 flag="fatal"
                 id="PEPPOL-T131-B10901">Value MUST be part of code list 'Type of Shipment ID (openPEPPOL)'.</assert>
      </rule>
      <rule context="/ubl:Manifest/cac:Shipment/cbc:Information"/>
      <rule context="/ubl:Manifest/cac:Shipment/cac:Consignment">
         <assert test="cbc:ID" flag="fatal" id="PEPPOL-T131-B11201">Element 'cbc:ID' MUST be provided.</assert>
         <assert test="cac:DocumentReference" flag="fatal" id="PEPPOL-T131-B11202">Element 'cac:DocumentReference' MUST be provided.</assert>
      </rule>
      <rule context="/ubl:Manifest/cac:Shipment/cac:Consignment/cbc:ID">
         <assert test="not(@schemeID) or (some $code in $clConsignmentIDType satisfies $code = @schemeID)"
                 flag="fatal"
                 id="PEPPOL-T131-B11301">Value MUST be part of code list 'Type of Consignment ID (openPEPPOL)'.</assert>
      </rule>
      <rule context="/ubl:Manifest/cac:Shipment/cac:Consignment/cbc:ConsigneeAssignedID"/>
      <rule context="/ubl:Manifest/cac:Shipment/cac:Consignment/cbc:ConsignorAssignedID"/>
      <rule context="/ubl:Manifest/cac:Shipment/cac:Consignment/cbc:GrossWeightMeasure">
         <assert test="@unitCode" flag="fatal" id="PEPPOL-T131-B11701">Attribute 'unitCode' MUST be present.</assert>
      </rule>
      <rule context="/ubl:Manifest/cac:Shipment/cac:Consignment/cbc:GrossVolumeMeasure">
         <assert test="@unitCode" flag="fatal" id="PEPPOL-T131-B11901">Attribute 'unitCode' MUST be present.</assert>
      </rule>
      <rule context="/ubl:Manifest/cac:Shipment/cac:Consignment/cbc:TotalTransportHandlingUnitQuantity">
         <assert test="@unitCode" flag="fatal" id="PEPPOL-T131-B12101">Attribute 'unitCode' MUST be present.</assert>
      </rule>
      <rule context="/ubl:Manifest/cac:Shipment/cac:Consignment/cac:DocumentReference">
         <assert test="cbc:ID" flag="fatal" id="PEPPOL-T131-B12301">Element 'cbc:ID' MUST be provided.</assert>
         <assert test="cbc:DocumentTypeCode" flag="fatal" id="PEPPOL-T131-B12302">Element 'cbc:DocumentTypeCode' MUST be provided.</assert>
      </rule>
      <rule context="/ubl:Manifest/cac:Shipment/cac:Consignment/cac:DocumentReference/cbc:ID"/>
      <rule context="/ubl:Manifest/cac:Shipment/cac:Consignment/cac:DocumentReference/cbc:DocumentTypeCode">
         <assert test="(some $code in $clUNCL1001 satisfies $code = normalize-space(text()))"
                 flag="fatal"
                 id="PEPPOL-T131-B12501">Value MUST be part of code list 'Document name code, full list (UNCL1001)'.</assert>
      </rule>
      <rule context="/ubl:Manifest/cac:Shipment/cac:Consignment/cac:DocumentReference/cbc:DocumentType"/>
      <rule context="/ubl:Manifest/cac:Shipment/cac:Consignment/cac:DocumentReference/*">
         <assert test="false()" flag="fatal" id="PEPPOL-T131-B12303">Document MUST NOT contain elements not part of the data model.</assert>
      </rule>
      <rule context="/ubl:Manifest/cac:Shipment/cac:Consignment/*">
         <assert test="false()" flag="fatal" id="PEPPOL-T131-B11203">Document MUST NOT contain elements not part of the data model.</assert>
      </rule>
      <rule context="/ubl:Manifest/cac:Shipment/*">
         <assert test="false()" flag="fatal" id="PEPPOL-T131-B10802">Document MUST NOT contain elements not part of the data model.</assert>
      </rule>
      <rule context="/ubl:Manifest/cac:DocumentReference">
         <assert test="cbc:ID" flag="fatal" id="PEPPOL-T131-B12701">Element 'cbc:ID' MUST be provided.</assert>
      </rule>
      <rule context="/ubl:Manifest/cac:DocumentReference/cbc:ID"/>
      <rule context="/ubl:Manifest/cac:DocumentReference/cbc:DocumentTypeCode">
         <assert test="(some $code in $clUNCL1001 satisfies $code = normalize-space(text()))"
                 flag="fatal"
                 id="PEPPOL-T131-B12901">Value MUST be part of code list 'Document name code, full list (UNCL1001)'.</assert>
      </rule>
      <rule context="/ubl:Manifest/cac:DocumentReference/cbc:DocumentType"/>
      <rule context="/ubl:Manifest/cac:DocumentReference/cac:Attachment"/>
      <rule context="/ubl:Manifest/cac:DocumentReference/cac:Attachment/cac:ExternalReference">
         <assert test="cbc:URI" flag="fatal" id="PEPPOL-T131-B13201">Element 'cbc:URI' MUST be provided.</assert>
      </rule>
      <rule context="/ubl:Manifest/cac:DocumentReference/cac:Attachment/cac:ExternalReference/cbc:URI"/>
      <rule context="/ubl:Manifest/cac:DocumentReference/cac:Attachment/cac:ExternalReference/*">
         <assert test="false()" flag="fatal" id="PEPPOL-T131-B13202">Document MUST NOT contain elements not part of the data model.</assert>
      </rule>
      <rule context="/ubl:Manifest/cac:DocumentReference/cac:Attachment/*">
         <assert test="false()" flag="fatal" id="PEPPOL-T131-B13101">Document MUST NOT contain elements not part of the data model.</assert>
      </rule>
      <rule context="/ubl:Manifest/cac:DocumentReference/*">
         <assert test="false()" flag="fatal" id="PEPPOL-T131-B12702">Document MUST NOT contain elements not part of the data model.</assert>
      </rule>
      <rule context="/ubl:Manifest/cac:DocumentDistribution">
         <assert test="cac:Party" flag="fatal" id="PEPPOL-T131-B13401">Element 'cac:Party' MUST be provided.</assert>
      </rule>
      <rule context="/ubl:Manifest/cac:DocumentDistribution/cbc:ID"/>
      <rule context="/ubl:Manifest/cac:DocumentDistribution/cbc:DistributionType"/>
      <rule context="/ubl:Manifest/cac:DocumentDistribution/cbc:DistributionType/*">
         <assert test="false()" flag="fatal" id="PEPPOL-T131-B13601">Document MUST NOT contain elements not part of the data model.</assert>
      </rule>
      <rule context="/ubl:Manifest/cac:DocumentDistribution/cac:Party"/>
      <rule context="/ubl:Manifest/cac:DocumentDistribution/cac:Party/cac:PartyName">
         <assert test="cbc:Name" flag="fatal" id="PEPPOL-T131-B13801">Element 'cbc:Name' MUST be provided.</assert>
      </rule>
      <rule context="/ubl:Manifest/cac:DocumentDistribution/cac:Party/cac:PartyName/cbc:Name"/>
      <rule context="/ubl:Manifest/cac:DocumentDistribution/cac:Party/cac:PostalAddress">
         <assert test="cac:Country" flag="fatal" id="PEPPOL-T131-B14001">Element 'cac:Country' MUST be provided.</assert>
      </rule>
      <rule context="/ubl:Manifest/cac:DocumentDistribution/cac:Party/cac:PostalAddress/cbc:CityName"/>
      <rule context="/ubl:Manifest/cac:DocumentDistribution/cac:Party/cac:PostalAddress/cac:Country">
         <assert test="cbc:IdentificationCode" flag="fatal" id="PEPPOL-T131-B14201">Element 'cbc:IdentificationCode' MUST be provided.</assert>
      </rule>
      <rule context="/ubl:Manifest/cac:DocumentDistribution/cac:Party/cac:PostalAddress/cac:Country/cbc:IdentificationCode">
         <assert test="(some $code in $clISO3166 satisfies $code = normalize-space(text()))"
                 flag="fatal"
                 id="PEPPOL-T131-B14301">Value MUST be part of code list 'ISO 3166-1:Alpha2 Country codes'.</assert>
      </rule>
      <rule context="/ubl:Manifest/cac:DocumentDistribution/cac:Party/cac:PostalAddress/cac:Country/*">
         <assert test="false()" flag="fatal" id="PEPPOL-T131-B14202">Document MUST NOT contain elements not part of the data model.</assert>
      </rule>
      <rule context="/ubl:Manifest/cac:DocumentDistribution/cac:Party/cac:PostalAddress/*">
         <assert test="false()" flag="fatal" id="PEPPOL-T131-B14002">Document MUST NOT contain elements not part of the data model.</assert>
      </rule>
      <rule context="/ubl:Manifest/cac:DocumentDistribution/cac:Party/cac:Contact"/>
      <rule context="/ubl:Manifest/cac:DocumentDistribution/cac:Party/cac:Contact/cbc:Name"/>
      <rule context="/ubl:Manifest/cac:DocumentDistribution/cac:Party/cac:Contact/cbc:ElectronicMail"/>
      <rule context="/ubl:Manifest/cac:DocumentDistribution/cac:Party/cac:Contact/*">
         <assert test="false()" flag="fatal" id="PEPPOL-T131-B14401">Document MUST NOT contain elements not part of the data model.</assert>
      </rule>
      <rule context="/ubl:Manifest/cac:DocumentDistribution/cac:Party/*">
         <assert test="false()" flag="fatal" id="PEPPOL-T131-B13701">Document MUST NOT contain elements not part of the data model.</assert>
      </rule>
      <rule context="/ubl:Manifest/cac:DocumentDistribution/*">
         <assert test="false()" flag="fatal" id="PEPPOL-T131-B13402">Document MUST NOT contain elements not part of the data model.</assert>
      </rule>
      <rule context="/ubl:Manifest/cac:Signature">
         <assert test="cbc:ID" flag="fatal" id="PEPPOL-T131-B14701">Element 'cbc:ID' MUST be provided.</assert>
         <assert test="cac:SignatoryParty" flag="fatal" id="PEPPOL-T131-B14702">Element 'cac:SignatoryParty' MUST be provided.</assert>
         <assert test="cac:DigitalSignatureAttachment"
                 flag="fatal"
                 id="PEPPOL-T131-B14703">Element 'cac:DigitalSignatureAttachment' MUST be provided.</assert>
      </rule>
      <rule context="/ubl:Manifest/cac:Signature/cbc:ID"/>
      <rule context="/ubl:Manifest/cac:Signature/cbc:ValidationDate"/>
      <rule context="/ubl:Manifest/cac:Signature/cbc:ValidationTime"/>
      <rule context="/ubl:Manifest/cac:Signature/cac:SignatoryParty"/>
      <rule context="/ubl:Manifest/cac:Signature/cac:SignatoryParty/cac:PartyName">
         <assert test="cbc:Name" flag="fatal" id="PEPPOL-T131-B15201">Element 'cbc:Name' MUST be provided.</assert>
      </rule>
      <rule context="/ubl:Manifest/cac:Signature/cac:SignatoryParty/cac:PartyName/cbc:Name"/>
      <rule context="/ubl:Manifest/cac:Signature/cac:SignatoryParty/cac:PostalAddress">
         <assert test="cac:Country" flag="fatal" id="PEPPOL-T131-B15401">Element 'cac:Country' MUST be provided.</assert>
      </rule>
      <rule context="/ubl:Manifest/cac:Signature/cac:SignatoryParty/cac:PostalAddress/cbc:StreetName"/>
      <rule context="/ubl:Manifest/cac:Signature/cac:SignatoryParty/cac:PostalAddress/cbc:CityName"/>
      <rule context="/ubl:Manifest/cac:Signature/cac:SignatoryParty/cac:PostalAddress/cac:Country">
         <assert test="cbc:IdentificationCode" flag="fatal" id="PEPPOL-T131-B15701">Element 'cbc:IdentificationCode' MUST be provided.</assert>
      </rule>
      <rule context="/ubl:Manifest/cac:Signature/cac:SignatoryParty/cac:PostalAddress/cac:Country/cbc:IdentificationCode">
         <assert test="(some $code in $clISO3166 satisfies $code = normalize-space(text()))"
                 flag="fatal"
                 id="PEPPOL-T131-B15801">Value MUST be part of code list 'ISO 3166-1:Alpha2 Country codes'.</assert>
      </rule>
      <rule context="/ubl:Manifest/cac:Signature/cac:SignatoryParty/cac:PostalAddress/cac:Country/*">
         <assert test="false()" flag="fatal" id="PEPPOL-T131-B15702">Document MUST NOT contain elements not part of the data model.</assert>
      </rule>
      <rule context="/ubl:Manifest/cac:Signature/cac:SignatoryParty/cac:PostalAddress/*">
         <assert test="false()" flag="fatal" id="PEPPOL-T131-B15402">Document MUST NOT contain elements not part of the data model.</assert>
      </rule>
      <rule context="/ubl:Manifest/cac:Signature/cac:SignatoryParty/cac:Person">
         <assert test="cbc:FamilyName" flag="fatal" id="PEPPOL-T131-B15901">Element 'cbc:FamilyName' MUST be provided.</assert>
      </rule>
      <rule context="/ubl:Manifest/cac:Signature/cac:SignatoryParty/cac:Person/cbc:FirstName"/>
      <rule context="/ubl:Manifest/cac:Signature/cac:SignatoryParty/cac:Person/cbc:FamilyName"/>
      <rule context="/ubl:Manifest/cac:Signature/cac:SignatoryParty/cac:Person/cbc:JobTitle"/>
      <rule context="/ubl:Manifest/cac:Signature/cac:SignatoryParty/cac:Person/*">
         <assert test="false()" flag="fatal" id="PEPPOL-T131-B15902">Document MUST NOT contain elements not part of the data model.</assert>
      </rule>
      <rule context="/ubl:Manifest/cac:Signature/cac:SignatoryParty/*">
         <assert test="false()" flag="fatal" id="PEPPOL-T131-B15101">Document MUST NOT contain elements not part of the data model.</assert>
      </rule>
      <rule context="/ubl:Manifest/cac:Signature/cac:DigitalSignatureAttachment"/>
      <rule context="/ubl:Manifest/cac:Signature/cac:DigitalSignatureAttachment/cac:ExternalReference">
         <assert test="cbc:URI" flag="fatal" id="PEPPOL-T131-B16401">Element 'cbc:URI' MUST be provided.</assert>
      </rule>
      <rule context="/ubl:Manifest/cac:Signature/cac:DigitalSignatureAttachment/cac:ExternalReference/cbc:URI"/>
      <rule context="/ubl:Manifest/cac:Signature/cac:DigitalSignatureAttachment/cac:ExternalReference/*">
         <assert test="false()" flag="fatal" id="PEPPOL-T131-B16402">Document MUST NOT contain elements not part of the data model.</assert>
      </rule>
      <rule context="/ubl:Manifest/cac:Signature/cac:DigitalSignatureAttachment/*">
         <assert test="false()" flag="fatal" id="PEPPOL-T131-B16301">Document MUST NOT contain elements not part of the data model.</assert>
      </rule>
      <rule context="/ubl:Manifest/cac:Signature/*">
         <assert test="false()" flag="fatal" id="PEPPOL-T131-B14704">Document MUST NOT contain elements not part of the data model.</assert>
      </rule>
      <rule context="/ubl:Manifest/*">
         <assert test="false()" flag="fatal" id="PEPPOL-T131-B00108">Document MUST NOT contain elements not part of the data model.</assert>
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
