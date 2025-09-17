CREATE TABLE [dbo].[Translations_backup20201125] (
    [TranslationId]       INT           IDENTITY (1, 1) NOT NULL,
    [Version]             INT           NOT NULL,
    [ClientId]            INT           NULL,
    [TranslationGroup]    VARCHAR (200) NULL,
    [LanguageCode]        VARCHAR (2)   NULL,
    [Value]               VARCHAR (MAX) NULL,
    [TranslationGroupKey] VARCHAR (100) NULL,
    [UserEdited]          BIT           NOT NULL
);

