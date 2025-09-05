create PROCEDURE [dbo].[GetSites]
(
	@ClientId				INT,
	@IsActiveOnly			BIT=0,
	@ParentSiteId			INT,
	@DisplayOnlyParentSite	BIT=0
)
AS
BEGIN

	IF @IsActiveOnly = 1
	BEGIN
		SELECT s.SiteId,s.[Name],s.SiteRef,ss.[Name] as Status,s.Display 
		FROM [Site] s
			inner join SiteStatus ss on s.SiteStatusId = ss.SiteStatusId
		WHERE s.Clientid=@ClientId
			AND ss.[Name] = 'Active'
			AND s.Display = 1
	END
	ELSE 
	BEGIN
		SELECT s.SiteId,s.[Name],s.SiteRef,ss.[Name] as Status,s.Display 
		FROM [Site] s
			inner join SiteStatus ss on s.SiteStatusId = ss.SiteStatusId
		WHERE s.Clientid=@ClientId
			AND s.Display = 1
	END


END