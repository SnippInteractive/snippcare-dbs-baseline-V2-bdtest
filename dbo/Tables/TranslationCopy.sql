CREATE TABLE [dbo].[TranslationCopy] (
    [TranslationId]       INT           IDENTITY (1, 1) NOT NULL,
    [Version]             INT           NOT NULL,
    [ClientId]            INT           NOT NULL,
    [TranslationGroup]    VARCHAR (100) NULL,
    [LanguageCode]        VARCHAR (2)   NULL,
    [Value]               VARCHAR (MAX) NULL,
    [TranslationGroupKey] VARCHAR (100) NULL,
    PRIMARY KEY CLUSTERED ([TranslationId] ASC)
);

