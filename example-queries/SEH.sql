Use [HiX_LS]

Drop table if exists #SEHREG
Drop table if exists #RONTVERR
GO

-- #region Röntgen Verrichtingen
Select distinct  
		O.PATIENTNR as 'Patient_id'
	,	V.ONDERZNR as 'Onderzoeksnummer'
	,	V.CODE as 'Radiologiecode'
	,	AO.AANMKDATUM + AO.AANMKTIJD as 'Aanvraagdatumtijd_Order'

Into #RONTVERR

From RONTGEN_RONTVERR [V]

Left join RONTGEN_RONTGEN [O] 
	on O.ONDERZNR = V.ONDERZNR

Left join ORDERCOM_ORDER [AO] 
	on AO.ORDERNR = O.[Order]

Left join ORDERCOM_ORDSTAT [OS] 
	on OS.STATUSCODE = O.WORKFSTATUS

Left join RONTGEN_RONTAAIH [ROA] 
	on ROA.RONTVERRID = V.RONTVERRID and ROA.STATUSCODE <> 'X'

Left join RONTGEN_RONTAANV [RAA] 
	on RAA.AANVRAAGID = ROA.AANVRAAGNR

Where 1=1 
	and O.ONDERZDAT between datefromparts(year(Getdate()) -4 ,1,1) and getdate()
	and RAA.KLINSTAT = 'E'
	and OS.ANNULERING = 0 
-- #endregion

-- #region SEH Registratie

