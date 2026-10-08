USE [HiX_LS]
Drop table if exists #R
GO

-- #region Radiologie aanvragen
SELECT 

    --  Patient
        RR.PATIENTNR as 'Patientnummer'
	,	CASE
			WHEN PP.VOORLETTER	<> '' THEN PP.VOORLETTER + ' '
			WHEN PP.VOORNAAM	<> '' THEN LEFT(PP.VOORNAAM, 1) + ' '
			WHEN PP.ROEPNAAM	<> '' THEN LEFT(PP.ROEPNAAM, 1) + ' '
		END + 
		IIF(PP.VOORVOEGA <> '', PP.VOORVOEGA + ' ', '') + 
		IIF(PP.ACHTERNAAM <> '', PP.ACHTERNAAM, '') +
		IIF(PP.VOORVOEGM <> '' OR PP.MEISJESNAA <> '', ' - ', '') +
		IIF(PP.VOORVOEGM <> '', PP.VOORVOEGM + ' ', '') +
		IIF(PP.MEISJESNAA <> '', PP.MEISJESNAA, '')
		AS 'Patient naam'
    ,   CONVERT(DATE, PP.GEBDAT) as 'Geboortedatum'
    ,   PP.Geslacht as 'Geslacht'

    --  Aanvraag
    ,	RR.[Order] as 'Order nummer'
    ,   OO.ORDERDEFNR as 'Order definitie nummer'
    ,   OD.OMSCHR as 'Order definitie omschrijving'
    ,   RA.AANVRAAGID as 'Aanvraag nummer'
    ,	convert(date, OO.STARTDATUM) as 'Order startdatum'
	,	OO.STARTTIJD as 'Order starttijd'
    -- ,   OO.STATUSCODE as 'Order status'
    ,   OS.OMSCHR as 'Order status omschrijving'
    
    --  Onderzoek
    ,   RR.ONDERZNR as 'Onderzoeknummer'
    ,	convert(date, RR.ONDERZDAT) as 'Onderzoekdatum'
	,	RR.AFSPRTIJD as 'Onderzoektijd'
    ,   RR.VERTRTIJD as 'Vertrektijd'

    --  Verrichting
    ,   RV.RONTVERRID as 'Rontgen Verichting ID'
	-- ,	RV.CODE as 'Rontgen Verichting Code'
    ,   VC.ZOEKCODE as 'Zoek Code'
	,	VC.OMSCHR as 'Zoek Omschrijving'

    -- Aanvragende arts
	,   CA.SPECIALISM as 'Aanvragende Specialisme'
    ,	case when CA.PONSNAAM='' 
			 then case when CA.ACHTERNAAM=''
					   then ltrim(rtrim(CA.MEISJESNAA)) collate SQL_Latin1_General_CP1_CI_AS
					   else ltrim(rtrim(CA.ACHTERNAAM)) collate SQL_Latin1_General_CP1_CI_AS  
				  end 
			 else ltrim(rtrim(CA.PONSNAAM)) 
		end as 'Aanvraagend Arts'

    -- Verslag
    ,   (
            Select top 1 VR.AANMAAKDATUM + VR.AANMAAKTIJD
            From RONTGEN_RONTVRSL as VR
            where VR.ONDERZNR = RR.ONDERZNR
            Order by VR.AANMAAKDATUM + VR.AANMAAKTIJD ASC
        ) as 'Verslag Aanmaakdatumtijd'

INTO #R

FROM RONTGEN_RONTVERR as RV

Left join RONTGEN_RONTGEN as RR
    on RR.ONDERZNR = RV.ONDERZNR

Left join ORDERCOM_ORDER as OO
    on OO.ORDERNR = RR.[Order]

LEFT join ORDERCOM_ORDSTAT as OS
    on OS.STATUSCODE = OO.STATUSCODE

LEFT JOIN ORDERCOM_ORDDEF AS OD
    ON OO.ORDERDEFNR = OD.ORDERDEFNR

Left join RONTGEN_RONTAAIH
    on RONTGEN_RONTAAIH.RONTVERRID = RV.RONTVERRID 
    and RONTGEN_RONTAAIH.STATUSCODE <> 'x'

Left join RONTGEN_RONTAANV as RA
    on RA.AANVRAAGID = RONTGEN_RONTAAIH.AANVRAAGNR

Left join RONTGEN_VERRCODE as VC
    on VC.CODE = RV.CODE 

Left join CSZISLIB_ARTS as CA
    on CA.ARTSCODE = RR.AANVRAGER

LEFT JOIN PATIENT_PATIENT as PP
    on PP.PATIENTNR = RR.PATIENTNR

WHERE 1 = 1
    AND year(OO.STARTDATUM) >= '2020'
    AND VC.[ZOEKCODE] = 'XA0837'
    -- AND (
    --     VC.[ZOEKCODE] = 'XA0837' OR
    --     VC.[ZOEKCODE] LIKE 'NZA%'
    -- )
-- #endregion Radiologie aanvragen

SELECT * 
FROM #R
WHERE 1=1
    -- AND Patientnummer IN (
    --         '500395032'
    --     ,   '006526489'
    --     ,   '007592639'
    -- )
ORDER BY #R.Onderzoekdatum DESC, #R.Onderzoektijd DESC
