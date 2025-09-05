CREATE TABLE [dbo].[TranslationCopy] (
    [TranslationId]       INT            IDENTITY (1, 1) NOT NULL,
    [Version]             INT            NOT NULL,
    [ClientId]            INT            NOT NULL,
    [TranslationGroup]    NVARCHAR (100) NULL,
    [LanguageCode]        NVARCHAR (2)   NULL,
    [Value]               NVARCHAR (MAX) NULL,
    [TranslationGroupKey] NVARCHAR (100) NULL,
    PRIMARY KEY CLUSTERED ([TranslationId] ASC)
);

