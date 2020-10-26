CREATE TABLE [Module.POC.IDS.TSQL].[VlastnostiPOC.IDS.TSQL]
(
	CasHodnoty datetime not null,
	CasHlaseni datetime not null,
	Objekt varchar(128) not null,
	Velicina varchar(128) not null,
	HodnotaFloat float,
	HodnotaText varchar(MAX),
	HodnotaInt bigint,
	Jednotka varchar(128)
)
