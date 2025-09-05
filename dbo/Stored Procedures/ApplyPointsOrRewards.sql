
  /*
-- =============================================
-- Author:		<Name>
-- Modified By: Najeeb KHAN
--Last Modification Date: 19-Feb-2024
--Last Modification Description: TaskId VOY-1713
-- =============================================
  */
CREATE PROCEDURE [dbo].[ApplyPointsOrRewards]        
(        
		@UserId							INT,        
		@Email							NVARCHAR(100),        
		@PromotionId					INT = NULL,        
		@ClientId						INT,        
		@PointsAwarded					DECIMAL(18,2) = 0,        
		@PointsDeducted					DECIMAL(18,2) = 0,        
		/*---------------------------------------------        
		For External call from third party websites.        
		These parameters are considered when a promotion        
		is not supplied.Transactions are generated with        
		the parameters.        
		---------------------------------------------*/        
		@TrxDate						DATETIME  = NULL,        
		@TrxType						NVARCHAR(250)= NULL,        
		@Description					NVARCHAR(MAX)=  '',        
		@ItemCode						NVARCHAR(250)= '',        
		@AnalysisCode1					NVARCHAR(250)= '',        
		@AnalysisCode2					NVARCHAR(250)= '',        
		@AnalysisCode3					NVARCHAR(250)= '',        
		@AnalysisCode4					NVARCHAR(250)= '',        
		@SiteRef						VARCHAR(30)='',      
		@ClientTransactionId			NVARCHAR(250) = '',     
		@ExtraProperties				NVARCHAR(MAX) = '',     
   
		-----------------------------------------------        
		@Result							NVARCHAR(250)='0' OUTPUT,        
		@EarnedPoints					NVARCHAR(250)='0' OUTPUT,        
		@NewPointBalance				NVARCHAR(250)='0' OUTPUT        
         
)        
AS        
BEGIN        
		DECLARE --@UserId     INT,		      
		@DeviceId						NVARCHAR(25),        
		@DeviceStatusId					INT,        
		@ProfileTemplateTypeId			INT,        
		@AccountId						INT,        
		@valid							BIT =1,        
		@PromotionOfferType				NVARCHAR(25),        
		@Reward							NVARCHAR(MAX)='',        
		@RewardIdAndProductID			NVARCHAR(20)='',        
		@PromotionOfferValue			DECIMAL(18,2),        
		@TrxTypeId						INT,        
		@TrxStatusId					INT = 0,        
		@TrxdateTime					DATETIME = GETDATE(),        
		@SiteId							INT,        
		@PosTxnId						NVARCHAR(250) = LOWER(NEWID()),      
		@TrxDetailId					INT,        
		@CurrentPoint					DECIMAL(18, 2),        
		@ActivityDescription			NVARCHAR(50),        
		@NewTrxId						INT,        
		@ActivityCategoryName			NVARCHAR(50),        
		@ActivityTypeName				NVARCHAR(50),        
		@MaxUsageLimitPerMember			INT  =0,        
		@PromotionHitLimitType			NVARCHAR(50),      
		@TrxPromotionUsageLimitCount	INT,        
		@TrxMaxUsageLimitPerMemberCount INT,       
		@ExternalDescription			NVARCHAR(250)='',      
		@PromotionUsageLimit			INT  =0,      
		@PromotionName					NVARCHAR(250)='' ,      
		@Config							NVARCHAR(MAX),      
		@IsPromotionExists				BIT = 0 ,      
		@IsUserExists					BIT = 0,      
		@PromotionCategoryName			NVARCHAR(100),      
		@ActivityReference				NVARCHAR(MAX),      
		@OutPutTransactionId			INT,      
		@TransactionId					INT,      
		@Quantity						FLOAT = 1,      
		@PunchQuantity					FLOAT,      
		@PunchPromotionId				INT,      
		@PunchTrxId						INT,      
		@IsPunch						BIT = 0,      
		@ChangeBy						INT = 1400006,      
		@UserLoyaltyDataId				INT    ,  
		@MisCode						NVARCHAR(50),
		@ActivityConfiguration			NVARCHAR(MAX) = ''
		

		--IF @PromotionId > 0  AND @TrxDate IS NOT NULL
		--BEGIN
		--	SET @TrxdateTime = @TrxDate
		--END

		DECLARE @User  TABLE (UserId  INT,Email  NVARCHAR(100),SiteId  INT)             
		SET @PosTxnId = CASE WHEN LEN(ISNULL(@ClientTransactionId,'')) > 0 THEN @ClientTransactionId  ELSE LOWER(NEWID()) END      
		/*        
		------------------------------------------------------------------        
		Fetching the userid from the user with the given identifier,      
		because the user can provide either useeId or email Id.If the         
		userid is null, then return error.        
		------------------------------------------------------------------        
		*/       
         
		SET @Result = '0'  

		SELECT		TOP 1      
					@UserId = u.UserId,      
					@Email = u.Username,      
					@SiteId = u.SiteId,      
					@UserLoyaltyDataId = UserLoyaltyDataId,      
					@IsUserExists = CASE WHEN u.UserId > 0 THEN 1 ELSE 0 END      
      
		FROM		[User] u      
		INNER JOIN	UserType ut      
		ON			u.UserTypeId = ut.UserTypeId      
		WHERE		ut.ClientId = @ClientId       
		AND			((UserId = @UserId AND ISNULL(@UserId,0) > 0) OR (Username = @Email AND LEN(ISNULL(@Email,'')) > 0))      
        
		IF @IsUserExists = 1      
		BEGIN      
			INSERT @User(UserId,Email,SiteId)       
			VALUES (@UserId,@Email,@SiteId)      
		END         
    
      
		SELECT  TOP 1      
					@PromotionName   = P.Name,      
					@PromotionCategoryName = PC.Name,      
					@PromotionOfferType  = POT.Name,      
					@ActivityCategoryName = AC.Name,      
					@ActivityTypeName  = ACT.Name,      
					@ActivityReference  = P.ActivityReference,  
					@ActivityConfiguration = P.ActivityConfiguration,    
					@PromotionHitLimitType = PH.Name,      
					@Reward     = P.Reward,      
					@Config     = P.Config,      
					@PromotionOfferValue = P.PromotionOfferValue,      
					@MaxUsageLimitPerMember = P.MaxUsagePerMember,      
					@PromotionUsageLimit = ISNULL(P.PromotionUsageLimit,0),      
					@IsPromotionExists  = CASE WHEN P.Id > 0 THEN 1 ELSE 0 END   ,  
					@MisCode = P.MisCode,  
					@SiteId = P.SiteId  
      
		FROM		Promotion P      
		LEFT JOIN	PromotionCategory PC        
		ON			p.PromotionCategoryId = PC.Id         
		LEFT JOIN   PromotionOfferType POT      
		ON			P.PromotionOfferTypeId = POT.Id      
		LEFT JOIN	ActivityCategory AC      
		ON			P.ActivityCategoryId = AC.Id      
		LEFT JOIN   ActivityCategoryType ACT      
		ON			P.ActivityCategoryTypeId = ACT.Id      
		LEFT JOIN   PromotionHitLimitType PH      
		ON			P.PromotionHitLimitTypeId = PH.Id      
		WHERE		P.Id = @PromotionId      
      
		IF LEN(ISNULL(@SiteRef,'')) > 0      
		BEGIN      
			SELECT TOP 1 @SiteId = SiteId FROM [Site] WHERE SiteRef= TRIM(@SiteRef)      
		END        
        
		/*-----------------------------------------------------------        
		Validating the User and Email. If both are null, then return        
		error.        
		-----------------------------------------------------------*/        
         
		IF (@IsUserExists = 0 ) OR (ISNULL(@UserId,0) = 0 AND ISNULL(@Email,'')='')        
		BEGIN        
			PRINT 'invalid user'        
			SET @Result = '3'        
			RETURN         
		END        
		/*-----------------------------------------------------------        
		Validating the promotion with the given promotionId. If there        
		is no promotion with the given promotionId, then return error.        
		-----------------------------------------------------------*/        
		IF ISNULL(@IsPromotionExists,0) = 0  AND ISNULL(@PromotionId,0) > 0      
		BEGIN        
			PRINT 'Invalid Promotion'        
			SET @Result = '5'        
			RETURN         
		END        
        
		/*-----------------------------------------------------------        
		Validating whether the given promotion is of challenge category        
		if not, then return error.        
		-----------------------------------------------------------*/        
		--IF @PromotionCategoryName <> 'Challenge'        
		--BEGIN        
		-- PRINT 'Invalid Promotion'        
		-- SET @Result = '5'        
		-- RETURN         
		--END        
		/*-----------------------------------------------------------        
		Checking, if the email provided matches with the Email of the   
		user with given userid, If not, then return error.        
		-----------------------------------------------------------*/        
		IF ISNULL(@UserId,0) > 0 AND (ISNULL(@Email,'') <> '' 
		AND (SELECT Email FROM @User WHERE UserId = @UserId)<>@Email)        
		BEGIN        
			PRINT 'Invalid Email'        
			SET @Result = '6'        
			RETURN         
		END        
		/*-----------------------------------------------------------        
		Checking, if the userid provided matches with the userid of the         
		user with given email, If not, then return error.        
		-----------------------------------------------------------*/        
		IF ISNULL(@Email,'')=''     
		AND (SELECT UserId FROM @User WHERE Email = @Email       
		AND ISNULL(Email,'')<>'')<>@UserId        
		BEGIN        
			PRINT 'Invalid UserId'        
			SET @Result = '7'        
			RETURN         
		END        
        
		/*-----------------------------------------------------------------        
		Fetching the deviceId to apply points-- if the promotion is set        
		to give points for the activity.        
		-----------------------------------------------------------------*/        
        
		SELECT		@DeviceStatusId = devicestatusid         
		FROM		devicestatus         
		WHERE		[name]='Active'         
		AND			clientid=@ClientId        
          
		SELECT		@ProfileTemplateTypeId= Id         
		FROM		DeviceProfileTemplateType      
		WHERE		Name='Loyalty'         
		AND			ClientId=@ClientId         
         
          
		SELECT		TOP 1 @DeviceId = d.DeviceId,@AccountId=d.AccountId         
		FROM		Device d           
		INNER JOIN  Account a         
		ON			a.AccountId=d.AccountId       
		INNER JOIN  DeviceLot dl      
		ON          d.DeviceLotId = dl.Id      
		INNER JOIN  DeviceLotDeviceProfile dldp      
		ON          d.DeviceLotId =dldp.DeviceLotId          
		INNER JOIN  DeviceProfileTemplate dpt         
		ON			dpt.Id=dldp.DeviceProfileId           
		AND			dpt.DeviceProfileTemplateTypeId =@ProfileTemplateTypeId          
		WHERE		d.UserId = @UserId         
		AND			d.DeviceStatusId=@DeviceStatusId            
		ORDER BY	d.StartDate DESC          
        
		/*------------------------------------------------        
		Checking whether the deviceId is Active,         
		If not return error        
		------------------------------------------------*/        
		IF ISNULL(@DeviceId,'') =''        
		BEGIN        
			PRINT 'No Active Device'        
			SET @Result = '8'        
			RETURN         
		END        
      
		/*      
		VOY-474 - Setting the @ActivityDescription as PromotionName      
		and @AnalysisCode1 as the old @Activitydescription      
		*/      
		SET @ActivityDescription = @PromotionName      
      
		SET @AnalysisCode1 = @ActivityCategoryName + '_'+       
			ISNULL(@ActivityTypeName,'') +       
			CASE       
				WHEN ISNULL(@ActivityTypeName,'')=''       
				THEN 'Activity('+@ActivityReference+')'      
				ELSE '_Activity'       
			END      
        
		IF ISNULL(@Reward,'') <> '' AND         
		ISNULL(ISJSON(@Reward),'')<> '' AND         
		ISJSON(@Reward)= 1        
           
		BEGIN        
			DECLARE @rewId NVARCHAR(10)=JSON_VALUE(@Reward,'$.RewardId')        
			DECLARE @ProductId NVARCHAR(10)=JSON_VALUE(@Reward,'$.Id')        
        
			IF ISNULL(@rewId,'')<>'' AND ISNULL(@ProductId,'')<>''        
			BEGIN        
				SET @RewardIdAndProductId = @rewId + '/' + @ProductId        
			END        
		END        
      
       
		IF @PromotionOfferType = 'Punches'      
		BEGIN      
			SET @Quantity = @PromotionOfferValue      
			SET @PunchQuantity = @PromotionOfferValue      
			SET @PromotionOfferValue = 0      
		END      
        
		SET @valid =    CASE         
							WHEN @PromotionOfferType = 'Reward'       
							AND  (ISNULL(@Reward,'') = ''       
							OR    ISNULL(ISJSON(@Reward),'')= ''    
							OR    ISJSON(@Reward)= 0)        
							THEN 0        
							ELSE 1        
						END 
        
        
		IF @valid =1     
		BEGIN        
			SELECT @TrxTypeId = TrxTypeId        
			FROM   TrxType        
			WHERE  Name ='Activity'        
			AND    ClientId = @ClientId        
        
			IF @TrxStatusId = 0         
			BEGIN        
				SELECT @TrxStatusId = TrxStatusId         
				FROM TrxStatus         
				WHERE Name = 'Completed'         
				AND  ClientId = @ClientId        
			END        
			/*------------------------------------------------------        
			Checking whether the user had used the activity and        
			points are applied already.If yes, return error.        
			------------------------------------------------------*/         
			IF ISNULL(@PromotionId,0) > 0        
			BEGIN      
				IF ISNULL(@PromotionUsageLimit,0) > 0       
				BEGIN      
					SET @TrxPromotionUsageLimitCount = [dbo].[PromotionUsage](0,@PromotionId,null)      
					IF @PromotionUsageLimit <= ISNULL(@TrxPromotionUsageLimitCount,0)      
					BEGIN      
						SET @PromotionId = 0;      
						PRINT 'Activity already used'        
						SET @Result = '2'        
						RETURN       
					END      
				END 
				 
				/*----------------VOY-1896 - check Activity usage belongs to a product family-START---------
				Checking whether the user had used any of the activity/promotion belongs to a product family
				and the points are applied already. If yes, return error.
				-------------------------------------------------------------------------------------------*/
				IF LEN(ISNULL(@ActivityConfiguration,'')) > 0 AND ISJSON(@ActivityConfiguration) = 1 AND ISNULL(@UserId,0) > 0
				BEGIN
					DECLARE @ProductFamilyHitLimitType NVARCHAR(100) = '',
							@ProductFamilyHitLimitPerMember INT,
							@ProductFamilyTypeId INT,
							@PromotionUsedCount INT,
							@PromotionHitLimitDate DATETIME = GETDATE()

					SET @ProductFamilyHitLimitPerMember = TRY_CAST(JSON_VALUE(JSON_QUERY(@ActivityConfiguration),'$.ProductFamilyHitLimitPerMember') AS INT)
					SET @ProductFamilyHitLimitType = JSON_VALUE(JSON_QUERY(@ActivityConfiguration),'$.ProductFamilyHitLimitType')
					IF EXISTS(SELECT 1 FROM PromotionProductFamilies WHERE PromotionId = @PromotionId) 
						AND LEN(ISNULL(@ProductFamilyHitLimitType,'')) > 0

					BEGIN
						SELECT		TOP 1 @ProductFamilyTypeId = pfs.ProductFamilyTypeId
						FROM		PromotionProductFamilies ppf
						INNER JOIN	ProductFamilySubType pfs
						ON			ppf.ProductFamilySubTypeId = pfs.Id
						WHERE		ppf.PromotionId = @PromotionId

						SELECT		@PromotionUsedCount = COUNT(prc.TrxId) 
						FROM		PromotionRedemptionCount prc
						INNER JOIN  TrxHeader th ON prc.TrxId = th.TrxId
						INNER JOIN	Promotion p on prc.PromotionId = p.Id
						INNER JOIN	PromotionProductFamilies ppf on ppf.PromotionId = p.Id
						INNER JOIN	ProductFamilySubType pfs on ppf.ProductFamilySubTypeId = pfs.Id
						WHERE		prc.MemberId = @UserId 
						AND			pfs.ProductFamilyTypeId = @ProductFamilyTypeId
						AND         th.SiteId = @SiteId
						AND			prc.LastRedemptionDate >	(CASE LOWER(@ProductFamilyHitLimitType)
																	WHEN 'day' 
																	THEN DATEADD(MS,-1,(DATEADD(DAY,+1,CONVERT(VARCHAR,DATEADD(DAY,-1,@PromotionHitLimitDate),101)))) 
																	WHEN 'week' 
																	THEN DATEADD(MS,-1,CONVERT(VARCHAR,DATEADD(WEEK, DATEDIFF(WEEK,0,@PromotionHitLimitDate),0),101)) 
																	WHEN 'month' 
																	THEN DATEADD(MS,-1,CONVERT(VARCHAR,DATEADD(MONTH,DATEDIFF(month,0,@PromotionHitLimitDate),0),101)) 
																	WHEN 'year' 
																	THEN DATEADD(MS,-1,CONVERT(VARCHAR,DATEADD(YEAR,DATEDIFF(YEAR,0,GETDATE()),0),101)) 
																	ELSE CAST('17530101' AS DATETIME)
																END )
						
						print 'PromotionUsedCount = '+CAST(@PromotionUsedCount AS VARCHAR(10))
						print 'ProductFamilyHitLimitPerMember = '+CAST(@ProductFamilyHitLimitPerMember AS VARCHAR(10))
						IF @ProductFamilyHitLimitPerMember <= @PromotionUsedCount
						BEGIN
						print 'activity usage based on product family'
						SET @PromotionId = 0;      
							PRINT 'Activity already used' 
							SET @Result =   CASE LOWER(@ProductFamilyHitLimitType)
												WHEN 'day' THEN  'DailyLimitReached'
												WHEN 'week' THEN 'WeeklyLimitReached'
												WHEN 'month' THEN 'MonthlyLimitReached'
												WHEN 'year' THEN 'YearlyLimitReached'
												ELSE '2'
											END
							PRINT @Result
							RETURN
						END

					END
				END
				--------------VOY-1896 - check Activity usage belongs to a product family -END -------------------
				ELSE
				BEGIN
					IF ISNULL(@MaxUsageLimitPerMember,0) > 0  AND ISNULL(@UserId,0) > 0 AND ISNULL(@PromotionId,0) > 0        
					BEGIN      
						SET @TrxMaxUsageLimitPerMemberCount = [dbo].[PromotionUsage](@UserId,@PromotionId,null)      
						IF @MaxUsageLimitPerMember <= ISNULL(@TrxMaxUsageLimitPerMemberCount,0)      
						BEGIN      
							SET @PromotionId = 0;      
							PRINT 'Activity already used'        
      
							IF @PromotionHitLimitType = 'day'      
							BEGIN      
								SET @Result = 'DailyLimitReached'       
							END      
							ELSE IF @PromotionHitLimitType = 'week'      
							BEGIN      
								SET @Result = 'WeeklyLimitReached'       
							END      
							ELSE IF @PromotionHitLimitType = 'month'      
							BEGIN      
								SET @Result = 'MonthlyLimitReached'       
							END      
							ELSE IF @PromotionHitLimitType = 'year'      
							BEGIN      
								SET @Result = 'YearlyLimitReached'       
							END      
							ELSE      
							BEGIN      
								SET @Result = '2'        
							END      
							PRINT @Result      
							RETURN         
						END      
					END 
				END     
			END      
        
			/*-------------------------------------------------------------------        
			Inserting records in the TrxHeader and TrxDetail tables after         
			ensuring the activity is not used by the user.        
			-------------------------------------------------------------------*/        
			BEGIN TRY        
			--BEGIN TRAN        
				DECLARE @Res NVARCHAR(250)=''        
				/*---------------------------------------------------------------        
				Checking if promotionId is supplied, If not, it is being assumed         
				that the method is being called from any thrid party website.So,        
				Transaction entries are being made with the available parameters.        
				----------------------------------------------------------------*/        
				IF ISNULL(@PromotionId,0)= 0 -- IS  NULL        
				BEGIN        
					SELECT @TrxTypeId = TrxTypeId        
					FROM   TrxType        
					WHERE  Name =@TrxType        
					AND    ClientId = @ClientId        
        
					IF ISNULL(@Description,'')='' OR        
					ISNULL(@TrxTypeId,0)=0  OR        
					ISNULL(@TrxType,'')=''  OR        
					@TrxDate IS NULL        
					BEGIN        
						PRINT 'INVALID Category,CategoryType,TrxType,TrxDate Or Description'        
						SET @Result = '4'        
						ROLLBACK        
						RETURN        
					END         
            
					/*      
					AT-2834 - Bally - Checking whether the given ClientTransactionId - TrxTypeId combination      
					exists, if it is,then return      
					*/      
					IF EXISTS      
					(      
							SELECT TOP 1 TrxId      
							FROM   TrxHeader WITH (NOLOCK)      
							WHERE  Reference = @PosTxnId      
							AND    TrxTypeId = @TrxTypeId      
					)       
					BEGIN      
							PRINT 'DuplicateTransaction'      
							SET  @Result = '9'      
							ROLLBACK      
							RETURN      
					END          
        
					IF @TrxStatusId = 0         
					BEGIN        
							SELECT @TrxStatusId = TrxStatusId         
							FROM TrxStatus         
							WHERE Name = 'Completed'         
							AND  ClientId = @ClientId        
					END        
        
					SET @ActivityDescription = ISNULL(@Description,'')        
        
        
					IF ISNULL(@PointsDeducted,0) <> 0        
					BEGIN        
							DECLARE @RedeemDescription NVARCHAR(250)=''        
      
							SET @RedeemDescription = @ActivityDescription        
							SET @PointsDeducted = @PointsDeducted*(-1)        
      
							EXEC CreateTransactions        
							@ClientId,@DeviceId,@TrxTypeId,@TrxDate,        
							@SiteId,@PosTxnId,@TrxStatusId,@RewardIdAndProductId,              
							@RedeemDescription,@PointsDeducted,        
							NULL,-- PromotionId is setting as NULL        
							@UserId,        
							0,-- Since TrxDetailPromotion is not needed.        
							1,-- Since Account balance has to be updated.        
							@PointsDeducted,@ItemCode,@AnalysisCode1,@AnalysisCode2,        
							@AnalysisCode3,@AnalysisCode4,@Quantity,        
							@Res OUTPUT,@CurrentPoint OUTPUT,@OutPutTransactionId OUTPUT              
        
							SET @Result = @Res        
							SET @TransactionId = @OutPutTransactionId      
					END        
           
					IF ISNULL(@PointsAwarded,0) <> 0        
					BEGIN      
							EXEC CreateTransactions        
							@ClientId,@DeviceId,@TrxTypeId,@TrxDate,        
							@SiteId,@PosTxnId,@TrxStatusId,@RewardIdAndProductId,              
							@ActivityDescription,@PointsAwarded,        
							NULL,-- PromotionId is setting as NULL        
							@UserId,        
							0,-- Since TrxDetailPromotion is not needed.        
							1,-- Since Account balance has to be updated.        
							@PointsAwarded,@ItemCode,@AnalysisCode1,@AnalysisCode2,        
							@AnalysisCode3,@AnalysisCode4,@Quantity,        
							@Res OUTPUT,@CurrentPoint OUTPUT,@OutPutTransactionId OUTPUT         
					END      
        
					SET @Result = @Res        
					SET @TransactionId = @OutPutTransactionId      
				END        
        
				ELSE        
				BEGIN        
						/*-----------------------------------------------------------------        
						Checking if the  points awarded and deducted is null or not.If not,        
						create Transaction entries for the points deducted as well as for         
						the points awarded.        
						------------------------------------------------------------------*/        
        
						IF ISNULL(@PointsAwarded,0) >= 0 AND ISNULL(@PointsDeducted,0) <> 0        
						BEGIN        
								/*-----------------------------------------------------        
								Trx Entries for Points Deducted, Here no entry is made         
								in the TrxDetailPromotion.        
								-----------------------------------------------------*/        
								DECLARE @pointsDeductingActivityDesc  NVARCHAR(100)        
								SET @pointsDeductingActivityDesc = @ActivityDescription + ' REDEEM'         
        
								SET @PointsDeducted = @PointsDeducted*(-1)        
        
        
								EXEC CreateTransactions        
								@ClientId,@DeviceId,@TrxTypeId,@TrxdateTime,        
								@SiteId,@PosTxnId,@TrxStatusId,@RewardIdAndProductId,              
								@pointsDeductingActivityDesc,@PointsDeducted,        
								@PromotionId,@UserId,0,1,        
								@PointsDeducted,@ItemCode,@AnalysisCode1,@AnalysisCode2,        
								@AnalysisCode3,@AnalysisCode4,@Quantity,        
								@Res OUTPUT,@CurrentPoint OUTPUT,@OutPutTransactionId OUTPUT              
        
								SET @Result = @Res        
								SET @TransactionId = @OutPutTransactionId      
        
        
								/*-----------------------------------------------------        
								Trx Entries for the points awarded.        
								---------------------------------------------------*/    
								SET @PromotionOfferValue = @PointsAwarded        
        
        
								EXEC CreateTransactions        
								@ClientId,@DeviceId,@TrxTypeId,@TrxdateTime,        
								@SiteId,@PosTxnId,@TrxStatusId,@RewardIdAndProductId,              
								@ActivityDescription,@PromotionOfferValue,        
								@PromotionId,@UserId,1,1,        
								@PromotionOfferValue,@ItemCode,@AnalysisCode1,@AnalysisCode2,        
								@AnalysisCode3,@AnalysisCode4,@Quantity,        
								@Res OUTPUT,@CurrentPoint OUTPUT,@OutPutTransactionId OUTPUT              
        
								SET @Result = @Res                
								SET @TransactionId = @OutPutTransactionId      
						END        
						/*--------------------------------------------------------------        
						Adding Trx Entries for normal promotions in which the points         
						are being taken from the points offered in the promotion itself.        
						--------------------------------------------------------------*/        
						ELSE        
						BEGIN       
							PRINT ('referral - punches')      
							/*--------------------------------------------------------------      
								If the activity category is referral - refer-friend and      
								offer type is punches, then need to apply punches to       
								both referrer and referree.      
							--------------------------------------------------------------*/             
							IF @ActivityCategoryName = 'Referral' AND       
							@ActivityTypeName = 'Refer Friend' AND      
							(@PromotionOfferType = 'Punches' OR @PromotionOfferType = 'Points' )     
							BEGIN -- Referral - punches - Start      
								IF ISNULL(@UserLoyaltyDataId,0) > 0      
								BEGIN      
      
										/*      
										Fetching the Extension data (ReferredByCode,ReferredByCodePromotion)      
										The ReferredByCode would contains the memberId of the referrer       
										in an encrypted format (For eg:1Y41U189D9EX-348.) concatenated with      
										the id of the promotion to be applied to the referee.      
      
										The ReferredByCodePromotion is the Id of the promotion to be applied       
										to the referrer.      
										*/      
										DECLARE @ReferralData  TABLE      
										(      
											Id     INT IDENTITY(1,1),      
											PropertyName  NVARCHAR(100),      
											PropertyValue  NVARCHAR(100),      
											UserId    INT,      
											PromotionId   INT,      
											DeviceId   NVARCHAR(100),      
											AccountId   INT      
										)      
      
										DECLARE @ReferredByCode NVARCHAR(100) = '',@Id INT      
      
										INSERT @ReferralData(PropertyName,PropertyValue,PromotionId)      
										SELECT PropertyName,      
										(      
											SELECT TOP 1 token       
											FROM [dbo].[SplitString](PropertyValue,'-')       
											WHERE ItemIndex = 0      
										),      
										CASE ISNUMERIC(PropertyValue)       
											WHEN 1       
											THEN PropertyValue       
											ELSE        
											(      
											SELECT TOP 1 token       
											FROM [dbo].[SplitString](PropertyValue,'-')       
											WHERE ItemIndex = 1      
											)       
										END      
      
										FROM   UserLoyaltyExtensionData      
										WHERE  UserLoyaltyDataId = @UserLoyaltyDataId      
										AND    PropertyName IN ('ReferredByCode','ReferredByCodePromotion') 
										AND    TRY_CAST(PropertyValue AS UNIQUEIDENTIFIER) IS NULL --must ensure it is not guid
                                        
										SELECT TOP 1 @ReferredByCode = PropertyValue       
										FROM @ReferralData       
										WHERE PropertyName = 'ReferredByCode'      
      
										-- Extracting userId from the encrypted ReferredByCode      
										WHILE PATINDEX('%[^0-9]%',@ReferredByCode) <> 0      
										BEGIN      
											SET @ReferredByCode = STUFF(@ReferredByCode,PATINDEX('%[^0-9]%',@ReferredByCode),1,'')  
										END      
      
										DECLARE @ReferrerDeviceId NVARCHAR(100) = '',@ReferrerAccountId INT      
      
										SELECT		TOP 1 @ReferrerDeviceId = d.DeviceId,@ReferrerAccountId=d.AccountId         
										FROM		Device d           
										INNER JOIN  Account a         
										ON			a.AccountId=d.AccountId       
										INNER JOIN  DeviceLot dl      
										ON          d.DeviceLotId = dl.Id      
										INNER JOIN  DeviceLotDeviceProfile dldp      
										ON          d.DeviceLotId =dldp.DeviceLotId          
										INNER JOIN  DeviceProfileTemplate dpt         
										ON			dpt.Id=dldp.DeviceProfileId           
										AND			dpt.DeviceProfileTemplateTypeId =@ProfileTemplateTypeId          
										WHERE		d.UserId = CAST(@ReferredByCode AS INT)         
										AND			d.DeviceStatusId=@DeviceStatusId            
										ORDER BY	d.StartDate DESC        
      
										UPDATE		@ReferralData       
										SET			PropertyValue = @ReferredByCode,      
										UserId =	CAST(@ReferredByCode AS INT),      
										DeviceId =	@ReferrerDeviceId,      
										AccountId = @ReferrerAccountId      
										WHERE		PropertyName = 'ReferredByCode'  
										AND ISNUMERIC(@ReferredByCode) = 1
      
										UPDATE		@ReferralData       
										SET			UserId = @UserId,---CAST(@ReferredByCode AS INT),      
										DeviceId =	@DeviceId,--@ReferrerDeviceId,      
										AccountId = @AccountId--@ReferrerAccountId        
										WHERE		PropertyName = 'ReferredByCodePromotion'      
      
										/*      
										Looping through the @ReferralData table as repective promotion has to be applied for       
										both referral and referree       
      
										The table contains the UserId and PromotionId of both parties.      
										*/      
										IF EXISTS(SELECT 1 FROM @ReferralData)      
										BEGIN      
											SELECT @Id = MIN(Id) FROM @ReferralData       
											WHILE @Id IS NOT NULL      
											BEGIN      
													DECLARE --@PunchPromotionId INT,      
														@ReferralUserId INT,      
														@ReferralDeviceId NVARCHAR(100) = '',      
														@ReferralAccountId INT      
      
													SET @PunchPromotionId = 0      
      
													SELECT TOP 1 @ReferralUserId = UserId,      
															@PunchPromotionId = PromotionId,      
															@ReferralDeviceId = DeviceId,      
															@ReferralAccountId = AccountId      
													FROM	@ReferralData      
													WHERE   Id = @Id      
      
													SELECT @IsUserExists = CASE WHEN UserId > 0 THEN 1 ELSE 0 END FROM [User] WHERE UserId = @ReferralUserId       
													SELECT @IsPromotionExists = CASE WHEN Id > 0 THEN 1 ELSE 0 END FROM Promotion WHERE Id = @PunchPromotionId      
      
													IF @IsPromotionExists = 1 AND @IsUserExists = 1      
													BEGIN      
															SET @PosTxnId = LOWER(NEWID())      
															SET @ItemCode = CASE WHEN @PromotionOfferType = 'Punches' 
																				 THEN  'StampClaim' 
																				 WHEN @PromotionOfferType = 'Points' 
																				 THEN 
																				 (
																						SELECT TOP 1 PRopertyValue 
																						FROM  UserLoyaltyExtensionData WITH (NOLOCK)  
																						WHERE  UserLoyaltyDataId = @UserLoyaltyDataId   
																						AND    PropertyName IN ('ReferredByCode')
																				 ) 
																			END

															EXEC CreateTransactions        
															@ClientId,@ReferralDeviceId,@TrxTypeId,@TrxdateTime,        
															@SiteId,@PosTxnId,@TrxStatusId,@RewardIdAndProductId,              
															@ActivityDescription,@PromotionOfferValue,        
															@PunchPromotionId,@ReferralUserId,1,1,        
															@PromotionOfferValue,@ItemCode,@AnalysisCode1,@AnalysisCode2,        
															@AnalysisCode3,@AnalysisCode4,@Quantity,        
															@Res OUTPUT,@CurrentPoint OUTPUT,@OutPutTransactionId OUTPUT              
        
															SET @Result = @Res       
															SET @TransactionId = @OutPutTransactionId       
      
															IF ISNULL(@TransactionId,0) > 0      
															BEGIN      
																EXEC [StampCardManualClaim]       
																@TransactionId,@PunchPromotionId,@PunchQuantity,      
																@PunchQuantity,@ClientId,@ChangeBy      
															END      
      
													END      
      
													SELECT @Id = MIN(Id) FROM @ReferralData WHERE Id > @Id      
      
											END      
										END      
      
      
								END      
      
      
							END -- Referral - punches - End   
							ELSE      
							BEGIN      
								SET @ItemCode = 'StampClaim'      
								EXEC CreateTransactions        
								@ClientId,@DeviceId,@TrxTypeId,@TrxdateTime,        
								@SiteId,@PosTxnId,@TrxStatusId,@RewardIdAndProductId,              
								@ActivityDescription,@PromotionOfferValue,        
								@PromotionId,@UserId,1,1,        
								@PromotionOfferValue,@ItemCode,@AnalysisCode1,@AnalysisCode2,        
								@AnalysisCode3,@AnalysisCode4,@Quantity,        
								@Res OUTPUT,@CurrentPoint OUTPUT,@OutPutTransactionId OUTPUT              
        
								SET @Result = @Res       
								SET @TransactionId = @OutPutTransactionId       
    
							END      
						END       
            
						IF @PromotionOfferType = 'Punches' AND @ActivityCategoryName <> 'Referral'      
						BEGIN      
							IF LEN(ISNULL(@Config,'')) > 1 AND ISJSON(@Config) = 1      
							BEGIN      
								SET @PunchPromotionId = CAST(JSON_VALUE(@Config,'$.PromotionId') AS INT)      
								IF ISNULL(@TransactionId,0) > 0      
								BEGIN      
									EXEC [StampCardManualClaim]       
										@TransactionId,@PunchPromotionId,@PunchQuantity,      
										@PunchQuantity,@ClientId,@ChangeBy      
								END      
      
            
							END      
             
						END       
        
				END        
        
        
				IF @Result = '1'        
				BEGIN        
						SET @EarnedPoints  =   CASE       
						WHEN ISNULL(@PromotionId,0) = 0 AND @PointsAwarded=0 AND @PointsDeducted<0       
						THEN @PointsDeducted       
						WHEN ISNULL(@PromotionId,0) = 0 AND @PointsAwarded>0       
						THEN @PointsAwarded        
						ELSE CAST(@PromotionOfferValue AS NVARCHAR(10))       
						END        
      
						SET @NewPointBalance =  CAST(@CurrentPoint AS NVARCHAR(10))      
						PRINT'points applied'   
     
						--Insert Extension data into TrxHeaderExtensionData   
						IF @ExtraProperties !='' AND @ExtraProperties IS NOT NULL   
						BEGIN  
							DECLARE @TempTable TABLE (  
							PropertyName NVARCHAR(250),  
							PropertyValue NVARCHAR(250),  
							DisplayOrder INT,  
							Deleted BIT  
							)  
  
							--Extract data from JSON and Store into Temp Table  
							INSERT INTO @TempTable (PropertyName, PropertyValue, DisplayOrder, Deleted)  
							SELECT PropertyName, PropertyValue, DisplayOrder, Deleted  
							FROM OPENJSON(@ExtraProperties)  
							WITH (  
							PropertyName NVARCHAR(250),  
							PropertyValue NVARCHAR(250),  
							DisplayOrder INT,  
							Deleted BIT  
							)  
  
							INSERT INTO TrxHeaderExtensionData (Version, TrxId, PropertyName, PropertyValue, DisplayOrder, Deleted)  
							SELECT 0, @TransactionId, PropertyName, PropertyValue, DisplayOrder, Deleted  
							FROM @TempTable  
							IF ISNULL(@MisCode ,'') <> ''  
							BEGIN  
								SET @Result=  '1-'+@MisCode  
							END  
						END  
    
				END            
				--COMMIT        
			END TRY        
			BEGIN CATCH        
        
					DECLARE @ErrorMessage NVARCHAR(4000);        
					DECLARE @ErrorSeverity INT;     
					DECLARE @ErrorState INT;        
        
					SELECT         
						@ErrorMessage = ERROR_MESSAGE() + ' occurred at Line_Number: ' + CAST(ERROR_LINE() AS VARCHAR(50)),        
						@ErrorSeverity = ERROR_SEVERITY(),        
						@ErrorState = ERROR_STATE();        
        
					RAISERROR 
					(
						@ErrorMessage, -- Message text.        
						@ErrorSeverity, -- Severity.        
						@ErrorState -- State.        
					);        
					--ROLLBACK        
			END CATCH        
        
        
		END        
        
END