USE HiX_LS
GO

SELECT
	-- 	P.REGISTRATIONID AS 'Consult_id'
	-- ,	R.PATIENTNR AS 'Patient_id'
	-- ,	CAST(R.DATE AS DATE) AS 'Datum'
	-- ,	P.CATEGORYID AS 'Categorie'
	-- ,	P.TEXT AS 'Naslag'
	-- ,	R.AUTHORCODE
	-- ,	TRIM(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(TRIM(P.TEXT), '}', ''), '{', ''), '\rtf1', ''), '\ansicpg1252', ''), '\ansi', ''), '\uc1', ''), '\htmautsp', ''), '\deff2', ''), '\fonttbl', ''), '\f0 Calibri;', ''), '\f0', ''), '\fcharset0 Times New Roman;', ''), '\f2', ''), '\f1 Segoe UI;', ''), '\fcharset0 Segoe UI;', ''), '\colortbl', ''), '\red0', ''), '\green0', ''), '\blue0;', ''), '\red255', ''), '\green255', ''), '\blue255;', ''), '\loch', ''), '\hich', ''), '\dbch', ''), '\pard', ''), '\plain', ''), '\ltrpar', ''), '\itap0', ''), '\li0', ''), '\ri0', ''), '\sa0', ''), '\sb0', ''), '\fi0', ''), '\ql', ''), '\par', ''), '\lang1033', ''), '\loch', ''), '\fs18', ''), '\cf0', ''), '\ltrch ', ''), '\lang1043', ''), '\fs18', ''), '\ql', ''), '\ltrch ', ''), '\qj', ''), '\b', ''), '\ul', ''), '\line', ''), 'cf2', ''), ' DP', ''), '\deff0', '')) AS 'Naslag'
		P.*
	,	R.*
FROM CONSULT_REGPART AS [P]

JOIN CONSULT_REGISTRATION AS [R] 
	ON R.REGISTRATIONID = P.REGISTRATIONID

WHERE 1=1
    AND P.PATIENTNR = '010301698'
    -- AND CAST(R.DATE AS DATE) = '2025-01-17'
	AND R.SPECIALISM = 'OOG'
	AND TYPEID IN ('CS00000012', 'CS00000007')

ORDER BY [DAte] DESC


SELECT *
FROM ZISCON_USER
WHERE Naam = '023769'


SELECT	
		R.REGISTRATIONID AS 'Consult_id'
	,	R.PATIENTNR AS 'Patient_id'
	,	CAST(R.DATE AS DATE) AS 'Datum'
    ,   R.*

FROM CONSULT_REGISTRATION AS [R] 

WHERE 1=1
	AND R.DATE BETWEEN '2025-01-01' AND '2025-04-30'
    AND R.PATIENTNR = '010976121' -- 2025-04-29 afspraaknummer 0023571637
    AND CAST(R.DATE AS DATE) = '2025-04-29'



SELECT * 
FROM AGENDA_AFSPRAAK 
WHERE 1=1
    AND PATIENTNR = '010976121' 
    AND AFSPRAAKNR = '0023571637'

SELECT *
FROM CONSULT_REGCONTEXT
WHERE 1=1
    AND CLASSID = 'AGENDA_AFSPRAAK'
    AND OBJECTID = '0023571637' -- Afspraaknummer