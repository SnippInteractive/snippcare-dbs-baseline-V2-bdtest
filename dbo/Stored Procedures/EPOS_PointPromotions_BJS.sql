﻿
-- =============================================
-- Author:		ANISH
-- Create date: 2018-03-01
-- Description:	EPOS
-- =============================================
-- Modified by:		Wei liu
-- Date: 2020-04-22
-- Description:	Quantity promotion/comments
-- =============================================
-- Modified by:		Binu Jacob Scaria
-- Date: 2020-05-19
-- Description:	Include / Exclude
-- =============================================
CREATE PROCEDURE [dbo].[EPOS_PointPromotions_BJS] 
-- Add the parameters for the stored procedure here
(@TrxId INT)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
		 BEGIN TRY                                                        
BEGIN TRAN  
	-- A procedure call to update homesite
	exec EPOS_AllocateHomeSiteFirstPurchase @TrxId
	-- One TIME operations, no relations with offers
	exec [dbo].[EPOS_AnonymousPreviousTransactionsWithSameReference] @TrxId 

	--Offer sections start here
	DECLARE @MemberId INT
	DECLARE @ClientId INT,@ClientName varchar(20)='baseline'
	SET @ClientId=(SELECT clientid from client where name=@ClientName)
	DECLARE @LoyaltyDevice VARCHAR(50)
	DECLARE @SiteId INt
	DECLARE @DeviceStatusActive INT
	DECLARE @item nvarchar(max), @code nvarchar(max), @quantity int, @itemQuantity int, @qualIFy int 
	DECLARE @reference varchar(50);
	SET @DeviceStatusActive=(SELECT devicestatusid from Devicestatus where name='Active' and clientid=@ClientId)
	-- Get the device id from trx header
	SELECT @LoyaltyDevice=deviceid,@SiteId=siteid,@reference=Reference from trxheader where trxid=@TrxId
	-- Get the member id from device id
	SET @MemberId=(SELECT userid from device where deviceid=@LoyaltyDevice)
 
	-- store all item filters to #itemcode from current trx detail table
	SELECT  TrxDetailId,Anal1,anal2,anal3,anal4,anal5,anal6,anal7,anal8,anal9,anal10,anal11,anal12,anal13,Points,LineNumber,@SiteId as SiteId,anal14,anal15,anal16,ItemCode,value, Quantity into #itemcode from TrxDetail where trxid=@TrxId
	-----------------------------------------------------------------------------------------
	print 'Start insert all promotion items at ' + convert(varchar(25), getdate(), 120)  
	-----------------------------------------------------------------------------------------
	-- store itemcode into #tempCode 
	SELECT * into #tempCode from
	(SELECT TrxDetailId,Points,value,LineNumber,( SELECT id from PromotionItemType where name='AnalysisCode1' and clientid=@ClientId) as TypeId,anal1 as Code,SiteId,Quantity   from #itemcode where anal1 is not null
	union
	SELECT TrxDetailId,Points,value,LineNumber,( SELECT id from PromotionItemType where name='AnalysisCode2' and clientid=@ClientId) as TypeId,anal2 as Code,SiteId,Quantity   from #itemcode where anal2 is not null
	union
	SELECT TrxDetailId,Points,value,LineNumber,( SELECT id from PromotionItemType where name='AnalysisCode3' and clientid=@ClientId) as TypeId,anal3 as Code,SiteId ,Quantity  from #itemcode where anal3 is not null
	union
	SELECT TrxDetailId,Points,value,LineNumber,( SELECT id from PromotionItemType where name='AnalysisCode4' and clientid=@ClientId) as TypeId,anal4 as Code,SiteId ,Quantity  from #itemcode where anal4 is not null
	union
	SELECT TrxDetailId,Points,value,LineNumber,( SELECT id from PromotionItemType where name='AnalysisCode5' and clientid=@ClientId) as TypeId,anal5 as Code,SiteId ,Quantity  from #itemcode where anal5 is not null
	union
	SELECT TrxDetailId,Points,value,LineNumber,( SELECT id from PromotionItemType where name='AnalysisCode6' and clientid=@ClientId) as TypeId,anal6 as Code,SiteId ,Quantity  from #itemcode where anal6 is not null
	union
	SELECT TrxDetailId,Points,value,LineNumber,( SELECT id from PromotionItemType where name='AnalysisCode7' and clientid=@ClientId) as TypeId,anal7 as Code,SiteId ,Quantity from #itemcode where anal7 is not null
	union
	SELECT TrxDetailId,Points,value,LineNumber,( SELECT id from PromotionItemType where name='AnalysisCode8' and clientid=@ClientId) as TypeId,anal8 as Code,SiteId ,Quantity  from #itemcode where anal8 is not null
	union
	SELECT TrxDetailId,Points,value,LineNumber,( SELECT id from PromotionItemType where name='AnalysisCode9' and clientid=@ClientId) as TypeId,anal9 as Code,SiteId ,Quantity  from #itemcode where anal9 is not null
	union
	SELECT TrxDetailId,Points,value,LineNumber,( SELECT id from PromotionItemType where name='AnalysisCode10' and clientid=@ClientId) as TypeId,anal10 as Code,SiteId ,Quantity  from #itemcode where anal10 is not null
	union
	SELECT TrxDetailId,Points,value,LineNumber,( SELECT id from PromotionItemType where name='AnalysisCode11' and clientid=@ClientId) as TypeId,anal11 as Code,SiteId ,Quantity  from #itemcode where anal11 is not null
	union
	SELECT TrxDetailId,Points,value,LineNumber,( SELECT id from PromotionItemType where name='AnalysisCode12' and clientid=@ClientId) as TypeId,anal12 as Code,SiteId ,Quantity  from #itemcode where anal12 is not null
	union
	SELECT TrxDetailId,Points,value,LineNumber,( SELECT id from PromotionItemType where name='AnalysisCode13' and clientid=@ClientId) as TypeId,anal13 as Code,SiteId ,Quantity  from #itemcode where anal13 is not null
	union
	SELECT TrxDetailId,Points,value,LineNumber,( SELECT id from PromotionItemType where name='AnalysisCode14' and clientid=@ClientId) as TypeId,anal14 as Code,SiteId ,Quantity  from #itemcode where anal14 is not null
	union
	SELECT TrxDetailId,Points,value,LineNumber,( SELECT id from PromotionItemType where name='AnalysisCode15' and clientid=@ClientId) as TypeId,anal15 as Code,SiteId ,Quantity from #itemcode where anal15 is not null
	union
	SELECT TrxDetailId,Points,value,LineNumber,( SELECT id from PromotionItemType where name='AnalysisCode16' and clientid=@ClientId) as TypeId,anal16 as Code,SiteId ,Quantity  from #itemcode where anal16 is not null
	union
	SELECT TrxDetailId,Points,value,LineNumber,( SELECT id from PromotionItemType where name='ItemCode' and clientid=@ClientId) as TypeId,itemcode as Code,SiteId ,Quantity from #itemcode where itemcode is not null

	) t
	
	-- This will give a felexibility of easy mapping
	-- Store all Promotions into #offer table that match the current trx detail
	SELECT distinct CONVERT(varchar(50), p.Id ) as PromotionId, p.Name, tmp.LineNumber, tmp.TrxDetailID, tmp.Points,
	case(pop.Name) 
		when 'PointsMultiplier' then 
								case isnull(OverrideBasePointRestriction,0) 
								when 0 
								--then tmp.Points * (p.PromotionOfferValue-1)
								--else tmp.Value * (p.PromotionOfferValue-1) END
								-- between 0.1 & 0.9 check done to handle cases when offervalue set between 0 and 1 ,example 0.5 for points multiplier
								--between 0.1 & 0.9 will not affect offervalue = 0 for points multiplier,that why between 0.1 and 0.9 was introduced .
								then tmp.Points * (case when p.PromotionOfferValue between 0.1 and 0.9  then (p.PromotionOfferValue*-1) else (p.PromotionOfferValue-1) end)
								else tmp.Value * (case when p.PromotionOfferValue between 0.1 and 0.9  then (p.PromotionOfferValue*-1) else (p.PromotionOfferValue-1) end) END
		when 'Points' then case when CriteriaId = 2 then p.PromotionOfferValue * CONVERT(INT,tmp.Quantity / pt.Quantity) else p.PromotionOfferValue end END as BonusPoints , 
		pop.Name as OfferType,p.PromotionOfferValue, 0 as PriorityLevel,0 as Processed,'Promotion' as Offer, CriteriaId, pt.Code, pt.Quantity as itemQuantity, ISNULL(Cumulation,0) Cumulation,ISNULL(MaxPromoApplicationOnSameBasket,0) MaxPromoApplicationOnSameBasket,ItemIncludeExclude
	into #Offer from Promotion p  with(nolock)
	inner join PromotionOfferType pop with(nolock) on p.PromotionOfferTypeId=pop.Id
	inner join PromotionItem pt with(nolock) on p.id=pt.PromotionId
	inner join PromotionSites ps with(nolock) on p.id=ps.PromotionId
	inner join PromotionCategory pc with(nolock) on p.PromotionCategoryId=pc.Id
	inner join #tempCode tmp on  pt.PromotionItemTypeId=tmp.TypeId
	where  RTRIM(LTRIM(pt.Code))= RTRIM(LTRIM(tmp.Code))
	and p.Id not in(SELECT PromotionId from  VirtualPointPromotions where trxid=@Trxid and PromotionId>0) 
	and p.StartDate<=GETDATE() and p.ENDDate>=GETDATE() and p.IsTemplate=0 and p.Enabled=1 and pop.Name in('PointsMultiplier','Points') 
	and pc.Name not in ('StampCardQuantity','StampCardValue')
	and tmp.SiteId in( SELECT SiteId from GetChildSitesBySiteId(ps.siteid))
	and pt.ItemIncludeExclude = 'IncludeItem' 
	and p.PromotionTypeId!=1
	--SELECT * FROM #Offer
	--TOP 666
