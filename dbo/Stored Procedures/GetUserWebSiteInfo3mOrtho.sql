/*
https://www.c-sharpcorner.com/article/working-with-json-in-sql-server-2016/
https://techcommunity.microsoft.com/t5/sql-server-blog/returning-child-rows-formatted-as-json-in-sql-server-queries/ba-p/384482
*/
CREATE Procedure [dbo].[GetUserWebSiteInfo3mOrtho] (@userid int, @IncludeTrxValue bit=0,@IncludeTrxCount bit=0, @GetNextTierInfo bit = 0, @Result NVARCHAR(max) OUTPUT) as 
/*
Declare @Result nvarchar(max)
exec [GetUserWebSiteInfo3mOrtho] 2504305,1,1,1, @Result output /*1411792*/
select @Result
*/ 

/*
Declare @Result nvarchar(max)
exec [GetUserWebSiteInfo3mOrtho] 2501285,1,1,1, @Result output /*1411792*/
select @Result
*/ 

Declare @ResultsTable as table(  
UserID INT NOT NULL ,  
PropertyName nvarchar(50),  
PropertyValue nvarchar(max),  
ModifiedDate datetime); 

Declare @ProductCategory as Table(
UserID INT NOT NULL , 
ProductCategoryLink nvarchar(50),
ProductCategoryName nvarchar(50));

Declare @Clinics as Table(
UserID INT NOT NULL ,  
code nvarchar(50),
title nvarchar(250),
description nvarchar(500));

--Added temp fix to load proper JSON until Niall Fixes the SP
--Set @userid = 1415383

Declare @Clientid int,@TrxStatusid_Complete int, @PointsBalance decimal(18,2),@TierPointsBalance DECIMAL(18,2),@clientName nvarchar(50), @LegacyNumber nvarchar(20)
--,@ValueBalance decimal(18,2)
--Use the clientid of the user that is passed to the SP for all selections, looksups, profiles and Tiers
select @Clientid = s.clientid, @clientName = c.[name], @LegacyNumber = LegacyNumber from site s join client c on c.clientid = s.clientid
join [user] u on u.siteid=s.siteid and UserId = @userid
select @PointsBalance  = sum(pointsBalance) from Account where userid = @userid
--select @ValueBalance  = sum(MonetaryBalance) from Account where userid = @userid

select @TrxStatusid_Complete = TrxstatusId from trxstatus where name = 'Completed' and clientid = @Clientid

