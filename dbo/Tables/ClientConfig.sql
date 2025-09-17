CREATE TABLE [dbo].[ClientConfig] (
    [Id]           INT           IDENTITY (1, 1) NOT NULL,
    [Version]      INT           CONSTRAINT [DF_ClientConfig_Version] DEFAULT ((0)) NOT NULL,
    [ClientId]     INT           NOT NULL,
    [Key]          VARCHAR (50)  NULL,
    [Value]        VARCHAR (MAX) NULL,
    [LanguageCode] VARCHAR (3)   CONSTRAINT [DF__ClientCon__Langu__2D729C23] DEFAULT ('all') NULL,
    [Environment]  VARCHAR (10)  CONSTRAINT [DF__ClientCon__Envir__2E66C05C] DEFAULT ('all') NULL,
    CONSTRAINT [PK_ClientConfig] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FK_ClientConfig_Client] FOREIGN KEY ([ClientId]) REFERENCES [dbo].[Client] ([ClientId]),
    CONSTRAINT [FK_ClientConfig_ClientConfig] FOREIGN KEY ([Id]) REFERENCES [dbo].[ClientConfig] ([Id]),
    CONSTRAINT [IX_ClientConfig] UNIQUE NONCLUSTERED ([Key] ASC, [ClientId] ASC, [LanguageCode] ASC, [Environment] ASC)
);


GO
CREATE TRIGGER [dbo].[ClientConfig_AspNet_SqlCacheNotification_Trigger] ON [dbo].[ClientConfig]
                       FOR INSERT, UPDATE, DELETE AS BEGIN
                       SET NOCOUNT ON
                       EXEC dbo.AspNet_SqlCacheUpdateChangeIdStoredProcedure N'ClientConfig'
                       END
                       