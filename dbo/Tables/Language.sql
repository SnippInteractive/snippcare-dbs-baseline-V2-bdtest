CREATE TABLE [dbo].[Language] (
    [LanguageId]   INT          IDENTITY (1, 1) NOT NULL,
    [Version]      INT          CONSTRAINT [DF_Language_Version] DEFAULT ((0)) NOT NULL,
    [Name]         VARCHAR (80) NULL,
    [LanguageCode] VARCHAR (10) NULL,
    [ClientId]     INT          CONSTRAINT [DF_Language_ClientId] DEFAULT ((1)) NOT NULL,
    [DisplayOrder] INT          NULL,
    [Display]      BIT          CONSTRAINT [DF_Language_Display] DEFAULT ((1)) NOT NULL,
    CONSTRAINT [PK_Language] PRIMARY KEY CLUSTERED ([LanguageId] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_Language_ClientId] FOREIGN KEY ([ClientId]) REFERENCES [dbo].[Client] ([ClientId])
);


GO
CREATE TRIGGER [dbo].[language_AspNet_SqlCacheNotification_Trigger] ON [dbo].[language]
                       FOR INSERT, UPDATE, DELETE AS BEGIN
                       SET NOCOUNT ON
                       EXEC dbo.AspNet_SqlCacheUpdateChangeIdStoredProcedure N'language'
                       END
                       