CREATE TABLE [dbo].[DBVersion] (
    [ID]            INT          IDENTITY (1, 1) NOT NULL,
    [VersionNumber] VARCHAR (50) NULL,
    [CreateDate]    DATETIME     NOT NULL,
    CONSTRAINT [PK_DBVersion] PRIMARY KEY CLUSTERED ([ID] ASC) WITH (FILLFACTOR = 100)
);

