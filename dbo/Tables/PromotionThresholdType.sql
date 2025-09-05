CREATE TABLE [dbo].[PromotionThresholdType] (
    [Id]       INT           IDENTITY (1, 1) NOT NULL,
    [Name]     NVARCHAR (50) NULL,
    [ClientId] INT           NOT NULL,
    [Version]  INT           DEFAULT ((0)) NOT NULL,
    [Display]  BIT           DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK__PromotionThresholdType] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FK_PromotionThresholdType_Client] FOREIGN KEY ([ClientId]) REFERENCES [dbo].[Client] ([ClientId])
);

