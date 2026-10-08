USE HiX_LS

DROP TABLE IF EXISTS #UITSLAGEN
DROP TABLE IF EXISTS #POPULATIE
DROP TABLE IF EXISTS #AKI
GO

SELECT --TOP (1000) 
        LLA.[BRONCODE] as 'Broncode'
    ,   LLA.[AANVRAAGNR] as 'Aanvraagnummer'
    ,   LLA.[PATIENTNR] as 'Patientnummer'
    ,   LLA.[ZENDDATUM] as 'Zenddatum'
    ,   LLA.[ZENDTIJD] as 'Zendtijd'
    ,   LLA.[AFDATUM] as 'Afname Datum'
    ,   LLA.[AFTIJD] as 'Afname Tijd'
    ,   LLA.[SPOED] as 'Spoed'
    ,   LLA.[AANVRAGER] as 'Aanvrager'
    ,   LLA.[STATUS] as 'Lab Aanvraag Status'
    ,   LHU.[STATUS] as 'Huidige Uitslag Status'
    ,   LHU.DATUM as 'Huidige Uitslag Datum'
    ,   LHU.TIJD as 'Huidige Uitslag Tijd'
    ,   LHU.BEPCODE as 'Huidige Uitslag Bepaalcode'
    ,   LBO.[DESC] as 'Huidige Uitslag Bepaling'
    ,   convert(float, LHU.UITSLAG) as 'Huidige Uitslag'
    ,   LBO.EENHEID as 'Huidige Uitslag Eenheid'
    ,   ROW_NUMBER() OVER (PARTITION BY LLA.[PATIENTNR] ORDER BY cast(LHU.DATUM as date) DESC, LHU.TIJD DESC) as RN

INTO #UITSLAGEN

FROM [HiX_LS].[dbo].[LAB_L_AANVRG] as LLA

JOIN LAB_HUIDIGE_UITSLAG as LHU
    ON LLA.AANVRAAGNR = LHU.AANVRAAGNR

JOIN LAB_L_B_OMS as LBO
    ON LHU.BEPCODE = LBO.BEP

WHERE 1=1
    and LHU.BEPCODE = 'CS000187' -- Kreatinine
    and LHU.STATUS = 'F'
    and cast(LHU.DATUM as date) >= '2024-01-01'
    and TRY_CONVERT(float, LHU.UITSLAG) IS NOT NULL

-- Patiënten met meerdere Kreatinine uitslagen
SELECT
        Patientnummer
    ,   count(*) as 'Aantal Uitslagen'
INTO #POPULATIE
FROM #UITSLAGEN
GROUP BY Patientnummer
HAVING count(*) > 1

-- Details van de patiënten met meerdere uitslagen
SELECT

        POP.Patientnummer
    ,   ELU.[Huidige Uitslag Datum] as 'Een na laatste Uitslag Datum'
    ,   ELU.[Huidige Uitslag Tijd] as 'Een na laatste Uitslag Tijd'
    ,   ELU.[Huidige Uitslag] as 'Een na laatste Uitslag'
    ,   LU.[Huidige Uitslag Datum] as 'Laatste Uitslag Datum'
    ,   LU.[Huidige Uitslag Tijd] as 'Laatste Uitslag Tijd'
    ,   LU.[Huidige Uitslag] as 'Laatste Uitslag'
    ,   CONVERT(
            DECIMAL(10, 2), 
            DATEDIFF(minute, ELU.[Huidige Uitslag Datum] + ELU.[Huidige Uitslag Tijd], LU.[Huidige Uitslag Datum] + LU.[Huidige Uitslag Tijd]) / 60.0
        ) as 'Verschil in uren'
    ,   CONVERT(
            DECIMAL(10, 2), 
            LU.[Huidige Uitslag] - ELU.[Huidige Uitslag] 
        ) as 'Verschil in Uitslag'
    ,   CONVERT(
            DECIMAL(10, 2), 
            (LU.[Huidige Uitslag] - ELU.[Huidige Uitslag]) / ELU.[Huidige Uitslag] * 100.0
        ) as 'Verschil in %'
    ,   case
            when CONVERT(
                    DECIMAL(10, 2), 
                    (LU.[Huidige Uitslag] - ELU.[Huidige Uitslag]) / ELU.[Huidige Uitslag] * 100.0
                ) >= 50 then 1
            else 0
        end as 'Stijging >= 50%'
    ,   case
            when 
                CONVERT(
                    DECIMAL(10, 2), 
                    DATEDIFF(minute, ELU.[Huidige Uitslag Datum] + ELU.[Huidige Uitslag Tijd], LU.[Huidige Uitslag Datum] + LU.[Huidige Uitslag Tijd]) / 60.0
                ) < 48 -- uur

                and

                CONVERT(
                    DECIMAL(10, 2), 
                    LU.[Huidige Uitslag] - ELU.[Huidige Uitslag] 
                ) >= 26.5 -- umol/L
            then 1
            else 0
        end as 'Stijging >= 26.5 binnen 48 uur'