Begin
	--3m-orthodontics is the client name for this user, so the JSon is very different
	drop table if exists #SubTypes
	drop table if exists #Clinics
	drop table if exists #AllDiscounts
	declare @UserSubTypeHospital int, @UserSubTypeEndUser int, @Corp nvarchar(100)	
	select @Corp = rtrim(ltrim([Corporate Group ID])) FROM catalystbaselinedev.dbo.[__Import_3M_Ortho_We_Love] where [cust nbr] = @legacynumber
	if isnull(@corp,'')!=''  
	Begin
		--{ "code": "66004806", "title": "LMS Avances Y Proyectos SLP", "description": "Torre del Oro 4A 41807 Espartinas Sevilla" }, 
		insert into @Clinics
		select distinct @UserID UserID, [Cust Nbr] as code,ltrim(rtrim([Cust Name])) as title ,rtrim(ltrim(isnull([Curr Addr3],''))) + ' ' + rtrim(isnull([Zip Code], '')) + ' ' + isnull([Curr City], '') as description 
		from catalystbaselinedev.dbo.[__Import_3M_Ortho_We_Love] where [Corporate Group ID] = @Corp
	end
	else
	begin
		IF (@legacynumber IS NOT NULL) OR (LEN(@legacynumber) > 0)
		BEGIN			
			print 'legacy'
			insert into @Clinics
			select distinct @UserID UserID, [Cust Nbr] as code,ltrim(rtrim([Cust Name])) as title ,rtrim(ltrim(isnull([Curr Addr3],''))) + ' ' + rtrim(isnull([Zip Code], '')) + ' ' + isnull([Curr City], '') as description 
			from catalystbaselinedev.dbo.[__Import_3M_Ortho_We_Love] where [cust nbr] = @legacynumber
		END		
		ELSE
		BEGIN
			print 'NULL legacy'
			insert into @Clinics
			select distinct @UserID UserID, '-' as code,'-' as title ,'-' as description 			
		END		
	End
	select LegacyNumber, [Corporate Group ID Description] into #SubTypes 
	FROM catalystbaselinedev.dbo.[__Import_3M_Ortho_We_Love] l join [user] u on convert(nvarchar(10),l.[Cust Nbr])=convert(nvarchar(10),u.LegacyNumber)
	where [Corporate Group ID Description]  = 'Hospitals' or [Corporate Group ID Description] = 'Private - credit card'

	Declare @CurrentYear int = year(getdate()), @CountOfTransactionsCP int, @SumValueCP int, @CountOfcategories int,
	@currentDiscount nvarchar(20), @Name nvarchar(200), @email nvarchar(200), @UserSubType nvarchar(25)
	drop table if exists #PeriodTrx
	drop table if exists #TrxVal
	--select Anal1 as 
	select tt.name TrxType, ts.name TrxStatus ,td.itemcode,td.description,td.anal1,td.value, th.trxid, td.TrxDetailID 
	into #PeriodTrx from  device dv join site s on siteid = dv.homesiteid
	join trxheader th on th.DeviceId=dv.deviceid
	join trxdetail td on th.trxid=td.trxid
	join trxtype tt on th.trxtypeid=tt.trxtypeid
	join trxstatus ts on ts.trxstatusid = th.TrxStatusTypeId
	where s.clientid = @clientid
	and tt.name = 'Transaction' and ts.name = 'Completed'
	and dv.userid = @userid
	and year(th.trxdate ) = @CurrentYear
	select 
	@CountOfTransactionsCP = count(distinct trxid), @SumValueCP= sum(Value), 
	@CountOfcategories=count(distinct anal1)  
	from #PeriodTrx

	--select * from #PeriodTrx
	/*
	"name": "Joseph", >> First name and last name! Mandatory for Reg
	"email": "joseph@gmail.com", >> CD Email
	"currentDiscount": "30%", ULED
	"currentSales": "�7.135",  for this year (group of below)
	"categoriesCount": "4", Distinct anal1
	"transactions": [ >> distinct Trxheader trxid
	*/

	/*select @Name = ltrim(rtrim(isnull(pd.Firstname,'') + ' ' + isnull(pd.Lastname,''))), 
	@email = email,@currentDiscount = uled.propertyvalue, @UserSubType = ust.name*/
	
	select @userid UserID, ltrim(rtrim(isnull(pd.Firstname,'') + ' ' + isnull(pd.Lastname,''))) as [name], isnull(cd.email,'') as email, uled.propertyvalue as currentDiscount
	into #UserInfo
	from [user] u join usercontactdetails ucd on u.userid = ucd.userid
	join contactdetails cd on cd.ContactDetailsId=ucd.contactdetailsid
	join PersonalDetails pd on u.PersonalDetailsId=pd.PersonalDetailsId
	left join UserLoyaltyExtensionData uled on u.UserLoyaltyDataId=uled.UserLoyaltyDataId and propertyname = 'PriceDiscountCode'
	join usersubtype ust on u.usersubtypeid=ust.UserSubTypeId
	where u.userid = @userid
	Alter table #UserInfo add currentSales money
	Alter table #UserInfo add categoriesCount int
	Alter table #UserInfo add transactions int
	update #UserInfo set transactions = @CountOfTransactionsCP
	update #UserInfo set categoriesCount = @CountOfcategories
	update #UserInfo set currentSales = @SumValueCP

	--	select * from #UserInfo
	select top 1 @currentDiscount=currentDiscount from #UserInfo
	/*
	insert into @ResultsTable (UserID, PropertyName, PropertyValue,ModifiedDate)
	Select @userid, 'transactions',ISNULL(@CountOfTransactionsCP,''),GetDate()
	insert into @ResultsTable (UserID, PropertyName, PropertyValue,ModifiedDate)
	Select @userid, 'categoriesCount',ISNULL(@CountOfcategories,''),GetDate()
	insert into @ResultsTable (UserID, PropertyName, PropertyValue,ModifiedDate)
	Select @userid, 'currentSales',ISNULL(@SumValueCP,''),GetDate()
	insert into @ResultsTable (UserID, PropertyName, PropertyValue,ModifiedDate)
	Select @userid, 'Name',ISNULL(@Name,''),GetDate()
	insert into @ResultsTable (UserID, PropertyName, PropertyValue,ModifiedDate)
	Select @userid, 'email',ISNULL(@email,''),GetDate()
	insert into @ResultsTable (UserID, PropertyName, PropertyValue,ModifiedDate)
	Select @userid, 'currentDiscount',ISNULL(@currentDiscount,''),GetDate()
	*/	
	--	select * from @ResultsTable
	--Clinics
	
	insert into @ProductCategory  	values(	@userid, 'adhesives', 'Adhesives')
	insert into @ProductCategory  	values(	@userid, 'ceramicBrackets', ' Ceramic Brackets')
	insert into @ProductCategory  	values(	@userid, 'others','Digital Lingual TOPs')
	insert into @ProductCategory  	values(	@userid, 'others','Headgear')
	insert into @ProductCategory  	values(	@userid, 'others','Infection Prevention')
	insert into @ProductCategory  	values(	@userid, 'others','Intraoral')
	insert into @ProductCategory  	values(	@userid, 'others','Other Ortho')
	insert into @ProductCategory  	values(	@userid, 'instruments','Instruments')
	insert into @ProductCategory  	values(	@userid, 'metalBrackets', 'Metal Brackets')
	insert into @ProductCategory  	values(	@userid, 'preventive', 'Preventive')
	insert into @ProductCategory  	values(	@userid, 'bandsAndTubes','Tubes')
	insert into @ProductCategory  	values(	@userid, 'wires','Wire')
	--select * from @ProductCategory
	
	select * into #trxVal from (select userid, ProductCategoryLink, val from (select UserID, ProductCategoryLink, sum(isnull(Value,0)) Val  from 
	(select userid, pc.ProductCategoryLink, Value from @ProductCategory pc left join #PeriodTrx pt on pc.ProductCategoryName=pt.Anal1 collate database_default 	
	union
	select userid, isnull(pc.ProductCategoryLink,'others') , Value from @ProductCategory pc right join #PeriodTrx pt on pc.ProductCategoryName=pt.Anal1 collate database_default where pc.ProductCategoryLink is null)pg 
	group by ProductCategoryLink, userid
	) x) Res
	Pivot(sum(Val) for ProductCategoryLink in (adhesives,bandsAndTubes,ceramicBrackets,instruments,metalBrackets,others,preventive,wires)) as TrxProducts

	select @userid as UserID, Revenue as salesRange,
	[Ceramic Brackets] as ceramicBrackets,[Metal Brackets] as metalBrackets ,[Bands & Tubes] as bandsAndTubes,[Wires] as wires,[Adhesives] as adhesives,[Instruments] as instruments,[Preventive / Ortholux] as preventive,[Other] as others, row_number() over( Order by Tier) RN,  [Customer Price Discount Code] as currentDiscount into #AllDiscounts
	FROM [SSISHelper].[DiscountAmounts3mOrtho] where country = 'UK' --and [Customer Price Discount Code] = @currentDiscount	
	--	select * into [SSISHelper].[DiscountAmounts3mOrtho] FROM catalystbaselinedev.[SSISHelper].[DiscountAmounts3mOrtho]
	declare @CurrentRow int = 0
	select @CurrentRow  = rn from #AllDiscounts where currentdiscount = @currentDiscount
	select * into #CurrDiscounts from #AllDiscounts where rn =@CurrentRow 
	select * into #NextDiscounts from #AllDiscounts where rn =@CurrentRow +1
	--First output	
	--	select * from #UserInfo
	--	select * from #NextDiscounts
	/*
	select u.*,adhesives,bandsAndTubes,ceramicBrackets,instruments,metalBrackets,others,preventive,wires from #UserInfo u left join #TrxVal t on u.userid=t.userid
	select * from #CurrDiscounts
	select * from #NextDiscounts
	select * from @Clinics-- FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
	select Userid,salesRange, adhesives,bandsAndTubes,ceramicBrackets,instruments,metalBrackets,others,preventive,wires,currentDiscount from #AllDiscounts -- FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
	*/
	-- Alter table #UserInfo add currentSales money
	--Alter table #UserInfo add categoriesCount int
	--Alter table #UserInfo add transactions int
	update #UserInfo set transactions = @CountOfTransactionsCP
	update #UserInfo set categoriesCount = @CountOfcategories
	--	update #UserInfo set currentSales = @SumValueCP
	/*
	SELECT h.UserID, h.[name], h.email, h.currentSales,h.currentDiscount, h.categoriesCount,h.transactions,
	Clinics = JSON_QUERY('[' + STRING_AGG( Clinics.DynamicData,',') + ']','$')
	FROM #UserInfo h
	INNER JOIN (
	SELECT userid, JSON_QUERY(Clinics,'$') AS DynamicData
	FROM #UserInfo h CROSS APPLY ( SELECT  ( SELECT   * FROM @Clinics c WHERE c.userid = h.userid FOR JSON PATH, WITHOUT_ARRAY_WRAPPER) AS Clinics) d 
	--      UNION ALL
	--        SELECT HomeId,JSON_QUERY(Cars,'$') AS DynamicData FROM #UserInfo h CROSS APPLY (SELECT(SELECT * FROM #Toy c WHERE c.userid = h.userid FOR JSON PATH, WITHOUT_ARRAY_WRAPPER) AS clinics) d
	) Clinics
	ON h.userid = clinics.userid
	Group By h.userid, h.[name], h.email, h.currentSales,h.currentDiscount, h.categoriesCount,h.transactions
	*/

	/*
	select u.Name name,u.email, u.currentDiscount,clinics.code, clinics.title, clinics.description,
	discountStructure.salesRange,discountStructure.ceramicBrackets,discountStructure.metalBrackets
	--discountStructure.bandsAndTubes,discountStructure.wires, discountStructure.adhesives,
	--discountStructure.instruments,discountStructure.preventive,discountStructure.others -- FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
	from #UserInfo u left join #TrxVal t on u.userid=t.userid
	join @Clinics clinics on u.userid = clinics.userid
	join #AllDiscounts discountStructure on u.userid = discountStructure.userid FOR JSON AUTO
	--FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
	*/
	/*
	select u.Name name,u.email, u.currentDiscount,
	(select c.code, c.title, c.description from @Clinics c 
	where u.userid = c.userid FOR JSON PATH) as clinics,
	( select 
	ad.salesRange,ad.ceramicBrackets,ad.metalBrackets,
	ad.bandsAndTubes,ad.wires, ad.adhesives,
	ad.instruments,ad.preventive,ad.others  
	from #AllDiscounts ad where u.userid = ad.userid FOR JSON PATH) as discountStructure
	-- FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
	from #UserInfo u left join #TrxVal t on u.userid=t.userid
	FOR JSON PATH
	*/
	--, ROOT ('EmployeeInfo')
	/*
	declare @tempData as varchar(max) = '
	{ "name": "' + ISNULL(@Name,'') + '", "email": "' + ISNULL(@email,'') + '", "currentDiscount": "30%", "currentSales": "' + convert(nvarchar(10),ISNULL(@SumValueCP,0)) +'", "categoriesCount": "' + convert(nvarchar(10),ISNULL(@CountOfTransactionsCP,0)) +'", "ceramicBrackets": "�360", "adhesives": "�2.239", "metalBrackets": "�2.239", "instruments": "�0", "bandsAndTubes": "�0", "preventive": "�0", "wires": "�0", "others": "�0", "maintainStatus": ">�10.000", "nextDiscount": "35%", "currentPurchaseAmount": "�7.135", "currentAchievement1": "70%", "nextStatusPurchases": ">�30.000", "currentAchievement2": ">�30.000", "nextStatusCategories": ">�30.000", 
	"clinics": [ 
	{ "code": "66004806", "title": "LMS Avances Y Proyectos SLP", "description": "Torre del Oro 4A 41807 Espartinas Sevilla" }, 
	{ "code": "66004810", "title": "Aznalcazar Salud 2008 S.L.P.", "description": "Sevilla 57 41849 Aznalcazar Seville" } ]
	, "discountStructure": [ 
	{ "salesRange": ">�35.600", "ceramicBrackets": "50%", "metalBrackets": "50%", "bandsAndTubes": "50%", 
	"wires": "50%", "adhesives": "50%", "instruments": "50%", "preventive": "50%", "others": "50%" }, 
	{ "salesRange": ">�35.600", "ceramicBrackets": "50%", "metalBrackets": "50%", "bandsAndTubes": "50%", "wires": "50%", "adhesives": "50%", "instruments": "50%", "preventive": "50%", "others": "50%" } ] }';
	*/
	--Select @userid, 'MemberDashboardData',ISNULL(@tempData,''),GetDate()
	--declare @tempData as varchar(max) = 
	set @Result = (select --u.Name name,u.email, u.currentDiscount,
	u.name,u.email,u.currentDiscount,u.currentSales,u.categoriesCount,t.ceramicBrackets,t.adhesives,
	t.metalBrackets,t.instruments,t.bandsAndTubes,t.preventive,t.wires,t.others,
	10 maintainStatus,'35%' nextDiscount,7.135 currentPurchaseAmount,'70%' currentAchievement1,
	30 nextStatusPurchases,30 currentAchievement2,30 nextStatusCategories,
	(select c.code, c.title, c.description from @Clinics c 
	where u.userid = c.userid FOR JSON PATH) as clinics,
	( select 
	ad.salesRange,ad.ceramicBrackets,ad.metalBrackets,
	ad.bandsAndTubes,ad.wires, ad.adhesives,
	ad.instruments,ad.preventive,ad.others  
	from #AllDiscounts ad where u.userid = ad.userid FOR JSON PATH) as discountStructure
	-- FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
	from #UserInfo u left join #TrxVal t on u.userid=t.userid
	FOR JSON PATH)

	--Set @Result = (select * from @ResultsTable FOR JSON AUTO);
	--select @tempData
	drop table if exists #Clinics
	drop table if exists #AllDiscounts
	drop table if exists #SubTypes
	drop table if exists #PeriodTrx
	drop table if exists #TrxVal
	drop table if exists #CurrDiscounts
	drop table if exists #NextDiscounts
	drop table if exists #UserInfo
end
