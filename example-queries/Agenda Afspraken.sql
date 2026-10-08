USE HiX_LS

SELECT
		AAF.PATIENTNR AS 'Patientnummer'
	,	CLOC.LOCOMSCH AS 'Locatie omschrijving'
	,	AA.OMSCHR AS 'Agenda omschrijving'
	,	ASA.OMSCHR AS 'Sub agenda omschrijving'
	,	AAF.AFSPRAAKNR AS 'Afspraak nummer'
	,	AAT.Omschrijving AS 'Afspraak type omschrijving'
	,	AAC.CODE AS 'Afspraak HiX code'
	,	AAC.OMSCHR AS 'Afspraak code omschrijving'
	,	CAST(RP.STARTDATEPLAN AS DATE) AS 'Afspraak datum'
	,	RP.STARTTIMEPLAN AS 'Afspraak tijd'
	,	AAF.voldaan AS 'Afspraak voldaan'
	,	CAA.ARTSCODE AS 'Aanvrager arts code'
	,	CASE
			WHEN CAA.PONSNAAM='' 
			THEN 
				CASE 
					WHEN CAA.ACHTERNAAM=''
					THEN LTRIM(RTRIM(CAA.MEISJESNAA)) COLLATE SQL_Latin1_General_CP1_CI_AS
					ELSE LTRIM(RTRIM(CAA.ACHTERNAAM)) COLLATE SQL_Latin1_General_CP1_CI_AS  
				END 
			ELSE LTRIM(RTRIM(CAA.PONSNAAM)) 
		END AS 'Aanvrager naam'
	,	CAA.SPECIALISM AS 'Aanvrager specialisme'
	,	CAU.ARTSCODE AS 'Uitvoerder arts code'
	,	CASE 
			WHEN CAU.PONSNAAM='' 
			THEN
				CASE 
					WHEN CAU.ACHTERNAAM=''
					THEN LTRIM(RTRIM(CAU.MEISJESNAA)) COLLATE SQL_Latin1_General_CP1_CI_AS
					ELSE LTRIM(RTRIM(CAU.ACHTERNAAM)) COLLATE SQL_Latin1_General_CP1_CI_AS  
				END 
			ELSE LTRIM(RTRIM(CAU.PONSNAAM)) 
		END AS 'Uitvoerder naam'
	,	CAU.SPECIALISM AS 'Uitvoerder specialisme'
	,'--' as '--' 
	,AAF.EPISODE as DBCAfspraak
	,DBC.BEGINDAT as DBCBeginDatum
	,DBC.HOOFDDIAG as Diagnose
	,ed.OMSCHRIJV as DiagnoseOmschrijving
	,DBC.ZORGPROD as Zorgproduct


FROM HiX_LS.dbo.AGENDA_AFSPRAAK AS AAF

-- Patientgegevens
JOIN PATIENT_PATIENT AS PP
	ON PP.PATIENTNR = AAF.PATIENTNR

-- Agenda Afspraak Code ophalen
OUTER APPLY (

	SELECT TOP 1
			AACD.CODE
		,	AAC.OMSCHR

	FROM HiX_LS.dbo.[AGENDA_AFSPCODE] AS AAC

	LEFT OUTER JOIN HiX_LS.dbo.[AGENDA_AFSPCODEDEF] AS AACD
		ON AACD.ID = AAC.CODE

	WHERE 
		AAC.CODE = AAF.CODE
		AND (
				(
					AAC.AGENDA = AAF.AGENDA 
					AND AAC.SUBAGENDA = AAF.SUBAGENDA 
				)
				OR AAC.AGENDA = AAF.AGENDA 
			) 
		AND	AAC.CODE <> ''

) AS AAC

-- Agenda's ophalen.
LEFT JOIN HiX_LS.dbo.AGENDA_AGENDA AS AA 
	ON AAF.AGENDA = AA.AGENDA

-- Subagenda's ophalen.
LEFT JOIN HiX_LS.dbo.AGENDA_SUBAGEND AS ASA 
	ON AAF.SUBAGENDA = ASA.SUBAGENDA

-- Afspraaktype Omschrijving ophalen.
LEFT JOIN BIC_HiX_HDW.dbo.AGENDA_AFSPRAAKTYPE AS AAT 
	ON AAF.AFSPTYPE = AAT.Code

-- Juiste datums behorende bij agenda afspraken ophalen. Door migratie kloppen de  datum kolommen in [AGENDA_AFSPRAAK] niet.
LEFT JOIN HiX_LS.dbo.RP_PLANOBJECT AS RP
	ON	RP.LINKEDOBJECTCLASSID = 'AGENDA_AFSPRAAK' 
	AND RP.LINKEDOBJECTID = AAF.AFSPRAAKNR

-- Aanvragend Arts informatie ophalen.
LEFT JOIN HiX_LS.dbo.CSZISLIB_ARTS AS CAA 
	ON AAF.AANVRAGER = CAA.ARTSCODE

-- Uitvoerend Arts informatie ophalen.
LEFT JOIN HiX_LS.dbo.CSZISLIB_ARTS AS CAU
	ON AAF.UITVOERDER = CAU.ARTSCODE

-- Locatie informatie ophalen.
LEFT JOIN HiX_LS.dbo.CSZISLIB_LOCATION AS CL 
	ON CL.LOCATIONID = AAF.LOCATIONID

-- Locatie informatie ophalen.
LEFT JOIN HiX_LS.dbo.CSZISLIB_LOCCODE AS CLOC
	ON CL.SHORTDESCR = CLOC.CODE

-- Agenda Consulttype ophalen.
LEFT JOIN BIC_HiX_HDW.dbo.AGENDA_CONSULTTYPE AS ACT
	ON ACT.Code = AAF.CONSTYPE 

LEFT JOIN HIX_LS.dbo.EPISODE_DBCPER as DBC
	ON DBC.DBCNUMMER = aaf.EPISODE

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

-- Filters 
WHERE 1=1
	AND AAF.AFSPTYPE = 'A' -- Afspraaktype = Afspraak
	AND AAF.VOLDAAN = 'J' -- Alleen afspraken waarbij de patient is op komen dagen
	AND YEAR(RP.STARTDATEPLAN) >= 2025
	-- AND AAC.CODE IN ('NPPES', 'CPPES')
	-- AND AAF.SUBAGENDA IN ('002299')
	AND AAC.CODE IN ('NPKIND','NPACNES')

	order by CAST(RP.STARTDATEPLAN AS DATE)