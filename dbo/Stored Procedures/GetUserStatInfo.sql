﻿CREATE Procedure [dbo].[GetUserStatInfo] (@userid int, @IncludeTrxValue bit=0,@IncludeTrxCount bit=0, @GetNextTierInfo bit = 0, @Result NVARCHAR(max) OUTPUT) as 
/*
Declare @Result nvarchar(max)
exec [GetUserStatInfo] 2501285,1,1,1, @Result output /*1411792*/
select @Result
*/
/*
Get KPI user inforamtion for 
1. Tier Current and what is needed for the next Tier
2. the Count of Trx Redemptions the user has had
3. the Count of Trx Receipts the user has had
Declare @Result nvarchar(max)
exec GetUserStatInfo 1415383,1,1,1, @Result output /*1411792*/
select @Result
*/ 
-- Modified By: Abdul Wahab-09-02-22
-- Reason: VOY-635 - add TierPoints from ULED

-- Modified By: Shivam Kislay 2023-03-06
-- Reason: VOY-1182 - add TrxDetailsCount

Declare @ResultsTable as table(  
    UserID INT NOT NULL ,  
    PropertyName nvarchar(50),  
    PropertyValue nvarchar(max),  
    ModifiedDate datetime); 

--Added temp fix to load proper JSON until Niall Fixes the SP
--Set @userid = 1415383

Declare @Clientid int,@TrxStatusid_Complete int, @PointsBalance decimal(18,2),
@TierPointsBalance DECIMAL(18,2),@clientName nvarchar(50) 
--,@ValueBalance decimal(18,2)
--Use the clientid of the user that is passed to the SP for all selections, looksups, profiles and Tiers
select @Clientid = s.clientid, @clientName = c.[name] from site s join client c on c.clientid = s.clientid
join [user] u on u.siteid=s.siteid and UserId = @userid
select @PointsBalance  = sum(pointsBalance) from Account where userid = @userid
--select @ValueBalance  = sum(MonetaryBalance) from Account where userid = @userid

select @TrxStatusid_Complete = TrxstatusId from trxstatus where name = 'Completed' and clientid = @Clientid

