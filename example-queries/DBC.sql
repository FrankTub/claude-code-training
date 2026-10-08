USE HiX_LS

DROP TABLE IF EXISTS #DBC
GO

SELECT
		EE.Episode AS 'Zorgtraject nummer'
	,	CAST(EE.BEGINDAT AS DATE) AS 'Zorgtraject begin datum'
	,	CAST(EE.EINDDAT AS DATE) AS 'Zorgtraject eind datum'
	,	EE.PATIENTNR AS 'Patientnummer'
	,	FLOOR(DATEDIFF(DAY, CAST(PP.GEBDAT AS DATE), CAST(DBC.BEGINDAT AS DATE)) / 365.25) AS 'Leeftijd bij DBC begin datum'

	/* Patientgegevens
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
	,	PP.GESLACHT AS 'Patient geslacht'
	,	MAIL.[Patient e-mail] AS 'Patient e-mail'
	,	CAST(PP.GEBDAT AS DATE) AS 'Patient geboortedatum'
	,	PP.WOONPLAATS AS 'Patient woonplaats'
	,	PP.POSTCODE AS 'Patient postcode'
	,	PP.ADRES AS 'Patient adres'
	,	PP.HUISNR AS 'Patient huisnummer'
	*/

	,	DBC.DBCNUMMER AS 'DBC nummer'
	,	CAST(DBC.BEGINDAT AS DATE) AS 'DBC begin datum'
	,	CAST(DBC.EINDDAT AS DATE) AS 'DBC eind datum'
	,	DBC.SPECIALISM AS 'DBC Specialisme'
	,	CAST(DBC.FAKTUURDAT AS DATE) AS 'DBC factuur datum'
	,	DBC.LOCATIE AS 'DBC locatie'
	,	CL.LOCOMSCH AS 'DBC locatie omschrijving'
	,	DBC.VERVALLEN AS 'DBC vervallen'
	,	DBC.UITVOERDER AS 'Uitvoerder'
	,	CASE WHEN CAU.PONSNAAM='' 
			 THEN CASE WHEN CAU.ACHTERNAAM=''
					   THEN LTRIM(RTRIM(CAU.MEISJESNAA)) COLLATE SQL_Latin1_General_CP1_CI_AS
					   ELSE LTRIM(RTRIM(CAU.ACHTERNAAM)) COLLATE SQL_Latin1_General_CP1_CI_AS  
				  END 
			 ELSE LTRIM(RTRIM(CAU.PONSNAAM)) 
		END AS 'Uitvoerder Naam'
	,	CAU.ARTSTYPE AS 'Uitvoerend Artstype'
	,	CATU.OMSCHR AS 'UitvoerendArtstype Omschrijving'
	,	CAU.SPECIALISM AS 'Uitvoerend Arts Specialisme'
	,	CAU.ZORGVSOORT AS 'Uitvoerend Arts Zorgverlenersoort'
	,	CUI.ZORGVCODE AS 'Uitvoerend Zorgverlener Code (AGB)'
	,	CAU.instantie AS 'Uitvoerend Arts Instantie Werkzaam Code'
	,	CUI.NAAM AS 'Uitvoerend Arts Instantie Werkzaam Naam'
	,	DBC.Zorgtype AS 'Zorgtype'
	,	EZT.OMSCHRIJV AS 'Zorgtype Omschrijving'
	,	DBC.HOOFDDIAG AS 'Hoofddiagnose'
	,	ED.OMSCHRIJV AS 'Hoofddiagnose Omschrijving'
	,	DBC.ICD10 AS 'ICD10'
	,	ISNULL(ICD10.ICD10OMS, CLT.DESCRIPTION) AS 'ICD10 Omschrijving'
	,	EE.VERWIJSNR AS 'Verwijsnummer'
	,	CAST(VERW.DATUM AS DATE) AS 'Verwijs datum'
	,	VERW.TYPEVERW AS 'Type Verwijzer'
	,	CASE 
			WHEN VERW.TYPEVERW = '01' THEN 'Zelfverwijzer SEH (een patient die zich meldt bij de SEH zonder verwijzing.)'
			WHEN VERW.TYPEVERW = '02' THEN 'Zelfverwijzer niet-SEH (bijvoorbeeld een patient die zich meldt bij de polikliniek zonder verwijzing).'
			WHEN VERW.TYPEVERW = '03' THEN 'Verwezen patient SEH (Een patient die zich meldt bij de SEH met een verwijzing).'
			WHEN VERW.TYPEVERW = '04' THEN 'Verwezen patient niet-SEH vanuit eerstelijn (bijvoorbeeld een patient die zich meldt bij de polikliniek met een verwijzing vanuit de eerstelijn).'
			WHEN VERW.TYPEVERW = '05' THEN 'Verwezen patient niet-SEH vanuit ander specialisme binnen dezelfde instelling (bijvoorbeeld een patient die zich meldt bij de polikliniek met een verwijzing van een ander medisch specialisme binnen dezelfde instelling).'
			WHEN VERW.TYPEVERW = '06' THEN 'Verwezen patient niet-SEH vanuit andere instelling (bijvoorbeeld een patient die zich meldt bij de polikliniek met een verwijzing van andere instelling).'
			WHEN VERW.TYPEVERW = '07' THEN 'Eigen patient (bijvoorbeeld ingeval vervolgtraject of nieuwe zorgvraag van eigen patient).'
			WHEN VERW.TYPEVERW = '08' THEN 'Verwezen patient niet-SEH vanuit eerstelijn, maar verwijzer heeft geen AGB-code (bijvoorbeeld ingeval van optometristen).'
			WHEN VERW.TYPEVERW = '09' THEN 'Patient welke gebruik maakt van directe toegang tot paramedisch hulp (bijvoorbeeld directe toegang tot fysiotherapie).' 
			ELSE '' 
		END AS 'Type Verwijzer Omschrijving'
	,	VERW.VERWIJZER AS 'Verwijzer'
	,	CASE WHEN CAV.PONSNAAM='' 
			 THEN CASE WHEN CAV.ACHTERNAAM=''
					   THEN LTRIM(RTRIM(CAV.MEISJESNAA)) COLLATE SQL_Latin1_General_CP1_CI_AS
					   ELSE LTRIM(RTRIM(CAV.ACHTERNAAM)) COLLATE SQL_Latin1_General_CP1_CI_AS  
				  END 
			 ELSE LTRIM(RTRIM(CAV.PONSNAAM)) 
		END AS 'Verwijzer Naam'
	,	CAV.ARTSTYPE AS 'Verwijzende Artstype'
	,	ATV.OMSCHR AS 'Verwijzende Artstype Omschrijving'
	,	CAV.SPECIALISM AS 'Verwijzende Arts Specialisme'
	,	CAV.ZORGVSOORT AS 'Verwijzende Arts Zorgverlenersoort'
	,	CVI.ZORGVCODE AS 'Verwijzende Zorgverlener Code (AGB)'
	,	CAV.instantie AS 'Verwijzende Arts Instantie Werkzaam Code'
	,	CVI.NAAM AS 'Verwijzende Arts Instantie Werkzaam Naam'
	,	CASE 
			WHEN DBC.DBCNUMMER IS NOT NULL THEN 
				ISNULL(
					CONVERT(
						VARCHAR(3),
						(
							SELECT TOP(1) 'Ja'

							FROM FAKTUUR_VERRICHT AS FV

							JOIN FAKTUUR_VERRSEC AS FS
								ON FS.ID = FV.ID

							JOIN EPISODE_DBCPER AS D
								ON D.DBCNUMMER = FV.CASENR

							-- Declaratiecode
							Outer apply (	Select top 1
											FZ.CODEDECL AS 'Declaratiecode'
											From [FAKTUUR_VERVERZ] as FZ
											Where 1=1 
												and FZ.AFDELING = FV.AFDELING
												and FZ.CODE = FS.CODE
												and isnull(FZ.BEGINDATUM,convert(date,'19000101')) <= FV.DATUM 
												and isnull(FZ.BLOKVANAF,convert(date,'29991231')) >= FV.DATUM 
											Order by isnull(FZ.BEGINDATUM,convert(date,'19000101')) desc
										) DC

							-- Zorgprofielklasse Code
							Outer apply (	Select top 1 * 
											From [EPISODE_DBCVERRO] as EZ
											Where 1=1 
												and EZ.CODE = DC.Declaratiecode
												and isnull(EZ.BEGINDATUM,convert(date,'19000101')) <= FV.DATUM 
												and isnull(EZ.Einddatum,convert(date,'29991231')) >= FV.DATUM 
											Order by isnull(EZ.BEGINDATUM, convert(date,'19000101')) desc
										) EZ

							WHERE 1 = 1

								-- DBC
								AND D.DBCNUMMER = DBC.DBCNUMMER
								AND FV.DATUM >= DBC.BEGINDAT
								AND (
										FV.DATUM <= DBC.EINDDAT 
										OR DBC.EINDDAT IS NULL
									)

								-- OPERATIEVE VERRICHTINGEN
								AND EZ.ZORGKLASSE = '05' 

								-- Geen lege DBC
								AND FS.AANTAL > 0 
								AND FS.CORRECTIE NOT LIKE '1%'

						)
					)
				, 'Nee'
				)
			ELSE NULL
		END AS 'Operatieve Verrichting in DBC?'

