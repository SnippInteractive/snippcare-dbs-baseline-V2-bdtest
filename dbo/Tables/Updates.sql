CREATE TABLE [dbo].[Updates] (
    [UpdateId]    INT           IDENTITY (1, 1) NOT NULL,
    [SiteId]      INT           NOT NULL,
    [Type]        VARCHAR (20)  NULL,
    [Title]       VARCHAR (MAX) NULL,
    [Description] VARCHAR (MAX) NULL,
    [Content]     VARCHAR (MAX) NULL,
    [Price]       DECIMAL (18)  NULL,
    [Image]       VARCHAR (MAX) NULL,
    [DateAdded]   DATETIME      NOT NULL,
    [ValidFrom]   DATETIME      NOT NULL,
    [ValidTo]     DATETIME      NOT NULL,
    CONSTRAINT [FK_Updates_Site] FOREIGN KEY ([SiteId]) REFERENCES [dbo].[Site] ([SiteId])
);

