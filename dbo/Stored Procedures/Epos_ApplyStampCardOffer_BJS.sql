-- =============================================
-- Modified by:		Binu Jacob Scaria
-- Date: 2020-10-20
-- Description:	Include / Exclude
-- Modified Date: 2021-10-06
-- =============================================
CREATE PROCEDURE [dbo].[Epos_ApplyStampCardOffer_BJS]
	-- Add the parameters for the stored procedure here
	(@TrxId INT,@DeviceId NVARCHAR(25))
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DECLARE @UserId INT,@CurrentQuantity decimal(18,2) = 0,@DeviceIdentifier INT,@ClientId INT
	SELECT @UserId = ISNULL(D.UserId,0),@DeviceIdentifier = ISNULL(D.Id,0),@ClientId = ds.ClientId FROM DEVICE d INNER JOIN DeviceStatus ds on d.DeviceStatusId = ds.DevicestatusId WHERE DeviceId = @DeviceId
	--BEGIN TRAN
	IF ISNULL (@UserId,0) > 0 OR ISNULL (@DeviceIdentifier,0) > 0
	BEGIN
		--IF Voucher is already used with line item then exclude line item for further calculation
			DECLARE @DefaultVoucher NVARCHAR(25)
			SELECT @DefaultVoucher = [Value] FROM ClientConfig Where [Key] = 'StampcardDefaultVoucher' AND ClientId =@ClientId

			DROP TABLE IF EXISTS #usedVouchers
			select DISTINCT TrxVoucherId,td.Linenumber 
			INTO #usedVouchers 
			from trxvoucherdetail tv with(nolock) inner join trxdetail td with(nolock) on tv.trxdetailid = td.trxdetailid 
			where  td.trxid = @TrxId AND TrxVoucherId NOT LIKE (@DefaultVoucher+'%')

			DROP TABLE IF EXISTS #usedVouchersProfile
			SELECT DISTINCT uv.*,dpt.Id AS DeviceProfileId 
			INTO #usedVouchersProfile 
			from #usedVouchers uv 
			inner join  Device d WITH(NOLOCK)  on uv.TrxVoucherId = d.DeviceId 
			inner join DeviceProfile dp WITH(NOLOCK) on d.id=dp.DeviceId 
			inner join DeviceProfileTemplate dpt WITH(NOLOCK) on dp.DeviceProfileId = dpt.Id

			DROP TABLE IF EXISTS #StampVoucherPromotions
			SELECT VoucherProfileId,P.Id PromotionId,QualifyingProductQuantity,ISNULL(StampCardMultiplier,1) StampCardMultiplier 
			INTO #StampVoucherPromotions 
			FROM Promotion p WITH(NOLOCK)
			INNER JOIN VirtualStampCard vs WITH(NOLOCK) on p.Id = vs.PromotionId
			INNER JOIN #usedVouchersProfile uvp on p.VoucherProfileId = uvp.DeviceProfileId
			Where vs.TrxId = @TrxId AND p.VoucherProfileId IS NOT NULL

			--DROP TABLE IF EXISTS #StampVoucherPromotions
			--SELECT VoucherProfileId,Id PromotionId,QualifyingProductQuantity,ISNULL(StampCardMultiplier,1) StampCardMultiplier 
			--INTO #StampVoucherPromotions 
			--FROM Promotion WHERE Id IN(SELECT DISTINCT PromotionId FROM VirtualStampCard Where trxid = @TrxId) AND VoucherProfileId IS NOT NULL AND VoucherProfileId IN (SELECT DISTINCT DeviceProfileId FROM #usedVouchersProfile)
			
			SELECT DISTINCT * INTO #updateVirtualStampCard FROM #usedVouchersProfile uv INNER JOIN #StampVoucherPromotions sv on uv.DeviceProfileId = sv.VoucherProfileId

			DECLARE @CurrentQty DECIMAL(18,2),@AfterValue DECIMAL(18,2),@BeforeValue DECIMAL(18,2),@CalBeforeValue INT,@OnTheFlyQuantity INT,@CalOnTheFlyQuantity INT

			DECLARE @vsVoucherProfileId INT,@vsPromotionId INT, @vsLinenumber INT,@vsQualifyingProductQuantity decimal(18,2) = 0,@vsBeforeValue decimal(18,2),@vsStampCardMultiplier float
			DECLARE VirtualStampCardCursor CURSOR LOCAL FORWARD_ONLY READ_ONLY FOR               
			SELECT DISTINCT VoucherProfileId ,PromotionId , Linenumber,ISNULL(QualifyingProductQuantity,0),ISNULL(StampCardMultiplier,1) FROM #updateVirtualStampCard                             
			OPEN VirtualStampCardCursor                                                  
				FETCH NEXT FROM VirtualStampCardCursor           
				INTO @vsVoucherProfileId ,@vsPromotionId , @vsLinenumber   ,@vsQualifyingProductQuantity   ,@vsStampCardMultiplier                          
				WHILE @@FETCH_STATUS = 0 
				BEGIN 
					UPDATE VirtualStampCard SET Quantity = ISNULL(Quantity,0) - @vsStampCardMultiplier Where trxid = @TrxId AND VoucherId = @vsVoucherProfileId AND PromotionId = @vsPromotionId AND Linenumber = @vsLinenumber  AND PromotionOfferType  = 'Voucher'

					SET @CurrentQty =0
					SET @AfterValue = 0

					SELECT @CurrentQty = SUM(Quantity) FROM VirtualStampCard Where trxid = @TrxId AND PromotionId = @vsPromotionId  AND PromotionOfferType  = 'Voucher'
					SELECT @AfterValue = AfterValue,@BeforeValue = BeforeValue,@OnTheFlyQuantity = OnTheFlyQuantity FROM [PromotionStampCounter] where UserId = @UserId AND PromotionId =@vsPromotionId

					IF(ISNULL(@CurrentQty,0)+ISNULL(@AfterValue,0) > 0 AND ISNULL(@vsQualifyingProductQuantity,0) > 0)
					BEGIN
						SET @CalOnTheFlyQuantity = (ISNULL(@CurrentQty,0) + ISNULL(@AfterValue,0)) / @vsQualifyingProductQuantity
						SET @CalBeforeValue = (ISNULL(@CurrentQty,0) + ISNULL(@AfterValue,0)) - ((ISNULL(@CurrentQty,0) + ISNULL(@AfterValue,0)) % @vsQualifyingProductQuantity)
					END

					IF ISNULL(@CurrentQty,0)+ISNULL(@AfterValue,0) <= @vsQualifyingProductQuantity
					BEGIN
						UPDATE [PromotionStampCounter] SET BeforeValue = 0,OnTheFlyQuantity = 0 where UserId = @UserId AND PromotionId =@vsPromotionId
					END
					ELSE
					BEGIN
						UPDATE [PromotionStampCounter] SET BeforeValue = ISNULL(@CalBeforeValue,0) * -@vsStampCardMultiplier,OnTheFlyQuantity = @CalOnTheFlyQuantity where UserId = @UserId AND PromotionId =@vsPromotionId
					END

					FETCH NEXT FROM VirtualStampCardCursor     
					INTO @vsVoucherProfileId ,@vsPromotionId , @vsLinenumber    ,@vsQualifyingProductQuantity ,@vsStampCardMultiplier     
				END     
			CLOSE VirtualStampCardCursor;    
			DEALLOCATE VirtualStampCardCursor; 

			DELETE FROM VirtualStampCard WHERE Quantity <= 0 AND trxid = @TrxId
			
			--SELECT * FROM VirtualStampCard Where trxid = @TrxId
			--SELECT * FROM [PromotionStampCounter] where UserId = @UserId
		IF EXISTS (SELECT 1 FROM VirtualStampCard Where trxid = @TrxId)
		BEGIN
		IF ISNULL (@UserId,0) > 0
		BEGIN
			UPDATE [PromotionStampCounter] SET PreviousStampCount = AfterValue where UserId = @UserId AND PromotionId IN (SELECT DISTINCT PromotionId FROM VirtualStampCard Where trxid = @TrxId)
		END
		ELSE IF ISNULL (@DeviceIdentifier,0) > 0
		BEGIN 
			UPDATE [PromotionStampCounter] SET PreviousStampCount = AfterValue where ISNULL(UserId,0) = 0 AND ISNULL(DeviceIdentifier,0) = @DeviceIdentifier AND PromotionId IN (SELECT DISTINCT PromotionId FROM VirtualStampCard Where trxid = @TrxId)
		END
		

		DECLARE @PromotionId INT,@VoucherId Varchar(50),@LineNumber INT,@PromotionValue decimal(18,2),@Quantity decimal(18,2),@NetValue decimal(18,2),@StampCardType NVARCHAR(25),@PromotionType NVARCHAR(20)
		                                                                 
		DECLARE OnlineCursor CURSOR LOCAL FORWARD_ONLY READ_ONLY FOR               
		SELECT PromotionId,VoucherId,LineNumber,PromotionValue,Quantity,NetValue,ISNULL(StampCardType,''),ISNULL(PromotionType,'') PromotionType FROM VirtualStampCard Where trxid = @TrxId                                     
		OPEN OnlineCursor                                                  
		FETCH NEXT FROM OnlineCursor           
		INTO @PromotionId ,@VoucherId,@LineNumber ,@PromotionValue,@Quantity,@NetValue,@StampCardType,@PromotionType                                       
		WHILE @@FETCH_STATUS = 0    
			BEGIN  
				IF(@StampCardType = 'StampCardQuantity')
				BEGIN
					UPDATE TrxDetail SET PromotionId = @PromotionId, PromotionalValue = @Quantity WHERE TrxId = @TrxId AND Linenumber = @LineNumber AND ISNULL(PromotionalValue,0) = 0
				END
				ELSE
				BEGIN
					UPDATE TrxDetail SET PromotionId = @PromotionId, PromotionalValue = @NetValue WHERE TrxId = @TrxId AND Linenumber = @LineNumber AND ISNULL(PromotionalValue,0) = 0
				END

				DECLARE @IfExists INT = 0;

				IF ISNULL(@UserId,0) > 0 AND EXISTS (SELECT 1 FROM [PromotionStampCounter] where UserId = @UserId AND  PromotionId = @PromotionId)
				BEGIN
					SET @IfExists = 1
				END
				ELSE IF ISNULL(@UserId,0) = 0 AND ISNULL (@DeviceIdentifier,0) > 0 AND EXISTS (SELECT 1 FROM [PromotionStampCounter] where ISNULL(UserId,0) = 0 AND ISNULL(DeviceIdentifier,0) =@DeviceIdentifier AND  PromotionId = @PromotionId)
				BEGIN
					SET @IfExists = 1
				END


				IF ISNULL(@IfExists,0) =  1
				BEGIN
					IF(@StampCardType = 'StampCardQuantity')
					BEGIN
					IF ISNULL (@UserId,0) > 0
					BEGIN
						UPDATE [PromotionStampCounter] SET AfterValue = AfterValue + ISNULL(@Quantity,0) , TrxId = @TrxId  where UserId = @UserId AND  PromotionId = @PromotionId
					END
					ELSE IF ISNULL (@DeviceIdentifier,0) > 0
					BEGIN 
						UPDATE [PromotionStampCounter] SET AfterValue = AfterValue + ISNULL(@Quantity,0) , TrxId = @TrxId  where ISNULL(UserId,0) = 0 AND ISNULL(DeviceIdentifier,0) = @DeviceIdentifier AND  PromotionId = @PromotionId
					END
						
					END
					ELSE
					BEGIN
						--IF @PromotionType = 'Basket'
						--BEGIN
						--	PRINT 'A'
						--	UPDATE [PromotionStampCounter] SET AfterValue = AfterValue + (  ISNULL(@NetValue,0)), TrxId = @TrxId  where UserId = @UserId AND  PromotionId = @PromotionId
						--END
						--ELSE
						--BEGIN
						IF ISNULL (@UserId,0) > 0
						BEGIN
							UPDATE [PromotionStampCounter] SET AfterValue = AfterValue + (ISNULL(@NetValue,0)), TrxId = @TrxId  where UserId = @UserId AND  PromotionId = @PromotionId
						END
						ELSE IF ISNULL (@DeviceIdentifier,0) > 0
						BEGIN 
							UPDATE [PromotionStampCounter] SET AfterValue = AfterValue + (ISNULL(@NetValue,0)), TrxId = @TrxId  where ISNULL(UserId,0) = 0 AND ISNULL(DeviceIdentifier,0) = @DeviceIdentifier AND  PromotionId = @PromotionId
						END
							
						--END
					END
				END
				ELSE
				BEGIN
				IF(@StampCardType = 'StampCardQuantity')
					BEGIN
					INSERT INTO [dbo].[PromotionStampCounter]
								   ([Version]
								   ,[UserId]
								   ,[PromotionId]
								   ,[TrxId]
								   ,[CounterDate]
								   ,[BeforeValue]
								   ,[AfterValue]
								   ,[PreviousStampCount],DeviceIdentifier)
							 VALUES
								   (1
								   ,@UserId
								   ,@PromotionId
								   ,@TrxId
								   ,getdate()
								   ,0
								   ,ISNULL(@Quantity,0)
								   ,0
								   ,@DeviceIdentifier)
					END
					ELSE
					BEGIN
						INSERT INTO [dbo].[PromotionStampCounter]
								   ([Version]
								   ,[UserId]
								   ,[PromotionId]
								   ,[TrxId]
								   ,[CounterDate]
								   ,[BeforeValue]
								   ,[AfterValue]
								   ,[PreviousStampCount],DeviceIdentifier)
							 VALUES
								   (1
								   ,@UserId
								   ,@PromotionId
								   ,@TrxId
								   ,getdate()
								   ,0
								   ,  ISNULL(@NetValue,0)
								   ,0
								   ,@DeviceIdentifier)
					END
				END
		
				FETCH NEXT FROM OnlineCursor     
				INTO @PromotionId ,@VoucherId,@LineNumber ,@PromotionValue,@Quantity,@NetValue,@StampCardType,@PromotionType
			END     
		CLOSE OnlineCursor;    
		DEALLOCATE OnlineCursor; 

			IF ISNULL (@UserId,0) > 0
			BEGIN
				UPDATE [PromotionStampCounter] SET AfterValue = AfterValue + ISNULL(BeforeValue,0) where UserId = @UserId AND PromotionId IN (SELECT DISTINCT PromotionId FROM VirtualStampCard Where trxid = @TrxId)
				UPDATE [PromotionStampCounter] SET BeforeValue = 0 where UserId = @UserId AND PromotionId IN (SELECT DISTINCT PromotionId FROM VirtualStampCard Where trxid = @TrxId  AND PromotionOfferType NOT IN ('Reward','Voucher'))
			END
			ELSE IF ISNULL (@DeviceIdentifier,0) > 0
			BEGIN 
				UPDATE [PromotionStampCounter] SET AfterValue = AfterValue + ISNULL(BeforeValue,0) where UserId = 0  AND ISNULL(DeviceIdentifier,0) = @DeviceIdentifier AND PromotionId IN (SELECT DISTINCT PromotionId FROM VirtualStampCard Where trxid = @TrxId)
				UPDATE [PromotionStampCounter] SET BeforeValue = 0 where UserId = 0 AND ISNULL(DeviceIdentifier,0) = @DeviceIdentifier AND PromotionId IN (SELECT DISTINCT PromotionId FROM VirtualStampCard Where trxid = @TrxId  AND PromotionOfferType NOT IN ('Reward','Voucher'))
			END

			delete from [VirtualStampCard] where trxid=@TrxId AND PromotionValue = 0 AND PromotionOfferType !='Voucher'
		END

	--DEFAULT VOUCHER 
		DROP TABLE IF EXISTS #usedDefaultVouchers
		select DISTINCT TrxVoucherId,td.Linenumber ,REPLACE(TrxVoucherId, @DefaultVoucher, '') PromotionId 
		INTO #usedDefaultVouchers 
		from trxvoucherdetail tv with(nolock) inner join trxdetail td with(nolock) on tv.trxdetailid = td.trxdetailid 
		where  td.trxid = @TrxId AND TrxVoucherId LIKE (@DefaultVoucher+'%')

		DROP TABLE IF EXISTS #usedDefaultVouchersPromotion
		select DISTINCT TrxVoucherId,Linenumber,PromotionId ,StampCardMultiplier
		INTO #usedDefaultVouchersPromotion
		FROM #usedDefaultVouchers udv inner join Promotion p with(nolock) on udv.PromotionId = P.Id

		IF EXISTS (SELECT 1 FROM #usedDefaultVouchersPromotion)
		BEGIN
			UPDATE VirtualStampCard
			SET Quantity = ISNULL(Quantity,0) - StampCardMultiplier
			FROM #usedDefaultVouchersPromotion v
			INNER JOIN VirtualStampCard vs
			ON v.PromotionId = vs.PromotionId AND v.Linenumber = vs.Linenumber
			WHERE vs.TrxId = @TrxId

			DELETE FROM VirtualStampCard WHERE Quantity <= 0 AND trxid = @TrxId
		END
	--END DEFAULT VOUCHER 

	END

	SELECT ISNULL(@CurrentQuantity,0) AS Result
	--ROLLBACK TRAN
END
