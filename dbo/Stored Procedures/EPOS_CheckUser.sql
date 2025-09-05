-- =============================================
-- Modified by:		Binu Jacob Scaria
-- Date: 2022-10-11
-- Description:	Include / Exclude
-- Modified Date: 2022-10-11
-- =============================================
CREATE PROCEDURE [dbo].[EPOS_CheckUser](@ClientId int,@SourceAddress nvarchar(50),@SiteRef nvarchar(25) = null)
AS
BEGIN
-- SET NOCOUNT ON added to prevent extra result sets from
-- interfering with SELECT statements
SET NOCOUNT ON;
	
BEGIN TRY                              
	DECLARE @UserId INT = 0,@DeviceId NVARCHAR(25),@profileType NVARCHAR(25) = 'Loyalty', @IsVirtual INT = 1,@message NVARCHAR(50)
IF ISNULL(@SourceAddress,'') != ''
BEGIN
	Declare @userstatusid int, @UserTypeId INT,@DeviceStatusIdActive INT
    SELECT @userstatusid =UserStatusId FROM UserStatus  WHERE [Name]='Active' and clientid = @clientid  
	SELECT @UserTypeId = [UserTypeId] FROM UserType  WHERE [Name]='LoyaltyMember' and clientid = @clientid 
	select @DeviceStatusIdActive = DeviceStatusId from [DeviceStatus]  WHERE [Name]='Active' and clientid = @clientid 
	
	if CHARINDEX('@',@SourceAddress) > 0 --EMAIL SEARCH
	begin
		SELECT Top 1 @UserId = u.UserId FROM [dbo].[User] u  
		INNER JOIN [dbo].[UserContactDetails] ucd   ON u.UserId = ucd.UserId   
		INNER JOIN [dbo].[ContactDetails] cd   ON ucd.ContactDetailsId = cd.ContactDetailsId  
		WHERE cd.Email = @SourceAddress  AND U.UserStatusId =@userstatusid AND  U.UserTypeId= @UserTypeId
	end
	--ELSE if ISNULL(@UserId,0) = 0 AND isnumeric(@SourceAddress) = 1 AND LEFT(@SourceAddress,1) <>'+' -- Userid Search
	--BEGIN
	--	SELECT Top 1 @UserId = u.UserId FROM [dbo].[User] u  
	--       WHERE u.userid = convert(int, @SourceAddress)  
	--	AND U.UserStatusId =@userstatusid AND  U.UserTypeId= @UserTypeId
	--END
	if ISNULL(@UserId,0) = 0 AND isnumeric(@SourceAddress) = 1 AND LEFT(@SourceAddress,1) ='+' -- Mobile with MobilePrefix
	BEGIN
	
		SELECT Top 1 @UserId = u.UserId FROM [dbo].[User] u   
		INNER JOIN [dbo].[UserContactDetails] ucd   ON u.UserId = ucd.UserId 
		INNER JOIN [dbo].[ContactDetails] cd   ON ucd.ContactDetailsId = cd.ContactDetailsId  
		INNER JOIN [dbo].[PersonalDetails] pd   ON u.PersonalDetailsId = pd.PersonalDetailsId  
		INNER JOIN [dbo].UserAddresses ua   ON u.UserId = ua.UserId
		INNER JOIN [dbo].[Address] a   on ua.AddressId = a.AddressId
		INNER JOIN [dbo].[Country] c   on a.CountryId = c.CountryId AND C.MobilePrefix IS NOT NULL
		WHERE U.UserStatusId =@userstatusid AND  U.UserTypeId= @UserTypeId 
		AND (ISNULL(c.MobilePrefix,'') + ISNULL(cd.MobilePhone,''))  = @SourceAddress COLLATE database_default 
		
			

	END
	ELSE IF ISNULL(@UserId,0) = 0 AND isnumeric(@SourceAddress) = 1-- Mobile with out MobilePrefix
	BEGIN
		
		SELECT Top 1 @UserId = u.UserId FROM [dbo].[User] u   
			 WHERE u.Username = @SourceAddress  
			AND U.UserStatusId =@userstatusid AND  U.UserTypeId= @UserTypeId

		IF ISNULL(@UserId,0) = 0 
		BEGIN
		SELECT Top 1 @UserId = u.UserId FROM [dbo].[User] u   
		INNER JOIN [dbo].[UserContactDetails] ucd   ON u.UserId = ucd.UserId 
		INNER JOIN [dbo].[ContactDetails] cd  ON ucd.ContactDetailsId = cd.ContactDetailsId  
		--INNER JOIN [dbo].[PersonalDetails] pd  ON u.PersonalDetailsId = pd.PersonalDetailsId  
		--INNER JOIN [dbo].UserAddresses ua  ON u.UserId = ua.UserId
		--INNER JOIN [dbo].[Address] a  on ua.AddressId = a.AddressId
		--INNER JOIN [dbo].[Country] c  on a.CountryId = c.CountryId
		WHERE U.UserStatusId =@userstatusid AND  U.UserTypeId= @UserTypeId 
		AND cd.MobilePhone = @SourceAddress 
		END
	END
	
	IF ISNULL(@UserId,0) = 0 AND LEFT(@SourceAddress,1) <>'+' AND CHARINDEX('@',@SourceAddress) = 0-- Device ID
	BEGIN
		SELECT TOP 1 @DeviceId = DeviceId, @UserId = UserId FROM Device  WHERE DeviceId = @SourceAddress AND DeviceStatusId = @DeviceStatusIdActive
	END
	--IF ISNULL(@UserId,0) = 0 AND LEFT(@SourceAddress,1) <>'+' AND CHARINDEX('@',@SourceAddress) = 0 AND ISNUMERIC (ISNULL(@SourceAddress,'')) = 1 AND CHARINDEX(',', @SourceAddress) = 0 AND CHARINDEX('.', @SourceAddress) = 0-- UserId 
	--BEGIN
	--	SELECT TOP 1 @DeviceId = DeviceId, @UserId = UserId FROM Device  WHERE UserId = CONVERT(BIGINT,@SourceAddress)
	--END
	--exec GetMemberByMobileOrEmail  8, @SourceAddress,@UserId OUTPUT
	IF ISNULL(@UserId,0) = 0
	BEGIN

	   SELECT TOP 1 @DeviceId = DeviceId FROM Device  WHERE ExtraInfo = @SourceAddress AND DeviceStatusId = @DeviceStatusIdActive
	   SET @message = 'Unregistered'

		IF ISNULL(@DeviceId,'') <> ''
		BEGIN
			DECLARE @TrxStatusCompletedId INT
			SELECT @TrxStatusCompletedId = TrxStatusId From TrxStatus  WHERE ClientId = @ClientId AND Name = 'Completed'
			IF NOT EXISTS (SELECT 1 FROM TrxHeader  Where DeviceId  = @DeviceId AND TrxStatusTypeId = @TrxStatusCompletedId)
			BEGIN
				SET @Message = 'NewUnregistered'
			END
		END

	   IF ISNULL(@DeviceId,'') =''
	   BEGIN
		 --DECLARE  @MyTable TABLE (DeviceId NVARCHAR(50) )
		 --INSERT INTO @MyTable EXEC [dbo].[GetNextAvailableDevice]  @ClientId, @profileType, @DeviceId output, @IsVirtual
		 
		 DROP TABLE IF EXISTS #DL

		 Select devicelotid into #DL
		 from devicelotdeviceprofile dlp
		 inner join DeviceProfileTemplate dpt on dlp.DeviceProfileId = dpt.Id
		 inner join DeviceProfileTemplateType dptt on dpt.DeviceProfileTemplateTypeId = dptt.Id
		 where dptt.ClientId = @ClientId AND dptt.Name = @profileType
		 
		 update device     
		   set ExtraInfo =@SourceAddress, StartDate = GETDATE(),  [Owner]='-1'   ,@DeviceId =DeviceId  
		   where id = (    
			select TOP (1) d.Id     
			from [Device] d  
			inner join #DL dl on d.DeviceLotId = dl.DeviceLotId
			--inner join DeviceProfile dp  on d.id = dp.DeviceId     
			where d.UserId is null     
			and d.ExtraInfo is null  and d.[Owner] is null --and d. --isnull(d.Owner,'0')<>'-1'
			and d.DeviceStatusId = @DeviceStatusIdActive    
			--and dp.DeviceProfileId= @ProfileTypeId    
			and (ABS(CAST(    
			  (BINARY_CHECKSUM    
			  (d.Id, NEWID())) as int))  % 100) < 10    
		   );  

			--select TOP 1 @DeviceId = d.DeviceId
			--from Device d  
			--inner join DeviceProfile dp  on d.id=dp.DeviceId 
			--inner join DeviceProfileTemplate dpt on dp.DeviceProfileId = dpt.Id
			--inner join DeviceProfileTemplateType dptt on dpt.DeviceProfileTemplateTypeId = dptt.Id
			--where d.DeviceStatusId=@DeviceStatusIdActive and dptt.Name = @profileType
			--AND isnull(d.Owner,0)<>'-1' and d.UserId is null and d.ExtraInfo IS NULL

		 --SELECT TOP 1 @DeviceId = d.deviceid
		 --from Device d  inner join DeviceProfile dp  on d.id=dp.DeviceId 
		 --where d.DeviceStatusId=@DeviceStatusIdActive and dp.DeviceProfileId=@ProfileTypeId 
		 --and isnull(d.Owner,0)<>'-1' and d.UserId is null and d.ExtraInfo IS NULL

			IF @DeviceId is not null
			BEGIN
				-- Assign the virtual device to the username
				--Update Device set Owner='-1', ExtraInfo = @SourceAddress ,StartDate = Getdate() where DeviceId = @DeviceId
				-- Audit assigned device
				EXEC Insert_Audit 'I', 1400012, 1, 'Device', 'ExtraInfo',@DeviceId, @SourceAddress

				SET @message = 'NewUnregistered'
			END
			ELSE
			BEGIN
				-- Audit error for no available device assigned 
				EXEC Insert_Audit 'I', 1400012, 1, 'Device', 'ExtraInfo','Error, no availabe device to assign', @SourceAddress
			END
		END
	END
