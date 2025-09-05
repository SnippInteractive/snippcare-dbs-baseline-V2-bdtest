CREATE TABLE [dbo].[ExportJoins] (
    [TableName]      VARCHAR (50)   COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [TableJoin]      VARCHAR (2000) NULL,
    [DependantTable] VARCHAR (50)   NULL,
    CONSTRAINT [PK_ExportJoins] PRIMARY KEY CLUSTERED ([TableName] ASC) WITH (FILLFACTOR = 100)
);