INTO #DBC

FROM EPISODE_EPISODE AS EE

-- Patientgegevens ophalen.
JOIN PATIENT_PATIENT AS PP
	ON PP.PATIENTNR = EE.PATIENTNR
	AND PP.IsTestPatient = 0

-- E-mail adres van patienten

LEFT JOIN (

	SELECT 	
			C.ADRSID AS	'PATIENTNR'
		,	RA.UITVOERDL AS 'Patient e-mail'
 
	FROM HiX_LS.dbo.ROUTEER_RADRES AS RA
 
	INNER JOIN HiX_LS.dbo.ROUTEER_RCONTACT AS C
		ON RA.CONTACT = C.RAID

	WHERE 
		RA.ADRTYPE = '0000000001'
		AND RA.UITVOERDL <> ''

	) AS MAIL 

	ON MAIL.PATIENTNR = PP.PATIENTNR

-- DBC gegevens ophalen gebaseerd op Zorgtraject
JOIN EPISODE_DBCPER AS DBC
	ON EE.EPISODE = DBC.EPISODE

-- Locatie Omschrijving
LEFT JOIN HiX_LS.dbo.CSZISLIB_LOCCODE AS CL
	ON CL.CODE = DBC.LOCATIE

-- Informatie over de uitvoerder ophalen
LEFT JOIN CSZISLIB_ARTS AS CAU 
	ON DBC.UITVOERDER = CAU.ARTSCODE

