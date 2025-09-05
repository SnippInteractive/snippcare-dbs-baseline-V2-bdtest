/***
DECLARE @UserId INT 
EXEC [GetMemberByMobileOrEmail] 1, 'abdul.wahab_______@snipp.com,0894217597', @UserId OUTPUT
SELECT @UserId
*/
CREATE PROCEDURE [dbo].[GetMemberByMobileOrEmail] 
@Clientid INT NULL =1 ,    
@Source NVARCHAR(250),    
@UserId INT OUTPUT        
AS    
BEGIN        
  --AW: 05/07/21 - Source can be a UserId, a mobile number or an email address    
     SET TRANSACTION ISOLATION LEVEL READ UNcommitTED   
    SET NOCOUNT ON;    
    if @clientid is null begin set @clientid =1 end       
    --the UserStatus has to be ACTIVE      
    Declare @userstatusid int, @UserTypeId INT    
    SELECT @userstatusid =UserStatusId FROM UserStatus WHERE [Name]='Active' and clientid = @clientid      
    SELECT @UserTypeId = [UserTypeId] FROM UserType WHERE [Name]='LoyaltyMember' and clientid = @clientid      
    SELECT @Source = replace (@Source,' ' ,'') 
    SELECT * INTO #source FROM dbo.SplitString(@source,',')  

    if isnumeric(@source) = 1 AND LEFT(@source,1) <>'+' --AW: 05/07/21 - isnumeric gives 1 if number is +12334... so ignoring + sign here      
    Begin      
        SELECT Top 1 @UserId = u.UserId FROM [dbo].[User] u      
        WHERE u.userid = convert(bigint, @Source)  AND U.UserStatusId =@userstatusid      
  AND  U.UserTypeId= @UserTypeId    
        if @UserId != 0 Return -- found it, then get out      
    end      
          
    --the email is the most obvious, check this first      
    SELECT Top 1 @UserId = u.UserId FROM [dbo].[User] u      
    INNER JOIN [dbo].[UserContactDetails] ucd ON u.UserId = ucd.UserId       
    INNER JOIN [dbo].[ContactDetails] cd ON ucd.ContactDetailsId = cd.ContactDetailsId      
    WHERE cd.Email IN (SELECT token COLLATE DATABASE_DEFAULT FROM #source) AND U.UserStatusId =@userstatusid AND  U.UserTypeId= @UserTypeId  
    if @UserId != 0 Return -- found it, then get out      
      
       
      
    --the username is the next most obvious, check this second      
    SELECT Top 1 @UserId = u.UserId FROM [dbo].[User] u where username COLLATE DATABASE_DEFAULT  IN (SELECT token FROM #source)  and U.UserStatusId =@userstatusid AND  U.UserTypeId= @UserTypeId   
    if @UserId != 0 Return -- found it, then get out      
      
 /*  
  Check whether the source is there in any of the ReceiptEmailBindingslist of any user.  
  Collecting all the receipt emails from the extension data and checking whether   
  the source is there in the list. If it is there then return.  
 */  
  
 IF EXISTS  
 (  
  SELECT  TOP 1 uled.Id  
  FROM  UserLoyaltyExtensionData uled (nolock)  
  INNER JOIN [User] u (nolock)  
  ON   uled.UserLoyaltyDataId = u.UserLoyaltyDataId  
  INNER JOIN [Site] s (nolock)  
  ON   u.SiteId = s.SiteId  
  WHERE  PropertyName = 'ReceiptEmailBindings'   
  AND   s.ClientId = @clientid  
  AND   ISNULL(uled.PropertyValue,'') <> ''  
  AND EXISTS  
  (  
     SELECT 1   
     FROM [dbo].[SplitString](uled.PropertyValue,',')   
     WHERE token = @source  
  )  
 )  
 BEGIN  
  RETURN  
 END   
       
      
    --Mobile prefix is not being stored with the phone number, hence during mobile comparison we need to add Prefix      
    SELECT Top 1 @UserId = u.UserId FROM [dbo].[User] u      
    INNER JOIN [dbo].[UserContactDetails] ucd ON u.UserId = ucd.UserId INNER JOIN [dbo].[ContactDetails] cd ON ucd.ContactDetailsId = cd.ContactDetailsId      
    INNER JOIN [dbo].[PersonalDetails] pd ON u.PersonalDetailsId = pd.PersonalDetailsId      
    LEFT OUTER JOIN (SELECT UA.UserId,MobilePrefix FROM UserAddresses UA INNER JOIN [Address] A  ON A.AddressId = UA.AddressId INNER JOIN Country C ON C.CountryId = A.CountryId) UA      
    ON  UA.UserId = U.UserId      
    WHERE cd.MobilePhone COLLATE DATABASE_DEFAULT  IN (SELECT token FROM #source) OR (UA.MobilePrefix+cd.MobilePhone) COLLATE DATABASE_DEFAULT  IN (SELECT token FROM #source)
    AND U.UserStatusId =@userstatusid AND  U.UserTypeId= @UserTypeId ;      
        
END