Select 

	/*ID*/
		SEH_SEHREG.SEHID as 'SEH ID'
	
    /*Data en Tijden*/

    --registratie
    ,	convert(date, SEH_SEHREG.DATUM) as 'Registratie Datum'
    ,   SEH_SEHREG.REGTIJD as 'Registratie Tijd'
    ,	convert(datetime, SEH_SEHREG.DATUM + SEH_SEHREG.REGTIJD) as 'Registratie DatumTijd'

    --Aankomst
    ,	convert(date,isnull(SEH_SEHREG.AANKSDATUM, MUTAGM.BeginDatum)) as 'Aankomst Datum'
    ,	iif(SEH_SEHREG.AANKSTIJD='', MUTAGM.BeginTijd, SEH_SEHREG.AANKSTIJD) as 'Aankomst Tijd'
    ,	isnull(convert(datetime, SEH_SEHREG.AANKSDATUM + SEH_SEHREG.AANKSTIJD), MUTAGM.BeginDatumTijd) as 'Aankomst DatumTijd'

    --Ongeval
    ,	convert(date, SEH_SEHREG.OGEVALDATU) as 'Ongeval Datum' 

    --Triage
    ,	convert(date, SEH_SEHREG.TRIADATUM) as 'Triage Datum'
    ,	SEH_SEHREG.TRIAGETIJD as 'Triage Tijd'
    ,	convert(datetime, SEH_SEHREG.TRIADATUM + SEH_SEHREG.TRIAGETIJD) as 'Triage DatumTijd'

    --Behandeling
    ,	convert(date, SEH_SEHREG.SDATEBEH) as 'Behandeling BeginDatum'
    ,	SEH_SEHREG.ARTSBHTIJD as 'Behandeling BeginTijd'
    ,	convert(datetime, SEH_SEHREG.SDATEBEH + SEH_SEHREG.ARTSBHTIJD) as 'Behandeling BeginDatumTijd'
    ,	MUTONT.BeginDatumTijd as 'Behandeling EindDatumTijd'
    ,	MUTIB.BeginDatumTijd as 'In Behandeling BeginDatumTijd'

    --Ontslag
    ,	convert(date, isnull(SEH_SEHREG.ONTSLAGDAT, MUTONT.EindDatum)) as 'Ontslag Datum'
    ,	IIF(SEH_SEHREG.EINDTIJD='', MUTONT.Eindtijd,SEH_SEHREG.EINDTIJD) as 'Ontslag Tijd'
    ,	isnull(convert(datetime, SEH_SEHREG.ONTSLAGDAT + SEH_SEHREG.EINDTIJD), MUTONT.EindDatumTijd) as 'Ontslag DatumTijd'

    --Arts-VPK
    , 	SEH_SEHREG.PATGEZIEN as 'Arts Gezien'
    ,	convert(datetime, SEH_SEHREG.PATGEZDAT + SEH_SEHREG.PATGEZT) as 'Arts Gezien DatumTijd'
    , 	SEH_SEHREG.PATGEZIENVPK	as 'Vpk Gezien'
    ,	convert(datetime, SEH_SEHREG.PATGEZVPKDAT + PATGEZVPKT)	as 'Vpk Gezien DatumTijd' 

    --Elders
    ,	MUTRON.BeginDatum as 'Elders BeginDatum'
    ,	MUTRON.BeginTijd as 'Elders BeginTijd'
    ,	MUTRON.BeginDatumTijd as 'Elders BeginDatumTijd'
    ,	MUTRON.EindDatum as 'Elders EindDatum'
    ,	MUTRON.Eindtijd as 'Elders EindTijd'
    ,	MUTRON.EindDatumTijd as 'Elders EindDatumTijd'
	,	MUTRON.Elders_Ruimte as 'Elders Ruimte'

	/*Doorlooptijden*/

	-- Totale Doorlooptijd (Aankomst - Ontslag)
	,	iif(datediff(minute,
			isnull(convert(datetime, SEH_SEHREG.AANKSDATUM + SEH_SEHREG.AANKSTIJD), MUTAGM.BeginDatumTijd),
			isnull(convert(datetime, SEH_SEHREG.ONTSLAGDAT + SEH_SEHREG.EINDTIJD), MUTONT.EindDatumTijd)) < 0, 0,
			datediff(minute,
			isnull(convert(datetime, SEH_SEHREG.AANKSDATUM + SEH_SEHREG.AANKSTIJD), MUTAGM.BeginDatumTijd),
			isnull(convert(datetime, SEH_SEHREG.ONTSLAGDAT + SEH_SEHREG.EINDTIJD), MUTONT.EindDatumTijd))) as 'Totale Doorlooptijd In Minuten'
	
    -- Doorlooptijd (Aankomst - Triage)
	,	iif(datediff(minute,
			isnull(convert(datetime, SEH_SEHREG.AANKSDATUM + SEH_SEHREG.AANKSTIJD), MUTAGM.BeginDatumTijd),
			isnull(convert(datetime, SEH_SEHREG.TRIADATUM + SEH_SEHREG.TRIAGETIJD), MUTIB.EindDatumTijd)) < 0, 0,
			datediff(minute,
			isnull(convert(datetime, SEH_SEHREG.AANKSDATUM + SEH_SEHREG.AANKSTIJD), MUTAGM.BeginDatumTijd),
			isnull(convert(datetime, SEH_SEHREG.TRIADATUM + SEH_SEHREG.TRIAGETIJD), MUTIB.EindDatumTijd))) as 'Doorlooptijd Aankomst Triage In Minuten'
	
    --Behandelduur (elders)
	,	iif(MUTRON.BeginDatum is null or MUTRON.EindDatum is null, null, datediff(minute, MUTRON.BeginDatumTijd, MUTRON.EindDatumTijd)) as 'Behandelduur Elders In Minuten'
	
    --Behandelduur (start behandeling - ontslag)
	,	iif(SEH_SEHREG.SDATEBEH is null, null,
			datediff(minute, convert(datetime, SEH_SEHREG.SDATEBEH + SEH_SEHREG.ARTSBHTIJD), MUTONT.BeginDatumTijd)) as 'Behandelduur In Minuten'
	
    --Aankomst - contact VPK 
	,	datediff(minute,
			isnull(convert(datetime, SEH_SEHREG.AANKSDATUM + SEH_SEHREG.AANKSTIJD), MUTAGM.BeginDatumTijd),
			convert(datetime, seh_sehreg.PATGEZVPKDAT + PATGEZVPKT)) as 'Aankomst Tot Behandeling VPK In Minuten'
	
    --Aankomst tot behandeling (arts)
	,	datediff(minute,
			isnull(convert(datetime, SEH_SEHREG.AANKSDATUM + SEH_SEHREG.AANKSTIJD), MUTAGM.BeginDatumTijd),
			convert(datetime, SEH_SEHREG.PATGEZDAT + SEH_SEHREG.PATGEZT)) as 'Aankomst Tot Behandeling Arts In Minuten'
			 
	/*Herkomst en Bestemming*/
	,	SEH_SEHREG.VERVOERTYP as 'Herkomst Code'
	,	isnull(nullif(SEH_SEHHERK.OMSCHRIJVI, ''), 'Onbekend') as 'Herkomst'
	,	SEH_SEHREG.BESTEMMING as 'Bestemming Code'
	,	isnull(nullif(SEH_SHBESTEM.OMSCHRIJVI, ''), 'Onbekend') as 'Bestemming'
	,	SEH_VERVOERDERS.OMSCHRIJVI as 'Vervoerder'
	
    /*Patiënt*/
	,	SEH_SEHREG.PATIENTNR as 'Patient ID'
	,	((CONVERT(int,
			CONVERT(char(8), SEH_SEHREG.DATUM, 112)) -
			CONVERT(char(8), PATIENT_PATIENT.GEBDAT, 112)) / 10000) as 'Leeftijd In Jaren Bij SEH'
	,	iif(SEH_SEHREG.TRAUMA  =1 ,'Ja', 'Nee') as 'Trauma'

	/*Klacht en reden van bezoek LBZ*/
	,	SEH_SEHREG.Klacht as 'SEH klacht'
	,	SEH_SEHREG.LBZOorzaakLetselCode as 'LBZ Oorzaak Letsel Code'
	,	SEH_LBZCAUSEINJURY.Omschrijving as 'LBZ Oorzaak Letsel'
	,	SEH_SEHREG.LBZRedenVanBezoekCode as 'LBZ Reden Bezoek Code'
	,	SEH_LBZREASONOFVISIT.Omschrijving as 'LBZ Reden Van Bezoek'
	,	case	when SEH_SEHREG.TRIANIVCOD	= '01' then 'Rood'
				when SEH_SEHREG.TRIANIVCOD  = '02' then 'Oranje'
				when SEH_SEHREG.TRIANIVCOD  = '03' then 'Geel'
				when SEH_SEHREG.TRIANIVCOD  = '04' then 'Groen'
				when SEH_SEHREG.TRIANIVCOD  = '05' then 'Blauw'
				else 'Geen triage' end as 'Triage Kleur'
	,	isnull(MU.Aantal, 0) as 'Triage Urgentie Wisseling'
	,	Case when MU.Aantal is not null then iif(SM.VOLGORDE < SE.VOLGORDE, 1, 0) else 0 end as 'Triage Urgentie Omlaag'
	,	Case when MU.Aantal is not null then iif(SM.VOLGORDE > SE.VOLGORDE, 1, 0) else 0 end 'Triage Urgentie Omhoog'
	,	SEH_SEHREG.LOCATIECOD as 'Locatie Code'
	,	CSZISLIB_LOCATION.[DESCRIPTION] as 'Locatie'
	,	SEH_SEHREG.ISNABEHAND as 'Nabehandeling'

	/*Specialisme en Artsen*/
	,	SEH_SEHREG.ARTSBHTIJD as 'Arts Behandeling Tijd'
	,	isnull(nullif(SEH_SEHREG.SPECIALISM, ''),'ONB') as 'Specialisme SEH'
	,	SEH_SEHREG.NurseHasCompletedActsDate + SEH_SEHREG.NurseHasCompletedActsTime as 'Verpleegkundige Klaar DatumTijd'
	,	convert(integer,SEH_SEHREG.NurseHasCompletedActs) as 'Verpleegkundige Klaar'
	,	SEH_SEHREG.ARTSKLAARDATUM + SEH_SEHREG.ARTSKLAARTIJD as 'Arts Klaar DatumTijd'
	,	convert(integer,SEH_SEHREG.ARTSKLAAR) as 'Arts Klaar'
	,	1 as 'Aantal'

