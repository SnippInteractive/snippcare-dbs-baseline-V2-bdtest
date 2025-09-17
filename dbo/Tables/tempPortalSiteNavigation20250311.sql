CREATE TABLE [dbo].[tempPortalSiteNavigation20250311] (
    [Id]                 INT           IDENTITY (1, 1) NOT NULL,
    [ClientId]           INT           NOT NULL,
    [ShortName]          VARCHAR (50)  NULL,
    [DisplayName]        VARCHAR (100) NULL,
    [NavigationPath]     VARCHAR (500) NULL,
    [DisplayOrder]       INT           NOT NULL,
    [LanguageCode]       VARCHAR (3)   NULL,
    [Active]             BIT           NOT NULL,
    [CreatedById]        INT           NOT NULL,
    [CreatedDateTime]    DATETIME      NOT NULL,
    [ModifiedById]       INT           NULL,
    [ModifiedDateTime]   DATETIME      NULL,
    [IconCss]            VARCHAR (150) NULL,
    [DesignType]         VARCHAR (50)  NULL,
    [NavigationPathType] VARCHAR (50)  NULL,
    [Configuration]      VARCHAR (MAX) NULL
);

