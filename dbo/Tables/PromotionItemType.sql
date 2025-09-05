CREATE TABLE [dbo].[PromotionItemType] (
    [Id]       INT           IDENTITY (1, 1) NOT NULL,
    [Version]  INT           CONSTRAINT [DF__PromotionItemType_Version] DEFAULT ((0)) NOT NULL,
    [Name]     NVARCHAR (50) NULL,
    [ClientId] INT           NOT NULL,
    [Display]  BIT           CONSTRAINT [DF_PromotionItemType_Display] DEFAULT ((1)) NOT NULL,
    CONSTRAINT [PK__PromotionItemType] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK__PromotionItemType__Client] FOREIGN KEY ([ClientId]) REFERENCES [dbo].[Client] ([ClientId])
);