-- Informatie over de uitvoerende instantie ophalen.
LEFT JOIN CSZISLIB_TBI AS CUI 
	ON CAU.instantie = CUI.TBICODE

-- Uitvoerend Arts type omschrijving ophalen.
LEFT JOIN CSZISLIB_ARTSTYPE AS CATU
	ON CATU.CODE = CAU.ARTSTYPE

-- Informatie over de verwijzing ophalen.
LEFT JOIN EPISODE_EPIVERW AS VERW
	ON VERW.VERWIJSNR = EE.VERWIJSNR

-- Informatie over de verwijzer ophalen
LEFT JOIN CSZISLIB_ARTS AS CAV 
	ON VERW.Verwijzer = CAV.ARTSCODE

-- Informatie over de verwijzende instantie ophalen.
LEFT JOIN CSZISLIB_TBI AS CVI 
	ON CAV.instantie = CVI.TBICODE

-- Verwijzende Arts type omschrijving ophalen.
LEFT JOIN CSZISLIB_ARTSTYPE AS ATV
	ON ATV.CODE = CAV.ARTSTYPE

-- Code lijst
LEFT JOIN HiX_LS.dbo.CODELYST_CODELYST AS CLT
	ON CLT.CLID = DBC.LIJSTCODE

-- Zorgtype Omschrijving ophalen.
OUTER APPLY (
	SELECT
	TOP 1 *
	FROM HiX_LS.dbo.EPISODE_ZORGTYPE AS EZT
	WHERE 1 = 1
		AND EZT.Code = DBC.ZORGTYPE 
		AND ISNULL(EZT.BEGINDAT, '1900-01-01') <= ISNULL(DBC.BEGINDAT, '1900-01-01')
		AND ISNULL(EZT.EINDDAT,  '9999-12-31') >= ISNULL(DBC.BEGINDAT, '9999-12-31')
		AND EZT.SPECIALISM = '_CS' -- Omschrijving vind je onder _CS
	ORDER BY EZT.BEGINDAT DESC			
) EZT

-- Hoofddiagnose Omschrijving ophalen.
OUTER APPLY (	
	SELECT 
	TOP 1 * 
	FROM EPISODE_DIAG AS ED
	WHERE 1 = 1 
		AND ED.CODE = DBC.HOOFDDIAG 
		AND ED.SPECIALISM = DBC.SPECIALISM 
		AND ISNULL(ED.DATUM, CONVERT(DATE, '19000101')) <= DBC.BEGINDAT 
		AND ISNULL(ED.EINDDATUM, CONVERT(DATE, '29991231')) >= DBC.BEGINDAT
	ORDER BY ISNULL(ED.DATUM, CONVERT(DATE, '19000101')) DESC
) ED

-- ICD10 Omschrijving
OUTER APPLY (   
	SELECT TOP 1 C.DESCRIPTION AS 'ICD10OMS'
	FROM HiX_LS.dbo.CODELYST_CODEMAP AS M
	LEFT JOIN HiX_LS.dbo.CODELYST_CODELYST AS C 
		ON C.CLID = M.TargetCode
	WHERE 1=1  
		AND CLT.LIJSTNR = 'DT00000011' -- Deze outer apply alleen toepassen wanneer CLT = DT00000011 - Diagnosethesaurus
		AND M.SourceCode = DBC.LIJSTCODE
		AND M.TargetLijst = 'DT00000009' -- ICD10
	ORDER BY COALESCE(NULLIF(M.ENDDATE, ''), '20991231') DESC
) ICD10

WHERE 1 = 1
	AND DBC.Vervallen = 0 -- Niet vervallen
	-- AND DBC.STATUS NOT IN ('X', 'N') -- Niet factureren en Niet declareren
	AND DBC.BEGINDAT BETWEEN '2026-01-01' AND GETDATE()
	AND DBC.SPECIALISM = 'CHI'
	AND DBC.HOOFDDIAG = '224'

-----------------------------------------------------------------------------------

SELECT * FROM #DBC ORDER BY [DBC begin datum] DESC

