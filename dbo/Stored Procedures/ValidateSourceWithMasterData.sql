
CREATE PROCEDURE ValidateSourceWithMasterData
(
	@Source					NVARCHAR(MAX) = '',
	@ClientId				INT,
	@ClientConfigKey		NVARCHAR(100) = '',
	@MasterTableName		NVARCHAR(100) = '',
	@Result					NVARCHAR(100) OUTPUT
)
AS
BEGIN
SET NOCOUNT ON
	DECLARE @ClientConfigVal		NVARCHAR(MAX) = '',
			@IsValidationRequired	NVARCHAR(6)   = '',
			@ValidationConfig		NVARCHAR(MAX) = '',
			@ExtensionPropertyName  NVARCHAR(MAX) = '',
			@SourceName				NVARCHAR(100) = '',
			@DeclareClause			NVARCHAR(MAX) = '',
			@SelectClause			NVARCHAR(MAX) = '',
			@WhereClause			NVARCHAR(MAX) = '',
			@SQL					NVARCHAR(MAX) = '',
			@FieldCounter			INT

	DECLARE @SourceMasterMapping	TABLE
	(
		Id							INT IDENTITY(1,1),
		MasterDataFieldName			NVARCHAR(200),
		SourcePropertyName			NVARCHAR(200),
		SourcePropertyValue			NVARCHAR(200)
	)

	DECLARE @ResultTable	TABLE(Result NVARCHAR(10))

	-- Checking whether @Source is a valid json.
	IF ISJSON(@Source) = 0
	BEGIN
		SET @Result = 'InvalidJson'
		RETURN
	END

	-- Checking whether the ClientId is valid.
	IF ISNULL(@ClientId,0) = 0
	BEGIN
		SET @Result = 'InvalidClient'
		RETURN
	END

	-- Checking whether the ClientConfigKey is valid.
	IF ISNULL(@ClientConfigKey,'') = ''
	BEGIN
		SET @Result = 'InvalidConfigKey'
		RETURN
	END

	IF NOT EXISTS (SELECT Top 1 Id FROM ClientConfig WHERE ClientId = @ClientId AND [Key] = @ClientConfigKey)
	BEGIN
		SET @Result = 'InvalidConfigKey'
		RETURN
	END

	IF LEN(@MasterTableName) = 0 OR NOT EXISTS(SELECT 1 FROM sys.tables WHERE NAME = @MasterTableName)
	BEGIN
		SET @Result = 'InvalidMasterTable'
		RETURN
	END
	-- Fetching the value from the client config for the key
	/*
		The key  in the client config is being used to enable/disable masterdata check 
		and contains the mapping fields of masterData and Request body. 
	*/
	SELECT @ClientConfigVal = [Value]
	FROM   ClientConfig 
	WHERE  ClientId = @ClientId
	AND    [Key] = @ClientConfigKey

	IF ISNULL(@ClientConfigVal,'') = '' OR ISJSON(@ClientConfigVal) <> 1
	BEGIN
		SET @Result = 'InvalidConfiguration'
		RETURN
	END

	SET @IsValidationRequired = JSON_VALUE(@ClientConfigVal,'$.Enabled')
	SET @SourceName = ISNULL(JSON_VALUE(@ClientConfigVal,'$.SourceName'),'Source')

	IF ISNULL(@IsValidationRequired,'false') = 'true'
	BEGIN
		SET @Source = '{ "'+@SourceName+'":' + @Source + '}'
		SET @ValidationConfig  = JSON_QUERY(@ClientConfigVal,'$.Config')
		IF ISNULL(@ValidationConfig,'') = '' OR ISJSON(@ValidationConfig) <> 1
		BEGIN
			SET @Result = 'InvalidConfiguration'
			RETURN
		END

		INSERT @SourceMasterMapping(MasterDataFieldName,SourcePropertyName)
		SELECT [key],[value]
		FROM   OPENJSON(@ValidationConfig) 
		
		IF (SELECT COUNT(Id) FROM @SourceMasterMapping) = 0
		BEGIN
			SET @Result = 'InvalidConfiguration'
			RETURN
		END

		SELECT TOP 1 @ExtensionPropertyName = ISNULL(SourcePropertyName,'')
		FROM   @SourceMasterMapping
		WHERE  MasterDataFieldName = 'ExtensionData'

		IF(LEN(@ExtensionPropertyName) > 0)
		BEGIN
			SET @ExtensionPropertyName = '$.'+ @ExtensionPropertyName
		END

		IF LEN(@ExtensionPropertyName) > 0
		BEGIN
			SET @DeclareClause = '
				DECLARE @SourceExtensionData    TABLE
				(
					Id						INT IDENTITY(1,1),
					PropertyName			NVARCHAR(100),
					PropertyValue			NVARCHAR(100)
				)

				DECLARE @SourceExtensionJSON NVARCHAR(MAX) = ''''
				SET @SourceExtensionJSON = JSON_QUERY('''+@Source+''','''+@ExtensionPropertyName+''')
			
				-- Fetching the Member Extension data.
				IF ISJSON(@SourceExtensionJSON) = 1
				BEGIN
					INSERT	@SourceExtensionData(PropertyName,PropertyValue)
					SELECT	PropertyName,PropertyValue
					FROM	OPENJSON(@SourceExtensionJSON) 
					WITH	(PropertyName NVARCHAR(100) ''$.PropertyName'',PropertyValue NVARCHAR(100) ''$.PropertyValue'')
				END
			
			
					
			'
		END
		ELSE
		BEGIN
			SET @DeclareClause = '
			'
		END

		SET @SelectClause = '
			SELECT CASE WHEN COUNT(masterdata.Id) > 0 THEN ''true'' ELSE ''false'' END AS Status
			FROM   '+@MasterTableName+' masterdata
		'

		SET @WhereClause = '
			WHERE  masterdata.ClientId = '+CAST(@ClientId AS VARCHAR(10))+' 
			AND 
			(
		'

		SELECT	@FieldCounter = MIN(Id) 
		FROM	@SourceMasterMapping

		WHILE @FieldCounter IS NOT NULL
		BEGIN
			DECLARE	@SourcePropertyName  NVARCHAR(100) = '',
					@SourcePropertyValue NVARCHAR(100) = '',
					@MasterDataField	 NVARCHAR(100) = ''

			SELECT  @SourcePropertyName = SourcePropertyName,
					@MasterDataField = MasterDataFieldName
			FROM    @SourceMasterMapping
			WHERE   MasterDataFieldName <> 'ExtensionData'
			AND		Id = @FieldCounter

			SET @SourcePropertyValue = ISNULL(JSON_VALUE(@Source,'$.'+ @SourcePropertyName),'')

			IF LEN(@SourcePropertyValue) > 0 AND LEN(@MasterDataField) > 0
			BEGIN
				IF @FieldCounter = 1
				BEGIN
					SET @WhereClause = @WhereClause + '
						ISNULL(CAST(masterdata.'+ @MasterDataField +' AS NVARCHAR(100)),'''') = '''+ @SourcePropertyValue +'''
					'
				END
				ELSE
				BEGIN
					SET @WhereClause = @WhereClause + '
						AND	ISNULL(CAST(masterdata.'+ @MasterDataField +' AS NVARCHAR(100)),'''') = '''+ @SourcePropertyValue +'''
					'
				END
			END

			UPDATE  @SourceMasterMapping
			SET     SourcePropertyValue = JSON_VALUE(@Source,'$.'+ SourcePropertyName)
			WHERE   Id = @FieldCounter

			SELECT	@FieldCounter = MIN(Id) 
			FROM	@SourceMasterMapping
			WHERE   MasterDataFieldName <> 'ExtensionData'
			AND	    Id > @FieldCounter
		END

		IF LEN(@ExtensionPropertyName) > 0 AND ISJSON(JSON_QUERY(@Source,''+@ExtensionPropertyName+'')) = 1
		BEGIN
			SET @WhereClause = @WhereClause + '
						AND EXISTS
						(	
							SELECT ma.*
							FROM   
							(
								SELECT PropertyName,PropertyValue
								FROM   OPENJSON(masterdata.ExtensionData) 
								WITH	(PropertyName NVARCHAR(100) ''$.PropertyName'',PropertyValue NVARCHAR(100) ''$.PropertyValue'')							
							) ma
							INNER JOIN @SourceExtensionData me
							ON ma.PropertyName COLLATE DATABASE_DEFAULT = me.PropertyName COLLATE DATABASE_DEFAULT
							AND ma.PropertyValue COLLATE DATABASE_DEFAULT = me.PropertyValue COLLATE DATABASE_DEFAULT
						)
				
			'			
		END

		SET @WhereClause = @WhereClause + '
			)
		'

		SET @SQL = @SQL + @DeclareClause + @SelectClause + @WhereClause
		INSERT @ResultTable(Result)
		EXEC(@SQL)
		PRINT @DeclareClause
		PRINT @SelectClause
		PRINT @WhereClause

		SET NOCOUNT ON
		SELECT TOP 1 @Result = Result  FROM @ResultTable
	END
	ELSE
	BEGIN
		SET @Result = 'true'
	END
	SET NOCOUNT OFF
END
