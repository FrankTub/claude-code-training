USE [HiX_LS]
DROP TABLE IF EXISTS #VERRICHTINGEN
GO

-- #region Verrichtingen
SELECT

      -- ID
      FV.ID
    , FV.SECID
    , FV.PATIENTNR AS 'PatientID'

      -- Zorgtraject
    , EE.EPISODE AS 'ZorgtrajectID'
    , CAST(EE.BEGINDAT AS DATE) AS 'Zorgtraject begin datum'
    , CAST(EE.EINDDAT AS DATE) AS 'Zorgtraject eind datum'

      -- Subtraject
    , IIF(FV.CASENR = '', null, FV.CASENR) AS 'SubtrajectID'
    , CAST(DBC.BEGINDAT AS DATE) AS 'Subtraject begin datum'
    , CAST(DBC.EINDDAT AS DATE) AS 'Subtraject eind datum'
    , DBC.HOOFDDIAG AS 'Hoofddiagnose'
    , ED.OMSCHRIJV AS 'Hoofddiagnose Omschrijving'
    , DBC.Zorgtype AS 'Zorgtype'

      -- Verrichting
    , DC.Declaratiecode AS 'Declaratiecode'
    , FV.CODE AS 'Verrichting Code'
    , ISNULL(FO.OMSCHRIJV, FO2.OMSCHRIJV) AS 'Verrichting Omschrijving'
    , EZ.ZORGKLASSE AS 'Zorgprofielklasse Code'
    , EZ.OMSCHKLASS AS 'Zorgprofielklasse Omschrijving'
    , CAST(FV.DATUM AS DATE) AS 'Verrichtingdatum'
    , FV.AANTAL AS 'Aantal Verrichtingen'

      -- Aanvrager
    , AAN.SPECIALISM AS 'Aanvragend Specialisme'
    , IIF(FV.AANVRAGER = '', null, FV.AANVRAGER) AS 'Aanvrager Code'
    , CASE
            WHEN AAN.PONSNAAM = ''
                  THEN CASE
                        WHEN AAN.ACHTERNAAM = ''
                              THEN LTRIM(RTRIM(AAN.MEISJESNAA)) COLLATE SQL_Latin1_General_CP1_CI_AS
                        ELSE LTRIM(RTRIM(AAN.ACHTERNAAM)) COLLATE SQL_Latin1_General_CP1_CI_AS
                  END
            ELSE LTRIM(RTRIM(AAN.PONSNAAM))
      END AS 'Aanvrager Naam'

      -- Uitvoerder
    , UIV.SPECIALISM AS 'Uitvoerend Specialisme'
    , IIF(FV.UITVOERDER = '', null, FV.UITVOERDER) AS 'Uitvoerder Code'
    , CASE
            WHEN UIV.PONSNAAM = ''
                  THEN CASE
                        WHEN UIV.ACHTERNAAM = ''
                              THEN LTRIM(RTRIM(UIV.MEISJESNAA)) COLLATE SQL_Latin1_General_CP1_CI_AS
                        ELSE LTRIM(RTRIM(UIV.ACHTERNAAM)) COLLATE SQL_Latin1_General_CP1_CI_AS
                  END
            ELSE LTRIM(RTRIM(UIV.PONSNAAM))
      END AS 'Uitvoerder Naam'

      -- Status en herkomst
    , FV.BRON AS 'Bron'
    , FV.BRONSTATUS AS 'Bronstatus Code'
    , CASE
            WHEN FV.BRONSTATUS = 'V' THEN 'Voorlopig'
            WHEN FV.BRONSTATUS = 'P' THEN 'Gepland'
            WHEN FV.BRONSTATUS = 'A' THEN 'Geaccordeerd'
            ELSE 'Geen'
      END AS 'Bronstatus'

      -- Referenties 
    , FV.REFNUMMER AS 'Referentienummer'

INTO #VERRICHTINGEN

-- Factuur Verrichting (FV)
FROM FAKTUUR_VERRVIEW AS FV

-- Patient (PP)
INNER JOIN PATIENT_PATIENT AS PP
      ON
            FV.PATIENTNR = PP.PATIENTNR
            AND PP.PATCODES NOT LIKE '%T%'

-- DBC
LEFT OUTER JOIN EPISODE_DBCPER AS DBC
      ON FV.CASENR = DBC.DBCNUMMER

-- Episode
LEFT OUTER JOIN EPISODE_EPISODE AS EE
      ON DBC.EPISODE = EE.EPISODE

-- Aanvrager
LEFT OUTER JOIN CSZISLIB_ARTS AS AAN
      ON FV.AANVRAGER = AAN.ARTSCODE

-- Uitvoerder
LEFT OUTER JOIN CSZISLIB_ARTS AS UIV
      ON FV.UITVOERDER = UIV.ARTSCODE

-- Verrichting Omschrijving
OUTER APPLY (
      SELECT TOP 1 *
      FROM FAKTUUR_VEROMSCH AS FO
      WHERE
            1 = 1
            AND FO.CODE = FV.CODE
            AND FO.AFDELING = FV.AFDELING
            AND ISNULL(FO.BEGINDATUM, CAST('19000101' AS DATE)) <= FV.DATUM
            AND ISNULL(FO.EINDDATUM, CAST('29991231' AS DATE)) >= FV.DATUM
      ORDER BY ISNULL(FO.BEGINDATUM, CAST('19000101' AS DATE)) DESC
) AS FO

