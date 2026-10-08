DROP TABLE IF EXISTS #Afspraken
GO

-- #region Agenda afspraken
SELECT

      -- Patient
      PatientId
    , Geboortedatum
    , LeeftijdOpGeplandeStartdatum
    , IsOverleden

      -- Afspraak
    , AfspraakId
    , VoldaanStatus

      -- Agenda
    , AgendaId
    , AgendaNaam
    , AgendaOmschrijving
    , IsFinancieleAgenda

      -- Subagenda
    , SubagendaId
    , SubagendaNaam
    , SubagendaOmschrijving

      -- Afspraakcode
    , AfspraakcodeId
    , Afspraakcode
    , AfspraakOmschrijving

      -- Gepland datumtijd
    , GeplandeStartdatumtijd
    , GeplandeEinddatumtijd
    , GeplandeDuurMinuten

      -- Gerealiseerd datumtijd
    , Startdatumtijd
    , Einddatumtijd
    , GerealiseerdDuurMinuten

      -- Overige datumtijd
    , Autorisatiedatum
    , Aanmaakdatum

      -- Aanvrager
    , AanvragerArtsId
    , AanvragerArtsNaam
    , AanvragerArtsType
    , AanvragerArtsSpecialismecode

      -- Uitvoerder
    , UitvoerderArtsId
    , UitvoerderArtsNaam
    , UitvoerendArtsType
    , UitvoerderArtsSpecialismecode

      -- Afspraaktype
    , AfspraaktypeId
    , Afspraaktype

      -- Consult
    , ConsulttypeId
    , Consulttype

      -- Contact
    , ContacttypeId
    , Contacttype

      -- Episode en Subtraject
    , EpisodeId
    , SubtrajectId
    , IsVervallen
    , Specialismecode
    , Zorgtypecode
    , Diagnosecode
    , Diagnose
    , ICD10code
    , ICD10Omschrijving
    , StartdatumEpisode
    , StartdatumSubtraject
    , EinddatumSubtraject
    , EinddatumEpisode
    , Zorgproductcode
    , Zorgproduct

      -- Locatie
    , ZorglocatieId
    , ZorglocatieOmschrijving
    , LocatieId
    , Bronlocatie
    , LocatieOmschrijving
    , AGBcode
    , AdministratieId
    , Administratie

      -- Programma
    , ProgrammaId
    , Programmadefinitie
    , Programmablauwdruk

      -- Overig
    , OrderId
    , BehandelmomentId
    , AfspraakgroepId
    , MutatieredenId

      -- DWH
    , Creatiedatum

INTO #Afspraken

FROM ASZ_DWH.[bus].[Afspraak]

WHERE
      1 = 1
      AND AfspraaktypeId = 'A' -- Afspraaktype = Afspraak
      AND VoldaanStatus = 'Ja' -- Alleen afspraken waarbij de patient is op komen dagen
      -- AND AgendaId = 'CSA006' -- Polikliniek Gynaecologie
      -- AND SubagendaId IN ('002299') -- Physician Assistant Gynaecologie
      -- AND GeplandeStartdatumtijd BETWEEN '2025-01-01' AND '2025-12-31'
      AND Afspraakcode IN ('NPFICT')
-- #endregion

-- Details
SELECT *
FROM #Afspraken
ORDER BY GeplandeStartdatumtijd DESC