if @clientname != '3m-orthodontics' 
Begin
	SELECT @TierPointsBalance = CAST(ISNULL(PropertyValue,0) AS DECIMAL(18,2)) FROM [User] U INNER JOIN UserLoyaltyData ULD 
	ON U.UserLoyaltyDataId = ULD.UserLoyaltyDataId
	INNER JOIN
	UserLoyaltyExtensionData ULED ON ULD.UserLoyaltyDataId = ULED.UserLoyaltyDataId
	WHERE UserId=@userid
	AND PropertyName='TierPoints'

	if @GetNextTierInfo = 1
	Begin
		Declare @TierID int, @CurrentTierThreshold nvarchar(20),@CurrentTierDescription nvarchar(150),@TierImageUrl varchar(max)
		--current Tier
		select @TierID = ta.id, @CurrentTierThreshold = ta.ThresholdTo  , @CurrentTierDescription = ta.Description,
		@TierImageUrl = ta.ImageUrl
		from tieradmin  ta join tierusers tu on ta.Id=tu.TierId
		join DeviceProfileTemplate dpt on dpt.id=ta.loyaltyprofileid 
		where tu.userid=@userid
	
		--All Tiers
		Declare @NextTierID int, @NextTierThreshold nvarchar(20),@NextTierDescription nvarchar(150),@NextProfileDescription nvarchar(150), @PointsNeedForNextTier int
		select top 1 @NextTierThreshold=ThresholdFrom, @NextTierDescription=ta.description, --@NextProfileDescription =dpt.Description,
		@PointsNeedForNextTier = ThresholdFrom- (CASE WHEN @TierPointsBalance > 0 THEN @TierPointsBalance ELSE @PointsBalance END)
		from site s join DeviceProfileTemplate dpt on dpt.siteid=s.siteid join tieradmin ta on dpt.id=ta.loyaltyprofileid 
		where clientid = @clientid and ThresholdTo > @CurrentTierThreshold
		order by thresholdto asc
	
		insert into @ResultsTable (UserID, PropertyName, PropertyValue,ModifiedDate)
		Select @userid, 'CurrentTierDescription',ISNULL(@CurrentTierDescription,''),GetDate()
		insert into @ResultsTable (UserID, PropertyName, PropertyValue,ModifiedDate)
		Select @userid, 'CurrentTierThreshold',ISNULL(@CurrentTierThreshold,''),GetDate()
		insert into @ResultsTable (UserID, PropertyName, PropertyValue,ModifiedDate)
		Select @userid, 'TierImageUrl',ISNULL(@TierImageUrl,''),GetDate()
		insert into @ResultsTable (UserID, PropertyName, PropertyValue,ModifiedDate)
		Select @userid, 'NextTierDescription',ISNULL(@NextTierDescription,''),GetDate()
		insert into @ResultsTable (UserID, PropertyName, PropertyValue,ModifiedDate)	
		Select @userid, 'PointsNeedForNextTier',ISNULL(@PointsNeedForNextTier,''),GetDate()
	End 
	--See if TRX need to be selected
	if @IncludeTrxCount !=0 and @IncludeTrxValue = 0
	Begin 
		insert into @ResultsTable (UserID, PropertyName, PropertyValue,ModifiedDate)
		select @userid, 'TrxCount'+Name as 'PropertyName','0',GetDate() from trxtype where clientid = @Clientid
	
		select 'TrxCount' + tt.name TrxType, Count(Th.Trxid) CountOfTrx into #TrxCount
		from device dv join trxheader th on dv.deviceid=th.deviceid
		and th.TrxStatusTypeId = @TrxStatusid_Complete and userid = @userid
		join trxtype tt on tt.TrxTypeId=th.trxtypeid 
		group by  tt.name
	
		Update r set r.propertyvalue = t.CountOfTrx from @ResultsTable r join #TrxCount t on r.PropertyName=t.TrxType collate database_default

		-- VOY-1182 Add TrxDetails Count As Well Along With TrxCounts
		insert into @ResultsTable (UserID, PropertyName, PropertyValue,ModifiedDate)
		select @userid, 'TrxDetailCount'+Name as 'PropertyName','0',GetDate() from trxtype where clientid = @Clientid

		-- VOY-1182
		select 'TrxDetailCount' + tt.name TrxType, Count(Td.TrxDetailid) CountOfTrxDetail, COUNT(td.TrxDetailID) CountOfTrxDetails into #TrxDetailCount
		from device dv join trxheader th on dv.deviceid=th.deviceid
		join TrxDetail td on th.TrxId = td.trxid
		and th.TrxStatusTypeId = @TrxStatusid_Complete and userid = @userid
		join trxtype tt on tt.TrxTypeId=th.trxtypeid 
		group by  tt.name
	
		Update r set r.propertyvalue = t.CountOfTrxDetail from @ResultsTable r join #TrxDetailCount t on r.PropertyName=t.TrxType collate database_default

	End

	if @IncludeTrxValue !=0
	Begin 
		insert into @ResultsTable (UserID, PropertyName, PropertyValue,ModifiedDate)
		select @userid, 'TrxValue' +Name collate database_default as 'PropertyName','0',GetDate() from trxtype where clientid = @Clientid
		union all
		select @userid, 'TrxPoints'+Name collate database_default as 'PropertyName','0',GetDate() from trxtype where clientid = @Clientid
		union all 
		select @userid, 'TrxCount' +Name collate database_default as 'PropertyName','0',GetDate() from trxtype where clientid = @Clientid
		-- VOY-1182
		union all 
		select @userid, 'TrxDetailCount' +Name collate database_default as 'PropertyName','0',GetDate() from trxtype where clientid = @Clientid
	/*	
		select tt.name TrxType, sum(Td.Value) SumOfTrx, sum(Points) SumOfPoints,Count(distinct Th.Trxid) CountOfTrx into #TrxValueAndPoints
		from device dv join trxheader th on dv.deviceid=th.deviceid
		and th.TrxStatusTypeId in (select TrxstatusId from trxstatus where name = 'Completed' ) and userid = @userid
		join trxtype tt on tt.TrxTypeId=th.trxtypeid 
		join trxdetail td on th.trxid=td.trxid
		group by  tt.name
		*/
		select tt.name TrxType, sum(Td.Value) SumOfTrx, sum(Points) SumOfPoints,Count(distinct Th.Trxid) CountOfTrx,Count(distinct Td.TrxDetailid) CountOfTrxDetails  into #TrxValueAndPoints
		from device dv join trxheader th on dv.deviceid=th.deviceid
		and th.TrxStatusTypeId in (select TrxstatusId from trxstatus where name = 'Completed' ) and userid = @userid
		join trxdetail td on th.trxid=td.trxid
		join trxtype tt on tt.TrxTypeId=th.trxtypeid 
		group by  tt.name



		Update r set r.propertyvalue = t.CountOfTrx from @ResultsTable r 
		join #TrxValueAndPoints t on r.PropertyName='TrxCount'+t.TrxType 	collate database_default and propertyname like 'TrxCount%'
		-- VOY-1182
		Update r set r.propertyvalue = t.CountOfTrxDetails from @ResultsTable r 
		join #TrxValueAndPoints t on r.PropertyName='TrxDetailCount'+t.TrxType 	collate database_default and propertyname like 'TrxDetailCount%'

		Update r set r.propertyvalue = t.SumOfTrx from @ResultsTable r 
		join #TrxValueAndPoints t on r.PropertyName='TrxValue'+t.TrxType collate database_default and propertyname like 'TrxValue%'
		Update r set r.propertyvalue = t.SumOfPoints from @ResultsTable r 
		join #TrxValueAndPoints t on r.PropertyName='TrxPoints'+t.TrxType collate database_default and propertyname like 'TrxPoints%'

	End

	insert into @ResultsTable (UserID, PropertyName, PropertyValue,ModifiedDate)
	select @userid, 'CurrentPointsBalance', @PointsBalance,GetDate()

	INSERT INTO @ResultsTable (UserID, PropertyName, PropertyValue,ModifiedDate)
	SELECT @userid, 'TierPoints', @TierPointsBalance,GETDATE()

	DECLARE @TierLogic NVARCHAR(MAX) = '';
	SELECT @TierLogic = STUFF((Select DP.Name as 'TierName',TA.Description as 'TierDesription',TA.ThresholdFrom as 'TierStartThreshold',
	TA.ThresholdTo as 'TierEndThreshold'
	From TierAdmin TA inner Join DeviceProfileTemplate DP on TA.loyaltyprofileid = DP.Id
	Inner Join [Site] S on S.SiteId = DP.SiteId
	--Where S.ClientId = (Select ClientId from Client where Name = 'Ballys')
	Where S.ClientId = @Clientid --Ballys was hardcoded above, I don't know why! --Niall 2023-03-09
	FOR json path), 1, 1, '')

	insert into @ResultsTable (UserID, PropertyName, PropertyValue,ModifiedDate)
	select @userid, 'TierDefinition', REPLACE(@TierLogic,']','') ,GetDate()
	--insert into @ResultsTable (UserID, PropertyName, PropertyValue,ModifiedDate)
	--select @userid, 'CurrentValueBalance', @ValueBalance,GetDate()
End
Else
Begin
	exec [GetUserWebSiteInfo3mOrtho] @userid,@IncludeTrxValue,@IncludeTrxCount, @GetNextTierInfo, @Result output /*1411792*/
	insert into @ResultsTable (UserID, PropertyName, PropertyValue,ModifiedDate)
	Select @userid, 'MemberDashboardData',ISNULL(@Result,''),GetDate()	
End
Set @Result = (select * from @ResultsTable FOR JSON AUTO);