Into #SEHREG

From SEH_SEHREG 

-- Patient gegevens
Join PATIENT_PATIENT
    on PATIENT_PATIENT.PATIENTNR = SEH_SEHREG.PATIENTNR 
    and PATIENT_PATIENT.PATCODES not like '%T%'

-- LBZ Oorzaak Letsel
Left join SEH_LBZCAUSEINJURY		
    on SEH_LBZCAUSEINJURY.Code = SEH_SEHREG.LBZOorzaakLetselCode

-- LBZ Reden van bezoek
Left join SEH_LBZREASONOFVISIT
    on SEH_LBZREASONOFVISIT.Code = SEH_SEHREG.LBZRedenVanBezoekCode

-- Bestemming
Left join SEH_SHBESTEM
    on SEH_SHBESTEM.CODE = SEH_SEHREG.BESTEMMING

-- Herkomst
Left join SEH_SEHHERK
    on SEH_SEHHERK.HERKMTCODE = SEH_SEHREG.VERVOERTYP

-- Locatie
Left join SEH_LOCATIE
    on SEH_LOCATIE.LOCATIE = SEH_SEHREG.LOCATIECOD

Left join CSZISLIB_LOCATION
    on CSZISLIB_LOCATION.LOCATIONID = SEH_LOCATIE.LOCATIONID

