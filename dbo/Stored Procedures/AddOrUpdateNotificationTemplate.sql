
CREATE PROCEDURE [dbo].[AddOrUpdateNotificationTemplate]
(
	@NotificationAsJSONString	NVARCHAR(MAX) = ''
)
AS
BEGIN
	/*---------------------------------------------------------------------------------------------------------------------------
		Since, the Notification details are being passed as JSON String, extracting the values from the JSON string.
	---------------------------------------------------------------------------------------------------------------------------*/
	DECLARE 
		@Result				NVARCHAR(MAX)	= '',
		@NotificationTemplateId		INT		= TRY_CAST(JSON_VALUE(@NotificationAsJSONString,'$.Id') AS INT),
		@NotificationTemplateTypeId	INT		= TRY_CAST(JSON_VALUE(@NotificationAsJSONString,'$.NotificationTemplateTypeId') AS INT),
		@ClientId			INT				= TRY_CAST(JSON_VALUE(@NotificationAsJSONString,'$.ClientId') AS INT),
		@NotificationName	NVARCHAR(100)	= JSON_VALUE(@NotificationAsJSONString,'$.Name'),		
		@Subject	NVARCHAR(100)	= JSON_VALUE(@NotificationAsJSONString,'$.Subject'),		
		@Placeholders		NVARCHAR(500)	= JSON_VALUE(@NotificationAsJSONString,'$.Placeholders')
		


	DECLARE @NotificationTemplateTypeIdPush INT,@NotificationTemplateTypeIdSMS INT,@NotificationTypeId INT,@Display bit = 1,@NotificareTemplateId NVARCHAR(100)	= NEWID() 
	select @NotificationTemplateTypeIdPush = Id from NotificationTemplateType where clientid = @ClientId AND Name = 'Push'
	select @NotificationTemplateTypeIdSMS = Id from NotificationTemplateType where clientid = @ClientId AND Name = 'SMS'
	select @NotificationTypeId = Id from NotificationType where clientid = @ClientId AND Name = 'System'

	IF(@NotificationTemplateTypeId = @NotificationTemplateTypeIdPush)
	BEGIN
		SET @Placeholders = '{ "Subject": "'+@Subject+'", "Body": "'+@Placeholders+'" }'
		SET @NotificareTemplateId = 'p-'+ LOWER(REPLACE(@NotificareTemplateId,'-',''))
	END
	IF(@NotificationTemplateTypeId = @NotificationTemplateTypeIdSMS)
	BEGIN
		SET @Placeholders = '{ "Content": "'+@Placeholders+'" }'
		SET @NotificareTemplateId = 's-'+ LOWER(REPLACE(@NotificareTemplateId,'-',''))
	END

	/*---------------------------------------------------------------------------------------------------------------------------
		validating the JSON string,ClientId and the subject.
	---------------------------------------------------------------------------------------------------------------------------*/

	IF ISJSON(ISNULL(@NotificationASJSONString,'')) = 0 OR ISJSON(@NotificationASJSONString) = 0
	BEGIN
		SELECT 'InvalidNotification' AS Result
		RETURN
	END
	IF @ClientId IS NULL OR @ClientId = 0
	BEGIN
		SELECT 'InvalidClient' AS Result
		RETURN		
	END
	IF LEN(ISNULL(@NotificationName,'')) = 0 
	BEGIN
		SELECT 'InvalidName' AS Result
		RETURN		
	END
	IF ISNULL(@Placeholders,'') = ''
	BEGIN
		SELECT 'InvalidPlaceholders' AS Result
		RETURN	
	END

	BEGIN TRY
		/*----------------------------------------------------------------------------------------------
			Checking whether the @NotificationId > 0, then the old values are updated with the new ones.
			Else, new record is being inserted.
		----------------------------------------------------------------------------------------------*/
		IF @NotificationTemplateId > 0
		BEGIN
			PRINT 'UPDATE'
			UPDATE [dbo].[NotificationTemplate]
			   SET [Version] = [Version]+1
				  ,[NotificationTemplateTypeId] = @NotificationTemplateTypeId
				  ,[Name] = @NotificationName
				  --,[Display] = <Display, bit,>
				  --,[NotificareTemplateId] = @NotificareTemplateId
				  ,[Placeholders] = @Placeholders
				  --,[NotificationTypeId] = <NotificationTypeId, int,>
			 WHERE Id = @NotificationTemplateId
		END
		ELSE
		BEGIN
			PRINT 'INSERT'
			INSERT INTO [dbo].[NotificationTemplate]([Version],[NotificationTemplateTypeId],[Name],[Display],[NotificareTemplateId],[Placeholders],[NotificationTypeId])
			VALUES(0,@NotificationTemplateTypeId,@NotificationName,@Display,@NotificareTemplateId,@Placeholders,@NotificationTypeId)

			SET @NotificationTemplateId = SCOPE_IDENTITY()
		END
		/*---------------------------------------------------------------------------------------------
			Updating the UserNotifications by replacing  the old records with the new ones.
		---------------------------------------------------------------------------------------------*/
		

		SET @Result = '
		{
			"Success":true,
			"Message":"SaveNotificationSuccess",
			"Data":' + CAST(@NotificationTemplateId AS NVARCHAR(200)) + '
		}'

	END TRY
	BEGIN CATCH

		SET @Result =	'SaveNotificationFailed;
						 ErrorProcedure:'	+	ERROR_PROCEDURE() +
						'Error at Line:'	+	CAST(ERROR_LINE() AS NVARCHAR(100))	+
						'Exception Message:'+	ERROR_MESSAGE()	
	END CATCH

	SELECT @Result AS Result
END