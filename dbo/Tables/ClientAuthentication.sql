CREATE TABLE [dbo].[ClientAuthentication] (
    [Id]       INT           IDENTITY (1, 1) NOT NULL,
    [ApiKey]   VARCHAR (MAX) NULL,
    [Secret]   VARCHAR (MAX) NULL,
    [ClientId] INT           NOT NULL,
    [Name]     VARCHAR (50)  NULL,
    CONSTRAINT [FK_ClientAuthentication_Client] FOREIGN KEY ([ClientId]) REFERENCES [dbo].[Client] ([ClientId])
);