--Include Item
select distinct convert(varchar(50), p.Id )as PromotionId				
into #OfferInclude 
from Promotion p with(nolock)
inner join PromotionOfferType pop with(nolock) on p.PromotionOfferTypeId=pop.Id
inner join PromotionItem pt with(nolock) on p.id=pt.PromotionId
inner join PromotionSites ps with(nolock) on p.id=ps.PromotionId
inner join PromotionCategory pc on p.PromotionCategoryId=pc.Id
inner join #tempCode tmp with(nolock) on  pt.PromotionItemTypeId=tmp.TypeId
where -- RTRIM(LTRIM(pt.Code))= RTRIM(LTRIM(tmp.Code))and 
p.Id not in(select PromotionId from  VirtualPointPromotions where trxid=@Trxid and PromotionId>0) 
and p.StartDate<=getdate() and p.EndDate>=getdate() and p.IsTemplate=0 and p.Enabled=1 and pop.Name in('PointsMultiplier','Points') 
and pc.Name not in ('StampCardQuantity','StampCardValue')
and tmp.SiteId in( select SiteId from GetChildSitesBySiteId(ps.siteid))
and pt.ItemIncludeExclude = 'IncludeItem' 
and p.PromotionTypeId!=1 

--SELECT * FROM #OfferInclude
--END Include Item
--Exclude Item
select distinct convert(varchar(50), p.Id )as PromotionId,p.Name,tmp.LineNumber, tmp.TrxDetailID,tmp.Points,
 case(pop.Name) 
	when 'PointsMultiplier' then 
		case isnull(OverrideBasePointRestriction,0) 
		when 0 
		--between 0.1 & 0.9 will not affect offervalue = 0 for points multiplier,that why between 0.1 and 0.9 was introduced
			then tmp.Points*(case when p.PromotionOfferValue between 0.1 and 0.9 then (p.PromotionOfferValue*1) else (p.PromotionOfferValue-1) end) 
			else tmp.Value*(case when p.PromotionOfferValue between 0.1 and 0.9 then (p.PromotionOfferValue*1) else (p.PromotionOfferValue-1) end) 
		end
		when 'Points' then p.PromotionOfferValue 
		end 
	as BonusPoints,
	pop.Name as OfferType,p.PromotionOfferValue, 0 as PriorityLevel,0 as Processed,'Promotion' as Offer, CriteriaId, pt.Code, pt.Quantity as itemQuantity, ISNULL(Cumulation,0) Cumulation,ISNULL(MaxPromoApplicationOnSameBasket,0) MaxPromoApplicationOnSameBasket,ItemIncludeExclude
																				
