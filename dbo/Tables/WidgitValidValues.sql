CREATE TABLE [dbo].[WidgitValidValues] (
    [WidgitValidValueId] INT          IDENTITY (1, 1) NOT NULL,
    [Version]            INT          CONSTRAINT [DF_WidgitValidValues_Version] DEFAULT ((0)) NOT NULL,
    [WidgitId]           INT          NOT NULL,
    [Value]              VARCHAR (20) NULL,
    [TranslationCode]    VARCHAR (30) NULL,
    CONSTRAINT [PK_WidgitValidValues] PRIMARY KEY CLUSTERED ([WidgitValidValueId] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_WidgitValidValues_Widgit] FOREIGN KEY ([WidgitId]) REFERENCES [dbo].[Widgit] ([WidgitId])
);

