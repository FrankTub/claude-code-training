SELECT distinct
        [Group_Name]
    ,   [Program_Name]
	,   Protocol
 
FROM [BIC_HiX_HDW].[dbo].[LUSCII DATA]

where 1=1
    and Group_Name <> 'demo'

--

SELECT * 
FROM [BIC_HiX_HDW].[dbo].[LUSCII DATA]
WHERE 1=1
    --AND Group_Name = 'CVA'