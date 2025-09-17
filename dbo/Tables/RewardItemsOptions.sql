CREATE TABLE [dbo].[RewardItemsOptions] (
    [RewardItemOptionId]            INT           IDENTITY (1, 1) NOT NULL,
    [OptionId]                      INT           NULL,
    [RewardItemId]                  INT           NOT NULL,
    [RewardItemOptionName]          VARCHAR (500) NULL,
    [SupplierRewardOptionReference] VARCHAR (20)  NULL,
    [RewardCostPrice]               DECIMAL (18)  NULL,
    [RewardPointsValue]             INT           NULL,
    [RewardCurrency]                INT           NULL,
    [QuantityAvailable]             INT           NULL,
    [QuantityRedeemed]              INT           NULL,
    [Attributes]                    VARCHAR (MAX) NULL,
    [Tags]                          VARCHAR (MAX) NULL,
    [SmallImageURL]                 VARCHAR (MAX) NULL,
    [MediumImageURL]                VARCHAR (MAX) NULL,
    [LargeImageURL]                 VARCHAR (MAX) NULL,
    [Enabled]                       BIT           NULL,
    [CreatedDate]                   DATETIME      NULL,
    [LastUpdatedDate]               DATETIME      NULL,
    CONSTRAINT [PK_RewardItemsOptions] PRIMARY KEY CLUSTERED ([RewardItemOptionId] ASC),
    CONSTRAINT [FK_RewardItemsOptions_RewardItems] FOREIGN KEY ([RewardItemId]) REFERENCES [dbo].[RewardItems] ([RewardItemId])
);

