CREATE PROCEDURE [dbo].[RedeemPoints]
@ClientId INT,    
@UserId INT,    
@ProductId NVARCHAR(100),     
@ItemCode NVARCHAR(1000),    
@ProductPoints DECIMAL(10,2),      --from API it is coming with * Qty , so no need to do here again.
@ItemDescription NVARCHAR(50),    
@ConfirmationId NVARCHAR(max),    
@ImageUrl NVARCHAR(max),    
@Qty INT=1,    
@Code INT OUTPUT,    
@TrxHeaderId INT OUTPUT    
AS    
BEGIN    
     
 SET NOCOUNT ON;    
  
 DECLARE     
 @DeviceId NVARCHAR(50),    
 @AccountId INT,    
 @TransactionTypeId INT,    
 @TransactionStatusId INT,    
 @SiteId INT,    
 @TerminalId NVARCHAR(20) = NULL,     
 @OpId NVARCHAR(50) = NULL,    
 @TransactionId INT,    
 @PointsValue FLOAT, -- source    
 @Points FLOAT, --actual points calculation    
 @PointsBalance FLOAT,    
 @NewPointsBalance FLOAT,    
 @OrderIdPrefix NVARCHAR(50), -- this will mainly have the SKU Id     
 @CurrentPointBalance FLOAT,  
 @OptionsId Nvarchar(50), -- AT-4636,  
 @RedemptionDateTime DATETIME=GETDATE(),  
 @RewardItemOptionId INT  ,
 @RewardDescription NVARCHAR(250)=NULL,
 @UserStatusId INT
 
  
  -- AT-4643  
 IF ((SELECT CHARINDEX(':', @ProductId)) > 0)  
 BEGIN  
 DECLARE @colon_position INT = CHARINDEX(':', @ProductId);  
 Declare @TempProductId NVARCHAR(100) = SUBSTRING(@ProductId, 1, @colon_position - 1);  
 SET @OptionsId = SUBSTRING(@ProductId, @colon_position + 1, LEN(@ProductId) - @colon_position);  
 SET @ProductId = @TempProductId  
 END  
 ELSE  
 BEGIN  
 SET @OptionsId = 0;  
 END  
 --  
  
--PUR-T106
--We need to ensure that reward or option name is stored in desc of trxdetail in case it is not passed
-- if itemdescription is passed as GUID, as itemdescription is passed as CLientTransactionId as GUID, then we take action
IF TRY_CAST(@ItemDescription AS uniqueidentifier) IS NOT NULL
BEGIN
	-- if a reward has multiple options then use option name as description otherwise  take from reward
	IF (SELECT COUNT(*) FROM RewardItemsOptions WHERE RewardItemId=@ProductId)>1 AND @OptionsId>0
	BEGIN
		SET @RewardDescription = (SELECT RewardItemOptionName FROM RewardItemsOptions WHERE RewardItemId=@ProductId AND OptionId=@OptionsId)
	END
	ELSE 
	BEGIN
		SET @RewardDescription = (SELECT RewardName FROM RewardItems WHERE RewardItemId=@ProductId)
	END
