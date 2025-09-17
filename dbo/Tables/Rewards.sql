CREATE TABLE [dbo].[Rewards] (
    [Id]                      INT           IDENTITY (1, 1) NOT NULL,
    [RewardId]                INT           NOT NULL,
    [Name]                    VARCHAR (50)  NULL,
    [Description]             VARCHAR (MAX) NULL,
    [TemplateCode]            VARCHAR (50)  NULL,
    [MonetaryValue]           DECIMAL (18)  NULL,
    [DeviceProfileTemplateId] INT           NULL,
    [PointsCost]              DECIMAL (18)  NULL,
    [AssetId]                 VARCHAR (50)  NULL,
    [ImagePath]               VARCHAR (MAX) NULL,
    [SiteId]                  INT           NULL,
    [Category]                VARCHAR (10)  NULL,
    [Brand]                   VARCHAR (50)  NULL,
    [StartDate]               DATETIME      NULL,
    [ExpirationDate]          DATETIME      NULL,
    [Instructions]            VARCHAR (MAX) NULL,
    [WalletDescription]       VARCHAR (50)  NULL,
    CONSTRAINT [PK_Rewards] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FK_Rewards_DeviceProfileTemplate] FOREIGN KEY ([DeviceProfileTemplateId]) REFERENCES [dbo].[DeviceProfileTemplate] ([Id]),
    CONSTRAINT [FK_Rewards_Site] FOREIGN KEY ([SiteId]) REFERENCES [dbo].[Site] ([SiteId])
);

