source(output(
		ID as short,
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
	folderPath: 'CustSCDTYPE2',
	fileName: 'Day2_Cust.csv',
	columnDelimiter: ',',
	escapeChar: '\\',
	quoteChar: '\"',
	columnNamesAsHeader: true) ~> AdlsCSVSource
source(output(
		CustId as integer,
		HashKey as long
	),
	allowSchemaDrift: true,
	validateSchema: false,
	format: 'query',
	store: 'sqlserver',
	query: 'Select  CustId, HashKey from dbo.CUST_SCDTYPE2 where isActive=1',
	isolationLevel: 'READ_UNCOMMITTED') ~> Target
AdlsCSVSource select(mapColumn(
		each(match(1==1),
			concat('src_',$$) = $$)
	),
	skipDuplicateMapInputs: true,
	skipDuplicateMapOutputs: true) ~> Rename
Rename derive(src_HashKey = crc32(concat(toString(src_ID),src_Name,src_City,toString(src_Phone)))) ~> GenerateHashKey
GenerateHashKey, Target lookup(src_ID == CustId,
	multiple: false,
	pickup: 'any',
	broadcast: 'auto')~> lookupTarget
lookupTarget split(isNull(CustId),
	src_ID==CustId && src_HashKey!=HashKey,
	disjoint: false) ~> Split@(Insert, Update)
Split@Update derive(src_UpdatedBy = 'Dataflow-Updated',
		src_UpdatedDate = currentTimestamp(),
		src_isActive = 0) ~> AuditUpdateColumns
AuditUpdateColumns alterRow(updateIf(1==1)) ~> alterRow
Split@Insert, Split@Update union(byName: true)~> union
union derive(src_CreatedBy = 'DataFlow',
		src_CreatedDate = currentTimestamp(),
		src_UpdatedBy = 'DataFlow',
		src_UpdatedDate = currentTimestamp(),
		src_isActive = 1) ~> InsertAuditColumns
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
		HashKey as long,
		isActive as integer
	),
	format: 'table',
	store: 'sqlserver',
	schemaName: 'dbo',
	tableName: 'CUST_SCDTYPE2',
	insertable: false,
	updateable: true,
	deletable: false,
	upsertable: false,
	keys:['CustId','HashKey'],
	skipDuplicateMapInputs: true,
	skipDuplicateMapOutputs: true,
	errorHandlingOption: 'stopOnFirstError',
	mapColumn(
		CustId,
		UpdatedBy = src_UpdatedBy,
		UpdatedDate = src_UpdatedDate,
		HashKey,
		isActive = src_isActive
	)) ~> sinkUpdate
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
		HashKey as long,
		isActive as integer
	),
	format: 'table',
	store: 'sqlserver',
	schemaName: 'dbo',
	tableName: 'CUST_SCDTYPE2',
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
		HashKey = src_HashKey,
		isActive = src_isActive
	)) ~> sinkInsert