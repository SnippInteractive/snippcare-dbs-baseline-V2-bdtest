CREATE TABLE [dbo].[Translations] (
    [TranslationId]       INT           IDENTITY (1, 1) NOT NULL,
    [Version]             INT           CONSTRAINT [DF_Translations_Version] DEFAULT ((0)) NOT NULL,
    [ClientId]            INT           NULL,
    [TranslationGroup]    VARCHAR (200) NULL,
    [LanguageCode]        VARCHAR (2)   NULL,
    [Value]               VARCHAR (MAX) NULL,
    [TranslationGroupKey] VARCHAR (100) NULL,
    [UserEdited]          BIT           CONSTRAINT [DF_Translations_UserEdited] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_Translations] PRIMARY KEY CLUSTERED ([TranslationId] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [uc_Client_Group_Key_Lang] UNIQUE NONCLUSTERED ([ClientId] ASC, [TranslationGroup] ASC, [LanguageCode] ASC, [TranslationGroupKey] ASC) WITH (FILLFACTOR = 100)
);


GO
CREATE TRIGGER [dbo].[Translations_AspNet_SqlCacheNotification_Trigger] ON [dbo].[Translations]
                       FOR INSERT, UPDATE, DELETE AS BEGIN
                       SET NOCOUNT ON
                       EXEC dbo.AspNet_SqlCacheUpdateChangeIdStoredProcedure N'Translations'
                       END
                       