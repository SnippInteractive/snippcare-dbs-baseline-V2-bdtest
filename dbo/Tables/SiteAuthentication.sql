CREATE TABLE [dbo].[SiteAuthentication] (
    [Id]     INT            IDENTITY (1, 1) NOT NULL,
    [Name]   NVARCHAR (MAX) NULL,
    [ApiKey] NVARCHAR (MAX) NULL,
    [Secret] NVARCHAR (MAX) NULL,
    [SiteId] INT            NOT NULL,
    CONSTRAINT [FK_ClientAuthentication_Site] FOREIGN KEY ([SiteId]) REFERENCES [dbo].[Site] ([SiteId])
);

