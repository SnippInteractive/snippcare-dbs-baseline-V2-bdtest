/*
DECLARE @JsonStringOut nvarchar(max)
exec [dbo].[DeviceGetRandomVoucherFromPool] '{"UserId":1403863,"DeviceLotId":1077}',@JsonStringOut OUTPUT
SELECT @JsonStringOut
*/

CREATE Procedure [dbo].[DeviceGetRandomVoucherFromPool] (@JsonStringIn nvarchar(max) , @JsonStringOut nvarchar(max) output)
as 
Begin 

	/*
	{"UserId":1403863,"DeviceLotId":1077}
	
	*/	
	Declare @UserId int, @DeviceNumber varchar(25), @DeviceLotID int
	select @UserId =json_value(@JsonStringIn,'$.UserId')
	select @DeviceLotID =json_value(@JsonStringIn,'$.DeviceLotId')
	/*output table for the result and update at the same time*/ 
	
	declare @tab_insert table (UpdateNo int)

	/*Double Random the number*/ 
	declare @Random_Choice int 
	select @Random_Choice=convert(int,rand()*100)

	Update [DeviceNumberPool] set statusid = 6/*used*/, UpdatedBy = @userid 
	/*reserve the number with the userid*/
	output inserted.id into @tab_insert (UpdateNo)
	where id in (select top 1 id from 
	(select top 100 id,row_number() over (order by newID()) rn 
	from [DeviceNumberPool] where statusid = 1/*Created*/
	and lotid = @DeviceLotID ) x
	where rn = @Random_Choice) 
	/*Get the result*/
	select @DeviceNumber=DeviceNumber 
	from [DeviceNumberPool] p 
	join @tab_insert i on i.UpdateNo=p.id 
	if @DeviceNumber is null
	Begin
		set @JsonStringOut = '{"MessageType":"VoucherUnavailable","Message":"No vouchers left for Lot ' +convert(nvarchar(10), @DeviceLotID) + '","Voucher":"' +
		isnull(@DeviceNumber,'')+ '"}'
	Return;  

		return
	End
	set @JsonStringOut = '{"MessageType":"","Message":"","Voucher":"' +
		isnull(@DeviceNumber,'')+ '"}'
	Return;  

	 /*all is good, number returned, message string is ""*/ 
	--{"MessageType":"","Voucher":"xxx234879"}

End