END

 IF EXISTS(SELECT TOP 1 [VALUE] FROM ClientConfig WITH (NOLOCK) WHERE [Key]='OrderFulfillmentProvider' AND ISNULL([VALUE],'') <> '')    
 BEGIN    
  SET @OrderIdPrefix = (SELECT [value] FROM OpenJson(    
  (SELECT TOP 1 [VALUE] FROM ClientConfig WHERE [Key]='OrderFulfillmentProvider')    
  ) WHERE [key]='OrderIdPrefix')    
 END    
 SELECT @UserStatusId = USerStatusId FROM UserStatus WHERE ClientId=@ClientId AND [Name]='Active'
 DECLARE @TrxIdTable TABLE (TrxId INT)    
    
 --storing in a temp table to avoid multiple queries to the table    
 SELECT DPTT.[Name] TemplateType,D.UserId,D.DeviceId,D.AccountId, u.SiteId, a.PointsBalance INTO #UserDeviceDetail     
 FROM Device D WITH (NOLOCK)    
 INNER JOIN [Site] S WITH (NOLOCK) ON D.HomeSiteId = S.SiteId AND S.ClientId = @ClientId      
 INNER JOIN DeviceProfile DP WITH (NOLOCK) ON D.Id = DP.DeviceId     
 INNER JOIN DeviceProfileTemplate DPT WITH (NOLOCK) ON DPT.Id = DP.DeviceProfileId --DeviceProfileId is the foreign key here from DeviceProfileTemplate table    
 INNER JOIN DeviceProfileTemplateType DPTT WITH (NOLOCK) ON DPTT.Id = DPT.DeviceProfileTemplateTypeId     
 INNER JOIN [User] u WITH (NOLOCK) on u.userid = D.userid   
 INNER JOIN Account a WITH(NOLOCK) on a.UserId = u.UserId  
 WHERE D.DeviceStatusId IN (SELECT DeviceStatusId FROM DeviceStatus WHERE [Name] IN ('Active','Ready') AND Clientid=@ClientId)    
 AND DP.StatusId IN (SELECT DeviceProfileStatusId FROM DeviceProfileStatus WHERE [Name] IN ('Active','Ready') AND Clientid=@ClientId)     
 AND DPT.StatusId IN (SELECT Id FROM DeviceProfileTemplateStatus WHERE [Name] IN ('Active','Ready') AND Clientid=@ClientId)    
 AND U.UserStatusId = @UserStatusId
 AND u.UserId=@UserId    
    
 -- user should have a valid active device and of loyalty type    
 IF NOT EXISTS(SELECT 1 FROM #UserDeviceDetail           
         WHERE UserId = @UserId    
            AND TemplateType='Loyalty')     
 BEGIN    
   SET @Code = 100 --InvalidUser    
  END    
 ELSE    
 BEGIN    
    
  SELECT @PointsBalance = a.PointsBalance From Account a WITH (NOLOCK)    
  join  #UserDeviceDetail udd WITH (NOLOCK) on udd.deviceId = a.extRef    
  where a.AccountStatusTypeId = (SELECT AccountStatusId FROM AccountStatus WITH (NOLOCK) WHERE [name]='Enable' AND ClientId = @ClientId) and a.Userid = @UserId and udd.TemplateType='Loyalty'    
  -- Verify if the user have enough points to redeem    
  IF (@PointsBalance < @ProductPoints)    
  BEGIN    
   SET @Code = 101  --Not enough points    
    
  END                
  ELSE     
  BEGIN      
   --get the deviceId & accountid of user    
   SELECT TOP 1 @DeviceId=DeviceId,@AccountId=AccountId , @SiteId = SiteId, @CurrentPointBalance = PointsBalance       
   FROM #UserDeviceDetail           
   WHERE UserId = @UserId    
   AND TemplateType='Loyalty'    
       
   SET @TransactionTypeId=(SELECT TrxTypeId FROM trxtype WITH (NOLOCK) WHERE [name]='RedeemPoints' AND ClientId = @ClientId)    
   SET @TransactionStatusId=(SELECT TrxStatusId FROM TrxStatus WITH (NOLOCK) WHERE [name]='Completed' AND ClientId = @ClientId)    
     
   BEGIN TRY    
    BEGIN TRAN 
	
	--Get EposeTrxId from sequence for client like purina. EposeTrxId is OrderId for Purina
	DECLARE @SequenceValue_EposTrxId INT;
	IF OBJECT_ID('Seq_RedeemPoints_EposTrxId', 'SO') IS NOT NULL 
	BEGIN
		SET @SequenceValue_EposTrxId = NEXT VALUE FOR Seq_RedeemPoints_EposTrxId 
	END
	ELSE 
	BEGIN
		SET @SequenceValue_EposTrxId = NULL 
	END

     INSERT INTO TrxHeader (ClientId, DeviceId, TrxTypeId, TrxDate, SiteId, TerminalId, TerminalDescription, Reference, OpId, TrxStatusTypeId, TerminalExtra3, TerminalExtra2, AccountPointsBalance,EposTrxId)    
     OUTPUT INSERTED.[TrxId] INTO @TrxIdTable          
     VALUES (@ClientId, @DeviceId, @TransactionTypeId, @RedemptionDateTime , @SiteId, @TerminalId, null, @ItemDescription, @OpId, @TransactionStatusId, @ImageUrl, @ConfirmationId, @CurrentPointBalance,@SequenceValue_EposTrxId)    
         
     SET @TransactionId = (SELECT TrxId FROM @TrxIdTable)    
         
     -- AT-4643 Set option ID in anal 15  
  INSERT INTO TrxDetail ([Version], TrxID, LineNumber, ItemCode, Anal15, Anal16, [Description], Quantity, [Value], EposDiscount, Points, PromotionId, PromotionalValue, LoyaltyDiscount)    
  VALUES ('1', @TransactionId, 1, @ItemCode, CASE WHEN @OptionsId > 0 THEN @OptionsId ELSE null END, @ProductId, ISNULL(@RewardDescription,@ItemDescription), @Qty, 0, 0, (@ProductPoints * -1), NULL, NULL, 0)      
         
     IF @OrderIdPrefix IS NOT NULL    
     BEGIN    
      UPDATE TrxHeader SET TerminalDescription=(@OrderIdPrefix+(CAST (@TransactionId AS VARCHAR))) WHERE TrxId=@TransactionId    
     END    
   -- update the user's account with latest points balance    
  UPDATE Account     
  SET @PointsBalance = ISNULL(PointsBalance,0),     
  PointsBalance = (ISNULL(PointsBalance,0) - @ProductPoints),    
  @NewPointsBalance = (ISNULL(PointsBalance,0) - @ProductPoints)    
  WHERE  AccountId= @AccountId     
  AND UserId = @UserId   
    
  EXEC TriggerActionsBasedOnTransactionHit @ClientId, @UserId, @TransactionId  
     
  -- stock management for reward  
     IF @OptionsId > 0  
  BEGIN   
  UPDATE RewardItemsOptions SET QuantityRedeemed = QuantityRedeemed + @Qty Where RewardItemId = @ProductId AND OptionId = @OptionsId  
  END  
       
  ELSE IF exists(select top 1 * from RewardItemsOptions Where RewardItemId = @ProductId)  
  BEGIN  
  UPDATE RewardItemsOptions SET QuantityRedeemed = QuantityRedeemed + @Qty Where RewardItemId = @ProductId  
  END  
  
     -- audit the account table    
     EXEC Insert_Audit 'U', @UserId, @SiteId, 'Account', 'PointsBalance',@NewPointsBalance,@PointsBalance    
  
  --temp check to ensure it doesn't break for other clients in case the table is not there  
  -- maintaining the reward history  
  IF EXISTS (SELECT * FROM sys.tables WHERE name = 'MemberRewardHistory')   BEGIN  
     SET @RewardItemOptionId = (SELECT RewardItemOptionId FROM RewardItemsOptions WHERE OptionId = (CASE WHEN @OptionsId<=0 THEN 1 ELSE @OptionsId END) AND RewardItemId=@ProductId)  
  INSERT MemberRewardHistory (ClientId,UserId,RewardItemId,RewardItemOptionId,CreatedDateTime) VALUES (@ClientId,@UserId, @ProductId, @RewardItemOptionId, @RedemptionDateTime)  
  END  
    
     DROP TABLE #UserDeviceDetail    
     SET @TrxHeaderId = @TransactionId    
     SET @Code = 200  --Valid    
    COMMIT    
   END TRY    
   BEGIN CATCH    
    IF @@TRANCOUNT > 0    
    BEGIN    
     ROLLBACK TRANSACTION    
    END    
    SET @Code = 500  --InternalServerError    
   END CATCH    
  END    
 END    
END