DROP TABLE IF EXISTS #Subtrajecten
GO
-- #region Subtrajecten
SELECT

      -- Patient
      PatientId
    , Geboortedatum
    , LeeftijdOpBegindatumSubtraject
    , IsOverleden

      -- Zorgtraject en Subtraject
    , EpisodeId
    , HoofdSubtrajectId
    , SubtrajectId
    , Statuscode
    , [Status]
    , IsVervallen
    , Zorgtypecode
    , Zorgtype
    , StartdatumEpisode
    , StartdatumSubtraject
    , EinddatumSubtraject
    , EinddatumEpisode
    , Factuurdatum
    , FactuurStatusCode

      -- Diagnose
    , Specialismecode
    , Diagnosecode
    , Diagnose
    , ICD10code
    , ICD10Omschrijving

      -- Uitvoerder
    , UitvoerderArtsId
    , UitvoerderArtsNaam
    , UitvoerendArtsType
    , UitvoerderArtsSpecialismecode

      -- Verwijzing
    , VerwijsId
    , Verwijsdatum
    , Verwijstypecode
    , Verwijstype

      -- Verwijzer
    , VerwijzerArtsId
    , VerwijzerArtsNaam
    , VerwijzerArtsAGBcode
    , VerwijzerArtsType
    , VerwijzerArtsSpecialismecode

      -- Verwijzer Instantie
    , VerwijzerArtsInstantieAGBcode
    , VerwijzerArtsInstantieId
    , VerwijzerArtsInstantie
    , VerwijzerArtsInstantieWoonplaats

      -- Locatie
    , ZorglocatieId
    , ZorglocatieOmschrijving
    , LocatieId
    , Bronlocatie
    , LocatieOmschrijving
    , ZorglocatieAGBcode
    , AdministratieId
    , Administratie

      -- Zorgproduct
    , Zorgproductcode
    , Zorgproduct
    , Zorgproductgroep
    , VerwachtZorgproductcode
    , VerwachtZorgproduct
    , VerwachtZorgproductgroep
    , Bedrag

      -- Verrichtingen
    , HeeftVerrichting

      -- DWH
    , Creatiedatum

INTO #Subtrajecten

FROM ASZ_DWH.[bus].[Subtraject]

WHERE
      1 = 1
      AND IsVervallen = 0 -- Niet vervallen
      AND Statuscode NOT IN ('X', 'N') -- Niet factureren en Niet declareren
      AND HeeftVerrichting = 1
      AND StartdatumSubtraject BETWEEN '2025-01-01' AND '2025-12-31'
      AND CASE
            WHEN Specialismecode = 'INT' AND Diagnosecode = '941' THEN 1
            WHEN Specialismecode = 'CHI' AND Diagnosecode = '329' THEN 1
            WHEN Specialismecode = 'MDL' AND Diagnosecode = '708' THEN 1
            ELSE 0
      END = 1

-- #endregion

-- INT 941
-- CHI 329
-- MDL 708

-- Details
SELECT DISTINCT
      Specialismecode
    , Diagnosecode
    , Diagnose
FROM #Subtrajecten
-- ORDER BY StartdatumEpisode ASC, EpisodeId ASC, StartdatumSubtraject ASC