END

IF ISNULL(@UserId,0) > 0 AND ISNULL(@DeviceId,'') = ''
BEGIN
	
	select TOP 1 @DeviceId = d.DeviceId
	from Device d  
	inner join DeviceProfile dp  on d.id=dp.DeviceId 
	inner join DeviceProfileTemplate dpt on dp.DeviceProfileId = dpt.Id
	inner join DeviceProfileTemplateType dptt on dpt.DeviceProfileTemplateTypeId = dptt.Id
	where d.UserId = @UserId AND d.DeviceStatusId=@DeviceStatusIdActive and dptt.Name = @profileType

	--SELECT TOP 1 @DeviceId = d.deviceid
	--from Device d  inner join DeviceProfile dp  on d.id=dp.DeviceId 
	--where d.UserId = @UserId AND d.DeviceStatusId=@DeviceStatusIdActive and dp.DeviceProfileId=@ProfileTypeId 

--select TOP 1 @DeviceId = d.DeviceId
--from   [Device] d 
--where  d.UserId = @UserId AND d.DeviceStatusId = @DeviceStatusIdActive
--       and (exists (select dp.Id from   [DeviceProfile] dp  where  d.Id = dp.DeviceId and 
--	   ((SELECT dt.Name from   DeviceProfileTemplateType dt  inner join DeviceProfileTemplate t  on t.DeviceProfileTemplateTypeId = dt.Id Where  t.Id = dp.DeviceProfileId) in ('Loyalty' /* @p2 */)))
--	   )
--order  by d.DeviceId desc

