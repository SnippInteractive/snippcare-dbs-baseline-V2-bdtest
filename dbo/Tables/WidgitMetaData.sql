CREATE TABLE [dbo].[WidgitMetaData] (
    [WidgitMetaDataId] INT           IDENTITY (1, 1) NOT NULL,
    [WidgitId]         INT           NOT NULL,
    [Version]          INT           CONSTRAINT [DF_WidgitMetaData_Version] DEFAULT ((0)) NOT NULL,
    [Key]              VARCHAR (100) NULL,
    [Value]            VARCHAR (255) NULL,
    CONSTRAINT [PK_WidgitMetaData] PRIMARY KEY CLUSTERED ([WidgitMetaDataId] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_WidgitMetaData_Widgit] FOREIGN KEY ([WidgitId]) REFERENCES [dbo].[Widgit] ([WidgitId])
);