-- Vervoerder
Left join SEH_VERVOERDERS
    on SEH_SEHREG.VVCODE = SEH_VERVOERDERS.VVCODE 
    and SEH_VERVOERDERS.Vervallen <> 1


--Ontslag datumtijd
Outer apply (	Select	top 1 
						SEH_SEHMUT.SEHID 
                    ,	convert(datetime,SEH_SEHMUT.DATUM + SEH_SEHMUT.BEGINTIJD) as 'BeginDatumTijd'
                    ,	convert(datetime,SEH_SEHMUT.EINDDATUM + SEH_SEHMUT.EINDTIJD) as 'EindDatumTijd'
                    ,	CONVERT(DATE,SEH_SEHMUT.EINDDATUM) as 'EindDatum'
                    ,	SEH_SEHMUT.EINDTIJD as 'EindTijd' 
                    ,	CONVERT(DATE,SEH_SEHMUT.DATUM) as 'BeginDatum'
                    ,	SEH_SEHMUT.BEGINTIJD as 'BeginTijd'
				From SEH_SEHMUT
				Where 1=1
                    and SEH_SEHMUT.SEHID = SEH_SEHREG.SEHID
                    and SEH_SEHMUT.WORKFLOWSTATUS = 'DT000253' -- Ontslagen
				order by SEH_SEHMUT.SEHMUTID
			) MUTONT

--Aangemeld datumtijd 
Outer apply (	Select	 top 1 SEH_SEHMUT.SEHID 
                    ,	convert(datetime,SEH_SEHMUT.DATUM + SEH_SEHMUT.BEGINTIJD) as 'BeginDatumTijd'
                    ,	convert(datetime,SEH_SEHMUT.EINDDATUM + SEH_SEHMUT.EINDTIJD) as 'EindDatumTijd'
                    ,	CONVERT(DATE,SEH_SEHMUT.EINDDATUM) as 'EindDatum'
                    ,	SEH_SEHMUT.EINDTIJD as 'EindTijd' 
                    ,	CONVERT(DATE,SEH_SEHMUT.DATUM) as 'BeginDatum'
                    ,	SEH_SEHMUT.BEGINTIJD as 'BeginTijd'
				From SEH_SEHMUT
				Where 1=1 
                    and SEH_SEHMUT.SEHID = SEH_SEHREG.SEHID
                    and SEH_SEHMUT.WORKFLOWSTATUS = 'DT000249' -- Aangemeld
				order by SEH_SEHMUT.SEHMUTID desc
			) MUTAGM