END

DECLARE @CountryCode NVARCHAR(25),@StateCode NVARCHAR(25)
IF ISNULL(@UserId,0)> 0 AND ISNULL(@SiteRef,'') = 'ecomm' 
BEGIN
	DECLARE @AddressStatusId INT,@AddressTypeId INT,@AddressValidStatusId INT

	SELECT @AddressStatusId = AddressStatusId FROM AddressStatus WHERE Name = 'Current' AND ClientId = @ClientId
	SELECT @AddressTypeId = AddressTypeId FROM AddressType WHERE Name = 'Main' AND ClientId = @ClientId
	SELECT @AddressValidStatusId = AddressValidStatusId FROM AddressValidStatus WHERE Name = 'Valid' AND ClientId = @ClientId

	select top 1 @CountryCode = C.CountryCode, @StateCode = S.StateCode 
	from [Address] A 
	INNER JOIN UserAddresses UA on A.Addressid = UA.Addressid
	INNER JOIN Country C ON A.CountryId = C.CountryId
	LEFT JOIN State s ON A.StateId = S.StateId
	--INNER JOIN AddressStatus AST ON A.AddressStatusId = AST.AddressStatusId 
	--INNER JOIN AddressType ATT ON A.AddressTypeId = ATT.AddressTypeId
	--INNER JOIN AddressValidStatus AVS ON A.AddressValidStatusId = AVS.AddressValidStatusId
	WHERE UA.Userid = @UserId 
	--AND AST.ClientId = @ClientId
	--AND AST.Name = 'Current'
	--AND ATT.Name = 'Main'
	--AND AVS.Name = 'Valid'
	AND A.AddressStatusId =@AddressStatusId
	AND A.AddressTypeId =@AddressTypeId
	AND A.AddressValidStatusId =@AddressValidStatusId
END

SELECT @UserId AS UserId,@DeviceId AS DeviceId,@message AS Message,@CountryCode CountryCode,@StateCode StateCode
	                                                      
END TRY                                                        
BEGIN CATCH       
	PRINT 'ERROR'      
	PRINT ERROR_NUMBER() 
	PRINT ERROR_SEVERITY()  
	PRINT ERROR_STATE()
	PRINT ERROR_PROCEDURE() 
	PRINT ERROR_LINE()  
	PRINT ERROR_MESSAGE()                                                                                               
END CATCH       
END