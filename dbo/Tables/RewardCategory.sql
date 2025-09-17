CREATE TABLE [dbo].[RewardCategory] (
    [RewardCategoryId] INT           IDENTITY (1, 1) NOT NULL,
    [Name]             VARCHAR (200) NULL,
    [SmallImageURL]    VARCHAR (MAX) NULL,
    [MediumImageURL]   VARCHAR (MAX) NULL,
    [Enabled]          BIT           NULL,
    [CreatedDate]      DATETIME      NULL,
    [LastUpdatedDate]  DATETIME      NULL,
    [ClientId]         INT           NOT NULL,
    CONSTRAINT [PK_RewardCategory] PRIMARY KEY CLUSTERED ([RewardCategoryId] ASC)
);

