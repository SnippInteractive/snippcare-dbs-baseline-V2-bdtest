CREATE TABLE [dbo].[ContentType] (
    [ContentTypeId] INT          IDENTITY (1, 1) NOT NULL,
    [Version]       INT          CONSTRAINT [DF_ContentType_Version] DEFAULT ((0)) NOT NULL,
    [Name]          VARCHAR (50) NULL,
    [ClientId]      INT          NOT NULL,
    CONSTRAINT [PK_ContentType] PRIMARY KEY CLUSTERED ([ContentTypeId] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_ContentType_ClientId] FOREIGN KEY ([ClientId]) REFERENCES [dbo].[Client] ([ClientId])
);

