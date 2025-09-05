CREATE PROCEDURE [dbo].[SaveVoucherCode]
(	
	@Code nvarchar(50),
	@Value int,
	@ExpirationDate datetime,
	@ClientId int,
	@ByUserId int
)
AS
BEGIN
	
	UPDATE VoucherCodes 
	SET [Value] = @Value,
		ExpirationDate = @ExpirationDate
	WHERE DeviceId = @Code
		AND ClientID = @ClientId
		
END