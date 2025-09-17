CREATE TABLE [dbo].[SiteAuthentication] (
    [Id]     INT           IDENTITY (1, 1) NOT NULL,
    [Name]   VARCHAR (MAX) NULL,
    [ApiKey] VARCHAR (MAX) NULL,
    [Secret] VARCHAR (MAX) NULL,
    [SiteId] INT           NOT NULL,
    CONSTRAINT [FK_ClientAuthentication_Site] FOREIGN KEY ([SiteId]) REFERENCES [dbo].[Site] ([SiteId])
);

