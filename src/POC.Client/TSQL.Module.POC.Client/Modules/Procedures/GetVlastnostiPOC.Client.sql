CREATE
PROCEDURE [Module.POC.Client].[GetVlastnostiPOC.Client]
	--@O_Result [Module.POC.Client].[VlastnostiPOC.Client] = null,
	@blokObjectId bigint
AS

BEGIN

	--declare @blokObjectId bigint = 11672;
	--declare @O_Result [Module.POC.Client].[VlastnostiPOC.Client] = null
	--if (object_id('tempdb..#aks') is not null) drop table #aks
	--if (object_id('tempdb..#ath') is not null) drop table #ath
	--if (object_id('tempdb..#result') is not null) drop table #result
	select top 0 * into #aks from [Core.Template].[AttributeSet]		

	;with validDdc as
	(
		select ID_CONNECT from [Core].[DDC] where ID_ATTRIB in (select am.ID from AM_WIDE am where OBJECT='DataDoDD.Terc')
		UNION ALL
		select ID_CONNECT from [Core].[DDC] where ID_ATTRIB in (select am.ID from AM_WIDE am where OBJECT in (select o.NAME from Core.OBJECTS o where o.OBJECT_TYPE in ('DataExportDd','VypocetDd')) and MEMBER like 'AdresaVTerciDat.Output:%')
	)
	insert into #aks
	(ID_ATTRIB, OBJECT_INDEX, OBSERV_INDEX)
	SELECT ID,-1, -1 from 
	(
		SELECT [ID] 
		FROM [Core].[AM_WIDE] 
		WHERE [OBJECT] in (
			SELECT [NAME] FROM [Core].[OBJECTS] WHERE [ID] = @blokObjectId 
			UNION ALL
			select [NAME] FROM [Core].[OBJECTS] where HOST_OBJECT_NAME=(SELECT o.[NAME] FROM [Core].[OBJECTS] o WHERE o.[ID] = @blokObjectId )
		) AND [ID] IN (select [ID_CONNECT] from validDdc)
	)x

	select top 0 * into #ath from [Core.Template].[ArchiveTable]
	exec [API].[GetAttributeSetRecords] @I_AttributeSet='#aks',@O_Result='#ath'

	select top 0 * into #result from  [Module.POC.Client].[VlastnostiPOC.Client]
	insert into #result([CasHodnoty], [CasHlaseni], [Objekt], [Velicina], [HodnotaFloat], [HodnotaText], [HodnotaInt], [Jednotka])
	SELECT 
			[CasHodnoty] = isnull(ath.[PROCESS_TIME],'1900-01-01')
		,[CasHlaseni] = isnull(ath.[REPORT_TIME],'1900-01-01')
		,[Objekt] = am.[OBJECT]
		,[Velicina] = am.[MEMBER]
		,[HodnotaFloat] = ath.[VALUE_FLOAT]
		,[HodnotaText] = case 
							when ath.PROCESS_TIME is null then '--unknown--'
							when enum.[ENUM_MEMBER_CODE] is not null then '('+cast(enum.[ENUM_MEMBER_CODE] as varchar(20))+')# '+enum.HUMAN_NAME
							else ath.[VALUE_TEXT]
						 end
		,[HodnotaInt] = case 
							when ath.PROCESS_TIME is null then aks.ID_ATTRIB --tohle je hack, kvuli ladeni vypoctu. Posleme si Text --unknown-- a int value = ID_ATTRIB a zkusime to najit v snapshotu
							when enum.[ENUM_MEMBER_CODE] is not null then null
							else ath.[VALUE_INTEGER]
						end
		,[Jednotka] = null
	FROM (select distinct ID_ATTRIB from #aks ) aks
	JOIN [Core].[AM_WIDE] am  
	ON aks.[ID_ATTRIB] = am.[ID]
	LEFT JOIN #ath ath
	ON (aks.ID_ATTRIB=ath.ID_ATTRIB)
	LEFT JOIN [Core].[TYPES_ENUMERATION_MEMBER] enum
	ON (am.VALUE_CLASS in ('ENUMERATION_NUMERIC', 'ENUMERATION_TEXT')
	and am.VALUE_CLASS_SUBTYPE=enum.ENUMERATION
	and ath.VALUE_INTEGER=enum.[ENUM_MEMBER_CODE])

	select * from #result
	order by Objekt, Velicina, CasHodnoty





end