into #OfferExclude 
from Promotion p with(nolock)
inner join PromotionOfferType pop with(nolock) on p.PromotionOfferTypeId=pop.Id
inner join PromotionItem pt with(nolock) on p.id=pt.PromotionId
inner join PromotionSites ps with(nolock) on p.id=ps.PromotionId
inner join PromotionCategory pc on p.PromotionCategoryId=pc.Id
inner join #tempCode tmp with(nolock) on  pt.PromotionItemTypeId=tmp.TypeId
where --RTRIM(LTRIM(pt.Code))= RTRIM(LTRIM(tmp.Code))and 
p.Id not in(select PromotionId from  VirtualPointPromotions where trxid=@Trxid and PromotionId>0) 
and p.StartDate<=getdate() and p.EndDate>=getdate() and p.IsTemplate=0 and p.Enabled=1 and pop.Name in('PointsMultiplier','Points') 
and pc.Name not in ('StampCardQuantity','StampCardValue')
and tmp.SiteId in( select SiteId from GetChildSitesBySiteId(ps.siteid))
and pt.ItemIncludeExclude = 'ExcludeItem' 
and p.PromotionTypeId!=1 
AND p.Id NOT IN (SELECT DISTINCT PromotionId FROM #OfferInclude)

--SELECT * FROM #OfferExclude
--IF EXISTS (SELECT 1 FROM  #OfferExclude)
--BEGIN
	INSERT INTO #Offer 
	SELECT * FROM #OfferExclude 
--END
--END Exclude Item
--END TOP 666

	SELECT * INTO #VirtualStampCard FROM VirtualStampCard WHERE TrxId = @TrxId AND PromotionOfferType IN ('Points','PointsMultiplier')
	---SELECT * FROM #VirtualStampCard
	INSERT INTO #Offer
	SELECT distinct CONVERT(varchar(50), p.Id ) as PromotionId, p.Name, tmp.LineNumber, tmp.TrxDetailID, tmp.Points,
	case(pop.Name) 
		when 'PointsMultiplier' then 
								case isnull(OverrideBasePointRestriction,0) 
								when 0 
								then tmp.Points * (p.PromotionOfferValue-1)
								else tmp.Value * (p.PromotionOfferValue-1) END
		when 'Points' then case when CriteriaId = 2 then p.PromotionOfferValue * CONVERT(INT,tmp.Quantity / pt.Quantity) else p.PromotionOfferValue end END as BonusPoints , pop.Name as OfferType,p.PromotionOfferValue, 0 as PriorityLevel,0 as Processed,'Promotion' as Offer, CriteriaId, pt.Code, pt.Quantity as itemQuantity, ISNULL(Cumulation,0) Cumulation,ISNULL(MaxPromoApplicationOnSameBasket,0) MaxPromoApplicationOnSameBasket,ItemIncludeExclude
	from Promotion p 
	inner join PromotionOfferType pop on p.PromotionOfferTypeId=pop.Id
	inner join PromotionItem pt on p.id=pt.PromotionId
	inner join PromotionSites ps on p.id=ps.PromotionId
	inner join PromotionCategory pc on p.PromotionCategoryId=pc.Id
	inner join #tempCode tmp on  pt.PromotionItemTypeId=tmp.TypeId
	inner join #VirtualStampCard vs on vs.LineNumber = tmp.LineNumber
	where  RTRIM(LTRIM(pt.Code))= RTRIM(LTRIM(tmp.Code))
	and p.Id not in(SELECT PromotionId from  VirtualPointPromotions where trxid=@Trxid and PromotionId>0) 
	and p.StartDate<=GETDATE() and p.ENDDate>=GETDATE() and p.IsTemplate=0 and p.Enabled=1 and pop.Name in('PointsMultiplier','Points') 
	and pc.Name in ('StampCardQuantity','StampCardValue')
	and tmp.SiteId in( SELECT SiteId from GetChildSitesBySiteId(ps.siteid))
	and p.PromotionTypeId!=1
	and vs.PromotionOfferType in('PointsMultiplier','Points') 

	-- Vouchers into temp #offer table that match the current trx detail
	insert into  #Offer
	SELECT distinct d.DeviceId as PromotionId,dpt.Name,tmp.LineNumber, tmp.TrxDetailID,tmp.Points,case(vsp.Name) when 'PointsMultiplier' then tmp.Points*(vdpt.OfferValue-1)
	when 'PointsFixed' then vdpt.OfferValue END as BonusPoints,vsp.Name as OfferType,vdpt.offervalue as PromotionOfferValue, 0 as PriorityLevel,0 as Processed,'Voucher' as Offer, null, null, null, null,0,null																
	from #tempCode tmp  inner join TrxVoucherDetail tv on tmp.TrxDetailID=tv.TrxDetailId
	inner join device d on tv.TrxVoucherId=d.DeviceId
	inner join DeviceProfile dp on d.id=dp.deviceid
	inner join deviceprofiletemplate dpt on  dp.DeviceProfileId=dpt.Id
	inner join VoucherDeviceProfileTemplate vdpt on dpt.id=vdpt.id
	inner join DeviceProfileTemplateSite vs on dpt.id=vs.deviceprofiletemplateid
	inner join [VoucherProfileItem] vt on dpt.id=vt.voucherprofileid
	inner join VoucherSubType vsp on vdpt.vouchersubtypeid=vsp.vouchersubtypeid											
	where vt.voucherprofileitemtypeid=tmp.TypeId and  RTRIM(LTRIM(vt.Code))= RTRIM(LTRIM(tmp.Code)) and d.StartDate<=GETDATE() and d.EXpirationdate>=GETDATE()  and d.devicestatusid=@DeviceStatusActive and 
	vsp.Name in('PointsMultiplier','PointsFixed') and tmp.SiteId in( SELECT SiteId from GetChildSitesBySiteId(vs.siteid))
	and tv.TrxVoucherId not in(SELECT voucherid from  VirtualPointPromotions where trxid=@Trxid)
	
	--SELECT * FROM #Offer

	DECLARE @VoucherPId INT
	DECLARE @TRXDETAILID INT
	DECLARE @PromotionId varchar(50),@OfferTypeP varchar(50), @BonusPoints decimal(18,2), @CriteriaId int
	DECLARE @trxCount INT
	DECLARE @itemcount int
	DECLARE @Offer varchar(50)
	Declare @itemcountInclude INT
	Declare @trxCountInclude INT
	Declare @itemcountExclude INT
	Declare @trxCountExclude INT
	DECLARE @LineNumber INT
	DECLARE @BasePoints decimal(18,2),@PromotionOfferValue decimal(18,2);
	-----------------------------------------------------------------------------------------
	print 'Start logic/usage checking at ' + convert(varchar(25), getdate(), 120)          --
	-----------------------------------------------------------------------------------------
	IF exists(SELECT 1 from #Offer)
	BEGIN
		DECLARE db_cursor CURSOR FOR  
		SELECT TrxDetailID, PromotionId,Offer,LineNumber,OfferType,Points,PromotionOfferValue,CriteriaId
		FROM #Offer order by PriorityLevel desc
		OPEN db_cursor  
		FETCH NEXT FROM db_cursor INTO @TRXDETAILID,@PromotionId,@Offer  ,@LineNumber,@OfferTypeP,@BasePoints,@PromotionOfferValue,@CriteriaId

		WHILE @@FETCH_STATUS = 0  
		BEGIN  
  
			IF(@Offer='Promotion')	 
			BEGIN
				PRINT 'Promotion'
				-- Only run if AND logic is turned on (item 1 and item 2)
				IF exists(SELECT * from promotion where id=CONVERT(int,@PromotionId) and PromotionItemFlagAnd = 1)
				BEGIN
					--TOP-666
					 select PromotionItemTypeId,code,0 as processed,PromotionItemGroupId,Quantity 
					 into #filteritemsInclude from PromotionItem where promotionId=convert(int,@PromotionId) And ItemIncludeExclude = 'IncludeItem'

					 select PromotionItemTypeId,code,0 as processed ,PromotionItemGroupId,Quantity
					 into #filteritemsExclude from PromotionItem where promotionId=convert(int,@PromotionId) And ItemIncludeExclude = 'ExcludeItem'
	 
					 --IF Analysis Code is not passing for Exclude items need to remove promo from list
							DECLARE @ExcludeGroupId INT,@ExcludeGroupInValidCount INT = 0
							DECLARE db_GroupSursor CURSOR FOR  
							SELECT DISTINCT PromotionItemGroupId
							FROM #filteritemsExclude
							OPEN db_GroupSursor  
							FETCH NEXT FROM db_GroupSursor INTO @ExcludeGroupId  
							WHILE @@FETCH_STATUS = 0  
							BEGIN 
								IF NOT EXISTS (SELECT 1 FROM #filteritemsExclude fe INNER JOIN #tempCode tc on fe.PromotionItemTypeId = tc.TypeId WHERE fe.PromotionItemGroupId = @ExcludeGroupId AND tc.LineNumber = @LineNumber)
								BEGIN
									SET @ExcludeGroupInValidCount += 1
								END
							FETCH NEXT FROM db_GroupSursor INTO @ExcludeGroupId 
							END  
							CLOSE db_GroupSursor  
							DEALLOCATE db_GroupSursor 


						 PRINT 'Exclude Group In-Valid Count= ' + CONVERT(VARCHAR(20), ISNULL( @ExcludeGroupInValidCount,0))

					 SET @itemcountInclude=(select  count(distinct PromotionItemGroupId) from #filteritemsInclude)
					 SET @itemcountExclude=(select  count(distinct PromotionItemGroupId) from #filteritemsExclude)
					--SELECT * FROM #filteritemsInclude
					--SELECT * FROM #filteritemsExclude
					--select  distinct promotionitemtypeid,* from #filteritemsInclude
		
					 SET @trxCountInclude=(select count(distinct f.PromotionItemGroupId) from #tempCode t inner join #filteritemsInclude f on t.TypeId=f.PromotionItemTypeId where t.Quantity >= f.Quantity and t.Code=f.Code and t.TrxDetailID=@TRXDETAILID)
					 SET @trxCountExclude=(select count(distinct f.PromotionItemGroupId) from #tempCode t inner join #filteritemsExclude f on t.TypeId=f.PromotionItemTypeId where t.Quantity >= f.Quantity and t.Code=f.Code and t.TrxDetailID=@TRXDETAILID)
					 --SELECT t.*,f.* FROM #tempCode t inner join #filteritemsExclude f on t.TypeId=f.PromotionItemTypeId where t.Code=f.Code and t.TrxDetailID=@TRXDETAILID

					 PRINT 'PromotonItem Include Group = ' + CONVERT(VARCHAR(20), ISNULL( @itemcountInclude,0)) +' TrxDetailID = ' + CONVERT(VARCHAR(20),@TRXDETAILID) + ' PromotionId = '+CONVERT(VARCHAR(20),@PromotionId)
					 PRINT 'TrxLine Item Include Group = ' + CONVERT(VARCHAR(20), ISNULL( @trxCountInclude,0)) +' TrxDetailID = ' + CONVERT(VARCHAR(20),@TRXDETAILID) + ' PromotionId = '+CONVERT(VARCHAR(20),@PromotionId)

					 PRINT 'PromotonItem Exclude Group = '+ CONVERT(VARCHAR(20), ISNULL( @itemcountExclude,0)) +' TrxDetailID = ' + CONVERT(VARCHAR(20),@TRXDETAILID) + ' PromotionId = '+CONVERT(VARCHAR(20),@PromotionId)
					 PRINT 'TrxLine Item Exclude Group = ' + CONVERT(VARCHAR(20), ISNULL( @trxCountExclude,0)) +' TrxDetailID = ' + CONVERT(VARCHAR(20),@TRXDETAILID) + ' PromotionId = '+CONVERT(VARCHAR(20),@PromotionId)

		
					 if ISNULL(@trxCountInclude,0)<>ISNULL(@itemcountInclude,0)
					 begin
						delete from #Offer where TrxDetailID=@TRXDETAILID and PromotionId=@PromotionId
						PRINT 'Not applicable Include PromotionId = '+CONVERT(VARCHAR(20),@PromotionId)
					 end
					 if ISNULL(@trxCountExclude,0) > 0 OR @ExcludeGroupInValidCount > 0--= ISNULL(@itemcountExclude,0) AND ISNULL(@itemcountExclude,0) > 0
					 begin
						delete from #Offer where TrxDetailID=@TRXDETAILID and PromotionId=@PromotionId
						PRINT 'Not applicable Exclude PromotionId = '+CONVERT(VARCHAR(20),@PromotionId)
					 end
					  drop table #filteritemsInclude
					  drop table #filteritemsExclude
					 end 	
					  PRINT '-----------------------------------------------'
				--TOP-666

				-- Check if any segment filter exists and its valid date is greater than current date
				IF exists(SELECT 1 from PromotionSegments p join segmentadmin s on p.segmentid=s.segmentid where validto >= GETDATE() and PromotionId=CONVERT(int, @PromotionId) )
				BEGIN
					-- Check again if any segment filter exists and belong to that user
					IF not exists(SELECT 1 from PromotionSegments ps join SegmentUsers s on ps.SegmentId = s.SegmentId where ps.PromotionId = CONVERT(int, @PromotionId) and s.UserId = @MemberId)
					BEGIN
						-- we remove all promotions that is related to the passed in transaction detail id and promotion id which mapped in #offer 
						delete from #Offer where TrxDetailID=@TRXDETAILID and PromotionId=@PromotionId
					END
				END

				-- Promotion Usage Filter Per Member
				DECLARE @PromotionLimitCount INT
				SET @PromotionLimitCount=(SELECT isnull(MaxUsagePerMember,0) from Promotion where Id =@PromotionId)
				-- check if any user promotion limit filter is set
				IF(@PromotionLimitCount > 0)
				BEGIN				 
					DECLARE @UsedCount INT=0
					SET @UsedCount=(SELECT count(promotionid) from [PromotionRedemptionCount] where [MemberId] = @MemberId and  PromotionId = @PromotionId)
					-- check user total redeem count with the user promotion limit count set
					IF (isnull(@UsedCount,0)>= @PromotionLimitCount)
					BEGIN
						-- if count reach the limit count then we remove the promotions
						delete from #Offer where TrxDetailID=@TRXDETAILID and PromotionId=@PromotionId
					END			 
				END	
			 
				-- Max Trx Limit for Promotion
				DECLARE @maxTrxCountforPromtion INT
				DECLARE @PromotionUsageLimit INT
				DECLARE @trxStatus int;
				SET @PromotionUsageLimit=(SELECT isnull(PromotionUsageLimit,0) from Promotion where Id =@PromotionId)
				IF(@PromotionUsageLimit>0)
				BEGIN				 
					SELECT @trxStatus = TrxStatusId  from TrxStatus where Name='Completed';
					-- SELECT total completed trx which hit the passed in promotion 
					with cte as (
						SELECT th.TrxId  as TotalTrxCount from  TrxDetailPromotion tp
						inner join trxdetail td on td.TrxDetailID = tp.TrxDetailId 
						inner join trxheader th on th.trxid= td.TrxId		
							where tp.promotionid=@PromotionId and th.TrxStatusTypeId = @trxStatus
							group by th.trxid
					)
					SELECT @maxTrxCountforPromtion = count(TotalTrxCount) from cte 
					-- IF trx count > promotionusage limit remove the trxdetails with that particular promotion  
					IF (@maxTrxCountforPromtion>= @PromotionUsageLimit)
					BEGIN
						-- remove the promotion for the trxdetail temptable,so it will not be considered in bestoffer rule
						delete from #Offer where TrxDetailID=@TRXDETAILID and PromotionId=@PromotionId
					END			 
				END
				
				IF EXISTS (SELECT 1 FROM #Offer where TrxDetailID=@TRXDETAILID and PromotionId=@PromotionId)
				BEGIN
				IF @CriteriaId = 2 -- Quantity Calculations
							BEGIN
							DECLARE @MaxPromoOnSameBasket INT = 0,@MaxPromoApplicationOnSameBasket INT;
							PRINT 'CRITERIA 2'
								SELECT @item = ItemCode, @itemQuantity = Quantity From trxdetail where Trxdetailid = @TRXDETAILID
								DECLARE  @promotionItemQuantity INT, @promotionItemCode NVARCHAR(MAX)

								SELECT TOP 1 @promotionItemQuantity = itemQuantity,@promotionItemCode = Code from #Offer 
								where TrxDetailID=@TRXDETAILID and PromotionId=@PromotionId and Processed=0 AND ItemIncludeExclude = 'IncludeItem' ORDER BY itemQuantity DESC
								-- Check if itemCode from trxdetail match promotion code
								
								IF @OfferTypeP = 'Points' OR @OfferTypeP = 'PointsMultiplier'
								BEGIN
								print 'itemQty-'+cast(@itemQuantity as nvarchar(100))
									print 'promoitemQty-'+cast(@promotionItemQuantity as nvarchar(100))
									DECLARE @maxPromoApplicationFlag INT= 0, @count INT = 0,@loop INT = 0;
									SET @count = FLOOR(@itemQuantity / ISNULL(@promotionItemQuantity,1))
									
									print 'count-'+cast(@count as nvarchar(100))
									IF ISNULL(@MaxPromoApplicationOnSameBasket,0) = 0
									BEGIN
											IF @OfferTypeP = 'PointsMultiplier'
											BEGIN
												set @BonusPoints = (@count *  @PromotionOfferValue * @BasePoints) - @BasePoints
												print 'count@BonusPoints-'+cast(@BonusPoints as nvarchar(100))
											END
											ELSE
											BEGIN
												set @BonusPoints = @count *  @PromotionOfferValue
											END
											if ISNULL(@BonusPoints,0) > 0
											BEGIN
											update TrxDetail  set Points = @BasePoints + @BonusPoints, BonusPoints = @BonusPoints 
											from #Offer t where t.PromotionId=@PromotionId and TrxDetail.TrxDetailID=@TRXDETAILID	
											update #Offer set BonusPoints = @BonusPoints,Points = @BasePoints where PromotionId=@PromotionId and TrxDetailID=@TRXDETAILID and code = @promotionItemCode
											END
											ELSE
											BEGIN
											update #Offer set Processed =3 where PromotionId=@PromotionId and TrxDetailID=@TRXDETAILID
											END
											DELETE #Offer where PromotionId=@PromotionId and TrxDetailID=@TRXDETAILID AND code != @promotionItemCode
											SET @maxPromoApplicationFlag = 1
											SET @MaxPromoOnSameBasket = @MaxPromoOnSameBasket + @count

											PRINT '--------------'
											PRINT 'LOOOP NULL'
											print cast(@BonusPoints as nvarchar(100))   + 'first bonus '
											print cast(@BonusPoints as nvarchar(100))   + ' bonus '									
											PRINT @PromotionOfferValue
											PRINT @BasePoints
											PRINT @promotionItemCode
											PRINT '--------------'
									END
									ELSE
									BEGIN
										WHILE @count > 0 AND @maxPromoApplicationFlag = 0
										BEGIN
											IF (@MaxPromoOnSameBasket + @count <= @MaxPromoApplicationOnSameBasket)
											BEGIN

												IF @OfferTypeP = 'PointsMultiplier'
												BEGIN
													set @BonusPoints = (@count *  @PromotionOfferValue * @BasePoints) - @BasePoints
												END
												ELSE
												BEGIN
													set @BonusPoints = @count *  @PromotionOfferValue
												END

												update TrxDetail  set Points = @BasePoints + @BonusPoints, BonusPoints = @BonusPoints 
												from #Offer t where t.PromotionId=@PromotionId and TrxDetail.TrxDetailID=@TRXDETAILID	

												update #Offer set BonusPoints = @BonusPoints,Points = @BasePoints where PromotionId=@PromotionId and TrxDetailID=@TRXDETAILID and code = @promotionItemCode
												DELETE #Offer where PromotionId=@PromotionId and TrxDetailID=@TRXDETAILID AND code != @promotionItemCode
												SET @maxPromoApplicationFlag = 1
												SET @MaxPromoOnSameBasket = @MaxPromoOnSameBasket + @count

												PRINT '--------------'
												PRINT 'LOOOP'
												print cast(@BonusPoints as nvarchar(100))   + 'first bonus '
												print cast(@BonusPoints as nvarchar(100))   + ' bonus '									
												PRINT @PromotionOfferValue
												PRINT @BasePoints
												PRINT @promotionItemCode
												PRINT '--------------'
											END
											SET @count=@count-1
										END
										IF @maxPromoApplicationFlag = 0
										BEGIN
												update TrxDetail  set Points = @BasePoints , BonusPoints = 0 
												from #Offer t where t.PromotionId=@PromotionId and TrxDetail.TrxDetailID=@TRXDETAILID	

												DELETE #Offer where PromotionId=@PromotionId and TrxDetailID=@TRXDETAILID	
										END
									END
								END -- 'END QTY Points'
								
								    
							END

				END
								 
			END
	 
			IF(@Offer='Voucher')	 
			BEGIN 
				-- Only run if AND logic is turned on (item 1 and item 2)
				IF exists(SELECT 1 from device d inner join DeviceProfile dp on d.id=dp.DeviceId inner join VoucherDeviceProfileTemplate vdp on dp.DeviceProfileId=vdp.id where d.deviceid=@PromotionId and vdp.logicaland=1)
				BEGIN
					SET @VoucherPId=(SELECT dp.DeviceProfileId from device d inner join DeviceProfile dp on d.id=dp.DeviceId where d.DeviceId=@PromotionId)
	
					insert into #filteritems  SELECT voucherprofileitemtypeid ,code,0 as processed  from [VoucherProfileItem] where VoucherProfileId=@VoucherPId
	 
					SET @itemcount=(SELECT  count(distinct voucherprofileitemtypeid) from #filteritems)

					SET @trxCount=(SELECT count(distinct t.TypeId) from #tempCode t inner join #filteritems f on t.TypeId=f.voucherprofileitemtypeid where t.Code=f.Code and t.TrxDetailID=@TRXDETAILID)

					IF(@trxCount<>@itemcount)
					BEGIN
						delete from #Offer where TrxDetailID=@TRXDETAILID and PromotionId=@PromotionId
					END
					drop table #filteritems
				END 	
	 	 
				--voucher segments filter
				IF exists(SELECT 1 from VoucherSegments v join segmentadmin s on v.segmentid=s.segmentid  where validto>=GETDATE() and VoucherId=(SELECT dp.DeviceProfileId from device d inner join DeviceProfile dp on d.id=dp.DeviceId where d.deviceid=@PromotionId))
				BEGIN
					IF not exists(SELECT 1 from VoucherSegments ps join SegmentUsers s on ps.SegmentId=s.SegmentId where ps.VoucherId=(SELECT dp.DeviceProfileId from device d inner join DeviceProfile dp on d.id=dp.DeviceId where d.deviceid=@PromotionId) and s.UserId=@MemberId)
					BEGIN
						delete from #Offer where TrxDetailID=@TRXDETAILID and PromotionId=@PromotionId
					END
				END
			END

			FETCH NEXT FROM db_cursor INTO @TRXDETAILID,@PromotionId,@Offer  ,@LineNumber,@OfferTypeP,@BasePoints,@PromotionOfferValue,@CriteriaId

		END  

		CLOSE db_cursor  
		DEALLOCATE db_cursor 
	END
	-----------------------------------------------------------------------------------------
	print 'Start Best Offer Ordering at ' + convert(varchar(25), getdate(), 120)           --
	-----------------------------------------------------------------------------------------
	------------------------------------------------------------------------------------------------------------------------------------
	--TopPharm rule where when point multiplier is set to 0 then top priority follow by 1 then rest of the value
	------------------------------------------------------------------------------------------------------------------------------------
	update #Offer set PriorityLevel= 100001 where OfferType ='PointsMultiplier' and PromotionOfferValue = 0 and Offer ='Promotion' --1
	update #Offer set PriorityLevel= 99999 where OfferType ='PointsMultiplier' and PromotionOfferValue = 1 and Offer ='Promotion' --3
	update #Offer set PriorityLevel= 100000 where OfferType ='PointsMultiplier' and PromotionOfferValue = 0 and Offer ='Voucher' --2
	update #Offer set PriorityLevel= 99998 where OfferType ='PointsMultiplier' and PromotionOfferValue = 1 and Offer ='Voucher' --4
	------------------------------------------------------------------------------------------------------------------------------------
	--Promotion Priority will alway be higher compare to voucher unless voucher offer value is higher than the promotion offer
	------------------------------------------------------------------------------------------------------------------------------------
	update #Offer set PriorityLevel=BonusPoints+2 where OfferType='PointsMultiplier' and PromotionOfferValue not in(0,1) and Offer ='Promotion'
	update #Offer set PriorityLevel=BonusPoints+2 where OfferType='Points' and Offer ='Promotion'
	------------------------------------------------------------------------------------------------------------------------------------
	update #Offer set PriorityLevel=BonusPoints+1 where OfferType='PointsMultiplier' and PromotionOfferValue not in(0,1) and Offer ='Voucher'
	update #Offer set PriorityLevel=BonusPoints+1 where OfferType='Points' and Offer ='Voucher'
	------------------------------------------------------------------------------------------------------------------------------------
	--select code, bonusPoints, points, promotionid, trxdetailid from #offer					
	-----------------------------------------------------------------------------------------
	print 'Start promotion processing at ' + convert(varchar(25), getdate(), 120) 
	-----------------------------------------------------------------------------------------
	DECLARE @ovdpoints decimal(18,2) = 0, @cumulationBasePoints decimal(18,2), @oLineNumber INT;
	-- If there is anymore offer left after filter out from limit/restriction checking
	set @BasePoints =0;
	set @PromotionOfferValue =0;
	IF exists(SELECT 1 from #Offer)
	BEGIN
	
		-----------------------------------------------------------------------------------------------
		 --INSTEAD of using the below cursor the below line of code will select the best offer for each line number group by linenumber and order by highest Prioritylevel desc
		-- SELECT TOP 1 WITH TIES * INTO #BestLineOffer FROM #Offer 
		--				ORDER BY ROW_NUMBER() OVER(PARTITION BY LineNumber ORDER BY PriorityLevel desc,PromotionId)

		DECLARE db_cursor CURSOR FOR  
		SELECT TrxDetailID,PromotionId,Offer,OfferType, BonusPoints, CriteriaId, Code, itemQuantity,LineNumber,Points,PromotionOfferValue,MaxPromoApplicationOnSameBasket
		FROM #Offer order by PriorityLevel desc,PromotionId
		-----------------------------------------------------------------------------------------------
		OPEN db_cursor  
		FETCH NEXT FROM db_cursor INTO @TRXDETAILID,@PromotionId,@Offer ,@OfferTypeP, @BonusPoints, @CriteriaId ,@code, @quantity ,@oLineNumber,@BasePoints,@PromotionOfferValue,@MaxPromoApplicationOnSameBasket

		WHILE @@FETCH_STATUS = 0  
		BEGIN  

			IF(@Offer='Promotion')
			BEGIN
			
			--select * from VirtualPointPromotions WHERE trxid =  @TrxId
				-- Check any promotion that is not processed
				IF exists(SELECT 1 from #Offer where TrxDetailID=@TRXDETAILID and PromotionId=@PromotionId and Processed=0)
				BEGIN
					IF not exists( SELECT 1 from VirtualPointPromotions vp with(nolock) join trxdetail td with(nolock) on vp.trxid=td.trxid inner join Promotion p with(nolock) on vp.PromotionId = p.Id inner join PromotionCategory pc with(nolock) on p.PromotionCategoryId=pc.Id where td.trxdetailid=@TRXDETAILID and td.linenumber=vp.LineNumber AND pc.Name not in ('StampCardQuantity','StampCardValue'))
					BEGIN
						--PRINT cast(@PromotionId as nvarchar(100)) + ' - ' + cast(@TRXDETAILID as nvarchar(100)) + ' - ' +cast(@oLineNumber as nvarchar(100))
						IF (SELECT TOP 1 Cumulation from #Offer where TrxDetailID=@TRXDETAILID and PromotionId=@PromotionId) = 0
						BEGIN
							PRINT 'Cumulation 0 - ' +cast(@oLineNumber as nvarchar(100))
							-- If any override restriction is turned on then
							IF exists(SELECT 1 from promotion where id=@PromotionId and isnull(OverrideBasePointRestriction,0) = 1)
							BEGIN
								-- Max restriction point = trx value - base points (loop through multiple transaction) -> used, later down in the sp for account balance
								SELECT @ovdpoints=@ovdpoints + TrxDetail.value - isnull(TrxDetail.points, 0 ) from #Offer t join TrxDetail on TrxDetail.TrxDetailID=t.TrxDetailID where t.PromotionId=@PromotionId and TrxDetail.TrxDetailID=@TRXDETAILID 
								------------------------------------------------------------------------------------------------------------------------------------------------------------------
								--Added quantity point to point restriction scenario
								------------------------------------------------------------------------------------------------------------------------------------------------------------------
								update TrxDetail  set Points =case @OfferTypeP when 'Points' then case when CriteriaId = 2 then @BonusPoints * Quantity else value * Quantity END else value END 
								from #Offer t where TrxDetail.TrxDetailID=t.TrxDetailID and t.PromotionId=@PromotionId and TrxDetail.TrxDetailID=@TRXDETAILID
								------------------------------------------------------------------------------------------------------------------------------------------------------------------
								update #Offer set Points=case @OfferTypeP when 'Points' then case when CriteriaId = 2 then @BonusPoints * Quantity else value * Quantity END else value END  
								from TrxDetail where TrxDetail.TrxDetailID=#Offer.TrxDetailID and #Offer.PromotionId=@PromotionId and TrxDetail.TrxDetailID=@TRXDETAILID
								------------------------------------------------------------------------------------------------------------------------------------------------------------------
							END

						END 
						--Print cast(@PromotionId as nvarchar(100)) + ' + ' + cast(@TRXDETAILID as nvarchar(100))
						-- Check for cumulation for each promotion
						IF (Select TOP 1 Cumulation from #offer where TrxDetailID=@TRXDETAILID and PromotionId=@PromotionId) = 1
						BEGIN
							PRINT 'Cumulation 1 - ' +cast(@oLineNumber as nvarchar(100))
							-- Update process to apply any promotion with cumulation set to 1
						    update #Offer set processed=2 where TrxDetailID=@TRXDETAILID and PromotionId=@PromotionId
							SELECT @item = ItemCode From trxdetail where Trxdetailid = @TRXDETAILID 

							IF EXISTS(SELECT 1 FROM [VirtualStampCard] WHERE TrxId = @TrxId AND LineNumber = @oLineNumber)
							BEGIN
								select @cumulationBasePoints = SUM(BonusPoints) from #Offer where TrxDetailID=@TRXDETAILID and PromotionId=@PromotionId	
								print cast(@cumulationBasePoints as nvarchar(100))   + 'cumulation bonus '
							END
							ELSE IF @code = @item
							BEGIN
								select @cumulationBasePoints = SUM(BonusPoints) from #Offer where TrxDetailID=@TRXDETAILID and Code = @item and PromotionId=@PromotionId	
								print cast(@cumulationBasePoints as nvarchar(100))   + 'cumulation bonus '
							END
							PRINT '-----------------'
							PRINT @cumulationBasePoints
							PRINT '-----------------'
							update TrxDetail  set Points = ISNULL(TrxDetail.Points,0) + ISNULL(@cumulationBasePoints,0) , BonusPoints = ISNULL(TrxDetail.BonusPoints,0) + ISNULL(@cumulationBasePoints,0)
							from #Offer t where t.PromotionId=@PromotionId and TrxDetail.TrxDetailID=@TRXDETAILID	
							--select * from #offer
						END
						ELSE
						BEGIN
							
							IF (Select processed from #Offer where TrxDetailID=@TRXDETAILID and PromotionId=@PromotionId) <> 3
							BEGIN		
							-- update process status to 1 (prevent duplicate trx get processed again)
							update #Offer set processed=1 where TrxDetailID=@TRXDETAILID and PromotionId=@PromotionId		 
							----BPA update Offer temp table so that if multiple Point Promotion hit same line item detail
							update #Offer set processed=1 where TrxDetailID=@TRXDETAILID and Offer='Promotion' and OfferType='Points'
							----BPA update Offer temp table so that if multiple Point Promotion hit same line item detail
							update #Offer set processed=1 where TrxDetailID=@TRXDETAILID and Offer='Promotion' and OfferType='PointsMultiplier'
							-- update process status to 2 (only the promotion that has applied to the trx detail as there could be multiple promotion hit for one trx)
							update #Offer set processed=2 where TrxDetailID=@TRXDETAILID and PromotionId=@PromotionId
							END
							
						END											
					END
				END
			END
			IF(@Offer='Voucher')
			BEGIN	
				IF exists(SELECT 1 from #Offer where TrxDetailID=@TRXDETAILID and PromotionId=@PromotionId and Processed=0)
				BEGIN
					IF not exists( SELECT 1 from VirtualPointPromotions vp join trxdetail td on vp.trxid=td.trxid where td.trxdetailid=@TRXDETAILID and td.linenumber=vp.LineNumber)
					BEGIN
						IF exists(SELECT 1 from #Offer where TrxDetailID=@TRXDETAILID and PromotionId=@PromotionId)
						BEGIN
							update TrxDetail  set Points=TrxDetail.Points+t.BonusPoints,BonusPoints=TrxDetail.BonusPoints+t.BonusPoints 
							from #Offer t inner join TrxVoucherDetail tv on t.TrxDetailID=tv.TrxDetailId 
							where TrxDetail.TrxDetailID=t.TrxDetailID  and TrxDetail.TrxDetailID=@TRXDETAILID and t.PromotionId=@PromotionId
						END 
						update #Offer set processed=1 where TrxDetailID=@TRXDETAILID
						update #Offer set processed=2 where TrxDetailID=@TRXDETAILID and PromotionId=@PromotionId
					END
				END
			END
			FETCH NEXT FROM db_cursor INTO @TRXDETAILID,@PromotionId,@Offer ,@OfferTypeP , @BonusPoints , @CriteriaId, @code, @quantity,@oLineNumber,@BasePoints,@PromotionOfferValue,@MaxPromoApplicationOnSameBasket
		END  
		CLOSE db_cursor  
		DEALLOCATE db_cursor 
		--SELECT * from #Offer
		DECLARE @DeviceId VARCHAR(50)
		DECLARE @TotalBonusPoints Decimal(18,2)=0
		-- check all processed(2) promotions then add them to trxdetail promotion table for record
		IF exists(SELECT 1 from #Offer where processed=2 )
		BEGIN
			IF exists(SELECT 1 from #Offer where processed=2 and Offer='Promotion')
			BEGIN
				insert into TrxDetailPromotion
				SELECT 1,PromotionId,TrxDetailId,BonusPoints from  #Offer where processed=2 and Offer='Promotion'
			END
			IF exists(SELECT 1 from #Offer where processed=2 and Offer='Voucher')
			BEGIN
				update TrxVoucherDetail set VoucherAmount=f.BonusPoints from #Offer f where TrxVoucherDetail.trxdetailid=f.trxdetailid and TrxVoucherDetail.TrxVoucherId=f.PromotionId and Offer='Voucher'
			END
			IF exists(SELECT 1 from #Offer where processed=2 )
			BEGIN
				SET @TotalBonusPoints=(SELECT sum(bonuspoints) from #Offer where processed=2)
				print cast(@TotalBonusPoints as nvarchar(100))   + ' Total bonus '
			END
		END
	END

	--SELECT * FROM #Offer
	-----------------------------------------------------------------------------------------
	print 'Start trx/account balance update at ' + convert(varchar(25), getdate(), 120) 
	-----------------------------------------------------------------------------------------
	SET @DeviceId=(SELECT deviceid from TrxHeader where trxid=@TrxId)
	IF exists(SELECT 1 from trxdetail td 
	join VirtualPointPromotions v on td.LineNumber=v.linenumber 
	inner join trxvoucherdetail tv on td.trxdetailid=tv.trxdetailid where v.trxid=@TrxId and td.trxid=@Trxid and VoucherId is not null and tv.trxvoucherid!='')
	BEGIN
		
		SELECT td.trxdetailid,v.promotionvalue,v.voucherid,v.linenumber into #pointvouchers from trxdetail td 
		join VirtualPointPromotions v on td.LineNumber=v.linenumber 
		inner join trxvoucherdetail tv on td.trxdetailid=tv.trxdetailid where v.trxid=@TrxId and td.trxid=@Trxid	
		update TrxDetail set BonusPoints=isnull(BonusPoints,0)+isnull(v.promotionvalue,0),Points=isnull(Points,0)+isnull(v.promotionvalue,0) from #pointvouchers v where trxdetail.TrxDetailID=v.TrxDetailID and trxdetail.trxid=@TrxId
		update TrxVoucherDetail set VoucherAmount=isnull(VoucherAmount,0)+isnull(v.promotionvalue,0) from  #pointvouchers v where TrxVoucherDetail.TrxDetailID=v.TrxDetailID 
		set @TotalBonusPoints=isnull(@TotalBonusPoints,0)+(SELECT isnull(sum(promotionvalue),0) from #pointvouchers)

		print @TotalBonusPoints
	END
	IF exists(SELECT 1 from VirtualPointPromotions where trxid=@TrxId and PromotionId > 0)
	BEGIN
		SELECT td.trxdetailid,v.promotionvalue,v.PromotionId,v.linenumber,isnull(p.OverrideBasePointRestriction,0) OverrideBasePointRestriction
		into #pointpromotions from trxdetail td 
		join VirtualPointPromotions v on td.LineNumber=v.linenumber 
		join Promotion p on v.PromotionId=p.Id
		where v.trxid=@TrxId and td.trxid=@Trxid and v.PromotionId > 0

		IF not exists(SELECT 1 from VirtualPointPromotions vp with(nolock) join trxdetail td with(nolock) on vp.trxid=td.trxid inner join Promotion p with(nolock) on vp.PromotionId = p.Id inner join PromotionCategory pc with(nolock) on p.PromotionCategoryId=pc.Id where td.trxdetailid=@TRXDETAILID and td.linenumber=vp.LineNumber AND pc.Name not in ('StampCardQuantity','StampCardValue'))
		BEGIN
			PRINT 'StampCard Bsket + Point Promotions'
			--INSERT INTO #pointpromotions
			SELECT td.trxdetailid,O.PromotionOfferValue AS promotionvalue,O.PromotionId,O.linenumber,isnull(p.OverrideBasePointRestriction,0) OverrideBasePointRestriction
			INTO #pointOffers
			from trxdetail td 
			join #Offer O on td.LineNumber=O.linenumber 
			join Promotion p on O.PromotionId=p.Id
			where td.trxid=@Trxid and O.PromotionId > 0 AND O.Processed  = 2
			
			--SELECT * FROM #pointOffers
			update TrxDetail 
			set BonusPoints=isnull(BonusPoints,0)+isnull(v.promotionvalue,0),Points=isnull(Points,0)+isnull(v.promotionvalue,0) 
			from #pointOffers v where trxdetail.TrxDetailID=v.TrxDetailID 
			and trxdetail.trxid=@TrxId

		END
		--INSERT INTO #Offer 
		--SELECT * FROM #OfferExclude 
		--SELECT * FROM #Offer

		-- update points for Override Restriction
		DECLARE @OverridePoints decimal(18,2)
		SELECT @OverridePoints=sum(value)-sum(points) from TrxDetail join  #pointpromotions v on trxdetail.TrxDetailID=v.TrxDetailID where OverrideBasePointRestriction=1
		update TrxDetail set Points=Value from #pointpromotions v where trxdetail.TrxDetailID=v.TrxDetailID and OverrideBasePointRestriction=1
		
		update TrxDetail 
		set BonusPoints=isnull(BonusPoints,0)+isnull(v.promotionvalue,0),Points=isnull(Points,0)+isnull(v.promotionvalue,0) 
		from #pointpromotions v where trxdetail.TrxDetailID=v.TrxDetailID 
		and trxdetail.trxid=@TrxId
		
		insert into TrxDetailPromotion
		SELECT 1,PromotionId,TrxDetailId,isnull(promotionvalue,0) from #pointpromotions

		set @TotalBonusPoints=isnull(@TotalBonusPoints,0)+(SELECT sum(promotionvalue) from #pointpromotions)
	END
	
	-- 
	update trxheader set [AccountPointsBalance]=isnull([AccountPointsBalance],0)+(isnull(@TotalBonusPoints,0)) where trxid=@TrxId
	update account set PointsBalance=isnull(PointsBalance,0)+(isnull(@TotalBonusPoints,0)) where accountid=(SELECT accountid from device where deviceid=@DeviceId)
	update account set PointsBalance=isnull(PointsBalance,0)+(isnull(@OverridePoints,0)) where accountid=(SELECT accountid from device where deviceid=@DeviceId)
	update account set PointsBalance=isnull(PointsBalance,0)+(isnull(@ovdpoints,0)) where accountid=(SELECT accountid from device where deviceid=@DeviceId)

	DECLARE @UserId INT
	SET @Userid=(SELECT userid from device where deviceid=@LoyaltyDevice)

	IF exists(SELECT 1 from memberlink m inner join memberlinktype mt on m.linktype=mt.MemberLinkTypeId where name='Community' and MemberId2=@Userid and CommunityId is not null)
	BEGIN	
		exec EPOS_ShadowPointTransfer @Userid,@LoyaltyDevice,@TrxId	
	END
	-----------------------------------------------------------------------------------------
	print 'Start voucher usage checker at ' + convert(varchar(25), getdate(), 120)
	-----------------------------------------------------------------------------------------
	DECLARE @DeviceStatusBlocked INT
	SET @DeviceStatusBlocked=(SELECT devicestatusid from Devicestatus where name='Inactive' and clientid=(SELECT clientid from client where name='baseline'))
	DECLARE @Maxusage INT=0,@ClassicalVoucherProfileExist int=0;
	DECLARE @VoucherId varchar(50)
	-----------------------------------------------------
	DECLARE db_cursor CURSOR FOR  
	SELECT trxdetailid from Trxdetail where trxid=@TrxId
	-----------------------------------------------------
	OPEN db_cursor  
	FETCH NEXT FROM db_cursor INTO @TRXDETAILID  

	WHILE @@FETCH_STATUS = 0  
	BEGIN  
		--Maximum Voucher usage check and insertion
		SET @VoucherId=(SELECT top 1 TrxVoucherId from TrxVoucherDetail where TrxDetailid=@TRXDETAILID order by VoucherAmount desc)
		PRINT 'TrxDetail cursor'
		PRINT @VoucherId
		PRINT @TRXDETAILID
		delete from TrxVoucherDetail where TrxVoucherId <> @VoucherId and TrxDetailId=@TRXDETAILID 
		SELECT top 1 @Maxusage=isnull(MaximumUsage,0),@ClassicalVoucherProfileExist = dpt.Id from  
		device d join deviceprofile dp on d.id=dp.deviceid 
		join deviceprofiletemplate dpt on dp.deviceprofileid=dpt.id 
		join deviceprofiletemplatetype dpty on dpt.deviceprofiletemplatetypeId=dpty.id
		join voucherdeviceprofiletemplate vdp on dpt.id=vdp.id where dpty.name='Voucher' and d.DeviceId=@VoucherId and vdp.ClassicalVoucher=1

		IF(@Maxusage>0)
		BEGIN
			IF not exists(SELECT 1 from [ClassicalVoucherRedemptionCount] where trxid=@Trxid and MemberId=@Userid and VoucherId=@VoucherId)
			BEGIN
				INSERT INTO [dbo].[ClassicalVoucherRedemptionCount]([MemberId],[VoucherId],[LastRedemptionDate],[TrxId])
				SELECT @Userid,@VoucherId,GETDATE(),@Trxid
			END
		END
		else
		BEGIN
		IF ISNULL(@ClassicalVoucherProfileExist,0) = 0
		BEGIN
		update device set devicestatusid=@DeviceStatusBlocked where deviceid=@VoucherId
		END
		
		END
			           
		SELECT * into #usedpromotion from 
		(SELECT distinct p.id from TrxDetailPromotion tp join Promotion p on tp.promotionid=p.id where trxdetailid=@TRXDETAILID
		union 
		SELECT p.id from TrxUsedPromotions tp join Promotion p on tp.PromotionName=p.Name where trxdetailid=@TRXDETAILID) up
		--SELECT * FROM #usedpromotion
		INSERT INTO [dbo].[PromotionRedemptionCount]
		([MemberId]
		,[PromotionId]
		,[LastRedemptionDate]           
		,[TrxId])
		SELECT @Userid,p.Id,GETDATE(),@Trxid from #usedpromotion p  where not exists(SELECT 1 from [PromotionRedemptionCount] where promotionid=p.Id and trxid=@Trxid)
		--SELECT * FROM [PromotionRedemptionCount]
		drop table #usedpromotion
		PRINT 'TrxDetail cursor END'
		FETCH NEXT FROM db_cursor INTO @TRXDETAILID  
	END  
	
	--Check for First Purchase , Second Purchase & Purchase with in Period Transactions--
	Declare @callTransactionPromo bit = 1; 
	IF @callTransactionPromo = 1 --this should come from config table based on client
	BEGIN
	EXEC dbo.ApplyPointsForTransactionPromo @ClientId,@UserId,@LoyaltyDevice,'Transaction','',@SiteId,0
	END
	--END of  Transactions Promo apply points
	-----------------------------------------------------------------------------------------
	print 'Start returning values at ' + convert(varchar(25), getdate(), 120) 
	-----------------------------------------------------------------------------------------
	SELECT BonusPoints,LineNumber,CONVERT(varchar(50),PromotionId) collate database_default as PromotionId ,Name ,Points+BonusPoints as TotalPoints,@TotalBonusPoints as TotalBonusPoints from #Offer where processed  = 2
	union
	SELECT promotionvalue as BonusPoints,td.LineNumber,voucherid as PromotionId,dpt.Name as Name,td.Points as TotalPoints,@TotalBonusPoints as TotalBonusPoints from VirtualPointPromotions v
	join trxdetail td on v.linenumber=td.linenumber
	inner join trxvoucherdetail tv on td.trxdetailid=tv.trxdetailid
	inner join device d on tv.TrxVoucherId=d.DeviceId
	inner join DeviceProfile dp on d.id=dp.DeviceId
	inner join DeviceProfileTemplate dpt on dp.DeviceProfileId=dpt.Id where v.trxid=@TrxId and td.trxid=@TrxId
	union
	SELECT distinct promotionvalue as BonusPoints,td.LineNumber,CONVERT(varchar(50),p.id) as PromotionId,p.Name as Name,td.Points as TotalPoints,@TotalBonusPoints as TotalBonusPoints from VirtualPointPromotions v
	join trxdetail td on v.linenumber=td.linenumber
	inner join TrxDetailPromotion tv on td.trxdetailid=tv.trxdetailid
	inner join Promotion p on tv.PromotionId=p.Id
	inner join PromotionCategory pc with(nolock) on p.PromotionCategoryId=pc.Id
	where v.trxid=@TrxId and td.trxid=@TrxId and pc.Name in ('StampCardQuantity','StampCardValue')

	delete from [VirtualStampCard] where trxid=@TrxId AND PromotionOfferType in('PointsMultiplier','Points') 
	PRINT 'COMMIT' 
	COMMIT TRAN
	--PRINT 'ROLLBACK' 
	--ROLLBACK TRAN     
	                                                      
END TRY                                                        
BEGIN CATCH       
	PRINT 'ERROR'      
	PRINT ERROR_NUMBER() 
	PRINT ERROR_SEVERITY()  
	PRINT ERROR_STATE()
	PRINT ERROR_PROCEDURE() 
	PRINT ERROR_LINE()  
	PRINT ERROR_MESSAGE()                                           
    ROLLBACK TRAN                                                        
END CATCH         
END
-- lines modified - 530
