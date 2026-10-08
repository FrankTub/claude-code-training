USE ASZ_DWH
GO

-- #region Opname (OO)
DROP TABLE IF EXISTS #Opname
SELECT

		-- Patient
		PatientId
    ,   Geboortedatum
    ,   LeeftijdOpStartdatum
    ,   IsOverleden

		-- Opname
	,	OpnameId
	,	Specialismecode
	,	[Status]

		-- Opnametype en subtype
	,	OpnametypeId
	,	OpnametypeCategorie
	,	OpnametypeOmschrijving
	,	OpnameSubtypeId
	,	OpnamesubtypeOmschrijving

		-- Behandelaar
	,	BehandelaarArtsId
    ,   BehandelaarArtsNaam
    ,   BehandelaarArtsType
    ,   BehandelaarArtsSpecialismecode

		-- Zorglocatie
	,	ZorglocatieId
    ,   ZorglocatieOmschrijving
    ,   LocatieId
    ,   Bronlocatie
    ,   LocatieOmschrijving
    ,  	AGBcode
    ,   AdministratieId
    ,   Administratie

	,	OrderId

		-- Datum en tijd
	,	Aanmaakdatumtijd
	,	Startdatumtijd
	,	Einddatumtijd
	,	GeplandeStartdatumtijd
	,	GeplandeEinddatumtijd
	,	VoorlopigeEinddatumtijd
	,	[Aantal dagen opgenomen]

	,	Medischklaardatumtijd
	,	Voorkeurdatum

		-- Bestemming en Herkomst
	,	BestemmingId
	,	Bestemming
	,	HerkomstId
	,	Herkomst

		-- Opname sjabloon
	,	OpnameSjabloonId
	,	OpnameSjabloon

		-- Overige
	,	IsSpoed
	,	IsMedischKlaar
	,	OverledenTijdensOpname
	,	IsOntslagen

		-- Urgentie
	,	OpnameUrgentieId
	,	OpnameUrgentie

		-- Behandeling
	,	Behandeling

INTO #Opname

FROM [ASZ_DWH].[bus].[Opname] AS OO

WHERE 1=1
	AND OO.[STATUS] IN (
			'Ontslagen'
		, 	'Opgenomen'
		-- ,	'Gepland'
		-- ,	'Opgeroepen'
		-- ,	'Wachtlijst'
		-- ,	'Niet planbaar'
		-- ,	'Oproep bevestigd'
	)
	AND OO.[Startdatumtijd] >= '2026-01-01'
-- #endregion



-- #region Opname Mutaties (OM)
DROP TABLE IF EXISTS #OpnameMutatie
SELECT

		-- Patient
		PatientId
    ,   Geboortedatum
    ,  	LeeftijdOpStartdatum
    ,   IsOverleden

		-- Opnamemutatie
	,	OpnameId
	,	OpnameMutatieId
	,	Mutatiepositie
	,	Specialismecode
	,	[Status]

		-- Datum en tijd
	,	Startdatumtijd
	,	Einddatumtijd
	,	GeplandeStartdatumtijd
	,	GeplandeEinddatumtijd
	,	VoorlopigeEinddatumtijd

		-- Opnametype en subtype
	,	OpnametypeId
	,	OpnametypeCategorie
	,	OpnametypeOmschrijving
	,	OpnameSubtypeId
	,	OpnamesubtypeOmschrijving

		-- Behandelaar
	,	BehandelaarArtsId
    ,   BehandelaarArtsNaam
    ,   BehandelaarArtsType
    ,   BehandelaarArtsSpecialismecode

		-- Locatie
	,	BedLocatieId
	,	BedLocatiecode
	,	BedLocatieOmschrijving
	,	KamerLocatieId
	,	KamerLocatiecode
	,	KamerLocatieOmschrijving
	,	AfdelingLocatieId
	,	AfdelingLocatiecode
	,	AfdelingLocatieOmschrijving

		-- Zorgtraject en Subtraject
    ,   EpisodeId
    ,   SubtrajectId
    ,   DBCSpecialismecode
    ,   Zorgtypecode
    ,   Diagnosecode
    ,   Diagnose
    ,   ICD10code
	,	ICD10Omschrijving
    ,   StartdatumEpisode
    ,   StartdatumSubtraject
    ,   EinddatumSubtraject
    ,   EinddatumEpisode

		-- Booleans
	,	IsOverdracht
	,	IsOverplaatsing
	,	IsMedischIndicatief

INTO #OpnameMutatie

FROM [ASZ_DWH].[bus].[OpnameMutatie] AS OM

-- #endregion

SELECT * 
FROM #Opname
WHERE 1=1
	AND PatientId = '010411752'

SELECT *
FROM #OpnameMutatie
WHERE 1=1
	AND PatientId = '010411752'