CREATE TABLE [dbo].[PortalSiteNavigation] (
    [Id]                 INT           IDENTITY (1, 1) NOT NULL,
    [ClientId]           INT           NOT NULL,
    [ShortName]          VARCHAR (50)  NULL,
    [DisplayName]        VARCHAR (100) NULL,
    [NavigationPath]     VARCHAR (500) NULL,
    [DisplayOrder]       INT           NOT NULL,
    [LanguageCode]       VARCHAR (3)   CONSTRAINT [DF__tmp_ms_xx__Langu__25D17A5B] DEFAULT ('en') NULL,
    [Active]             BIT           NOT NULL,
    [CreatedById]        INT           NOT NULL,
    [CreatedDateTime]    DATETIME      CONSTRAINT [DF_PortalMenu_CreatedDateTime] DEFAULT (getdate()) NOT NULL,
    [ModifiedById]       INT           NULL,
    [ModifiedDateTime]   DATETIME      NULL,
    [IconCss]            VARCHAR (150) NULL,
    [DesignType]         VARCHAR (50)  NULL,
    [NavigationPathType] VARCHAR (50)  NULL,
    [Configuration]      VARCHAR (MAX) NULL,
    CONSTRAINT [PK_PortalMenu] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FK_PortalSiteNavigation_Client] FOREIGN KEY ([ClientId]) REFERENCES [dbo].[Client] ([ClientId]),
    CONSTRAINT [FK_PortalSiteNavigationCreatedBy_User] FOREIGN KEY ([CreatedById]) REFERENCES [dbo].[User] ([UserId]),
    CONSTRAINT [FK_PortalSiteNavigationModifiedBy_User] FOREIGN KEY ([ModifiedById]) REFERENCES [dbo].[User] ([UserId])
);


GO
CREATE TRIGGER [dbo].[PortalSiteNavigation_AspNet_SqlCacheNotification_Trigger] ON [dbo].[PortalSiteNavigation]
                       FOR INSERT, UPDATE, DELETE AS BEGIN
                       SET NOCOUNT ON
                       EXEC dbo.AspNet_SqlCacheUpdateChangeIdStoredProcedure N'PortalSiteNavigation'
                       END
                       