OUTER APPLY (
      SELECT TOP 1 *
      FROM FAKTUUR_VEROMSCH AS FO2
      WHERE
            1 = 1
            AND FO2.CODE = FV.CODE
            AND ISNULL(FO2.BEGINDATUM, CAST('19000101' AS DATE)) <= FV.DATUM
            AND ISNULL(FO2.EINDDATUM, CAST('29991231' AS DATE)) >= FV.DATUM
      ORDER BY ISNULL(FO2.BEGINDATUM, CAST('19000101' AS DATE)) DESC
) AS FO2

-- Declaratiecode
OUTER APPLY (
      SELECT TOP 1 FZ.CODEDECL AS 'Declaratiecode'
      FROM FAKTUUR_VERVERZ AS FZ
      WHERE
            1 = 1
            AND FZ.AFDELING = FV.AFDELING
            AND FZ.CODE = FV.CODE
            AND ISNULL(FZ.BEGINDATUM, CAST('19000101' AS DATE)) <= FV.DATUM
            AND ISNULL(FZ.BLOKVANAF, CAST('29991231' AS DATE)) >= FV.DATUM
      ORDER BY ISNULL(FZ.BEGINDATUM, CAST('19000101' AS DATE)) DESC
) AS DC

-- Zorgprofielklasse Code
OUTER APPLY (
      SELECT TOP 1 *
      FROM EPISODE_DBCVERRO AS EZ
      WHERE
            1 = 1
            AND EZ.CODE = DC.DECLARATIECODE
            AND ISNULL(EZ.BEGINDATUM, CAST('19000101' AS DATE)) <= FV.DATUM
            AND ISNULL(EZ.EINDDATUM, CAST('29991231' AS DATE)) >= FV.DATUM
      ORDER BY ISNULL(EZ.BEGINDATUM, CAST('19000101' AS DATE)) DESC
) AS EZ

-- Hoofddiagnose Omschrijving ophalen.
OUTER APPLY (
      SELECT TOP 1 *
      FROM EPISODE_DIAG AS ED
      WHERE
            1 = 1
            AND ED.CODE = DBC.HOOFDDIAG
            AND ED.SPECIALISM = DBC.SPECIALISM
            AND ISNULL(ED.DATUM, CAST('19000101' AS DATE)) <= DBC.BEGINDAT
            AND ISNULL(ED.EINDDATUM, CAST('29991231' AS DATE)) >= DBC.BEGINDAT
      ORDER BY ISNULL(ED.DATUM, CAST('19000101' AS DATE)) DESC
) AS ED

WHERE
      1 = 1

      -- Standaard filters
      AND FV.BRONSTATUS NOT IN ('P', 'V')
      AND FV.AANTAL > 0
      AND FV.CORRECTIE NOT LIKE '1%'

      -- Verrichting filters
      AND CAST(FV.DATUM AS DATE) BETWEEN '2025-01-01' AND '2025-12-31'
      AND FV.CODE IN ('190218', '190158', '190021', '7UUR', '231902', '190032K')

      -- DBC
      AND DBC.Vervallen = 0 -- Niet vervallen
      AND DBC.STATUS NOT IN ('X', 'N') -- Niet factureren en Niet declareren
      AND FV.DATUM >= DBC.BEGINDAT
      AND (
            FV.DATUM <= DBC.EINDDAT
            OR DBC.EINDDAT IS null
      )

-- #endregion

SELECT * FROM #VERRICHTINGEN

