
create Procedure [dbo].[Api_GetMemberReceiptSubmissionKpi] 
(
	@UserId int, 
	@FromDate DATETIME = null,
	@ToDate DATETIME = null,
	@LanguageCode NVARCHAR(10),	
	@SearchParams NVARCHAR(max)='',
	@Result NVARCHAR(MAX) OUTPUT
) 
AS
BEGIN
	SET NOCOUNT ON
	--DECLARE @UserId INT, @FromDate DATETIME, @ToDate DATETIME
	--DECLARE @Result	NVARCHAR(MAX) = ''

	--SET @UserId = 3034642 -- Retailer
	--SET @UserId = 3034690 -- Distributor
	--SET @UserId = 3031950 

--DECLARE @Result NVARCHAR(MAX) = ''
--EXEC Api_GetMemberReceiptSubmissionKpi 3025774,null,null,'en',@Result output
--select @Result

	IF @LanguageCode = ''
	BEGIN
		SET @LanguageCode = 'en'
	END
		

	DROP TABLE IF EXISTS #ReceiptDistinct
	DROP TABLE IF EXISTS #ReceiptCountDetails
	DROP TABLE IF EXISTS #ReceiptSummaryPivoted
	DROP TABLE IF EXISTS #PointsByProduct
	DROP TABLE IF EXISTS ##PointsByProductSummaryPivoted
	DROP TABLE IF EXISTS #PointsByDistributor
	DROP TABLE IF EXISTS #PointsByDistributorWithName
	DROP TABLE IF EXISTS ##PointsByDistributorPivoted
	DROP TABLE IF EXISTS #UploadsByRetailer
	DROP TABLE IF EXISTS #UploadsByRetailerWithName
	DROP TABLE IF EXISTS ##UploadsByRetailerPivoted
	DROP TABLE IF EXISTS #ReceiptRetailerByTrxtypePivoted

	DROP TABLE IF EXISTS #QtyByProduct
	DROP TABLE IF EXISTS ##QtyByProductSummaryPivoted

	DROP TABLE IF EXISTS #ReceiptTranslations
	CREATE TABLE #ReceiptTranslations
	(
		TGroup  NVARCHAR(50),TKey NVARCHAR(50),LCode NVARCHAR(5),TValue NVARCHAR(250)
	)
	


	CREATE TABLE #ReceiptDistinct
	(
		ReceiptId INT,YMonth NVARCHAR(20),TrxType NVARCHAR(15)
	)
	CREATE TABLE #ReceiptCountDetails
	(
		YMonth NVARCHAR(20),TrxType NVARCHAR(15),ReceiptsCount INT
	)
	CREATE TABLE #ReceiptSummaryPivoted
	(
		YMonth NVARCHAR(20),ValidReceipts INT,InValidReceipts INT,PendingReceipts INT
	)

	CREATE TABLE #QtyByProduct
	(
		YMonth NVARCHAR(20),Product NVARCHAR(max),Qty INT
	)

	DECLARE @ColumnsToPivot NVARCHAR(MAX) = '',@SQL NVARCHAR(MAX) =''
	DECLARE @UserSubType NVARCHAR(50), @UserName NVARCHAR(250)
	DECLARE @TrxTypeIdReceipt INT, @TrxTypeIdInValidReceipt INT, @TrxTypeIdRedeemPoints INT, @ClientId INT, @TrxStatusIdCompleted INT, @TrxTypeIdActivity INT, @TrxTypeIdManualClaim INT
	DECLARE @TValidReceipts NVARCHAR(250), @TInValidReceipts NVARCHAR(250),@TPendingReceipts NVARCHAR(250)
	DECLARE @AddressTypeId INT,@AddressStatusId INT, @AddressValidStatusId INT

	SELECT top 1 @UserSubType = [Name], @UserName = isnull(pd.Firstname,'') + ' ' + isnull(pd.LastName,''), @ClientId = st.ClientId
	FROM [User] u
	INNER JOIN UserSubType st on st.UserSubtypeId = u.UserSubtypeId
	INNER JOIN PersonalDetails pd on pd.PersonalDetailsId = u.PersonalDetailsId
	WHERE u.UserId = @UserId 

	select @TrxTypeIdReceipt=TrxTypeId from TrxType where [Name] = 'Receipt' and ClientId = @ClientId
	select @TrxTypeIdInValidReceipt=TrxTypeId from TrxType where [Name] = 'InValidReceipt' and ClientId = @ClientId

	select @TrxTypeIdRedeemPoints=TrxTypeId from TrxType where [Name] = 'RedeemPoints' and ClientId = @ClientId
	select @TrxStatusIdCompleted = TrxStatusId from TrxStatus where [Name] = 'Completed' and ClientId = @ClientId

	select @TrxTypeIdActivity=TrxTypeId from TrxType where [Name] = 'Activity' and ClientId = @ClientId
	select @TrxTypeIdManualClaim=TrxTypeId from TrxType where [Name] = 'ManualClaim' and ClientId = @ClientId
	
	select @AddressTypeId = AddressTypeId from AddressType where [Name] = 'Main' and ClientId = @ClientId
	select @AddressStatusId = AddressStatusId from AddressStatus where [Name] = 'Current' and ClientId = @ClientId
	select @AddressValidStatusId = AddressValidStatusId from AddressValidStatus where [Name] = 'Valid' and ClientId = @ClientId

	declare @DeviceStatusIdActive int
	Select top 1 @DeviceStatusIdActive = DeviceStatusId From DeviceStatus Where [Name] = 'Active' and ClientId = 1

	INSERT INTO #ReceiptTranslations(TGroup,TKey,LCode,TValue)
	SELECT TranslationGroup, TranslationGroupKey,@LanguageCode,Replace([Value],' ','')
	FROM Translations 
	WHERE TranslationGroup IN ('PortalKPIs') AND LanguageCode = @LanguageCode AND ClientId = @ClientId
	


	--SELECT TOP 1 @TValidReceipts=TValue		FROM #ReceiptTranslations WHERE TGroup = 'Receipt' AND TKey = 'ValidReceipts'
	--SELECT TOP 1 @TInValidReceipts=TValue	FROM #ReceiptTranslations WHERE TGroup = 'Receipt' AND TKey = 'InValidReceipts'
	SET @TValidReceipts = 'ValidDeliveryNotes'
	SET @TInValidReceipts = 'InValidDeliveryNotes'
	SET @TPendingReceipts = 'InProgressDeliveryNotes'

	print 'UserSubType - '+  @UserSubType
	IF @UserSubType = 'Retailer'
	BEGIN
		
			DECLARE @ReceiptDataByRetailer TABLE (ReceiptId INT,Retailer INT,DistributorId INT, DistributorName NVARCHAR(250), YMonth NVARCHAR(20),TrxType NVARCHAR(15), TrxId INT, TrxDetailID INT,PointsEarned decimal, Quantity Float,ItemCode NVARCHAR(100),ProductDescription NVARCHAR(max), SlugReceiptId NVARCHAR(150), ReceiptDate NVARCHAR(15),CreatedDate datetimeoffset)

			INSERT INTO @ReceiptDataByRetailer(ReceiptId,Retailer,DistributorId,DistributorName,YMonth,TrxType,TrxId,TrxDetailID,PointsEarned,Quantity,ItemCode,ProductDescription,SlugReceiptId,ReceiptDate,CreatedDate)
			SELECT	  r.ReceiptId
					, r.SnippUserId as Retailer
					, r.UserId as DistributorId
					, CASE WHEN ISJSON(r.ExtraInfo) =1 THEN (SELECT ISNULL([value],'') FROM OPENJSON(r.ExtraInfo,'$.Receipts[0]') WHERE [key] = 'Store_Name') ELSE '' END as DistributorName		
					
					, FORMAT(cast(r.CreatedDate as datetime2 ), 'MMMM') + '-' + FORMAT(cast(r.CreatedDate as datetime2 ), 'yyyy') TransYearMonth
					, tt.[Name] as TrxType
					, th.TrxId
					, td.TrxDetailID
					, td.[Points] PointsEarned
					, td.Quantity
					, td.ItemCode
					, pInfo.ProductDescription
					, CASE WHEN ISJSON(r.Response) =1 THEN (SELECT ISNULL([value],'') FROM OPENJSON(r.Response,'$') WHERE [key] = 'slug_receipt_id') ELSE '' END as SlugReceiptId
					, CASE WHEN ISJSON(r.Response) =1 THEN (SELECT ISNULL([value],'') FROM OPENJSON(r.Response,'$') WHERE [key] = 'receipt_date') ELSE '' END as ReceiptDate
					,r.CreatedDate
			from Receipt r
			inner join TrxHeader th on r.ReceiptId = th.ReceiptId
			inner join TrxDetail td on td.TrxId = th.TrxId
			inner join TrxType tt on tt.TrxTypeId = th.TrxTypeId
			left join ProductInfo pInfo on pInfo.ProductId = td.ItemCode
			where r.SnippUserId = @UserId -- retailer
			and th.TrxTypeId in (@TrxTypeIdReceipt,@TrxTypeIdInValidReceipt) 
			and th.TrxStatusTypeId = @TrxStatusIdCompleted
			and (@FromDate is null or r.CreatedDate between @FromDate and @ToDate)

			UNION ALL

			SELECT	  r.ReceiptId
					, r.SnippUserId as Retailer
					, r.UserId as DistributorId
					, CASE WHEN ISJSON(r.ExtraInfo) =1 THEN (SELECT ISNULL([value],'') FROM OPENJSON(r.ExtraInfo,'$.Receipts[0]') WHERE [key] = 'Store_Name') ELSE '' END as DistributorName		
					
					, FORMAT(cast(r.CreatedDate as datetime2 ), 'MMMM') + '-' + FORMAT(cast(r.CreatedDate as datetime2 ), 'yyyy') TransYearMonth
					, 'PendingReceipt' as TrxType
					, NULL
					, NULL
					, NULL
					, NULL
					, NULL
					,NULL
					, CASE WHEN ISJSON(r.Response) =1 THEN (SELECT ISNULL([value],'') FROM OPENJSON(r.Response,'$') WHERE [key] = 'slug_receipt_id') ELSE '' END as SlugReceiptId
					, CASE WHEN ISJSON(r.Response) =1 THEN (SELECT ISNULL([value],'') FROM OPENJSON(r.Response,'$') WHERE [key] = 'receipt_date') ELSE '' END as ReceiptDate
					,r.CreatedDate
			from	Receipt r
			WHERE   r.SnippUserId = @UserId
			AND		r.ProcessingStatus = 'Processing'
			and (@FromDate is null OR r.CreatedDate between @FromDate and @ToDate)

			order by r.CreatedDate desc			

		
			CREATE TABLE #PointsByProduct
			(
				YMonth NVARCHAR(20),Product NVARCHAR(max),PointsEarned decimal(18,2)
			)
			CREATE TABLE #PointsByDistributor
			(
				YMonth NVARCHAR(20),DistributorId INT,PointsEarned decimal(18,2)
			)
			CREATE TABLE #PointsByDistributorWithName
			(
				YMonth NVARCHAR(20),DistributorName NVARCHAR(250),PointsEarned decimal(18,2)
			)

			INSERT INTO #ReceiptDistinct
			SELECT distinct ReceiptId,YMonth,TrxType
			from @ReceiptDataByRetailer

			INSERT INTO #ReceiptCountDetails(YMonth,TrxType,ReceiptsCount)
			SELECT YMonth,TrxType, COUNT(ReceiptId) as ReceiptsCount
			from #ReceiptDistinct 
			group by YMonth,TrxType


			INSERT INTO #ReceiptSummaryPivoted
			SELECT YMonth,Receipt,InValidReceipt,PendingReceipt
			FROM 
			(
				SELECT	YMonth,TrxType,ReceiptsCount
				FROM	#ReceiptCountDetails 
			) AS P
			PIVOT
			(
				MIN(ReceiptsCount)
				FOR TrxType IN (Receipt,InValidReceipt,PendingReceipt)
			)AS PivotedTable

			IF EXISTS (SELECT 1 FROM #ReceiptSummaryPivoted)
			BEGIN
				;with cte as 
				(
						Select (SELECT isnull(TValue,'no-translation') 
						FROM #ReceiptTranslations 
						WHERE TGroup='PortalKPIs' 
						AND TKey =	FORMAT(cast(replace(YMonth,'-','') as datetime2 ), 'MMMM')) + '-' + 
									FORMAT(cast(replace(YMonth,'-','') as datetime2 ), 'yyyy') as YMonth,JS=JSON_QUERY( (Select isnull(ValidReceipts,0) ValidReceipts
												   ,isnull(InValidReceipts,0) InValidReceipts,
												   isnull(PendingReceipts,0) PendingReceipts
											   FOR JSON PATH,Without_Array_Wrapper) )
				 From #ReceiptSummaryPivoted
				)
				Select  @Result = '"NoOfReceiptsUploaded":{'+string_agg('"'+YMonth+'":'+ REPLACE(REPLACE(REPLACE(JS,'ValidReceipts',@TValidReceipts),'InValidReceipts',@TInValidReceipts),'PendingReceipts',@TPendingReceipts),',')+'}'
				From  cte
			END
			ELSE
			BEGIN
				Select  @Result = '"NoOfReceiptsUploaded":{}'
			END


			-----------------------------------------------------------------------------------------
			-- Start of PointsByProducts
			-----------------------------------------------------------------------------------------
			INSERT INTO #PointsByProduct(YMonth,Product,PointsEarned)
			SELECT YMonth, Replace(Replace(ProductDescription,'.','--'),',','-'), sum(PointsEarned) as PointsEarned
			FROM @ReceiptDataByRetailer 
			WHERE ProductDescription is not null
			GROUP BY YMonth,ProductDescription

			--select * from #PointsByProduct
		
			IF EXISTS (SELECT Product FROM #PointsByProduct)
			BEGIN
				SELECT @ColumnsToPivot = @ColumnsToPivot+ '[' + t.Product + '],'
				FROM(SELECT DISTINCT Product FROM #PointsByProduct) AS t

				SET @ColumnsToPivot = LEFT(@ColumnsToPivot,LEN(@ColumnsToPivot) - 1)
				SET @SQL = '
							SELECT YMonth, '+@ColumnsToPivot+' INTO ##PointsByProductSummaryPivoted
								FROM 
								(
									SELECT	YMonth,Product,PointsEarned
									FROM	#PointsByProduct  
								) AS P
								PIVOT
								(
									MIN(PointsEarned)
									FOR Product IN ('+@ColumnsToPivot+')
								) AS PivotedTable
							'

				EXEC (@sql)

		
				;with cte as (
				 Select (SELECT isnull(TValue,'no-translation') FROM #ReceiptTranslations WHERE TGroup='PortalKPIs' AND TKey = FORMAT(cast(replace(YMonth,'-','') as datetime2 ), 'MMMM'))  + '-' + FORMAT(cast(replace(YMonth,'-','') as datetime2 ), 'yyyy') as YMonth
				 ,JS= JSON_MODIFY(JSON_QUERY( (Select ##PointsByProductSummaryPivoted.* FOR JSON PATH,Without_Array_Wrapper ) ), '$.YMonth', NULL) 
				 From ##PointsByProductSummaryPivoted
				)
				
				Select  @Result = @Result + ',"PointsEarnedByProduct":{'+string_agg('"'+YMonth+'":'+JS,',')+'}'
				From  cte



				DROP TABLE ##PointsByProductSummaryPivoted

			END
			ELSE
			BEGIN
				Select  @Result = @Result + ',"PointsEarnedByProduct":{}'
			END


			---------------------------------------------------------------------------------------------------------
			-- Start of PointsByDistributor
			---------------------------------------------------------------------------------------------------------
			INSERT INTO #PointsByDistributor(YMonth,DistributorId,PointsEarned)
			SELECT YMonth, DistributorId, sum(PointsEarned) as PointsEarned
			FROM @ReceiptDataByRetailer 
			GROUP BY YMonth,DistributorId
			

			--INSERT INTO #PointsByDistributorWithName(YMonth,DistributorName,PointsEarned)
			--SELECT d.YMonth, pd.FirstName+ ' '+pd.LastName as DistributorName, d.PointsEarned
			--FROM #PointsByDistributor d
			--inner join [User] u on u.UserId = d.DistributorId
			--inner join PersonalDetails pd on pd.PersonalDetailsId = u.PersonalDetailsId
			--WHERE d.PointsEarned >0

			INSERT INTO #PointsByDistributorWithName(YMonth,DistributorName,PointsEarned)
			SELECT d.YMonth, isnull(addr.AddressLine1,'') as DistributorName, d.PointsEarned
			FROM #PointsByDistributor d
			OUTER APPLY ( 				
					select top 1 a.addressline1 --used OUTER APPLY thinking no duplicate addresses.
					from UserAddresses ua 
					inner join [Address] a on ua.AddressId = a.AddressId
					Where ua.Userid = d.DistributorId
					and a.AddressTypeId = @AddressTypeId
					and a.AddressStatusId = @AddressStatusId
					and a.AddressValidStatusId = @AddressValidStatusId
					order by a.addressid desc
					) addr
			WHERE d.PointsEarned >0

			


			IF EXISTS(SELECT DistributorName FROM #PointsByDistributorWithName)
			BEGIN
				SET @ColumnsToPivot = ''

				SELECT @ColumnsToPivot = @ColumnsToPivot+ '[' + t.DistributorName + '],'
				FROM(SELECT DISTINCT DistributorName FROM #PointsByDistributorWithName) AS t

				SET @ColumnsToPivot = LEFT(@ColumnsToPivot,LEN(@ColumnsToPivot) - 1)
				SET @SQL = '
							SELECT YMonth, '+@ColumnsToPivot+' INTO ##PointsByDistributorPivoted
								FROM 
								(
									SELECT	YMonth,DistributorName,PointsEarned
									FROM	#PointsByDistributorWithName  
								) AS P
								PIVOT
								(
									MIN(PointsEarned)
									FOR DistributorName IN ('+@ColumnsToPivot+')
								) AS PivotedTable
							'

				EXEC (@sql)


				;with cte as (
				 Select (SELECT isnull(TValue,'no-translation') FROM #ReceiptTranslations WHERE TGroup='PortalKPIs' AND TKey = FORMAT(cast(replace(YMonth,'-','') as datetime2 ), 'MMMM')) + '-' + FORMAT(cast(replace(YMonth,'-','') as datetime2 ), 'yyyy') as YMonth,JS= JSON_MODIFY(JSON_QUERY( (Select ##PointsByDistributorPivoted.*
											   FOR JSON PATH,Without_Array_Wrapper ) ), '$.YMonth', NULL) 
				 From ##PointsByDistributorPivoted
				)
		
				Select  @Result = @Result + ',"PointsEarnedByDistributor":{'+string_agg('"'+YMonth+'":'+JS,',')+'}'
				From  cte
			END
			ELSE
			BEGIN
				Select  @Result = @Result + ',"PointsEarnedByDistributor":{}'
			END

			--SET @Result = '"RetailerId":"'+Cast(@UserId as nvarchar)+'", "RetailerName":"'+@UserName+'",' + @Result	



			-----------------------------------------------------------------------------------------
			-- Start of QuantityByProducts
			-----------------------------------------------------------------------------------------
			INSERT INTO #QtyByProduct(YMonth,Product,Qty)
			SELECT YMonth, Replace(Replace(ProductDescription,'.','--'),',','-'), sum(Quantity) as Qty
			FROM @ReceiptDataByRetailer 
			WHERE ProductDescription is not null
			GROUP BY YMonth,ProductDescription

			--select * from #QtyByProduct
		
			SEt @ColumnsToPivot = ''
			IF EXISTS (SELECT Product FROM #QtyByProduct)
			BEGIN
				SELECT @ColumnsToPivot = @ColumnsToPivot+ '[' + t.Product + '],'
				FROM(SELECT DISTINCT Product FROM #QtyByProduct) AS t

				SET @ColumnsToPivot = LEFT(@ColumnsToPivot,LEN(@ColumnsToPivot) - 1)
				SET @SQL = '
							SELECT YMonth, '+@ColumnsToPivot+' INTO ##QtyByProductSummaryPivoted
								FROM 
								(
									SELECT	YMonth,Product,Qty
									FROM	#QtyByProduct  
								) AS P
								PIVOT
								(
									MIN(Qty)
									FOR Product IN ('+@ColumnsToPivot+')
								) AS PivotedTable
							'

				EXEC (@sql)

		

				;with cte as (
				 Select (SELECT isnull(TValue,'no-translation') FROM #ReceiptTranslations WHERE TGroup='PortalKPIs' AND TKey = FORMAT(cast(replace(YMonth,'-','') as datetime2 ), 'MMMM')) + '-' + FORMAT(cast(replace(YMonth,'-','') as datetime2 ), 'yyyy') as YMonth,JS= JSON_MODIFY(JSON_QUERY( (Select ##QtyByProductSummaryPivoted.*
											   FOR JSON PATH,Without_Array_Wrapper ) ), '$.YMonth', NULL) 
				 From ##QtyByProductSummaryPivoted
				)


				Select  @Result = @Result + ',"QuantityPerProduct":{'+string_agg('"'+YMonth+'":'+JS,',')+'}'
				From  cte

				DROP TABLE ##QtyByProductSummaryPivoted

			END
			ELSE
			BEGIN
				Select  @Result = @Result + ',"QuantityPerProduct":{}'
			END


			-----------------------------------------------------------------------------------------------------------
			-- Start of points available vs redeemed
			-----------------------------------------------------------------------------------------------------------

			--DROP TABLE IF EXISTS #PointsByMonth
			--CREATE TABLE #PointsByMonth
			--(
			--	YMonth NVARCHAR(20), PointsEarned decimal(18,2)
			--)
			--INSERT INTO #PointsByMonth(YMonth,PointsEarned)
			--SELECT YMonth,  sum(PointsEarned) as PointsEarned
			--FROM @ReceiptDataByRetailer 
			--GROUP BY YMonth

			DECLARE @EarnedPointsDataForRetailer TABLE (YMonth NVARCHAR(20),PointsEarned decimal(18,2) )

			INSERT INTO @EarnedPointsDataForRetailer(YMonth, PointsEarned)
			select FORMAT(cast(th.TrxDate as datetime2 ), 'MMMM') + '-' + FORMAT(cast(th.TrxDate as datetime2 ), 'yyyy')  as TransYearMonth,  isnull(td.[Points],0) as PointsEarned
			from TrxHeader th 
			inner join TrxDetail td on th.TrxId = td.TrxId 
			inner join Device d on d.Deviceid = th.Deviceid
			inner join TrxType tt on tt.TrxTypeId = th.TrxTypeId
			where th.TrxTypeId in (@TrxTypeIdReceipt,@TrxTypeIdInValidReceipt,@TrxTypeIdActivity,@TrxTypeIdManualClaim) 
			and (@FromDate is null or th.TrxDate between @FromDate and @ToDate)
			and d.UserId = @UserId
			and d.DeviceStatusId = @DeviceStatusIdActive
			and th.TrxStatusTypeId = @TrxStatusIdCompleted
			order by th.TrxDate desc

			DROP TABLE IF EXISTS #PointsByMonth
			CREATE TABLE #PointsByMonth
			(
				YMonth NVARCHAR(20), PointsEarned decimal(18,2)
			)
			INSERT INTO #PointsByMonth(YMonth,PointsEarned)
			SELECT YMonth,  sum(PointsEarned) as PointsEarned
			FROM @EarnedPointsDataForRetailer 
			GROUP BY YMonth

			
			DECLARE @RedeemPointsDataForRetailer TABLE (YMonth NVARCHAR(20),TrxType NVARCHAR(15), PointsRedeemed decimal, Quantity int,Reward nvarchar(250) )

			INSERT INTO @RedeemPointsDataForRetailer(YMonth, TrxType, PointsRedeemed, Quantity,Reward)
			select FORMAT(cast(th.TrxDate as datetime2 ), 'MMMM') + '-' + FORMAT(cast(th.TrxDate as datetime2 ), 'yyyy')  as TransYearMonth, tt.[Name] as TrxType,  td.[Points] PointsRedeemed,td.Quantity, td.[Description] as Reward
			from TrxHeader th 
			inner join TrxDetail td on th.TrxId = td.TrxId 
			inner join Device d on d.Deviceid = th.Deviceid
			inner join TrxType tt on tt.TrxTypeId = th.TrxTypeId
			where th.TrxTypeId = @TrxTypeIdRedeemPoints
			and (@FromDate is null or th.TrxDate between @FromDate and @ToDate)
			and d.UserId = @UserId
			and d.DeviceStatusId = @DeviceStatusIdActive
			and th.TrxStatusTypeId = @TrxStatusIdCompleted
			order by th.TrxDate desc
			

			DROP TABLE IF EXISTS #PointsRedeemedByMonth
			CREATE TABLE #PointsRedeemedByMonth
			(
				YMonth NVARCHAR(20), PointsRedeemed decimal(18,2)
			)
			INSERT INTO #PointsRedeemedByMonth(YMonth,PointsRedeemed)
			SELECT YMonth,  sum(PointsRedeemed) 
			FROM @RedeemPointsDataForRetailer 
			GROUP BY YMonth


			DROP TABLE IF EXISTS #PointsDataByMonth
			
			select Identity(int) as id, isnull(pe.YMonth,pr.YMonth) as YMonth, isnull(pe.PointsEarned,0) as PointsEarned, isnull(pr.PointsRedeemed,0) as PointsRedeemed
			into #PointsDataByMonth
			from #PointsByMonth pe full outer join #PointsRedeemedByMonth pr on pe.YMonth = pr.YMonth
			

			DROP TABLE IF EXISTS #PointsAvailableRedeemedByMonth
			CREATE TABLE #PointsAvailableRedeemedByMonth
			(
				YMonth NVARCHAR(20), PointsEarned decimal(18,2), PointsRedeemed decimal(18,2),PointsAvailable decimal(18,2)
			)
			declare @MonthString NVARCHAR(20)
			declare @MonthStringTranslated NVARCHAR(20)
			declare @PointsAvailable decimal(18,2) = 0 -- have to get prevoius available point before @fromDate
			declare @PointsEarnedInMonth decimal(18,2) = 0
			declare @PointsRedeemedInMonth decimal(18,2) = 0
			declare @StartMonth datetime
			declare @CurrentMonth datetime
			declare @EndMonth datetime
			if @FromDate is null
			begin
				select top 1 @StartMonth = cast(replace(YMonth,'-','') as datetime) from #PointsDataByMonth order by id asc
				select top 1 @EndMonth = cast(replace(YMonth,'-','') as datetime) from #PointsDataByMonth order by id desc
			end
			else
			begin
				select @StartMonth = @FromDate
				select @EndMonth = @ToDate

				-- get available points before @fromdate
				declare @PointsEarnedBefore decimal(18,2)
				declare @PointsRedeemedBefore decimal(18,2)

				--SELECT @PointsEarnedBefore = sum(td.[Value])
				--from Receipt r
				--inner join TrxHeader th on r.ReceiptId = th.ReceiptId
				--inner join TrxDetail td on td.TrxId = th.TrxId
				--inner join TrxType tt on tt.TrxTypeId = th.TrxTypeId
				--left join ProductInfo pInfo on pInfo.ProductId = td.ItemCode
				--where r.SnippUserId = @UserId -- retailer
				--and th.TrxTypeId in (@TrxTypeIdReceipt,@TrxTypeIdInValidReceipt) 
				--and th.TrxStatusTypeId = @TrxStatusIdCompleted
				--and  r.CreatedDate < @FromDate

				--select  @PointsRedeemedBefore= sum(td.[Points]) 
				--from TrxHeader th 
				--inner join TrxDetail td on th.TrxId = td.TrxId 
				--inner join Device d on d.Deviceid = th.Deviceid
				--inner join TrxType tt on tt.TrxTypeId = th.TrxTypeId
				--where th.TrxTypeId = @TrxTypeIdRedeemPoints
				--and th.TrxStatusTypeId = @TrxStatusIdCompleted
				--and th.TrxDate < @FromDate 
				--and d.UserId = @UserId

				--set @PointsAvailable = @PointsEarnedBefore + @PointsRedeemedBefore -- + since its negative				

				select  @PointsAvailable= sum(td.[Points]) 
				from TrxHeader th 
				inner join TrxDetail td on th.TrxId = td.TrxId 
				inner join Device d on d.Deviceid = th.Deviceid
				inner join TrxType tt on tt.TrxTypeId = th.TrxTypeId
				where th.TrxTypeId in (@TrxTypeIdReceipt,@TrxTypeIdInValidReceipt,@TrxTypeIdActivity,@TrxTypeIdManualClaim,@TrxTypeIdRedeemPoints) 
				and th.TrxStatusTypeId = @TrxStatusIdCompleted
				and th.TrxDate < @FromDate 
				and d.UserId = @UserId
				and d.DeviceStatusId = @DeviceStatusIdActive

			end
			
			set @CurrentMonth = @StartMonth
			WHILE(@CurrentMonth <= @EndMonth)
			BEGIN 

				set @MonthString = FORMAT(cast(@CurrentMonth as datetime2 ), 'MMMM') + '-' + FORMAT(cast(@CurrentMonth as datetime2 ), 'yyyy')
				
				if exists(select 1 from #PointsDataByMonth where YMonth = @MonthString)
				begin
					select @PointsAvailable = isnull(@PointsAvailable,0) + isnull(PointsEarned,0) + isnull(PointsRedeemed,0),@PointsEarnedInMonth = isnull(PointsEarned,0), @PointsRedeemedInMonth = isnull(PointsRedeemed,0)
					from #PointsDataByMonth where YMonth = @MonthString
				end
				else
				begin
					set @PointsEarnedInMonth = 0
					set @PointsRedeemedInMonth = 0
				end

				--set @MonthStringTranslated = (SELECT isnull(TValue,'no-translation') FROM #ReceiptTranslations WHERE TGroup='PortalKPIs' AND TKey = FORMAT(cast(r.CreatedDate as datetime2 ), 'MMMM')) + '-' + FORMAT(cast(r.CreatedDate as datetime2 ), 'yyyy')

				--If @PointsEarnedInMonth> 0 OR ABS(@PointsRedeemedInMonth) >0
				--BEGIN
				--	INSERT INTO #PointsAvailableRedeemedByMonth(YMonth,PointsAvailable,PointsEarned,PointsRedeemed)
				--	VALUES(@MonthString,isnull(@PointsAvailable,0),@PointsEarnedInMonth,ABS(@PointsRedeemedInMonth))
				--END

				INSERT INTO #PointsAvailableRedeemedByMonth(YMonth,PointsEarned,PointsRedeemed,PointsAvailable)
					VALUES(@MonthString,@PointsEarnedInMonth,ABS(@PointsRedeemedInMonth),isnull(@PointsAvailable,0))

				--select @PointsAvailable = isnull(@PointsAvailable,0) + @PointsRedeemedInMonth -- + since its negative

				set @CurrentMonth = DATEADD(MONTH, 1, @CurrentMonth)
			END


			IF EXISTS (select 1 from #PointsAvailableRedeemedByMonth)
			BEGIN

				;with cte as (
				 Select (SELECT isnull(TValue,'no-translation') FROM #ReceiptTranslations WHERE TGroup='PortalKPIs' AND TKey = FORMAT(cast(replace(YMonth,'-','') as datetime2 ), 'MMMM')) + '-' + FORMAT(cast(replace(YMonth,'-','') as datetime2 ), 'yyyy')  as YMonth,JS= JSON_MODIFY(JSON_QUERY( (Select #PointsAvailableRedeemedByMonth.*
											   FOR JSON PATH,Without_Array_Wrapper ) ), '$.YMonth', NULL) 
				 From #PointsAvailableRedeemedByMonth
				)


				Select  @Result = @Result + ',"PointsRedeemedVsAvailable":{'+string_agg('"'+YMonth+'":'+JS,',')+'}'
				From  cte
							

			END 
			ELSE
			BEGIN
				Select  @Result = @Result + ',"PointsRedeemedVsAvailable":{}'
			END

			--------------------------------------------
			-- END of Points available vs redeemed
			--------------------------------------------


			----------------------------------------------------------------------------------------------------------
			-- Start of Points generated purchase/non-purchase
			----------------------------------------------------------------------------------------------------------


			DECLARE @ActivityTypeDataByRetailer TABLE ( YMonth NVARCHAR(20),TrxType NVARCHAR(15), TrxId INT, TrxDetailID INT,PointsEarned decimal, Quantity Float)


			INSERT INTO @ActivityTypeDataByRetailer(YMonth,TrxType,TrxId,TrxDetailID,PointsEarned,Quantity)
			SELECT	 FORMAT(cast(th.TrxDate as datetime2 ), 'MMMM') + '-' + FORMAT(cast(th.TrxDate as datetime2 ), 'yyyy') TransYearMonth
					, tt.[Name] as TrxType
					, th.TrxId
					, td.TrxDetailID
					, isnull(td.[Points],0) PointsEarned
					, td.Quantity
			from TrxHeader th
			inner join TrxDetail td on td.TrxId = th.TrxId
			inner join TrxType tt on tt.TrxTypeId = th.TrxTypeId
			inner join Device d on d.Deviceid = th.Deviceid
			where d.UserId = @UserId -- retailer
			and th.TrxTypeId in (@TrxTypeIdActivity) 
			and th.TrxStatusTypeId = @TrxStatusIdCompleted
			and (@FromDate is null or th.TrxDate between @FromDate and @ToDate)
			order by th.TrxDate desc

			
			DROP TABLE IF EXISTS #PointsByPurchaseNonPurchase
			CREATE TABLE #PointsByPurchaseNonPurchase
			(
				YMonth NVARCHAR(20),TrxType NVARCHAR(100),PointsEarned decimal(18,2)
			)
			INSERt INTO #PointsByPurchaseNonPurchase(YMonth,TrxType,PointsEarned)
			select YMonth,'Purchase' as TrxType,  isnull(sum(PointsEarned),0) as PointsEarned
			from @ReceiptDataByRetailer
			group by YMonth
			union 
			select YMonth,'NonPurchase' as TrxType,  isnull(sum(PointsEarned),0) as PointsEarned
			from @ActivityTypeDataByRetailer
			group by YMonth

			--select * from @ReceiptDataByRetailer
			--select * from @ActivityTypeDataByRetailer

			DROP TABLE IF EXISTS #PointsByPurchaseNonPurchasePivoted
			CREATE TABLE #PointsByPurchaseNonPurchasePivoted
			(
				YMonth NVARCHAR(20),Purchase decimal(18,2),NonPurchase decimal(18,2)
			)

			INSERT INTO #PointsByPurchaseNonPurchasePivoted
			SELECT YMonth,Purchase,NonPurchase
			FROM 
			(
				SELECT	YMonth,TrxType,PointsEarned
				FROM	#PointsByPurchaseNonPurchase 
			) AS P
			PIVOT
			(
				MIN(PointsEarned)
				FOR TrxType IN (Purchase,NonPurchase)
			)AS PivotedTablePurchaseNonPurchase 

			DROP TABLE IF EXISTS #PointsByPurchaseNonPurchaseFiltered
			CREATE TABLE #PointsByPurchaseNonPurchaseFiltered
			(
				YMonth NVARCHAR(20),Purchase decimal(18,2),NonPurchase decimal(18,2)
			)
			INSERT INTO #PointsByPurchaseNonPurchaseFiltered
			SELECT YMonth,isnull(Purchase,0) as Purchase,isnull(NonPurchase,0) as NonPurchase 
			FROM #PointsByPurchaseNonPurchasePivoted
			WHERE Purchase > 0 OR NonPurchase > 0

			
			IF EXISTS (SELECT 1 FROM #PointsByPurchaseNonPurchaseFiltered)
			BEGIN
				;with cte as (
				 Select (SELECT isnull(TValue,'no-translation') FROM #ReceiptTranslations WHERE TGroup='PortalKPIs' AND TKey = FORMAT(cast(replace(YMonth,'-','') as datetime2 ), 'MMMM')) + '-' + FORMAT(cast(replace(YMonth,'-','') as datetime2 ), 'yyyy') as YMonth,JS=JSON_QUERY( (Select isnull(Purchase,0) Purchase
												   ,isnull(NonPurchase,0) NonPurchase
											   FOR JSON PATH,Without_Array_Wrapper) )
				 From #PointsByPurchaseNonPurchaseFiltered
				)
				Select  @Result = @Result + ',"PointsByPurchaseNonPurchase":{'+string_agg('"'+YMonth+'":'+ JS,',')+'}'
				From  cte
			END
			ELSE
			BEGIN
				Select  @Result = @Result + ',"PointsByPurchaseNonPurchase":{}'
			END

			----------------------------------------------------------------------------------------------------------
			-- END Points generated purchase/non-purchase
			----------------------------------------------------------------------------------------------------------

			----------------------------------------------------------------------------------------------------------
			-- Start of Points/Quantity/Product By Receipt
			----------------------------------------------------------------------------------------------------------
			DROP TABLE IF EXISTS #ReceiptDetails
			CREATE TABLE #ReceiptDetails
			(
				ReceiptId NVARCHAR(150),PurchaseDate NVARCHAR(15),Distributor NVARCHAR(max),Product NVARCHAR(max), Quantity INT,PointsEarned decimal(18,2)
			)

			INSERT INTO #ReceiptDetails(ReceiptId,PurchaseDate,Distributor,Product, Quantity,PointsEarned)
			SELECT SlugReceiptId,ReceiptDate,isnull(addr.AddressLine1,'') , Replace(Replace(Replace(Replace(ProductDescription,'.','--'),',','-'),'(',''),')','') ,Quantity,  PointsEarned
			FROM @ReceiptDataByRetailer rd
			OUTER APPLY ( 				
					select top 1 a.addressline1 --used OUTER APPLY thinking no duplicate addresses.
					from UserAddresses ua 
					inner join [Address] a on ua.AddressId = a.AddressId
					Where ua.Userid = rd.DistributorId
					and a.AddressTypeId = @AddressTypeId
					and a.AddressStatusId = @AddressStatusId
					and a.AddressValidStatusId = @AddressValidStatusId
					order by a.addressid desc
					) addr

			WHERE ProductDescription is not null
			

			--select * from #ReceiptDetails

			if exists(select 1 from #ReceiptDetails)
			begin
				;with cte as (
					 Select ReceiptId,PurchaseDate,Distributor
					 ,jq= JSON_MODIFY(JSON_MODIFY(JSON_MODIFY(JSON_QUERY( (Select #ReceiptDetails.* FOR JSON PATH,Without_Array_Wrapper ) ), '$.ReceiptId', NULL) , '$.PurchaseDate', NULL) , '$.Distributor', NULL) 
					 From #ReceiptDetails
					)

				--select * from cte
				select ReceiptId,PurchaseDate,Distributor,string_agg(jq,',') as ProductDetails 
				into #ReceiptDetailsAggregated
				from cte group by ReceiptId,PurchaseDate ,Distributor

				--select * from #ReceiptDetailsAggregated

				Select  @Result =  @Result + ',"ReceiptsDetails":'+(select ReceiptId,PurchaseDate,Distributor, '['+ProductDetails+']' as ProductDetails from #ReceiptDetailsAggregated  FOR JSON PATH)+''				
				
				DROP TABLE IF EXISTS #ReceiptDetailsAggregated
			
			end
			else
			begin
				Select  @Result = @Result + ',"ReceiptsDetails":{}'
			end

			----------------------------------------------------------------------------------------------------------
			-- END of Points/Quantity/Product By Receipt
			----------------------------------------------------------------------------------------------------------


			----------------------------------------------------------------------------------------------------------
			-- Start of Reward items redeemed with count and points used per item
			----------------------------------------------------------------------------------------------------------


			DROP TABLE IF EXISTS #RewardsByQtyAndPoints
			
			select Reward, JSON_QUERY( (Select sum(isnull(Quantity,0)) Quantity,abs(sum(isnull(PointsRedeemed,0))) PointsRedeemed FOR JSON PATH,Without_Array_Wrapper )) as Details
			into #RewardsByQtyAndPoints
			from @RedeemPointsDataForRetailer
			group by Reward
			having Reward is not null

			IF EXISTS (SELECT 1 FROM #RewardsByQtyAndPoints)
			BEGIN
				set @ColumnsToPivot = ''
				SELECT @ColumnsToPivot = @ColumnsToPivot+ '[' + t.Reward + '],'
				FROM(SELECT DISTINCT Reward FROM @RedeemPointsDataForRetailer) AS t

				SET @ColumnsToPivot = LEFT(@ColumnsToPivot,LEN(@ColumnsToPivot) - 1)
				SET @SQL = '
							SELECT '+@ColumnsToPivot+' INTO ##RewardsByQtyAndPointsPivoted
									FROM 
									(
										SELECT	Reward,Details
										FROM	#RewardsByQtyAndPoints 
									) AS P
									PIVOT
									(
										MIN(Details)
										FOR Reward IN ('+@ColumnsToPivot+')
									) AS PivotedTable
								'

				EXEC (@sql)

				declare @tempResult nvarchar(max) = ''


				;with cte as (
				Select 
					JS= '{'+(select string_agg('"'+[key] COLLATE Latin1_General_CI_AS+'":'+[value] COLLATE Latin1_General_CI_AS,',') from OPENJSON((Select ##RewardsByQtyAndPointsPivoted.* FOR JSON PATH,Without_Array_Wrapper )))+'}'
					From ##RewardsByQtyAndPointsPivoted
				)
		

				Select  @Result = @Result + ',"RewardsRedeemedByPointsAndQuantity":'+string_agg(JS,',')+''
				From  cte

				
				--Select  @tempResult = @tempResult + ',"RewardRedeemedByPointsAndQuantity":'+string_agg(JS,',')+''
				--From  cte
				--print '{'+@tempResult+'}'

				DROP TABLE IF EXISTS  ##RewardsByQtyAndPointsPivoted

			END
			ELSE
			BEGIN
				Select  @Result = @Result + ',"RewardsRedeemedByPointsAndQuantity":{}'
			END

			

			----------------------------------------------------------------------------------------------------------
			-- END of Reward items redeemed with count and points used per item
			----------------------------------------------------------------------------------------------------------




			SET @Result = '{'+@Result+'}'

			--print @Result
			PRINT CAST(@Result AS NTEXT)

	END
	ELSE IF @UserSubType = 'Distributor'
	BEGIN

			DECLARE @SubDistributorList	NVARCHAR(max)

			IF LEN(ISNULL(@SearchParams,''))>0 AND ISJSON(@SearchParams) = 1
			BEGIN
				SET @SubDistributorList = ISNULL(CAST(JSON_VALUE(@SearchParams,'$.SubDistributorList') AS NVARCHAR(max)),'')
			END

			DECLARE @SubDistributorIds TABLE(UserId INT)
			IF len(isnull(@SubDistributorList,''))>0
			BEGIN				
				INSERT @SubDistributorIds(UserId)
				SELECT token FROM [dbo].[SplitString](@SubDistributorList,',') option (maxrecursion 1000)
			END
			
		
			--drop table if exists #ExtReferences
			drop table if exists #AssociatedRetailers
			declare @userloyaltyExtensiondataid int, @RelationshipData nvarchar(max)
			--select @userloyaltyExtensiondataid = UserLoyaltyDataId from [User] where userid = @UserId
			--select @RelationshipData = PropertyValue from UserLoyaltyExtensionData where PropertyName = 'Relationship' and UserLoyaltyDataId = @userloyaltyExtensiondataid			


			--select CASE WHEN ISJSON(t.[value])=1 THEN (SELECT ISNULL(p.[value],'') FROM OPENJSON(t.[value],'$') p WHERE p.[key] = 'ExtReference') ELSE '' END as ExtReference 
			--into #ExtReferences
			--from openjson(@RelationshipData) as t

			INSERT INTO @SubDistributorIds(UserId) VALUES(@UserId) -- add main distributorid

			DECLARE @ExtReferences TABLE(ExtReference nvarchar(50))
			Declare @cnt int, @subdistributorId int
			select @cnt = count(*) from @SubDistributorIds
			WHILE @cnt>0
			BEGIN
				--fetching main distributor + subdistributor's associated retailers
				select top 1 @subdistributorId = UserId from @SubDistributorIds

				select @userloyaltyExtensiondataid = UserLoyaltyDataId from [User] where userid = @subdistributorId
				select @RelationshipData = PropertyValue from UserLoyaltyExtensionData where PropertyName = 'Relationship' and UserLoyaltyDataId = @userloyaltyExtensiondataid	

				insert into @ExtReferences(ExtReference)
				select CASE WHEN ISJSON(t.[value])=1 THEN (SELECT ISNULL(p.[value],'') FROM OPENJSON(t.[value],'$') p WHERE p.[key] = 'ExtReference') ELSE '' END as ExtReference
				from openjson(@RelationshipData) as t

				delete from @SubDistributorIds where UserId = @subdistributorId
				
				SET @cnt = @cnt - 1
			END

			-- get associated retailers
			select u.userid as RetailerId
			into #AssociatedRetailers
			from @ExtReferences ext 
			inner join [User] u on u.ExtReference COLLATE Latin1_General_CI_AS = ext.ExtReference COLLATE Latin1_General_CI_AS		

			
			IF len(isnull(@SubDistributorList,''))>0
			BEGIN				
				INSERT @SubDistributorIds(UserId)
				SELECT token FROM [dbo].[SplitString](@SubDistributorList,',') option (maxrecursion 1000)
			END
			INSERT INTO @SubDistributorIds(UserId) VALUES(@UserId)

			DECLARE @ReceiptDataByDistributor TABLE (ReceiptId INT,RetailerId INT,DistributorId INT,  YMonth NVARCHAR(20),TrxType NVARCHAR(15), TrxId INT, Quantity INT, ProductDescription NVARCHAR(max),CreatedDate DATETIMEOFFSET)

			INSERT INTO @ReceiptDataByDistributor(ReceiptId,RetailerId,DistributorId,YMonth,TrxType,TrxId, Quantity, ProductDescription,CreatedDate)
			SELECT	  r.ReceiptId
					, r.SnippUserId as RetailerId
					, r.UserId as DistributorId		
					, (SELECT isnull(TValue,'no-translation') FROM #ReceiptTranslations WHERE TGroup='PortalKPIs' AND TKey = FORMAT(cast(r.CreatedDate as datetime2 ), 'MMMM')) + '-' + FORMAT(cast(r.CreatedDate as datetime2 ), 'yyyy')  as TransYearMonth
					, tt.[Name] as TrxType
					, th.TrxId
					, td.Quantity
					, pInfo.ProductDescription
					,r.CreatedDate
			from Receipt r
			inner join TrxHeader th on r.ReceiptId = th.ReceiptId
			inner join TrxDetail td on td.TrxId = th.TrxId
			inner join TrxType tt on tt.TrxTypeId = th.TrxTypeId			
			left join ProductInfo pInfo on pInfo.ProductId = td.ItemCode
			where r.UserId in (select UserId from @SubDistributorIds) -- includes distributorid plus subdistributorids if any
			and th.TrxTypeId in (@TrxTypeIdReceipt,@TrxTypeIdInValidReceipt)
			and th.TrxStatusTypeId = @TrxStatusIdCompleted
			and (@FromDate is null OR r.CreatedDate between @FromDate and @ToDate)
			and r.ProcessingStatus != 'Processing'

			union all 

			SELECT	  r.ReceiptId
					, r.SnippUserId as RetailerId
					, r.UserId as DistributorId
					, (SELECT isnull(TValue,'no-translation') FROM #ReceiptTranslations WHERE TGroup='PortalKPIs' AND TKey = FORMAT(cast(r.CreatedDate as datetime2 ), 'MMMM')) + '-' + FORMAT(cast(r.CreatedDate as datetime2 ), 'yyyy')  as TransYearMonth
					, 'PendingReceipt' as TrxType
					, NULL
					, NULL
					, NULL,
					r.CreatedDate
			from	Receipt r
			WHERE   r.UserId in (select UserId from @SubDistributorIds) -- includes distributorid plus subdistributorids if any
			AND		r.ProcessingStatus = 'Processing'
			and (@FromDate is null OR r.CreatedDate between @FromDate and @ToDate)


			order by r.CreatedDate desc
						
			-----------------------------------------------------------------------------------------------
			-- Start NoOfReceiptsUploaded - valid/invalid status
			-----------------------------------------------------------------------------------------------
			INSERT INTO #ReceiptDistinct
			SELECT distinct ReceiptId,YMonth,TrxType
			from @ReceiptDataByDistributor
		
			INSERT INTO #ReceiptCountDetails(YMonth,TrxType,ReceiptsCount)
			SELECT YMonth,TrxType, COUNT(ReceiptId) as ReceiptsCount
			from #ReceiptDistinct 
			group by YMonth,TrxType

			--select * from #ReceiptCountDetails
		
			INSERT INTO #ReceiptSummaryPivoted
			SELECT YMonth,Receipt,InValidReceipt,PendingReceipt
			FROM 
			(
				SELECT	YMonth,TrxType,ReceiptsCount
				FROM	#ReceiptCountDetails 
			) AS P
			PIVOT
			(
				MIN(ReceiptsCount)
				FOR TrxType IN (Receipt,InValidReceipt,PendingReceipt)
			)AS PivotedTable

			IF EXISTS (SELECT 1 FROM #ReceiptSummaryPivoted)
			BEGIN
				;with cte as (
				 Select YMonth,JS=JSON_QUERY( (Select isnull(ValidReceipts,0) ValidReceipts
												   ,isnull(InValidReceipts,0) InValidReceipts,
												   isnull(PendingReceipts,0) PendingReceipts
											   FOR JSON PATH,Without_Array_Wrapper) )
				 From #ReceiptSummaryPivoted
				)
				Select  @Result = '"NoOfReceiptsUploaded":{'+string_agg('"'+YMonth+'":'+REPLACE(REPLACE(REPLACE(JS,'ValidReceipts',@TValidReceipts),'InValidReceipts',@TInValidReceipts),'PendingReceipts',@TPendingReceipts),',')+'}'
				From  cte
			END
			ELSE
			BEGIN
				Select  @Result = '"NoOfReceiptsUploaded":{}'
			END

			-----------------------------------------------------------------------------------------------
			-- Start NoOfReceiptsUploaded - by retailer
			-----------------------------------------------------------------------------------------------
			CREATE TABLE #UploadsByRetailer
			(
				YMonth NVARCHAR(20),RetailerId INT,TrxType VARCHAR(20),ReceiptsCount INT
			)

			INSERT INTO #UploadsByRetailer(YMonth,RetailerId,TrxType,ReceiptsCount)
			SELECT YMonth,RetailerId,TrxType,COUNT(ReceiptId) as ReceiptsCount
			from @ReceiptDataByDistributor
			where RetailerId in (select RetailerId from #AssociatedRetailers)
			group by YMonth,RetailerId,TrxType

			

			CREATE TABLE #ReceiptRetailerByTrxtypePivoted
			(
				YMonth NVARCHAR(20),RetailerId INT, Receipt INT,InValidReceipt INT,PendingReceipt INT
			)

			CREATE TABLE #UploadsByRetailerWithName
			(
				YMonth NVARCHAR(20),RetailerName NVARCHAR(250), ReceiptsCountJson VARCHAR(200)
			)

			

			IF EXISTS(SELECT RetailerId FROM #UploadsByRetailer)
			BEGIN


				INSERT INTO #ReceiptRetailerByTrxtypePivoted
				SELECT YMonth,RetailerId,Receipt,InValidReceipt,PendingReceipt
				FROM 
				(
					SELECT	YMonth,RetailerId,TrxType,ReceiptsCount
					FROM	#UploadsByRetailer 
				) AS P
				PIVOT
				(
					MIN(ReceiptsCount)
					FOR TrxType IN (Receipt,InValidReceipt,PendingReceipt)
				)AS PivotedTable


				--INSERT INTO #UploadsByRetailerWithName(YMonth,RetailerName,ReceiptsCountJson)
				--SELECT r.YMonth, Replace(isnull(pd.FirstName+ ' '+pd.LastName,'unknown'),'.','-') as RetailerName,JSON_QUERY( (Select isnull(r.Receipt,0) ValidReceipts,isnull(r.InvalidReceipt,0) InValidReceipts,isnull(r.PendingReceipt,0)PendingReceipts FOR JSON PATH,Without_Array_Wrapper ))
				--FROM #ReceiptRetailerByTrxtypePivoted r
				--inner join [User] u on u.UserId = r.RetailerId
				--inner join PersonalDetails pd on pd.PersonalDetailsId = u.PersonalDetailsId	
				
				
				INSERT INTO #UploadsByRetailerWithName(YMonth,RetailerName,ReceiptsCountJson)
				SELECT r.YMonth, Replace(isnull(addr.AddressLine1,'unknown'),'.','__') as RetailerName,JSON_QUERY( (Select isnull(r.Receipt,0) ValidReceipts,isnull(r.InvalidReceipt,0) InValidReceipts,isnull(r.PendingReceipt,0)PendingReceipts FOR JSON PATH,Without_Array_Wrapper ))
				FROM #ReceiptRetailerByTrxtypePivoted r
				OUTER APPLY ( 				
					select top 1 a.addressline1 -- requirement came up to use company name instead of Retailer Name. used OUTER APPLY thinking no duplicate addresses.
					from UserAddresses ua 
					inner join [Address] a on ua.AddressId = a.AddressId
					Where ua.Userid = r.RetailerId
					and a.AddressTypeId = @AddressTypeId
					and a.AddressStatusId = @AddressStatusId
					and a.AddressValidStatusId = @AddressValidStatusId
					order by a.addressid desc
					) addr

				


				SET @ColumnsToPivot = ''
				SELECT @ColumnsToPivot = @ColumnsToPivot+ '[' + t.RetailerName + '],'
				FROM(SELECT DISTINCT RetailerName FROM #UploadsByRetailerWithName) AS t

				SET @ColumnsToPivot = LEFT(@ColumnsToPivot,LEN(@ColumnsToPivot) - 1)
				SET @SQL = '
							SELECT YMonth, '+@ColumnsToPivot+' INTO ##UploadsByRetailerPivoted 
								FROM 
								(
									SELECT	YMonth,RetailerName,ReceiptsCountJson
									FROM	#UploadsByRetailerWithName  
								) AS P
								PIVOT
								(
									MIN(ReceiptsCountJson)
									FOR RetailerName IN ('+@ColumnsToPivot+')
								) AS PivotedTable
							'

				EXEC (@sql)
				

				;with cte as (
				 Select YMonth,
				 JS= '{'+(select string_agg('"'+[key] COLLATE Latin1_General_CI_AS+'":'+[value] COLLATE Latin1_General_CI_AS,',') from OPENJSON(JSON_MODIFY( (Select ##UploadsByRetailerPivoted.* FOR JSON PATH,Without_Array_Wrapper ) , '$.YMonth', NULL)))+'}'
				 From ##UploadsByRetailerPivoted
				)
		

				Select  @Result = @Result + ',"NoOfReceiptsUploadedForRetailer":{'+string_agg('"'+YMonth+'":'+REPLACE(REPLACE(REPLACE(REPLACE(JS,'ValidReceipts',@TValidReceipts),'InValidReceipts',@TInValidReceipts),'PendingReceipts',@TPendingReceipts),'__','.'),',')+'}'
				From  cte

				DROP TABLE ##UploadsByRetailerPivoted

			END
			ELSE
			BEGIN
				Select  @Result = @Result + ',"NoOfReceiptsUploadedForRetailer":{}'
			END


			-----------------------------------------------------------------------------------------
			-- Start of QuantityByProducts
			-----------------------------------------------------------------------------------------
			INSERT INTO #QtyByProduct(YMonth,Product,Qty)
			SELECT YMonth, Replace(Replace(ProductDescription,'.','--'),',','-'), sum(Quantity) as Qty
			FROM @ReceiptDataByDistributor 
			WHERE ProductDescription is not null
			GROUP BY YMonth,ProductDescription			
		
			SEt @ColumnsToPivot = ''
			IF EXISTS (SELECT Product FROM #QtyByProduct)
			BEGIN
				SELECT @ColumnsToPivot = @ColumnsToPivot+ '[' + t.Product + '],'
				FROM(SELECT DISTINCT Product FROM #QtyByProduct) AS t

				SET @ColumnsToPivot = LEFT(@ColumnsToPivot,LEN(@ColumnsToPivot) - 1)
				SET @SQL = '
							SELECT YMonth, '+@ColumnsToPivot+' INTO ##QtyByProductSummaryPivoted
								FROM 
								(
									SELECT	YMonth,Product,Qty
									FROM	#QtyByProduct  
								) AS P
								PIVOT
								(
									MIN(Qty)
									FOR Product IN ('+@ColumnsToPivot+')
								) AS PivotedTable
							'

				EXEC (@sql)

		

				;with cte as (
				 Select YMonth,JS= JSON_MODIFY(JSON_QUERY( (Select ##QtyByProductSummaryPivoted.*
											   FOR JSON PATH,Without_Array_Wrapper ) ), '$.YMonth', NULL) 
				 From ##QtyByProductSummaryPivoted
				)


				Select  @Result = @Result + ',"QuantityPerProduct":{'+string_agg('"'+YMonth+'":'+JS,',')+'}'
				From  cte

				DROP TABLE ##QtyByProductSummaryPivoted

			END
			ELSE
			BEGIN
				Select  @Result = @Result + ',"QuantityPerProduct":{}'
			END



			-----------------------------------------------------------------------------------------------
			-- Start Top 5 Retailers by qty per product
			-----------------------------------------------------------------------------------------------

			DROP TABLE IF EXISTS #ProductQtySumByRetailerAndProduct
			CREATE TABLE #ProductQtySumByRetailerAndProduct
			(
				RetailerId INT, QuantitySum INT,Product nvarchar(max)
			)
			DROP TABLE IF EXISTS #ProductQtySumByRetailerAndProductByName
			CREATE TABLE #ProductQtySumByRetailerAndProductByName
			(
				RetailerId INT,RetailerName nvarchar(250), Product nvarchar(max), QuantitySum INT, displayRank int
			)

			DROP TABLE IF EXISTS #ProductQtySumByRetailerAndProductTop5


			INSERT INTO #ProductQtySumByRetailerAndProduct(RetailerId,QuantitySum,Product)
			SELECT RetailerId,  sum(Quantity) as Qty, ProductDescription
			FROM @ReceiptDataByDistributor 
			WHERE ProductDescription is not null
			and RetailerId in (select RetailerId from #AssociatedRetailers)
			GROUP BY RetailerId,ProductDescription


			SELECT top 5 RetailerId,  sum(QuantitySum) as QuantityByRetailer,IDENTITY(int) as displayRank
			INTO #ProductQtySumByRetailerAndProductTop5
			FROM #ProductQtySumByRetailerAndProduct 
			GROUP BY RetailerId
			ORDER BY QuantityByRetailer desc


			--INSERT INTO #ProductQtySumByRetailerAndProductByName(RetailerId,QuantitySum,Product,RetailerName, displayRank)
			--SELECT r.RetailerId,QuantitySum,Replace(Replace(Product,'.','--'),',','-') as Product, Replace(isnull(pd.FirstName+ ' '+pd.LastName,'unknown'),'.','-') as RetailerName, top5.displayRank
			--FROM #ProductQtySumByRetailerAndProduct r
			--inner join [User] u on u.UserId = r.RetailerId
			--inner join PersonalDetails pd on pd.PersonalDetailsId = u.PersonalDetailsId	
			--inner join #ProductQtySumByRetailerAndProductTop5 as top5 on top5.RetailerId = r.RetailerId
			--WHERE r.RetailerId in (SELECT RetailerId FROM #ProductQtySumByRetailerAndProductTop5)
			--ORDER BY top5.displayRank


			INSERT INTO #ProductQtySumByRetailerAndProductByName(RetailerId,QuantitySum,Product,RetailerName, displayRank)
			SELECT r.RetailerId,QuantitySum,Replace(Replace(Product,'.','--'),',','-') as Product, Replace(isnull(addr.addressline1,'unknown'),'.','__') as RetailerName, top5.displayRank
			FROM #ProductQtySumByRetailerAndProduct r
			OUTER APPLY ( 				
					select top 1 a.addressline1 -- requirement came up to use company name instead of Retailer Name. used OUTER APPLY thinking no duplicate addresses.
					from UserAddresses ua 
					inner join [Address] a on ua.AddressId = a.AddressId
					Where ua.Userid = r.RetailerId
					and a.AddressTypeId = @AddressTypeId
					and a.AddressStatusId = @AddressStatusId
					and a.AddressValidStatusId = @AddressValidStatusId
					order by a.addressid desc
					) addr
			inner join #ProductQtySumByRetailerAndProductTop5 as top5 on top5.RetailerId = r.RetailerId
			WHERE r.RetailerId in (SELECT RetailerId FROM #ProductQtySumByRetailerAndProductTop5)
			ORDER BY top5.displayRank



			SEt @ColumnsToPivot = ''
			IF EXISTS (SELECT Product FROM #ProductQtySumByRetailerAndProductByName)
			BEGIN
				SELECT @ColumnsToPivot = @ColumnsToPivot+ '[' + t.Product + '],'
				FROM(SELECT DISTINCT Product FROM #ProductQtySumByRetailerAndProductByName) AS t

				SET @ColumnsToPivot = LEFT(@ColumnsToPivot,LEN(@ColumnsToPivot) - 1)
				SET @SQL = '
							SELECT RetailerName,displayRank, '+@ColumnsToPivot+' INTO ##ProductQtySumByRetailerPivoted
								FROM 
								(
									SELECT	RetailerName,displayRank,Product,QuantitySum
									FROM	#ProductQtySumByRetailerAndProductByName  
								) AS P
								PIVOT
								(
									MIN(QuantitySum)
									FOR Product IN ('+@ColumnsToPivot+')
								) AS PivotedTable
							'

				EXEC (@sql)


				;with cte as (
				 Select RetailerName,displayRank,JS= JSON_MODIFY(JSON_MODIFY(JSON_QUERY( (Select ##ProductQtySumByRetailerPivoted.*
											   FOR JSON PATH,Without_Array_Wrapper ) ), '$.RetailerName', NULL) , '$.displayRank', NULL)
				 From ##ProductQtySumByRetailerPivoted 
				)

				SELECT cte.RetailerName,cte.displayRank,cte.JS
				INTO #TempOrderTop5
				FROM cte order by displayRank

				
				Select  @Result = @Result + ',"Top5RetailerByQtyPerProduct":{'+string_agg('"'+RetailerName COLLATE Latin1_General_CI_AS+'":'+JS COLLATE Latin1_General_CI_AS,',')+'}'
				From  #TempOrderTop5 

				DROP TABLE IF EXISTS #TempOrderTop5
				DROP TABLE IF EXISTS  ##ProductQtySumByRetailerPivoted

			END
			ELSE
			BEGIN
				Select  @Result = @Result + ',"Top5RetailerByQtyPerProduct":{}'
			END



			-----------------------------------------------------------------------------------------------
			-- End Top 5 Retailers by qty per product
			-----------------------------------------------------------------------------------------------


			---***--------------------------------------------------------------------------------------------
			-- Start No. of active retailers per city
			-----------------------------------------------------------------------------------------------

			drop table if exists #NumberOfRetailersPerCity
			declare  @addressTypeIdMain int, @userStatusIdActive int
			select @addressTypeIdMain = AddressTypeId from AddressType where [Name] = 'Main' and clientid = @ClientId
			select @userStatusIdActive = UserStatusId from UserStatus where [Name] = 'Active' and clientid = @ClientId

			
			select a.City as City,Count(u.userid) as NumberOfRetailers
			into #NumberOfRetailersPerCity
			from @ExtReferences ext -- includes extreferences of associated retailers of main distributor + sub distributors
			inner join [User] u on u.ExtReference COLLATE Latin1_General_CI_AS = ext.ExtReference COLLATE Latin1_General_CI_AS
			inner join UserAddresses ua on ua.UserId = u.userid
			inner join [Address] a on a.AddressId = ua.AddressId
			where a.AddressTypeId = @addressTypeIdMain
			and u.UserStatusId = @userStatusIdActive
			group by a.City order by Count(u.userid) desc
						

			IF EXISTS (SELECT 1 FROM #NumberOfRetailersPerCity)
			BEGIN
				set @ColumnsToPivot = ''
				SELECT @ColumnsToPivot = @ColumnsToPivot+ '[' + t.City + '],'
				FROM(SELECT DISTINCT City FROM #NumberOfRetailersPerCity) AS t

				SET @ColumnsToPivot = LEFT(@ColumnsToPivot,LEN(@ColumnsToPivot) - 1)

				--print @ColumnsToPivot

				SET @SQL = '
								SELECT  '+@ColumnsToPivot+' INTO ##NumberOfRetailersPerCityPivoted
									FROM 
									(
										SELECT	City,NumberOfRetailers
										FROM	#NumberOfRetailersPerCity  
									) AS P
									PIVOT
									(
										MIN(NumberOfRetailers)
										FOR City IN ('+@ColumnsToPivot+')
									) AS PivotedTable
								'

				EXEC (@sql)

				;with cte as (
				 Select JS= JSON_QUERY( (Select ##NumberOfRetailersPerCityPivoted.*
											   FOR JSON PATH,Without_Array_Wrapper ) )
				 From ##NumberOfRetailersPerCityPivoted
				)

				--select * from cte

				Select  @Result = @Result + ',"NumberOfActiveRetailersPerCity":'+string_agg(JS,',')+''
				From  cte

				DROp TABLE IF EXISTS ##NumberOfRetailersPerCityPivoted
			END
			ELSE
			BEGIN

				Select  @Result = @Result + ',"NumberOfActiveRetailersPerCity":{}'

			END

			-----------------------------------------------------------------------------------------------
			-- END No. of active retailers per city
			-----------------------------------------------------------------------------------------------

			--=============================================================================================
			-- Start Retailers' summary
			-----------------------------------------------------------------------------------------------

			

			Drop Table if Exists #Retailers

			-- This query is redundant, active check is extra
			select u.userid as RetailerId
			into #Retailers
			from @ExtReferences ext 
			inner join [User] u on u.ExtReference COLLATE Latin1_General_CI_AS = ext.ExtReference COLLATE Latin1_General_CI_AS
			where u.UserStatusId = @userStatusIdActive
			

			Drop Table if Exists #RetailersWithTransaction

			
			SELECT	th.TrxId as TrxId,d.UserId as UserId
			into #RetailersWithTransaction
			from TrxHeader th
			inner join TrxType tt on tt.TrxTypeId = th.TrxTypeId
			inner join Device d on d.Deviceid = th.Deviceid
			inner join #Retailers ret on ret.RetailerId = d.UserId
			where th.TrxTypeId in (@TrxTypeIdReceipt,@TrxTypeIdInValidReceipt,@TrxTypeIdRedeemPoints,@TrxTypeIdActivity) 
			and th.TrxStatusTypeId = @TrxStatusIdCompleted
			and (@FromDate is null or th.TrxDate between @FromDate and @ToDate)
			

			DROP TABLE IF EXISTS #RetailersSummary
			CREATE TABLE #RetailersSummary
			(
				PName nvarchar(100), PValue INT
			)

			INSERT INTO #RetailersSummary(PName,PValue)
			SELECT 'NoOfRetailers' as PName, count(distinct RetailerId) as PValue from #Retailers 

			INSERT INTO #RetailersSummary(PName,PValue)
			SELECT 'NoOfRetailersHavingTransaction' as PName, count(distinct UserId) as PValue from #RetailersWithTransaction  

			--select * from #RetailersSummary

			set @ColumnsToPivot = ''
				SELECT @ColumnsToPivot = @ColumnsToPivot+ '[' + t.PName + '],'
				FROM(SELECT DISTINCT PName FROM #RetailersSummary) AS t

				SET @ColumnsToPivot = LEFT(@ColumnsToPivot,LEN(@ColumnsToPivot) - 1)

				SET @SQL = '
								SELECT  '+@ColumnsToPivot+' INTO ##RetailersSummaryPivoted
									FROM 
									(
										SELECT	PName,PValue
										FROM	#RetailersSummary  
									) AS P
									PIVOT
									(
										MIN(PValue)
										FOR PName IN ('+@ColumnsToPivot+')
									) AS PivotedRetailersTable
								'

				EXEC (@sql)


			;with cte as (
			Select JS= JSON_QUERY( (Select ##RetailersSummaryPivoted.*
											   FOR JSON PATH,Without_Array_Wrapper ) )
			From ##RetailersSummaryPivoted
			)

				--select * from cte

			Select  @Result = @Result + ',"RetailersSummary":'+string_agg(JS,',')+''
			From  cte

			DROp TABLE IF EXISTS ##RetailersSummaryPivoted


			-----------------------------------------------------------------------------------------------
			-- END Retailers' summary
			-----------------------------------------------------------------------------------------------



			--SET @Result = '"DistributorId":"'+Cast(@UserId as nvarchar)+'", "DistributorName":"'+@UserName+'",' + @Result
			SET @Result = '{'+@Result+'}'

			--print @Result
			PRINT CAST(@Result AS NTEXT)
			
	END

END