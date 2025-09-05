CREATE PROCEDURE [dbo].[BulkRedeemPoints]
@ClientId INT,
@UserId   INT,
@TotalPoints FLOAT,
@Json        NVARCHAR(max),
@Code        INT output,
@TrxHeaderId INT output
AS
BEGIN
	SET nocount ON;
	DECLARE 
	@DeviceId            NVARCHAR(50),
	@AccountId           INT,
	@TransactionTypeId   INT,
	@TransactionStatusId INT,
	@SiteId              INT,
	@TerminalId          NVARCHAR(20) = NULL,
	@OpId                NVARCHAR(50) = NULL,
	@TransactionId       INT,
	@PointsValue FLOAT,
	-- source
	@Points FLOAT,
	--actual points calculation
	@PointsBalance FLOAT,
	@NewPointsBalance FLOAT,
	@OrderIdPrefix NVARCHAR(50),
	-- this will mainly have the SKU Id
	@CurrentPointBalance FLOAT;
	DECLARE @RewardId   INT;
	DECLARE @RewardName NVARCHAR(500);
	DECLARE @DeductPoints FLOAT;
	DECLARE @AdditionalDetails NVARCHAR(max);
	DECLARE @ItemCode         NVARCHAR(max);
	DECLARE @ImageUrl         NVARCHAR(max);
	DECLARE @Qty              INT;

	IF EXISTS (SELECT TOP 1 [VALUE] FROM   clientconfig WITH (nolock) WHERE  [Key] = 'OrderFulfillmentProvider' AND Isnull([VALUE], '') <> '')
	BEGIN
		SET @OrderIdPrefix = (SELECT [value] FROM Openjson(( SELECT TOP 1 [VALUE] FROM clientconfig WHERE  [Key] = 'OrderFulfillmentProvider'))
							  WHERE  [key] = 'OrderIdPrefix' )
	END
	DECLARE @TRXIDTABLE TABLE
	(trxid INT) --storing in a temp table to avoid multiple queries to the table
	SELECT dptt.[Name] templatetype,d.userid,d.deviceid,d.accountid,u.siteid,a.pointsbalance
	INTO #userdevicedetail FROM device D WITH (nolock)
	INNER JOIN [Site] S WITH (nolock)
	ON  d.homesiteid = s.siteid
	AND s.clientid = @ClientId
	INNER JOIN deviceprofile DP WITH (nolock)
	ON d.id = dp.deviceid
	INNER JOIN deviceprofiletemplate DPT WITH (nolock)
	ON dpt.id = dp.deviceprofileid --DeviceProfileId is the foreign key here from DeviceProfileTemplate table
	INNER JOIN deviceprofiletemplatetype DPTT WITH (nolock)
	ON dptt.id = dpt.deviceprofiletemplatetypeid
	INNER JOIN [User] u WITH (nolock)
	ON u.userid = d.userid
	INNER JOIN account a WITH(nolock)
	ON a.userid = u.userid
	WHERE d.devicestatusid IN(
	SELECT devicestatusid FROM devicestatus WHERE  [Name] IN ('Active', 'Ready')
	AND clientid = @ClientId )
	AND dp.statusid IN	( SELECT deviceprofilestatusid FROM   deviceprofilestatus WHERE  [Name] IN ('Active','Ready')
	AND clientid = @ClientId )
	AND dpt.statusid IN	( SELECT id FROM   deviceprofiletemplatestatus WHERE  [Name] IN ('Active', 'Ready')
	AND clientid = @ClientId )
	AND u.userid = @UserId
		IF Object_id('tempdb..#RewardList') IS NOT NULL
		BEGIN
			DROP TABLE #RewardList;
		END 
		IF Object_id('tempdb..#RewardQtyCheck') IS NOT NULL
		BEGIN
			DROP TABLE #RewardQtyCheck;
		END
	-- user should have a valid active device and of loyalty type
		IF NOT EXISTS
		(SELECT 1 FROM   #userdevicedetail WHERE  userid = @UserId AND templatetype = 'Loyalty')
		BEGIN
			SET @Code = 100 --InvalidUser
		END
	ELSE
	BEGIN
		SELECT @PointsBalance = a.pointsbalance FROM   account a WITH (nolock)
		JOIN   #userdevicedetail udd WITH (nolock)
		ON     udd.deviceid = a.extref
		WHERE  a.accountstatustypeid = (SELECT accountstatusid FROM accountstatus WITH (nolock) WHERE  [name] = 'Enable' AND clientid = @ClientId )
		AND a.userid = @UserId AND udd.templatetype = 'Loyalty' -- Verify if the user have enough points to redeem
		IF (@PointsBalance < @TotalPoints)
		BEGIN
			SET @Code = 101 --Not enough points
		END
		ELSE
		BEGIN --get the deviceId & accountid of user
			SELECT TOP 1 @DeviceId = deviceid, @AccountId = accountid, @SiteId = siteid, @CurrentPointBalance = pointsbalance
			FROM   #userdevicedetail WHERE  userid = @UserId AND templatetype = 'Loyalty'
			SET @TransactionTypeId = ( SELECT trxtypeid FROM   trxtype WITH (nolock) WHERE  [name] = 'RedeemPoints' AND    clientid = @ClientId )
			SET @TransactionStatusId =
			( SELECT trxstatusid FROM   trxstatus WITH (nolock) WHERE  [name] = 'Completed' AND clientid = @ClientId )
			SELECT RewardId, RewardName, DeductPoints, AdditionalDetails, ItemCode, ImageUrl, Qty
			INTO   #rewardlist
			FROM   Openjson(@json) WITH ( rewardid int '$.RewardId', rewardname nvarchar(500) '$.RewardName', deductpoints float '$.DeductPoints', AdditionalDetails nvarchar(max) '$.AdditionalDetails', itemcode nvarchar(max) '$.ItemCode', imageurl nvarchar(max) '$.ImageUrl', qty int '$.Qty' );			
			BEGIN try
				BEGIN TRAN
				INSERT INTO trxheader
				(clientid,deviceid,trxtypeid,trxdate,siteid,terminalid,terminaldescription,reference,opid,trxstatustypeid,terminalextra3,terminalextra2,accountpointsbalance)
				output inserted.[TrxId]
				INTO @TrxIdTable VALUES
				(@ClientId,@DeviceId,@TransactionTypeId,Getdate(),@SiteId,@TerminalId,NULL,Newid(),@OpId,@TransactionStatusId,NULL,'Bulk Redemption',@CurrentPointBalance)
				SET @TransactionId =(SELECT trxid FROM   @TrxIdTable)
				DECLARE my_cursor CURSOR FOR								
				SELECT rewardid,rewardname,deductpoints,AdditionalDetails,itemcode,imageurl,qty FROM #rewardlist;          
				OPEN my_cursor;
				FETCH next
				FROM  my_cursor INTO  @RewardId, @RewardName, @DeductPoints,@AdditionalDetails,@ItemCode,@ImageUrl,@Qty;          
				WHILE @@FETCH_STATUS = 0
				BEGIN
					--Added below code to save SiteId and ExtraInfo in Anal1 and Anal2 columns respectively, 
					--these were required by Niall to do the fullfilment of physical rewards in BulkRedemption.
					Declare @supplierSiteId as varchar(50) = (Select Value From STRING_SPLIT(@AdditionalDetails,'|') where Value like '%siteid%')
					Set @supplierSiteId = (Select Replace(Replace(@supplierSiteId,'SiteId:',''),'"','') as SiteId);
					IF(LEN(@supplierSiteId)>0)
					BEGIN
						Declare @ExtraInfo as varchar(50) = (Select ISNULL(ExtraInfo,'0') From Site where Siteid =  @supplierSiteId);						
					END					
					INSERT INTO trxdetail
					([Version],trxid,linenumber,itemcode,Anal1,Anal2,anal16,[Description],quantity,[Value],eposdiscount,points,promotionid,promotionalvalue,loyaltydiscount)
					VALUES('1',@TransactionId,1,@ItemCode,@supplierSiteId,@ExtraInfo,@RewardId,@RewardName,@Qty,0,0,(@DeductPoints * @Qty) * -1,NULL,NULL,0)
					FETCH next
					FROM  my_cursor
					INTO  @RewardId, @RewardName, @DeductPoints, @AdditionalDetails, @ItemCode, @ImageUrl, @Qty;          
				END
				CLOSE my_cursor;
				DEALLOCATE my_cursor;
				IF @OrderIdPrefix IS NOT NULL
				BEGIN
					UPDATE trxheader
					SET    terminaldescription =( @OrderIdPrefix +( Cast (@TransactionId AS VARCHAR) ) )
					WHERE  trxid = @TransactionId
				END -- update the user's account with latest points balance
				UPDATE account SET    @PointsBalance = Isnull(pointsbalance, 0),
				pointsbalance = ( Isnull(pointsbalance, 0)     - @TotalPoints ),
				@NewPointsBalance = ( Isnull(pointsbalance, 0) - @TotalPoints )
				WHERE  accountid = @AccountId AND userid = @UserId
				
				EXEC triggeractionsbasedontransactionhit @ClientId, @UserId, @TransactionId -- audit the account table

				EXEC insert_audit 'U', @UserId, @SiteId, 'Account', 'PointsBalance', @NewPointsBalance, @PointsBalance
				DROP TABLE #userdevicedetail
				SET @TrxHeaderId = @TransactionId
				SET @Code = 200 --Valid
				COMMIT
			END try
			BEGIN catch
			IF @@TRANCOUNT > 0
			BEGIN
				ROLLBACK TRANSACTION
			END
			SET @Code = 500 --InternalServerError
			END catch
		END
	END
END
