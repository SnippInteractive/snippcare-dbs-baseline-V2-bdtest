
-- =============================================
-- Author:		ANISH
-- Create date: 28-06-2017
-- Description:	Classical Voucher Maximum Redemption Check
-- =============================================
CREATE PROCEDURE [dbo].[Epos_CheckClassicalVoucherUsage]
	-- Add the parameters for the stored procedure here
	@LoyaltyDevice varchar(50),
	@Voucher varchar(50)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	Declare @UserId INT
	SET @UserId=(select userid from device where deviceid=@LoyaltyDevice)
	Declare @MaxUsage INT
	SET @MaxUsage=(select top 1 isnull(MaximumUsage,0) from  
device d join deviceprofile dp on d.id=dp.deviceid 
join deviceprofiletemplate dpt on dp.deviceprofileid=dpt.id 
join deviceprofiletemplatetype dpty on dpt.deviceprofiletemplatetypeId=dpty.id
join voucherdeviceprofiletemplate vdp on dpt.id=vdp.id where dpty.name='Voucher' and d.DeviceId=@Voucher and vdp.ClassicalVoucher=1)

Declare @UsedVoucherCount INT
SET @UsedVoucherCount=(SELECT isnull(count(1),0)
  FROM [ClassicalVoucherRedemptionCount] where MemberId=@UserId and VoucherId=@Voucher)
	
	if(@UsedVoucherCount>=@MaxUsage AND @UsedVoucherCount>0)
	begin
	select 2 as Result -- failed
	end
	else
	begin
	select 1 as Result-- ok
	end
END

