/*
ParamString can be passed using criterias in JSon format TrxId int=2167
declare @ReturnedJSON nvarchar(max), @InputtedJSON nvarchar(1000)='{"TrxId":"9429"}'
exec API_PostReceiptProcessingCalculationsWIP @InputtedJSON,@ReturnedJSON OutPut
select @ReturnedJSON

*/


CREATE Procedure [dbo].[API_PostReceiptProcessingCalculations] (@ParamString nvarchar(max), @ReturnedJSON nvarchar(max) Output) as 
Begin
	--Declare @ParamString nvarchar(max)='{"TrxId":"9429"}',@ReturnedJSON nvarchar(max)
	Declare @TrxId int, @Deviceid varchar(25), @AccountPointsBalance Money, @Accountid int, @UserId int,@CurrentTier int, @MinTier int, @Multiplier int = 2, @PointsToAdd money, @RecsToProcess int, @BonusAmount money = 75000
	select @TrxId =json_value(@ParamString,'$.TrxId')
	set @ReturnedJSON = ''
	Declare @Trx table (
	id int IDENTITY(1,1),TrxType nvarchar(50),TrxStatus nvarchar(50), TrxID int, 
	ClientID int,SiteID int, TrxDate datetimeoffset, CreateDate datetimeoffset,Deviceid nvarchar(25),
	TerminalID nvarchar(100),Reference nvarchar(500), OpId nvarchar(50), TrxDetailId int, LineNumber int,
	itemcode nvarchar(50), [description] nvarchar(500),quantity int,[value] money,points money,VatPercentage money, RunningTotal Money, UntilBonus Money, userid int,Anal1 nvarchar(100),Anal2 nvarchar(100),Anal3 nvarchar(100),Anal13 nvarchar(100),InitialTransaction int,SplitterLine int)
	
	select @UserID = dv.userid, @DeviceID = DV.deviceid  from trxheader th join device dv on dv.deviceid = th.deviceid where th.trxid = @trxid
	
	insert into @Trx (TrxType, TrxStatus,TrxId, Clientid,SiteID,
	TrxDate,CreateDate,th.Deviceid,TerminalID,Reference,Opid,
	trxdetailid,LineNumber,itemcode, [description],quantity,[value],points,VatPercentage,RunningTotal,UntilBonus, userid,Anal1,Anal2,Anal3,InitialTransaction)

	select tt.name TrxType, ts.Name TrxStatus,th.TrxId,th.Clientid,th.SiteID,
	th.TrxDate,th.CreateDate,th.Deviceid,th.TerminalID,th.Reference,th.Opid,
	td.trxdetailid,td.LineNumber,td.itemcode, td.[description],td.quantity,td.[value],td.points,VatPercentage, 
	SUM (case when th.createdate > dateadd(year, datediff(year,0, Getdate()), 0) then td.Value else 0 end ) OVER (PARTITION BY th.trxtypeid ORDER BY th.trxid, TrxDetailId) as RunningTotal,
	SUM (case when th.createdate > dateadd(year, datediff(year,0, Getdate()), 0) then td.Value else 0 end) OVER (PARTITION BY th.trxtypeid ORDER BY th.trxid, TrxDetailId) -@BonusAmount UntilBonus , dv.userid,Anal1,Anal2,Anal3,InitialTransaction
	from trxheader th join trxdetail td on th.trxid =td.trxid
	join trxstatus ts on ts.trxstatusid=th.TrxStatusTypeId
	join TrxType tt on tt.trxtypeid =th.trxtypeid
	join device dv on dv.deviceid = th.deviceid and dv.userid =  @UserID 
	where tt.Name = 'Receipt' and ts.name = 'Completed' 
	and itemcode !='Item(s)'  --and InitialTransaction is null
	and Anal13 is null ----- these are the ones from this Year to be taken into account!!!
	order by th.TrxId asc, td.TrxDetailID asc	

	update t set t.splitterline = 1 from @Trx t join (
	select id,TrxDetailID, Trxid,untilbonus,[Value]-untilbonus as SplitAmount, Row_number()Over(order by trxdetailid) rn from @Trx where untilbonus > 0) x on t.id=x.id
		where rn = 1
	
	select @RecsToProcess = count(*) from @Trx where trxid = @trxid 
	if @RecsToProcess =0
		Begin
			select @ReturnedJSON = 'No Records to Process'
			return;
		End
	
	select 
	--Get the amount of Rebate that is there already BEFORE we get the amount for this transaction
	@accountpointsbalance= pointsbalance, 
	@userid = dv.userid,
	@Accountid = ac.accountid
	from account ac join device dv on dv.accountid = ac.accountid where dv.deviceid = @DeviceID 

	select @MinTier=min(id) from TierAdmin 
	select @CurrentTier = tu.TierID from tierusers tu left join tieradmin ta on ta.id=tu.tierid 
	where userid = @userid
	if @CurrentTier is null
	Begin
		select @CurrentTier=@MinTier  
		insert into tierusers (TierId, UserID,[Enabled]) values (@CurrentTier ,@userid,1)
	End
	
	if @CurrentTier = @minTier 
	Begin
		--its 2 %
		
		update t set t.vatpercentage = @multiplier, points = ([Value]*@multiplier)/100 from @trx t 
		where t.trxid = @trxid
		
		Update td set td.vatpercentage = t.vatpercentage, td.points = t.points, Anal3=@multiplier  from @trx t  join trxdetail td on t.trxdetailid=td.trxdetailid where t.trxid = @trxid
		
		select @PointsToAdd = sum(points) from @Trx where trxid = @Trxid
		Update th set th.accountpointsbalance = @accountpointsbalance + @PointsToAdd  from trxheader th where th.trxid = @trxid
		update a set a.pointsbalance = a.pointsbalance  + @PointsToAdd from account a where a.accountid = @Accountid
		set @ReturnedJSON = '{"RebateAmountAdded":"' +convert(nvarchar(50), isnull(@PointsToAdd,0))+ '","RebateAmountTotal":"' +convert(nvarchar(50), isnull(@AccountPointsBalance,0))+ '"}'
		Return;
	End
	else
	Begin
		Declare @TrxDetailID int
		set @multiplier = 3
		update @trx set VatPercentage = @multiplier, points = ([Value]*@multiplier)/100 where SplitterLine is null and UntilBonus <=0 and trxid = @trxid 
		set @multiplier = 4
		update @trx set VatPercentage = @multiplier, points = ([Value]*@multiplier)/100  where SplitterLine is null and UntilBonus >0 and trxid = @trxid 
		Declare @Splitter int
		select @TrxDetailID = Trxdetailid from @trx where trxid = @trxid and SplitterLine = 1
		if @TrxDetailID is not null
		Begin
			insert into @Trx (TrxType, TrxStatus,TrxId, Clientid,SiteID,TrxDate,CreateDate,Deviceid,TerminalID,Reference,Opid,
			trxdetailid,LineNumber,itemcode, [description],quantity,[value],points,VatPercentage,RunningTotal,UntilBonus, userid, Anal1, Anal2, Anal3)
			select TrxType, TrxStatus,TrxId, Clientid,SiteID,TrxDate,CreateDate,Deviceid,TerminalID,Reference,Opid,
			0,LineNumber,itemcode, [description],quantity,untilbonus,(untilbonus*@multiplier)/100,@multiplier,RunningTotal,UntilBonus, userid, Anal1, Anal2, @multiplier from @trx where trxdetailid = @TrxDetailID
			set @multiplier = 3
			update @Trx set [value] = [Value]-untilbonus, vatpercentage = @multiplier,points = (([Value]-untilbonus)*@multiplier)/100 where trxdetailid = @TrxDetailID
			
			insert into trxdetail 
			([Version],TrxID,ItemCode,Description,Anal1,Anal2,Anal3,Quantity,Value,Points,PromotionalValue,
			EposDiscount,LoyaltyDiscount,
			[Status],BonusPoints,VAT,VatPercentage,ConvertedNetValue,Anal15,LineNumber)
			select 1,@Trxid,itemcode,Description,Anal1,Anal2,Anal3,Quantity,Value,Points,0 ,0 ,0 ,
			'P' [Status],0 BonusPoints,1.00 VAT,VatPercentage,0,'Split',LineNumber from @trx
			where trxdetailid = 0
			
		End
		Update td set td.vatpercentage = t.vatpercentage, td.points = t.points, Anal3=t.vatpercentage, td.Value=t.value from @trx t  join trxdetail td on t.trxdetailid=td.trxdetailid
		where t.trxid = @trxid
	
		select @PointsToAdd = sum(points) from @Trx where trxid = @Trxid
		Update th set th.accountpointsbalance = @accountpointsbalance + @PointsToAdd  from trxheader th where th.trxid = @trxid
		update a set a.pointsbalance = a.pointsbalance  + @PointsToAdd from account a where a.accountid = @Accountid
	End
	set @ReturnedJSON = '{"RebateAmountAdded":"' +convert(nvarchar(50), isnull(@PointsToAdd,0))+ '","RebateAmountTotal":"' +
	convert(nvarchar(50), isnull(@AccountPointsBalance,0))+ '"}'
	Return;  
	  --@ReturnedJSON
	--update account set pointsbalance = 0 where accountid = 8570
	
END
