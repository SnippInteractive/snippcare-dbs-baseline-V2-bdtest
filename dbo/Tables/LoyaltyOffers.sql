CREATE TABLE [dbo].[LoyaltyOffers] (
    [LoyaltyOfferId]       INT                IDENTITY (1, 1) NOT NULL,
    [Name]                 VARCHAR (150)      NULL,
    [HtmlContentId]        INT                NULL,
    [VoucherHtmlContentId] INT                NULL,
    [LoyaltyProgramId]     INT                NOT NULL,
    [StartDateTime]        DATETIMEOFFSET (7) NOT NULL,
    [EndDateTime]          DATETIMEOFFSET (7) NOT NULL,
    [Version]              INT                DEFAULT ((0)) NOT NULL,
    [MaximumRedemptions]   INT                DEFAULT ((0)) NOT NULL,
    [FirstTimeReward]      BIT                DEFAULT ((0)) NOT NULL,
    [Description]          VARCHAR (1000)     NULL,
    [OfferType]            VARCHAR (50)       NULL,
    PRIMARY KEY CLUSTERED ([LoyaltyOfferId] ASC),
    CONSTRAINT [FK_LoyaltyOffers_HtmlContent] FOREIGN KEY ([HtmlContentId]) REFERENCES [dbo].[HtmlContent] ([ContentId]),
    CONSTRAINT [FK_LoyaltyOffers_HtmlContent_VoucherContent] FOREIGN KEY ([VoucherHtmlContentId]) REFERENCES [dbo].[HtmlContent] ([ContentId]),
    CONSTRAINT [FK_LoyaltyOffers_LoyaltyProgram] FOREIGN KEY ([LoyaltyProgramId]) REFERENCES [dbo].[LoyaltyProgramme] ([ProgramId])
);