/*

        -- Factuur
    ,	IIF(FV.FAKTUURNUM = '', NULL, FV.FAKTUURNUM) AS 'Factuurnummer'
    ,	CONVERT(DATE, FV.FAKTUURDAT) AS 'Factuurdatum'
    ,	CASE
            WHEN FV.TYPE_CODE = 'D' THEN 'All-in bij DBC'
            WHEN FV.TYPE_CODE = 'N' THEN 'Niet declareren'
            WHEN FV.TYPE_CODE = 'Z' THEN 'Alleen kostendeel declareren'
            ELSE 'Declareren'
        END AS 'Factuurmelding'

        -- Locatie en afdeling
    ,	FV.LOCATIE AS 'Locatie Code'
    ,	CL.LOCOMSCH AS 'Locatie'
    ,	FV.AFDELING AS 'Tariefafdeling Code'
    ,	FTA.OMSCHRIJV AS 'Tariefafdeling'

        -- Datums
    ,	IIF(FV.VERRTIJD = '', NULL, FV.VERRTIJD) AS 'Tijd'
    ,	IIF(FV.EINDTIJD = '', NULL, FV.EINDTIJD) AS 'Eindtijd'
    ,	CONVERT(DATE, FV.INVOERDAT) AS 'Invoerdatum'
    ,	YEAR(FV.DATUM) AS 'Schadelastjaar'
    ,	YEAR(FV.FAKTUURDAT) AS 'Boekjaar'
    ,	CONVERT(DATE, FV.EindDatum) AS 'Einddatum'

        -- DGM
    ,   DGM.ZINUMMER AS 'DGM ZI-nummer'
    , 	DGM.Medaantal AS 'DGM Aantal'
    ,	ZI.VPINHV AS 'DGM Verpakking Inhoud'
    , 	DGM.AFLEENH AS 'DGM Afleveringseenheid'
    ,	IIF(
            DGM.CODESOORTDG = '01',
            '01 - Add-ON duur geneesmiddel',
            IIF(
                DGM.CODESOORTDG = '02',
                '02 - Stollingsfactor',
                NULL
                )
            ) AS 'DGM_Soort'
    ,	DGM.INDICATIE 'DGM Indicatie'
    ,	case	WHEN DGM.AANSPZVW = 'J' THEN 'Ja'
                WHEN DGM.AANSPZVW = 'N' THEN 'Nee'
                WHEN DGM.AANSPZVW = 'O' THEN '(Nog) niet beoordeeld'
                ELSE NULL end 'DGM_Aanspraak ZVW'

        -- TBI & kostenplaats
    ,	IIF(FV.VERZEKERIN = '', NULL,FV.VERZEKERIN) AS 'TBI Code'
    ,	FI.TBIGROEP AS 'TBI Groep'
    ,	FV.KOSTPLAATS AS 'Kostenplaats Code'
    , 	FK.OMSCHRIJV AS 'Kostenplaats'

        -- Bedragem
    ,	FV.BEDRAGSPEC AS 'Bedrag Specialist'
    ,	FV.BEDRAGZIEK AS 'Bedrag Ziekenhuis'
    ,	FV.BEDRAGSPEC + FV.BEDRAGZIEK AS 'Bedrag'
    ,	Round(CONVERT(float,KP.KOSTPRIJS) * CONVERT(int,FV.AANTAL),2) AS 'Kostprijs'
    ,	Round(CONVERT(float,KP2.KOSTPRIJS) * CONVERT(int,FV.AANTAL),2) AS 'Kostprijs Soft'
    ,   ISNULL(FVB.BTWKOSTEN,0) AS 'BTWKosten'

-- Factuur Tarief Afdeling (FTA)
LEFT JOIN [FAKTUUR_TARAFD] AS FTA
    ON FV.AFDELING = FTA.CODE

-- Locatie
LEFT JOIN [CSZISLIB_LOCCODE] AS CL
    ON CL.CODE = FV.LOCATIE

-- Dure geneesmiddelen (DGM)
LEFT JOIN [FAKTUUR_VERRMED] AS DGM
    ON FV.ID = DGM.ID
    AND FV.AFDELING = 'PAPO'

-- DGM Verpakking Inhoud
LEFT JOIN [ZINDEX_004] AS ZI
    ON FV.CODE = ZI.ATKODE

-- Kostenplaats Omschrijving
LEFT JOIN [FAKTUUR_KOSTPLTS] AS FK
    ON FK.KOSTPLAATS = FV.KOSTPLAATS

-- Belasting
LEFT JOIN [FAKTUUR_VERRBTW] AS FVB
    ON FVB.SECID = FV.SECID

-- Te Betalen Instantie (TBI) Groep
OUTER APPLY (
    SELECT TOP 1 *
    FROM [FAKTUUR_INSGRPIN] AS FI
    WHERE 1=1
        AND FI.VERZEKERIN = FV.VERZEKERIN
        AND ISNULL(FI.BEGINDATUM, CONVERT(DATE,'19000101')) <= FV.DATUM
        AND ISNULL(FI.EINDDATUM,  CONVERT(DATE,'29991231')) >= FV.DATUM
    ORDER BY ISNULL(FI.BEGINDATUM, CONVERT(DATE,'19000101')) DESC
) FI

-- Kostprijs
OUTER APPLY (
    SELECT TOP 1 *
    FROM [EPISODE_VERRKOST] AS EK
    WHERE 1=1
        AND EK.SPECIALISM = UIV.SPECIALISM
        AND EK.VERRCODE = FV.CODE
        AND EK.KOSTPLAATS = FV.KOSTPLAATS
        AND ISNULL(EK.BEGINDATUM, CONVERT(DATE, '19000101')) <= FV.DATUM
        AND ISNULL(EK.EINDDATUM, CONVERT(DATE, '29991231')) >= FV.DATUM
    ORDER BY ISNULL(EK.BEGINDATUM, CONVERT(DATE, '19000101')) DESC
) KP

OUTER APPLY (
    SELECT TOP 1 *
    FROM [EPISODE_VERRKOST] AS EK
    WHERE 1=1
        AND EK.VERRCODE = FV.CODE
        AND ISNULL(EK.BEGINDATUM, CONVERT(DATE, '19000101')) <= FV.DATUM
        AND ISNULL(EK.EINDDATUM, CONVERT(DATE, '29991231')) >= FV.DATUM
    ORDER BY ISNULL(EK.BEGINDATUM, CONVERT(DATE, '19000101')) DESC
) KP2

*/
