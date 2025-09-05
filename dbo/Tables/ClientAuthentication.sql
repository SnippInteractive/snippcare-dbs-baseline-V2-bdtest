CREATE TABLE [dbo].[ClientAuthentication] (
    [Id]       INT            IDENTITY (1, 1) NOT NULL,
    [ApiKey]   NVARCHAR (MAX) NULL,
    [Secret]   NVARCHAR (MAX) NULL,
    [ClientId] INT            NOT NULL,
    [Name]     NVARCHAR (50)  NULL,
    CONSTRAINT [FK_ClientAuthentication_Client] FOREIGN KEY ([ClientId]) REFERENCES [dbo].[Client] ([ClientId])
);