INTO #AKI

FROM #POPULATIE as POP

-- Laatste Uitslag
LEFT JOIN #UITSLAGEN as LU -- Laatste Uitslag
    ON LU.Patientnummer = POP.Patientnummer
    AND LU.RN = 1

-- Een na laatste Uitslag
LEFT JOIN #UITSLAGEN as ELU 
    ON ELU.Patientnummer = POP.Patientnummer
    AND ELU.RN = 2

WHERE 1=1
    AND (
        case
            when 
                CONVERT(
                    DECIMAL(10, 2), 
                    DATEDIFF(minute, ELU.[Huidige Uitslag Datum] + ELU.[Huidige Uitslag Tijd], LU.[Huidige Uitslag Datum] + LU.[Huidige Uitslag Tijd]) / 60.0
                ) < 48 -- uur

                and

                CONVERT(
                    DECIMAL(10, 2), 
                    LU.[Huidige Uitslag] - ELU.[Huidige Uitslag] 
                ) >= 26.5 -- umol/L
            then 1
            else 0
        end = 1

        OR

        case
            when CONVERT(
                    DECIMAL(10, 2), 
                    (LU.[Huidige Uitslag] - ELU.[Huidige Uitslag]) / ELU.[Huidige Uitslag] * 100.0
                ) >= 50 then 1
            else 0
        end = 1
    )

-- AKI Details
SELECT * FROM #AKI

-- AKI Patiënten
SELECT DISTINCT Patientnummer 
FROM #AKI











-- Select	O.BEP [Bepalingcode]	
-- 	,	O.[DESC] [Bepaling_HiX]
-- 	,	nullif(O.EENHEID,'') [Eenheid]
-- 	,	(	Select Min(convert(date,L.DATUM))
-- 			From LAB_HUIDIGE_UITSLAG [L] 
-- 			Where 1=1 
-- 			and L.[STATUS] = 'F'
-- 			and L.BEPCODE = O.BEP
-- 		) Eerste_datum
-- 	,	(	Select Max(convert(date,L.DATUM))
-- 			From LAB_HUIDIGE_UITSLAG [L] 
-- 			Where 1=1 
-- 			and L.[STATUS] = 'F'
-- 			and L.BEPCODE = O.BEP
-- 		) Laatste_datum
-- 	,	(	Select SUM(1)
-- 			From LAB_HUIDIGE_UITSLAG [L] 
-- 			Where 1=1 
-- 			and L.[STATUS] = 'F'
-- 			and L.BEPCODE = O.BEP
-- 		) Aantal_uitslagen
-- From LAB_L_B_OMS [O]

-- Where 1=1 
--     and O.BRONCODE = 'LABBR1'
--     and O.ACTIVE = 1 
--     and O.BEP IN ('CS000187','ZH000046') -- 'Kreatinine'
