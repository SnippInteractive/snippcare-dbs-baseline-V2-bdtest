/*---------------------------------- 
Written : Sreejith
Date : 25 Jan 2024
Details : used in catalyst->Prog.Admin->receipt validation
-----------------------------------*/
CREATE PROCEDURE [dbo].[GetReceiptsValidationQueue]
(
	@ClientId			INT,
	@PageIndex			INT=0,
	@PageSize			INT= 10,
	@SortDirection	VARCHAR(100) = 'desc',
	@SortProperty	VARCHAR(100)
)
AS
BEGIN
	
	DECLARE @Result					NVARCHAR(MAX) = ''

	Declare @TotalCount INT=0, @Offset int= 0

	DECLARE  @ReceiptsOnHold TABLE (RId INT,RetailerName NVARCHAR(250),RetailerAddress NVARCHAR(250),DnId NVARCHAR(15))
	
	INSERt INTO @ReceiptsOnHold
	Select ReceiptId,
		CASE WHEN ISJSON(ExtraInfo) =1 THEN (SELECT ISNULL([value],'') FROM OPENJSON(ExtraInfo,'$.Receipts[0]') WHERE [key] = 'Store_Name') ELSE '' END as RetailerName,
		CASE WHEN ISJSON(ExtraInfo) =1 THEN (SELECT ISNULL([value],'') FROM OPENJSON(ExtraInfo,'$.Receipts[0]') WHERE [key] = 'ship_to_address') ELSE '' END as RetailerAddress,
		CASE WHEN ISJSON(ExtraInfo) =1 THEN (SELECT ISNULL([value],'') FROM OPENJSON(ExtraInfo,'$.Receipts[0]') WHERE [key] = 'slug_receipt_id') ELSE '' END as SlugReceiptId 
	From Receipt 
	Where userid in (
	select u.UserId from [user] u inner join  usertype ut on u.UserTypeId = ut.UserTypeId where ut.ClientId = @ClientId
	)
	AND ProcessingStatus = 'OnHold'
	

	Select @TotalCount = COUNT(1) From @ReceiptsOnHold

	SET @Offset = @PageIndex * @PageSize

	SET @Result = 
		(
			SELECT	RId, DnId, RetailerName, RetailerAddress, @TotalCount as TotalCount
			FROM	@ReceiptsOnHold
			order by RId desc
			OFFSET @Offset ROWS
			FETCH NEXT @PageSize ROWS ONLY
				
			FOR JSON PATH, INCLUDE_NULL_VALUES
		)

	SELECT @Result AS Result
END
