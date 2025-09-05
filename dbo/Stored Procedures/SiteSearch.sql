
CREATE PROCEDURE SiteSearch
(
	@SearchCriteria NVARCHAR(MAX) = ''
)
AS
BEGIN

	-- Validating Input parameter Whether it is in JSON format
	IF ISJSON(ISNULL(@SearchCriteria,'')) <> 1
	BEGIN
		SELECT 'InvalidCriteria' AS Result
		RETURN
	END

	-- Dropping pre-existed temp tables
	DROP TABLE IF EXISTS #SiteTypeTranslations 
	DROP TABLE IF EXISTS #SiteStatusTranslations
	DROP TABLE IF EXISTS #Site
	DROP TABLE IF EXISTS #UpdatedByUser

	-- Creating Temp tables
	CREATE TABLE #SiteTypeTranslations(SiteTypeId INT,SiteType NVARCHAR(100),Translation NVARCHAR(250))
	CREATE TABLE #SiteStatusTranslations(SiteStatusId INT,SiteStatus NVARCHAR(100),Translation NVARCHAR(250))
	CREATE TABLE #Site(SiteId INT,Name NVARCHAR(200),SiteTypeId NVARCHAR(250),SiteStatusId NVARCHAR(250),ParentId INT,UpdatedBy INT,UpdatedDate DATETIME,TotalCount INT)
	CREATE TABLE #UpdatedByUser(UserId INT, UserName NVARCHAR(100))

	DECLARE	@Name			NVARCHAR(100) ,
			@SiteType		INT,
			@SiteRef		NVARCHAR(100) = '',
			@City			NVARCHAR(100) = '',
			@SiteParent		INT = NULL,
			@ClientId		INT,
			@SortProperty	NVARCHAR(100) = '',
			@SortDirection	NVARCHAR(10) = 'ASC',
			@PageIndex		INT = 0,
			@PageSize		INT = 20,
			@Offset			INT,
			@TotalCount		INT,
			@LanguageCode	NVARCHAR(2) = 'en', --Thread.CurrentThread.CurrentUICulture.TwoLetterISOLanguageName
			@Result			NVARCHAR(MAX) = ''

	-- Extracting the search criteria values
	SELECT	@Name			=	ISNULL(JSON_VALUE(@SearchCriteria,'$.Name'),''),
			@SiteType		=	TRY_CAST(ISNULL(JSON_VALUE(@SearchCriteria,'$.SiteType'),'') AS INT),
			@SiteRef		=	ISNULL(JSON_VALUE(@SearchCriteria,'$.SiteRef'),''),
			@City			=	ISNULL(JSON_VALUE(@SearchCriteria,'$.City'),''),
			@SiteParent		=	TRY_CAST(ISNULL(JSON_VALUE(@SearchCriteria,'$.SiteParent'),'') AS INT),
			@ClientId		=	TRY_CAST(ISNULL(JSON_VALUE(@SearchCriteria,'$.ClientId'),'') AS INT),
			@PageIndex		=	TRY_CAST(ISNULL(JSON_VALUE(@SearchCriteria,'$.PageIndex'),'') AS INT),
			@PageSize		=	TRY_CAST(ISNULL(JSON_VALUE(@SearchCriteria,'$.PageSize'),'') AS INT),
			@SortProperty	=	ISNULL(JSON_VALUE(@SearchCriteria,'$.SortProperty'),''),
			@SortDirection	=	ISNULL(JSON_VALUE(@SearchCriteria,'$.SortDirection'),''),
			@LanguageCode   =   ISNULL(JSON_VALUE(@SearchCriteria,'$.Language'),'en')

	-- Validating ClientId
	IF @ClientId IS NULL
	BEGIN
		SELECT 'InvalidClient' AS Result
		RETURN
	END

	SET  @PageSize = CASE @PageSize WHEN 0 THEN 10 ELSE @PageSize END

	IF @PageIndex IS NOT NULL AND @PageSize IS NOT NULL
	BEGIN
		SET @PageIndex = @PageIndex + 1
		SET @Offset = (@PageIndex-1) * @PageSize
	END

	IF @SiteType = 0 OR @SiteType = -1
	BEGIN
		SET @SiteType = NULL
	END

	IF @SiteParent = 0 OR @SiteType = -1
	BEGIN
		SET @SiteParent = NULL
	END

	-- Preparing SiteTypeTranslations
	INSERT		#SiteTypeTranslations(SiteTypeId,SiteType,Translation)
	SELECT		st.SiteTypeId,st.Name,ISNULL(t.[Value],st.Name) as TRanslation
	FROM		SiteType  st
	LEFT JOIN   Translations t
	ON			t.TranslationGroupKey = st.Name
	WHERE		st.ClientId = @ClientId
	AND         t.TranslationGroup = 'SiteType'
	AND         t.ClientId = @ClientId
	AND         t.LanguageCode = @LanguageCode

	-- Preparing SiteStatusTranslations
	INSERT		#SiteStatusTranslations(SiteStatusId,SiteStatus,Translation)
	SELECT		st.SiteStatusId,st.Name,ISNULL(t.[Value],st.Name) as TRanslation
	FROM		SiteStatus  st
	LEFT JOIN   Translations t
	ON			t.TranslationGroupKey = st.Name
	AND         t.TranslationGroup = 'SiteStatus'
	AND         t.ClientId = @ClientId
	WHERE		st.ClientId = @ClientId
	AND         t.LanguageCode = @LanguageCode

	-- Taking the total count of the matched records based on the search
	SELECT		@TotalCount = COUNT(s.SiteId) 
	FROM		[Site] s
	LEFT JOIN	[Address] a
	ON			s.AddressId = a.AddressId
	WHERE		s.ClientId = @ClientId
	AND			s.Display = 1
	AND			(s.Name LIKE '%'+@Name+'%' OR @Name = '')
	AND			(s.ParentId = @SiteParent OR @SiteParent IS NULL)
	AND			(s.SiteTypeId = @SiteType OR @SiteType IS NULL)
	AND			(s.SiteRef LIKE '%'+@SiteRef+'%' OR @SiteRef = '')
	AND			(a.City LIKE '%'+@City+'%' OR @City = '')

	-- Fetching the sites based on the criteria
	INSERT		#Site
	(			
				SiteId,Name,SiteTypeId,SiteStatusId,
				ParentId,UpdatedBy,UpdatedDate,TotalCount
	)
	SELECT		s.SiteId,s.Name,s.SiteTypeId,s.SiteStatusId,
				s.ParentId,s.UpdatedBy,s.UpdatedDate,@TotalCount 

	FROM		[Site] s
	LEFT JOIN	[Address] a
	ON			s.AddressId = a.AddressId
	WHERE		s.ClientId = @ClientId
	AND			s.Display = 1
	AND			(s.Name LIKE '%'+@Name+'%' OR @Name = '')
	AND			(s.ParentId = @SiteParent OR @SiteParent IS NULL)
	AND			(s.SiteTypeId = @SiteType OR @SiteType IS NULL)
	AND			(s.SiteRef LIKE '%'+@SiteRef+'%' OR @SiteRef = '')
	AND			(a.City LIKE '%'+@City+'%' OR @City = '')
	ORDER BY	CASE WHEN @SortDirection = 'asc' THEN s.Name END,
				CASE WHEN @SortDirection = 'desc' THEN s.Name END DESC
	OFFSET		@Offset ROWS
	FETCH		NEXT @PageSize ROWS ONLY

	INSERT		#UpdatedByUser(UserId,UserName)
	SELECT      u.UserId,u.UserName
	FROM		[User] u
	INNER JOIN	UserType ut
	ON			u.UserTypeId = ut.UserTypeId
	WHERE		ut.ClientId = @ClientId
	AND			ut.Name IN('Admin','Helpdesk','SystemUser','SuperUser')

	-- Preparing the result as JSON
	SET @Result = CASE 
						WHEN @TotalCount > 0
						THEN
						(
							SELECT		s.SiteId,
										s.Name AS SiteName,
										st.Translation AS SiteTypeDescription,
										ss.Translation AS SiteStatusDescription,
										ps.Name AS ParentSite,
										u.UserName AS UpdatedByUserName,
										CONVERT(VARCHAR,s.UpdatedDate,101) AS UpdatedDate,
										s.TotalCount
							FROM		#Site s
							INNER JOIN  #SiteTypeTranslations st
							ON			s.SiteTypeId = st.SiteTypeId
							INNER JOIN	#SiteStatusTranslations ss
							ON			s.SiteStatusId = ss.SiteStatusId
							INNER JOIN	[Site] ps
							ON			s.ParentId = ps.SiteId
							LEFT JOIN	#UpdatedByUser u
							ON			s.UpdatedBy = u.UserId
							FOR	JSON PATH,INCLUDE_NULL_VALUES
						)
						ELSE NULL
					END

	SELECT @Result AS Result



/*
EXEC SiteSearch
'{
	"Name":"",
	"SiteType":-1,
	"SiteRef":"",
	"City":"",
	"SiteParent":0,
	"ClientId":1,
	"Language":"en",
	"PageIndex":0,
	"PageSize":10,
	"SortProperty":
	"Name",
	"SortDirection":"asc"
}'

*/


END