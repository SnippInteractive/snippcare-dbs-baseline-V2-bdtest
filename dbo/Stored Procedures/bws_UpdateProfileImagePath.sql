	CREATE PROCEDURE [dbo].[bws_UpdateProfileImagePath](@profileId int,@path varchar(250))
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	BEGIN TRY
BEGIN TRAN
    Update DeviceProfileTemplate set ImageUrl=@path where Id=@profileId;

	--IF MultiLanguageEnabled update Config json data
	Declare @ClientId INT
	select @ClientId = ClientId from DeviceProfileTemplateType where Id = (Select DeviceProfileTemplateTypeId from DeviceProfileTemplate where id= @profileId)

	if exists(select * from ClientConfig where [Key] = 'MultiLanguageEnabled' and clientid = @ClientId and [Value] = 'true')
	begin
	 
		Declare @jsonIndex INT = -1, @json nvarchar(max), @updatedjson nvarchar(max), @languageCode nvarchar(5)

		Select @json = Config From DeviceProfileTemplate where Id=@profileId

		-- find language code from url
		select @languageCode = left(right(@path, charindex('.', reverse(@path))+2),2)

		if @json is not null
		begin
			SELECT  @jsonIndex = CONVERT(int, j1.[key])
			FROM OPENJSON (@json, '$.Content') j1
			CROSS APPLY OPENJSON(j1.[value], '$') WITH (
			   LanguageCode nvarchar(2) '$.LanguageCode'
			) j2
			where j2.LanguageCode = @languageCode

			if @jsonIndex <> -1
			begin
				SELECT @updatedjson = JSON_MODIFY(@json, '$.Content['+CONVERT(VARCHAR(15),@jsonIndex)+'].ImageUrl', @path)
				Update DeviceProfileTemplate set Config=@updatedjson where Id=@profileId;
			end
			

		end

	end

	COMMIT TRAN
END TRY
BEGIN CATCH
    ROLLBACK TRAN
END CATCH
END
