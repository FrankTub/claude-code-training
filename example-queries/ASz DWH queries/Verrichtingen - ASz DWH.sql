DROP TABLE IF EXISTS #Verrichtingen
GO

-- #region Verrichtingen
SELECT

      -- Patient
      [PatientId]
    , [Geboortedatum]
    , [LeeftijdOpDatumVerrichting]
    , [LeeftijdOpBegindatumSubtraject]
    , [IsOverleden]

      -- Verrichting
    , [VerrichtingId]
    , [VerrichtingSecundairId]
    , [Status]
    , [Verrichtingcode]
    , [VerrichtingOmschrijving]
    , [Correctie]
    , [Aantal]

      -- Verrichting datumtijd
    , [Datum]
    , [Tijd]
    , [Eindtijd]
    , [Einddatum]

      -- Aanvrager
    , [AanvragerArtsId]
    , [AanvragerArtsNaam]
    , [AanvragerArtsType]
    , [AanvragerArtsSpecialismecode]
    , [AanvragerArtsSpecialismeVektiscode]

      -- Uitvoerder
    , [UitvoerderArtsId]
    , [UitvoerderArtsNaam]
    , [UitvoerendArtsType]
    , [UitvoerderArtsSpecialismecode]
    , [UitvoerderArtsSpecialismeVektiscode]

      -- Declaratie
    , [Declaratiecode]
    , [DeclaratiecodeOmschrijving]
    , [DeclaratieTariefafdelingcode]
    , [DeclaratieTariefafdelingOmschrijving]

      -- Invoer
    , [Invoerdatum]
    , [Invoercode]
    , [InvoercodeOmschrijving]
    , [InvoercodeTariefafdelingcode]
    , [InvoerDeclaratiecode]
    , [InvoerDeclaratiecodeTariefafdelingcode]

      -- Factuur
    , [Factuurmelding]
    , [Factuurdatum]
    , [Factuurnummer]

      -- Zorgprofielklasse
    , [Zorgprofielklassecode]
    , [ZorgprofielklasseOmschrijving]

      -- Episode en Subtraject
    , [EpisodeId]
    , [HoofdSubtrajectId]
    , [SubtrajectId]
    , [Specialismecode]
    , [Zorgtypecode]
    , [Diagnosecode]
    , [Diagnose]
    , [ICD10code]
    , [ICD10Omschrijving]
    , [StartdatumEpisode]
    , [StartdatumSubtraject]
    , [EinddatumSubtraject]
    , [EinddatumEpisode]

      -- Zorgproduct
    , [Zorgproductcode]
    , [Zorgproduct]

      -- Bron
    , [Broncode]
    , [Bron]

      -- Tariefafdeling
    , [Tariefafdelingcode]
    , [VerrichtingTariefafdelingOmschrijving]

      -- Zorglocatie
    , [ZorglocatieId]
    , [ZorglocatieOmschrijving]
    , [LocatieId]
    , [Bronlocatie]
    , [LocatieOmschrijving]
    , [AGBcode]
    , [AdministratieId]
    , [Administratie]

      -- Financieel
    , [InstantiegroepId]
    , [InstantieId]
    , [Instantie]
    , [Instantietype]
    , [Kostenplaatscode]
    , [Kostenplaats]
    , [Bedrag]
    , [BTWkosten]

      -- Referentie
    , [ReferentieId]

      -- DWH
    , [Creatiedatum]

INTO #Verrichtingen

FROM ASZ_DWH.[bus].[Verrichting]

WHERE
      1 = 1

      -- Standaard filters
      AND [Status] NOT IN ('Gepland', 'Voorlopig')
      AND Aantal > 0
      AND Correctie NOT LIKE '1%'
      AND Tariefafdelingcode <> 'DBC'

      -- Specifieke filters
      AND Diagnosecode IN ('G25')
      AND Datum BETWEEN '20240101' AND GETDATE()
      AND Verrichtingcode IN (
            '037263'
          , '037347'
          , '037404'
          , '037370'
          , '037272'
          , '037210'
          , '037346'
          , '037347'
          , '037273'
          , '037272'
          , '037263'
          , '037265'
      )
      AND Specialismecode = 'GYN'
-- #endregion

-- Details
SELECT
      Verrichtingcode
    , COUNT(*) AS Aantal
FROM #Verrichtingen
GROUP BY Verrichtingcode
