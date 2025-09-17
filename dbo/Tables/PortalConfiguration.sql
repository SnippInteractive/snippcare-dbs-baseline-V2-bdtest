CREATE TABLE [dbo].[PortalConfiguration] (
    [Id]                     INT           IDENTITY (1, 1) NOT NULL,
    [PortalSiteNavigationId] INT           NOT NULL,
    [ClientId]               INT           NOT NULL,
    [Config]                 VARCHAR (MAX) NULL,
    [LanguageCode]           VARCHAR (3)   CONSTRAINT [DF__tmp_ms_xx__Langu__2200E977] DEFAULT ('en') NULL,
    [CreatedById]            INT           NOT NULL,
    [CreatedDateTime]        DATETIME      CONSTRAINT [DF_PortalConfiguration_CreatedDateTime] DEFAULT (getdate()) NOT NULL,
    [ModifiedById]           INT           NULL,
    [ModifiedDateTime]       DATETIME      NULL,
    CONSTRAINT [PK_PortalConfiguration] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FK_PortalConfiguration_CreatedByUser] FOREIGN KEY ([CreatedById]) REFERENCES [dbo].[User] ([UserId]),
    CONSTRAINT [FK_PortalConfiguration_ModifiedByUser] FOREIGN KEY ([ModifiedById]) REFERENCES [dbo].[User] ([UserId]),
    CONSTRAINT [FK_PortalConfiguration_PortalConfiguration] FOREIGN KEY ([ClientId]) REFERENCES [dbo].[Client] ([ClientId])
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'a json string', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PortalConfiguration', @level2type = N'COLUMN', @level2name = N'Config';

