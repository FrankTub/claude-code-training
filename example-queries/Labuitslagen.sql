
USE HiX_LS

DROP TABLE IF EXISTS #AANVRAGEN
DROP TABLE IF EXISTS #UITSLAGEN

SELECT DISTINCT

	-- Lab Aanvraag
		LLA.PATIENTNR as 'Patientnummer'
	,	LLA.AANVRAAGNR as 'Lab Aanvraag Nummer'
	,	CONVERT(DATE, LLA.ZENDDATUM) AS 'Lab Aanvraag Datum'
	,	LLA.ZENDTIJD AS 'Lab Aanvraag Tijd'
	,	CONVERT(DATE, LLA.AFDATUM) AS 'Lab Aanvraag Afname Datum'
	,	LLA.AFTIJD AS 'Lab Aanvraag Afname Tijd'
	,	LLA.SPOED as 'Lab Aanvraag Spoed'
	,	LLA.AANVRAGER as 'Lab Aanvraag Aanvrager'
	,	CASE WHEN CAA.PONSNAAM='' 
			THEN CASE WHEN CAA.ACHTERNAAM=''
					THEN LTRIM(RTRIM(CAA.MEISJESNAA)) COLLATE SQL_Latin1_General_CP1_CI_AS
					ELSE LTRIM(RTRIM(CAA.ACHTERNAAM)) COLLATE SQL_Latin1_General_CP1_CI_AS  
				END 
			ELSE LTRIM(RTRIM(CAA.PONSNAAM)) 
		END AS 'Aanvrager Naam'
	,	CAA.SPECIALISM AS 'Aanvragend Arts Specialisme'

INTO #AANVRAGEN

FROM [HiX_LS].[dbo].[LAB_L_AANVRG] as LLA

-- Informatie over de aanvrager
LEFT JOIN CSZISLIB_ARTS AS CAA 
	ON LLA.AANVRAGER = CAA.ARTSCODE

WHERE 1=1
	and CONVERT(DATE, LLA.ZENDDATUM) BETWEEN '2024-01-01' AND '2024-06-30'

-- Uitslagen

SELECT DISTINCT

	-- Lab Aanvraag
		LLA.Patientnummer
	,	LLA.[Lab Aanvraag Nummer]
	,	LLA.[Lab Aanvraag Datum]
	,	LLA.[Lab Aanvraag Tijd]
	,	LLA.[Lab Aanvraag Afname Datum]
	,	LLA.[Lab Aanvraag Afname Tijd]
	,	LLA.[Lab Aanvraag Spoed]
	,	LLA.[Lab Aanvraag Aanvrager]

	-- Lab Uitslag
	,	LHU.EXTERNALLABTESTCODE as 'Lab Externe Code'
	,	LHU.BEPCODE as 'Lab Bepalings Code'
	,	LLBO.[DESC] as 'Lab Omschrijving'
	,	CONVERT(DATE, LHU.DATUM) as 'Lab Uitslag Datum'
	,	LHU.Tijd as 'Lab Uitslag Tijd'
	,	LHU.[STATUS] as 'Lab Uitslag Status'
	,	LHU.UITSLAG as 'Lab Uitslag'
	,	LLBO.EENHEID as 'Lab Eenheid'
	,	LHU.GRENSVAL as 'Lab Hoog Laag waarde'
	,	LHU.GRENSFLAG as 'Lab Hoog Laag'

INTO #UITSLAGEN

FROM [HiX_LS].[dbo].[LAB_HUIDIGE_UITSLAG] as LHU

-- Lab aanvragen
inner join #AANVRAGEN as LLA
	on LLA.[Lab Aanvraag Nummer] = LHU.AANVRAAGNR 
			
-- Lab Bepalingen
left join [HiX_LS].[dbo].[LAB_L_B_OMS] as LLBO
	on LLBO.BEP = LHU.BEPCODE 

WHERE 1=1
	AND LHU.STATUS <> 'X'
	AND LLBO.[DESC] <> 'Order Ontvangen'
	AND LHU.BEPCODE = 'ASZ00012' -- Totaal eiwit/Kreatinine ratio in portie urine

-- Aanvragen
-- SELECT * 
-- FROM #AANVRAGEN
-- ORDER BY [Lab Aanvraag Datum] DESC, [Lab Aanvraag Tijd] DESC

-- Uitslagen
SELECT * 
FROM #UITSLAGEN
WHERE 1=1
	AND TRY_CONVERT(FLOAT, [LAB uitslag]) >= 30
ORDER BY [Lab Uitslag Datum] DESC


SELECT * 
FROM [HiX_LS].[dbo].[LAB_L_B_OMS]
WHERE 1=1
	AND [DESC] LIKE '%kreatinine%'