--Elders datumtijd 
Outer apply (	Select	 top 1 SEH_SEHMUT.SEHID 
                    ,	convert(datetime,SEH_SEHMUT.DATUM + SEH_SEHMUT.BEGINTIJD) as 'BeginDatumTijd'
                    ,	convert(datetime,SEH_SEHMUT.EINDDATUM + SEH_SEHMUT.EINDTIJD) as 'EindDatumTijd'
                    ,	CONVERT(DATE,SEH_SEHMUT.EINDDATUM) as 'EindDatum'
                    ,	SEH_SEHMUT.EINDTIJD	as 'EindTijd' 
                    ,	CONVERT(DATE,SEH_SEHMUT.DATUM) as 'BeginDatum'
                    ,	SEH_SEHMUT.BEGINTIJD as 'BeginTijd'
                    ,	SEH_SEHELDERS.OMSCHRIJ as 'Elders_Ruimte'
				From SEH_SEHMUT
				Left join SEH_SEHELDERS 
                    on SEH_SEHMUT.SEHELDCODE = SEH_SEHELDERS.ID 
                    AND SEH_SEHELDERS.VERVALL = 0
				Where 1=1 
                    and SEH_SEHMUT.SEHID = SEH_SEHREG.SEHID
                    and SEH_SEHMUT.WORKFLOWSTATUS = 'DT000251' -- Elders
				order by SEH_SEHMUT.SEHMUTID desc
			) MUTRON

--In behandeling datumtijd 
Outer apply (	Select	 top 1 SEH_SEHMUT.SEHID 
                    ,	convert(datetime,SEH_SEHMUT.DATUM + SEH_SEHMUT.BEGINTIJD) as 'BeginDatumTijd'
                    ,	convert(datetime,SEH_SEHMUT.EINDDATUM + SEH_SEHMUT.EINDTIJD) as 'EindDatumTijd'
                    ,	CONVERT(DATE,SEH_SEHMUT.EINDDATUM) as 'EindDatum'
                    ,	SEH_SEHMUT.EINDTIJD as 'EindTijd' 
                    ,	CONVERT(DATE,SEH_SEHMUT.DATUM) as 'BeginDatum'
                    ,	SEH_SEHMUT.BEGINTIJD as 'BeginTijd'
				From SEH_SEHMUT
				Where 1=1 
                    and SEH_SEHMUT.SEHID = SEH_SEHREG.SEHID
                    and SEH_SEHMUT.WORKFLOWSTATUS = 'DT000252' -- Inbehandeling
				order by SEH_SEHMUT.SEHMUTID desc
			) MUTIB

--Adherentie
Outer apply (	Select	top 1  *
                From (	Select	
                                    PAT.PATIENTNR as 'Patientnummer'
                                ,   convert(datetime,PAT.MUTDAT + PAT.MUTTIJD) as 'MutatieDatumTijd'
                                ,   CONVERT(DATE,PAT.MUTDAT) as 'MutatieDatum'
                                ,   PAT.MUTWIE as 'UserCode'
                                ,   PAT.POSTCODE as 'Postcode'
                                ,   1 as 'Volgorde'
						From PATIENT_PATIENT [PAT]
						Where 1=1 
                            and PAT.PATTYPE <> 'C'
                            and PAT.PATIENTNR = PATIENT_PATIENT.PATIENTNR
						Union all
 						Select			
                                    PATHI.PATIENTNR as 'Patientnummer'
								,   convert(datetime,PATHI.MUTDAT + PATHI.MUTTIJD) as 'MutatieDatumTijd'
								,   CONVERT(DATE,PATHI.MUTDAT) as 'MutatieDatum'
								,   PATHI.MUTWIE as 'UserCode'
								,   PATHI.POSTCODE as 'Postcode'
								,   2 as 'Volgorde'
						From PATIENT_PATHIST [PATHI]
						Where 1=1 
                            and PATHI.PATTYPE <> 'C'
                            and PATHI.PATIENTNR = PATIENT_PATIENT.PATIENTNR
					) PP
				Where 1=1 
				    and PP.MutatieDatum <= SEH_SEHREG.DATUM
				Order by 
					    PP.Volgorde
				    ,	PP.MutatieDatumTijd desc
			) ADRES

-- Triage Urgentie
Left join	(	Select M.SEHID, 1 [Aantal]
				From SEH_SEHMUT [M]
				Where 1=1
				and M.TRIAKLEU <> '' 
				Group by 
				M.SEHID
				Having
				Count(distinct(M.TRIAKLEU)) > 1 
			) MU on MU.SEHID = SEH_SEHREG.SEHID

