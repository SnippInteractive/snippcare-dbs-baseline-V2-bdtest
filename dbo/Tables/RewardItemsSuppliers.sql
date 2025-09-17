CREATE TABLE [dbo].[RewardItemsSuppliers] (
    [RewardItemsSuppliersID] INT           IDENTITY (1, 1) NOT NULL,
    [ExternalReference]      VARCHAR (50)  NULL,
    [Name]                   VARCHAR (500) NULL,
    [Enabled]                BIT           NULL,
    [CreatedDate]            DATETIME      NULL,
    [LastUpdatedDate]        DATETIME      NULL,
    [ClientId]               INT           NOT NULL,
    CONSTRAINT [PK_RewardItemsSuppliers] PRIMARY KEY CLUSTERED ([RewardItemsSuppliersID] ASC)
);

