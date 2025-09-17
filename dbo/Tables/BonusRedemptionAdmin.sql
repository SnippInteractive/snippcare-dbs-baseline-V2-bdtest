CREATE TABLE [dbo].[BonusRedemptionAdmin] (
    [Id]         INT           IDENTITY (1, 1) NOT NULL,
    [Version]    INT           NOT NULL,
    [SiteId]     INT           NOT NULL,
    [Type]       INT           NOT NULL,
    [Coupon1]    INT           NOT NULL,
    [Voucher1]   INT           NULL,
    [OfferText1] VARCHAR (250) NULL,
    [Coupon2]    INT           NULL,
    [Voucher2]   INT           NULL,
    [OfferText2] VARCHAR (250) NULL,
    [Coupon3]    INT           NULL,
    [Promotion3] INT           NULL,
    [Coupon4]    INT           NULL,
    [Promotion4] INT           NULL,
    [OfferText4] VARCHAR (250) NULL,
    CONSTRAINT [PK_BonusRedemptionAdmin] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FK_BonusRedemptionAdmin_Site] FOREIGN KEY ([SiteId]) REFERENCES [dbo].[Site] ([SiteId])
);

