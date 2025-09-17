CREATE TABLE [dbo].[Region] (
    [Id]        INT          IDENTITY (1, 1) NOT NULL,
    [Version]   INT          NOT NULL,
    [Name]      VARCHAR (50) NULL,
    [Reference] VARCHAR (50) NULL,
    [ClientId]  INT          NOT NULL,
    [Code]      VARCHAR (5)  NULL,
    CONSTRAINT [PK_Region] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FK_Region_Client] FOREIGN KEY ([ClientId]) REFERENCES [dbo].[Client] ([ClientId])
);

