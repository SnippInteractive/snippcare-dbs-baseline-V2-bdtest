CREATE PROCEDURE ValidateVoucherCode
(
	@VoucherCriteria		NVARCHAR(MAX),
	@Result					NVARCHAR(MAX) OUTPUT
)
AS
BEGIN
	DECLARE @VoucherCode	NVARCHAR(100)='',
			@UserId			INT,
			@Classical		BIT,
			@DeviceId		NVARCHAR(100),
			@DateUsed		DATETIMEOFFSET,
			@ExpirationDate DATETIMEOFFSET,
			@ExtReference   NVARCHAR(MAX),
			@Value			INT,
			@ValueType      NVARCHAR(10),
			@ClientId		INT
			


	IF ISJSON(ISNULL(@VoucherCriteria,'')) <> 1
	BEGIN
		SET @Result = 'InvalidCritieria'
		RETURN
	END

	SELECT	@VoucherCode = JSON_VALUE(@VoucherCriteria,'$.VoucherCode'),
			@UserId = ISNULL(TRY_CAST(JSON_VALUE(@VoucherCriteria,'$.UserId') AS INT),0),
			@ClientId = ISNULL(TRY_CAST(JSON_VALUE(@VoucherCriteria,'$.ClientId') AS INT),0)
	
	
	IF @VoucherCode IS NULL OR LEN(@VoucherCode) = 0
	BEGIN
		PRINT 'VoucherCode is Null'
		SET @Result = 'InvalidVoucherCode'
		RETURN
	END


	SELECT	@DeviceId = DeviceId,
			@Classical = Classical,
			@DateUsed = DateUsed,
			@ExpirationDate = ExpirationDate,
			@ExtReference = ExtReference,
			@Value = [Value],
			@ValueType = ValueType
	FROM	VoucherCodes
	WHERE	DeviceId = @VoucherCode
	AND		ExpirationDate > GETDATE()
	AND     ClientId = @ClientId

	IF @DeviceId IS NULL 
	BEGIN
		PRINT 'VoucherCode is not found'
		SET @Result = 'InvalidVoucherCode'
		RETURN	
	END
	--IF CAST(ISNULL(@Classical,0) AS BIT) = 1 AND @UserId = 0
	--BEGIN
	--	PRINT 'UserId is invalid'
	--	SET @Result = 'InvalidUserId'
	--	RETURN	
	--END

	DECLARE		@HasVoucherUsedAlready BIT = 0
	IF CAST(ISNULL(@Classical,0) AS BIT) = 1
	BEGIN
		SELECT		@HasVoucherUsedAlready = CASE WHEN COUNT(detail.TrxDetailId) > 0 THEN 1 ELSE 0 END
		FROM		TrxDetail detail
		INNER JOIN	TrxHeader header
		ON			detail.TrxId = header.TrxId
		INNER JOIN	Device d
		ON			header.DeviceId = d.DeviceId
		WHERE		detail.ItemCode = @VoucherCode
		AND			d.UserId = @UserId
	END
	ELSE
	BEGIN
		SET @HasVoucherUsedAlready = CASE WHEN @DateUsed IS NOT NULL THEN 1 ELSE 0 END	
	END

	IF @HasVoucherUsedAlready = 1
	BEGIN
		PRINT 'VoucherCode Used already'
		SET @Result = 'InvalidVoucherCode'
		RETURN			
	END


	SET @Result  = 
	(
		SELECT	@UserId AS UserId,
				@ExpirationDate AS ExpirationDate,
				@ExtReference AS ExtReference,
				@Value AS [Value],
				@ValueType AS ValueType,
				@Classical AS Classical,
				@DateUsed AS DateUsed

		FOR	JSON PATH,WITHOUT_ARRAY_WRAPPER,INCLUDE_NULL_VALUES
				
	)

		/*
		DECLARE @VoucherCriteria NVARCHAR(MAX) = '{"VoucherCode":"6j9HTQIcSLD6","UserId":"1403870"}',
		@Result NVARCHAR(MAX)
		EXEC ValidateVoucherCode @VoucherCriteria,@Result OUTPUT
		SELECT @Result
		*/

END