-- Triage Urgentie Volgorde
Outer apply (	Select top 1 M.TRIANIVCOD, N.VOLGORDE, convert(datetime,M.DATUM + M.BEGINTIJD) [DatumTijd]
				From SEH_SEHMUT [M]
				Left join SEH_SEHTRIANIVEAU [N] on N.TRIANIV = M.TRIANIVCOD
				Where 1=1 
				and M.TRIANIVCOD <> ''
				and M.SEHID = SEH_SEHREG .SEHID
				Order by  
					convert(datetime,M.DATUM + M.BEGINTIJD)
				,	N.VOLGORDE
			) SM

-- Triage Urgentie Volgorde
Outer apply (	Select top 1  M.TRIANIVCOD, N.VOLGORDE, convert(datetime,M.DATUM + M.BEGINTIJD) [DatumTijd]
				From SEH_SEHMUT [M]
				Left join SEH_SEHTRIANIVEAU [N] on N.TRIANIV = M.TRIANIVCOD
				Where 1=1 
				and M.TRIANIVCOD <> ''
				and M.TRIANIVCOD <> SM.TRIANIVCOD
				and M.SEHID = SEH_SEHREG.SEHID
				Order by  
					convert(datetime,M.DATUM + M.BEGINTIJD) desc
				,	N.VOLGORDE 
			) SE

Where 1=1 
    and SEH_SEHREG.VERVALL = 0 
    and SEH_SEHREG.DATUM between '20260101' and convert(date,GETDATE())
    and SEH_SEHREG.[STATUS] = ''
    and SEH_SEHREG.PATIENTNR = '010411752'
-- #endregion

