
CREATE PROCEDURE [dbo].[GetDocuments]
(
	@PageIndex INT = 0,
	@PageSize  INT = 10,
	@SortDirection VARCHAR(100) = 'desc',
	@SortProperty VARCHAR(100),
	@ClientId INT,
	@Status VARCHAR(50),
	@DocumentType VARCHAR(20),-- ffl,w9
	@FromDate datetime=NULL,
	@ToDate datetime=NULL,
	@SourceAddress VARCHAR(150)
)
AS
BEGIN

	IF @PageSize = 0  
	BEGIN  
		SET @PageSize = 10  
	END
			  
	IF @PageIndex =-1          
	BEGIN          
		SET @PageIndex = 0;          
	END 
			  
	DECLARE @FirstRow INT = 0, @LastRow INT = 0          
	SET @LastRow = @PageSize*(@PageIndex+1)          
	SET @FirstRow = @LastRow + 1 - @PageSize  
			
	DECLARE @SQL VARCHAR(MAX)=''
	DECLARE @OrderClause VARCHAR(100)=''

	--IF (@SortProperty  <> '' OR @SortProperty <> NULL) and @SortProperty <> 'Select'
	--	SET @OrderClause = ' ORDER BY '+ @SortProperty + ' ' + @SortDirection
	--ELSE
	--	SET @OrderClause = ' ORDER BY th.TrxId desc '

	SET @OrderClause = ' ORDER BY d.CreateDate desc '

	DECLARE @StatusId INT = 0
	if isnull(@Status,'')= ''
		set @Status = 'Queued'

	if @Status = 'Pending' -- Pending
	begin
		select @StatusId = Id from MemberDocumentStatus where [Name]='Pending' and ClientId = @ClientId
	end
	else if @Status = 'Queued' --Submitted
	begin
		select @StatusId = Id from MemberDocumentStatus where [Name]='Submitted' and ClientId = @ClientId
	end
	else if @Status = 'Valid' --Approved
	begin
		select @StatusId = Id from MemberDocumentStatus where [Name]='Approved' and ClientId = @ClientId
	end
	else if @Status = 'Invalid' --Declined
	begin
		select @StatusId = Id from MemberDocumentStatus where [Name]='Declined' and ClientId = @ClientId
	end

	DECLARE @DocTypeId INT = 0
	select @DocTypeId = DocumentTypeId from MemberDocumentType where [Name] = @DocumentType
	

	
	
	SET @SQL = '


		DECLARE @TotalCount INT
		DECLARE @table TABLE
				(	
					RowNum				INT,
					DocumentId			INT,	
					UserId				INT,
					ReceivedDate		datetime,
					SourceAddress		NVARCHAR(100),					
					ImageUrl			NVARCHAR(max),					
					Status				NVARCHAR(10),
					StatusId			INT,
					DocumentData		NVARCHAR(max),
					ExtraInfo			NVARCHAR(max),
					Notes				NVARCHAR(max),
					DocumentType		NVARCHAR(20),
					DocumentTypeId		INT
				)	

		INSERT @table(RowNum,DocumentId,UserId,SourceAddress,ReceivedDate,ImageUrl,Status,StatusId,DocumentData,ExtraInfo,Notes,DocumentType,DocumentTypeId)	
		select	ROW_NUMBER()OVER( '+@OrderClause+') RowNum,
				d.MemberDocumentId as DocumentId,
				d.UserId,
				cd.Email as SourceAddress ,		
				d.CreateDate as ReceivedDate,
				d.DocumentUrl as ImageUrl,
				ds.[Name] as Status,
				d.StatusId,
				d.DocumentData,
				d.ExtraInfo,
				d.Notes,
				dt.[Name] as DocumentType,
				d.MemberDocumentTypeId as DocumentTypeId
		from MemberDocument d
			inner join MemberDocumentStatus ds on d.StatusId = ds.Id
			inner join MemberDocumentType dt on dt.DocumentTypeId = d.MemberDocumentTypeId
			left join UserContactDetails uc on uc.userid = d.userid
			left join ContactDetails cd on cd.ContactDetailsId = uc.ContactDetailsId
		where d.StatusId = '+ cast(@StatusId as varchar(10)) +'
			and d.MemberDocumentTypeId = '+ cast(@DocTypeId as varchar(10)) +'
				
	'

	if @FromDate is not null 
		SET @SQL = @SQL +' and d.CreateDate >=''' + cast(@FromDate as nvarchar(20)) + ''''

	if @ToDate is not null
		SET @SQL = @SQL +' and d.CreateDate <= dateadd(DAY, 1, ''' + cast(@ToDate as nvarchar(20)) + ''') '

	if len(isnull(@SourceAddress,'')) > 0
		SET @SQL = @SQL +' AND cd.Email  like ''%' + @SourceAddress + '%'' '

	set @SQL = @SQL + @OrderClause

	set @SQL = @SQL + ' 
	
		SELECT @TotalCount = COUNT(1)
		FROM   @table

		DELETE @table where RowNum < '+CAST(@FirstRow AS VARCHAR(100))+'
		DELETE @table where RowNum >'+CAST( @LastRow AS VARCHAR(100))+'
			
		SELECT  DocumentId,
				UserId,
				case when ISJSON(DocumentData) = 1 then JSON_VALUE(DocumentData, ''$.ShipToAccountNo'') else '''' end AS ShipToAccountNo,
				case when ISJSON(DocumentData) = 1 then JSON_VALUE(DocumentData, ''$.FflNumber'') else '''' end AS FflNumber,
				ReceivedDate,
				SourceAddress,
				case when ISJSON(DocumentData) = 1 then JSON_VALUE(DocumentData, ''$.PremiseStreet'') else '''' end AS PremiseStreet,
				case when ISJSON(DocumentData) = 1 then JSON_VALUE(DocumentData, ''$.PremiseCity'') else '''' end AS PremiseCity,
				case when ISJSON(DocumentData) = 1 then JSON_VALUE(DocumentData, ''$.PremiseState'') else '''' end AS PremiseState,
				case when ISJSON(DocumentData) = 1 then JSON_VALUE(DocumentData, ''$.PremiseZipcode'') else '''' end AS PremiseZipcode,
				ImageUrl,
				case when ISJSON(DocumentData) = 1 then case when JSON_VALUE(DocumentData, ''$.ExpirationDate'') is not null then Cast(JSON_VALUE(DocumentData, ''$.ExpirationDate'') as datetime) else null end else null end AS ExpirationDate,
				case when ISJSON(DocumentData) = 1 then JSON_VALUE(DocumentData, ''$.AtfBizName'') else '''' end AS AtfBizName,
				Notes as InvalidReason,
				Status,
				StatusId,
				DocumentType,
				DocumentTypeId,
				ExtraInfo,
				case when ISJSON(DocumentData) = 1 then DocumentData else '''' end as DocumentData,
				@TotalCount TotalCount
		FROM	@table 
			
		'

	

	--print @SQL
	EXEC(@SQL)

	

END