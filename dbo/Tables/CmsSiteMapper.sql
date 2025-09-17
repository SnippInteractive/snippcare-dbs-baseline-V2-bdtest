CREATE TABLE [dbo].[CmsSiteMapper] (
    [Id]            INT           IDENTITY (1, 1) NOT NULL,
    [SiteId]        INT           NOT NULL,
    [DisplayName]   VARCHAR (30)  NULL,
    [LanguageId]    INT           NOT NULL,
    [Configuration] VARCHAR (MAX) NULL,
    [Display]       BIT           NULL,
    PRIMARY KEY CLUSTERED ([Id] ASC),
    FOREIGN KEY ([LanguageId]) REFERENCES [dbo].[Language] ([LanguageId]),
    FOREIGN KEY ([SiteId]) REFERENCES [dbo].[Site] ([SiteId])
);


GO
CREATE TRIGGER [dbo].[CmsSiteMapper_AspNet_SqlCacheNotification_Trigger] ON [dbo].[CmsSiteMapper]
                       FOR INSERT, UPDATE, DELETE AS BEGIN
                       SET NOCOUNT ON
                       EXEC dbo.AspNet_SqlCacheUpdateChangeIdStoredProcedure N'CmsSiteMapper'
                       END
                       