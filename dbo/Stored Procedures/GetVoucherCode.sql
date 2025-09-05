CREATE PROCEDURE [dbo].[GetVoucherCode](@ClientId int,@Code nvarchar(50))
AS
BEGIN
	SET NOCOUNT ON;

	SELECT	vc.DeviceId, 
			vc.UserId,
			convert(varchar(10), 
			vc.ExpirationDate, 120) ExpirationDate ,
			vc.ExtReference,
			vc.[Value],
			vc.ValueType, 
			convert(varchar(10), vc.DateUsed, 120) DateUsed,
			vc.code_id as CodeId,
			vc.usage_id as UsageId,
			isnull(vc.Classical,0) as Classical,
			s.[Name] as SiteName
	FROM VoucherCodes vc 
		inner join [Site] s on s.SiteId = vc.SiteId
	WHERE vc.DeviceId = @Code 
	AND vc.ClientID = @ClientId
END