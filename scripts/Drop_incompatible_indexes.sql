--Script to generate required drop statements for Fabric Mirroring to work for SQL Server databases
SELECT 'ALTER TABLE [' + SchemaName + '].[' + Table_name + '] DROP CONSTRAINT [' + IndexName + ']'
FROM (
	SELECT SchemaName = ss.name
		,so.object_id
		,Table_name = so.name
		,SysColName = sc.name
		,EI.*
	FROM sys.objects so
	INNER JOIN sys.schemas ss ON so.schema_id = ss.schema_id
	INNER JOIN sys.columns sc ON sc.object_id = so.object_id
	INNER JOIN (
		SELECT ColumnName = sc.name
			,IndexName = si.name
			,SysTypeName = st.name
			,ColObject_id = sc.object_id
			,sc.column_id
		FROM sys.columns sc
		JOIN sys.indexes si ON sc.object_id = si.object_id
			AND (
				si.is_primary_key = 1
				OR si.is_unique = 1
				)
		JOIN sys.index_columns sic ON sc.object_id = sic.object_id
			AND si.index_id = sic.index_id
			AND sic.column_id = sc.column_id
		JOIN sys.types st ON sc.user_type_id = st.user_type_id
		-- geometry, geography, hierachyid, image, text, ntext, sql_variant, timestamp, xml, UDT
		WHERE (sc.system_type_id IN (240,34,35,99,98,189,241)
				OR (sc.system_type_id IN (41,42,43)
					AND sc.scale = 7
					)
				OR st.is_user_defined = 1
				OR sc.is_computed = 1
				)
		) AS EI ON EI.ColObject_id = so.object_id
		AND EI.column_id = sc.column_id
	WHERE so.type = 'U'
	) AS X