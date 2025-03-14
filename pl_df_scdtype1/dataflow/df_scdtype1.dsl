source(output(
		ID as integer,
		Name as string,
		City as string,
		Phone as long
	),
	useSchema: false,
	allowSchemaDrift: true,
	validateSchema: false,
	ignoreNoFilesFound: false,
	format: 'delimited',
	fileSystem: 'mycontainer',
	folderPath: 'CustSCDTYPE1',
	fileName: 'Day2_Cust.csv',
	columnDelimiter: ',',
	escapeChar: '\\',
	quoteChar: '\"',
	columnNamesAsHeader: true,
	multiLineRow: true) ~> source1
source(output(
		CustId as integer,
		Hashkey as long
	),
	allowSchemaDrift: true,
	validateSchema: false,
	format: 'query',
	store: 'sqlserver',
	query: 'Select CustId, Hashkey from dbo.CUST_SCDTYPE1',
	isolationLevel: 'READ_UNCOMMITTED') ~> source2
source1 select(mapColumn(
		each(match(1==1),
			concat('src_',$$) = $$)
	),
	skipDuplicateMapInputs: true,
	skipDuplicateMapOutputs: true) ~> Rename
Rename derive(src_Hashkey = crc32(concat(toString(src_ID), src_Name, src_City, toString(src_Phone)))) ~> Hashkey
Hashkey, source2 lookup(src_ID == CustId,
	multiple: false,
	pickup: 'any',
	broadcast: 'auto')~> lookup
lookup split(isNull(CustId),
	src_ID == CustId && Hashkey != src_Hashkey,
	disjoint: true) ~> split@(Insert, Update)
split@Insert derive(src_CreatedBy = 'DataFlow',
		src_CreatedDate = currentTimestamp(),
		src_UpdatedBy = 'DataFlow',
		src_UpdatedDate = currentTimestamp()) ~> InsertAuditColumns
split@Update derive(src_UpdatedBy = 'Dataflow-Updated',
		src_UpdatedDate = currentTimestamp()) ~> UpdateAuditColumns
UpdateAuditColumns alterRow(updateIf(1==1)) ~> alterRow
InsertAuditColumns sink(allowSchemaDrift: true,
	validateSchema: false,
	input(
		CustId as integer,
		CustName as string,
		CustCity as string,
		CustPhoneNumber as long,
		CreatedBy as string,
		CreatedDate as timestamp,
		UpdatedBy as string,
		UpdatedDate as timestamp,
		HashKey as long
	),
	format: 'table',
	store: 'sqlserver',
	schemaName: 'dbo',
	tableName: 'CUST_SCDTYPE1',
	insertable: true,
	updateable: false,
	deletable: false,
	upsertable: false,
	skipDuplicateMapInputs: true,
	skipDuplicateMapOutputs: true,
	errorHandlingOption: 'stopOnFirstError',
	mapColumn(
		CustId = src_ID,
		CustName = src_Name,
		CustCity = src_City,
		CustPhoneNumber = src_Phone,
		CreatedBy = src_CreatedBy,
		CreatedDate = src_CreatedDate,
		UpdatedBy = src_UpdatedBy,
		UpdatedDate = src_UpdatedDate,
		HashKey = src_Hashkey
	)) ~> sinkInsert
alterRow sink(allowSchemaDrift: true,
	validateSchema: false,
	input(
		CustId as integer,
		CustName as string,
		CustCity as string,
		CustPhoneNumber as long,
		CreatedBy as string,
		CreatedDate as timestamp,
		UpdatedBy as string,
		UpdatedDate as timestamp,
		HashKey as long
	),
	format: 'table',
	store: 'sqlserver',
	schemaName: 'dbo',
	tableName: 'CUST_SCDTYPE1',
	insertable: false,
	updateable: true,
	deletable: false,
	upsertable: false,
	keys:['CustId'],
	skipDuplicateMapInputs: true,
	skipDuplicateMapOutputs: true,
	errorHandlingOption: 'stopOnFirstError',
	mapColumn(
		CustId = src_ID,
		CustName = src_Name,
		CustCity = src_City,
		CustPhoneNumber = src_Phone,
		UpdatedBy = src_UpdatedBy,
		UpdatedDate = src_UpdatedDate,
		HashKey = src_Hashkey
	)) ~> sinkUpdate