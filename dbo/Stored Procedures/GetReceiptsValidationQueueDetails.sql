/*---------------------------------- 
Written : Sreejith
Date : 25 Jan 2024
Details : used in catalyst->Prog.Admin->receipt validation
-----------------------------------*/
CREATE PROCEDURE [dbo].[GetReceiptsValidationQueueDetails]
(
	@ReceiptId			INT,/*Table Id*/
	@ClientId			INT
)
AS
BEGIN
	
	DECLARE @Result					NVARCHAR(MAX) = ''
	DECLARE @DnId NVARCHAR(50), @RetailerName  NVARCHAR(250), @RetailerAddress NVARCHAR(250), @ImageUrl NVARCHAR(250), @MostLikelyMatches NVARCHAR(max), @ResponseData NVARCHAR(max), @ExtraInfoData  NVARCHAR(max)

	DECLARE  @MatchesMemberIds TABLE (MemberId INT, AddressLine1 NVARCHAR(250),AddressLine2 NVARCHAR(250), MatchPercentage NVARCHAR(10))

	Select 
		@DnId = CASE WHEN ISJSON(ExtraInfo) =1 THEN (SELECT ISNULL([value],'') FROM OPENJSON(ExtraInfo,'$.Receipts[0]') WHERE [key] = 'slug_receipt_id') ELSE '' END,
		@RetailerName = CASE WHEN ISJSON(ExtraInfo) =1 THEN (SELECT ISNULL([value],'') FROM OPENJSON(ExtraInfo,'$.Receipts[0]') WHERE [key] = 'Store_Name') ELSE '' END,
		@RetailerAddress = CASE WHEN ISJSON(ExtraInfo) =1 THEN (SELECT ISNULL([value],'') FROM OPENJSON(ExtraInfo,'$.Receipts[0]') WHERE [key] = 'ship_to_address') ELSE '' END,
		@ImageUrl = ImageUrl, --CASE WHEN ISJSON(ExtraInfo) =1 THEN (SELECT ISNULL([value],'') FROM OPENJSON(ExtraInfo,'$.Receipts[0]') WHERE [key] = 'ImageURL') ELSE '' END,
		@MostLikelyMatches = CASE WHEN ISJSON(ExtraInfo) =1 THEN (SELECT ISNULL([value],'') FROM OPENJSON(ExtraInfo,'$.Receipts[0]') WHERE [key] = 'MostLikelyMatches') ELSE '' END,
		@ResponseData = Response,
		@ExtraInfoData = ExtraInfo
	From Receipt 
	Where receiptId = @ReceiptId
	--AND userid in (
	--select u.UserId from [user] u inner join  usertype ut on u.UserTypeId = ut.UserTypeId where ut.ClientId = @ClientId
	--)

	
	INSERT INTO @MatchesMemberIds
	SELECT MemberId,AddressLine1,AddressLine2, MatchPercentage 
	FROM OPENJSON(@MostLikelyMatches,'$')
	WITH( 
	MemberId NVARCHAR(20) '$.MemberId', AddressLine1 NVARCHAR(250) '$.AddressLine1',  AddressLine2 NVARCHAR(250) '$.Addressline2', MatchPercentage NVARCHAR(10) '$.MatchPercentage')
	

	DECLARE  @MatchesMemberDetails TABLE (MemberId INT, FullName nvarchar(250),AddressLine1 nvarchar(250),AddressLine2 nvarchar(250), MatchPercentage NVARCHAR(10))
	
	INSERT INTO @MatchesMemberDetails
	Select u.UserId, pd.Firstname + ' ' + pd.Lastname, matches.AddressLine1, matches.AddressLine2, matches.MatchPercentage
	From 
	[User] u 
	inner join @MatchesMemberIds matches on matches.MemberId = u.UserId
	inner join PersonalDetails pd on pd.PersonalDetailsId = u.PersonalDetailsId	


	SET @Result = 
		(
			SELECT 	@ReceiptId as RId,
					@DnId as DnId,
					@RetailerName as RetailerName,
					@RetailerAddress as RetailerAddress,
					@ImageUrl as ImageUrl,
					@ResponseData as ResponseData,
					@ExtraInfoData as ExtraInfoData,
					(
						SELECT			MemberId, FullName, AddressLine1, AddressLine2, MatchPercentage
						FROM			@MatchesMemberDetails
						FOR JSON PATH, INCLUDE_NULL_VALUES				
					) AS MemberMatches
				
			FOR JSON PATH, INCLUDE_NULL_VALUES
		)


	SELECT @Result AS Result
END