-- #region Finale tabel
Select S.*
	,	Case	
            when S.[Totale Doorlooptijd In Minuten] > 420 
            then 1 
            else 0 
        end as 'Exces'
	,	Case	
            when S.[Totale Doorlooptijd In Minuten] > 420 
                and S.[Aankomst Datum] < S.[Ontslag Datum]
                and S.[Ontslag DatumTijd] > DATETIMEFROMPARTS(YEAR(S.[Ontslag Datum]),MONTH(S.[Ontslag Datum]),DAY(S.[Ontslag Datum]),4,0,0,0) 
            then 1 
            When S.[Aankomst DatumTijd] < DATETIMEFROMPARTS(YEAR(S.[Aankomst Datum]),MONTH(S.[Aankomst Datum]),DAY(S.[Aankomst Datum]),3,0,0,0) 
                and S.[Ontslag DatumTijd] > DATETIMEFROMPARTS(YEAR(S.[Ontslag Datum]),MONTH(S.[Ontslag Datum]),DAY(S.[Ontslag Datum]),11,0,0,0) 
            then 1 
            else 0 
        end as 'Overnachting'
	,	Case	
            when datediff(day,S.[Aankomst DatumTijd],S.[Ontslag DatumTijd]) > 0 
                and S.[Aankomst DatumTijd] <= DATETIMEFROMPARTS(YEAR(S.[Aankomst Datum]), MONTH(S.[Aankomst Datum]), DAY(S.[Aankomst Datum]), 23, 59, 0, 0) 
                and S.[Ontslag DatumTijd] >= DATETIMEFROMPARTS(YEAR(S.[Ontslag Datum]), MONTH(S.[Ontslag Datum]), DAY(S.[Ontslag Datum]), 7, 0, 0, 0) 
            then 1 
            else 0 
        end 'Slaper'
	,	Case	
            when S.[Specialisme SEH] in ('CHI','LON','INT','MDL','NEU','ANE') 
            then 180 
            else 120 
        end as 'Normtijd'
	,	Case
            when S.[Totale Doorlooptijd In Minuten] <= iif(S.[Specialisme SEH] in ('CHI','LON','INT','MDL','NEU','ANE'),180,120) 
            then 1 
            else 0 
        end as 'Binnen norm'
	,	OO.PLANNR as 'Opname ID'
	,	OO.SPECIALISM as 'Opname Specialisme'
	,	Case 
            when S.[Arts klaar] = 1 
                and S.[Verpleegkundige klaar] = 1 
            then 1 
            else 0 
        end as 'Medischklaar'
	,	Case 
            when S.[Arts klaar] = 1 
                and S.[Verpleegkundige Klaar] = 1
            then iif(S.[Verpleegkundige Klaar DatumTijd] >= S.[Arts Klaar DatumTijd], S.[Verpleegkundige Klaar DatumTijd], S.[Arts Klaar DatumTijd]) 
            else S.[Ontslag DatumTijd] 
        end 'Medischklaar DatumTijd'
	,	Case 
            when S.[Arts Klaar] = 1 
                and S.[Verpleegkundige Klaar] = 1 
            then DATEDIFF(minute, S.[Aankomst DatumTijd], iif(S.[Verpleegkundige Klaar DatumTijd] >= S.[Arts Klaar DatumTijd], S.[Verpleegkundige Klaar DatumTijd], S.[Arts Klaar DatumTijd])) 
            else S.[Totale Doorlooptijd In Minuten]
        end 'Doorlooptijd Aankomst Medischklaar'
	,	Case
            when S.[Arts Klaar] = 1 
                and S.[Verpleegkundige Klaar] = 1 
            then DATEDIFF(minute, iif(S.[Verpleegkundige Klaar DatumTijd] >= S.[Arts Klaar DatumTijd], S.[Verpleegkundige Klaar DatumTijd], S.[Arts Klaar DatumTijd]), S.[Ontslag DatumTijd]) 
            else 0 
        end 'Doorlooptijd Medischklaar Vertrek'
	,	isnull(
            (   Select top 1 1 
                From #RONTVERR [A] 
                Where 1=1 
                    and A.[Patient_id] = S.[Patient ID] 
                    and A.Aanvraagdatumtijd_Order between S.[Registratie DatumTijd] and S.[Ontslag DatumTijd]
            ), 
        0) as 'Radiologie Order'
	,	(
            Select top 1 
                ASI.PatientSeenDateTime 
            From SEH_SEHAASSI [ASI] 
            Where 1=1 
                and ASI.SEHNUMMER = S.[SEH ID] 
                and ASI.PatientSeen = 1 
            order by ASI.PatientSeenDateTime
        ) as 'Arts Assistent Patient Gezien DatumTijd'
	,	(
            Select top 1 VPK.PatientSeenDateTime
            From SEH_SEHVPKRG [VPK] 
            Where 1=1 
                and VPK.SEHNUMMER = S.[SEH ID]
                and VPK.PatientSeen = 1 
            order by VPK.PatientSeenDateTime
        ) as 'Verpleegkundige Patient Gezien DatumTijd'
    ,   iif(
            datediff(
                minute, 
                (
                    Select top 1 ASI.PatientSeenDateTime 
                    From SEH_SEHAASSI [ASI] 
                    Where 1=1 
                        and ASI.SEHNUMMER = S.[SEH ID]  
                        and ASI.PatientSeen = 1 
                    order by ASI.PatientSeenDateTime
                ), 
                S.[Behandeling EindDatumTijd]
            ) > 0, 
            datediff(
                minute,
                (   
                    Select top 1 ASI.PatientSeenDateTime 
                    From SEH_SEHAASSI [ASI] 
                    Where 1=1 
                        and ASI.SEHNUMMER = S.[SEH ID]  
                        and ASI.PatientSeen = 1 
                    order by ASI.PatientSeenDateTime
                ), 
                S.[Behandeling EindDatumTijd]
            ), null) as 'Arts Assistent Patient Gezien Tot Behandeling EindDatumTijd'

From  #SEHREG [S]

Outer apply (	Select top 1 
                        OO.PLANNR
                    ,   OO.SPECIALISM
				From OPNAME_OPNAME [OO]
				Where 1=1 
                    and OO.PATIENTNR = S.[Patient ID]
                    and OO.WORKFLOWSTATUS in ('DT000099','DT000097')
                    and OO.VERBLIJFSTARTDAT between S.[Ontslag Datum] and dateadd(day,1,S.[Ontslag Datum])
				Order by (OO.VERBLIJFSTARTDAT + OO.VERBLIJFSTARTTIJD) desc
			) as OO

Where 1=1
-- #endregion

SELECT [Bestemming Code], Bestemming, COUNT([SEH ID])
FROM #SEHREG
GROUP BY [Bestemming Code], Bestemming
ORDER BY [Bestemming Code]
