CREATE TABLE [dbo].[PromotionItem] (
    [Id]                   INT           IDENTITY (1, 1) NOT NULL,
    [Version]              INT           CONSTRAINT [DF__PromotionItem_Version] DEFAULT ((0)) NOT NULL,
    [PromotionId]          INT           NOT NULL,
    [PromotionItemTypeId]  INT           NOT NULL,
    [Code]                 VARCHAR (150) NULL,
    [FilterType]           INT           NULL,
    [Quantity]             INT           NULL,
    [ItemIncludeExclude]   VARCHAR (25)  NULL,
    [PromotionItemGroupId] INT           NULL,
    [LogicalAnd]           BIT           NULL,
    [Mode]                 VARCHAR (20)  CONSTRAINT [DF__PromotionI__Mode__410F807C] DEFAULT ('') NULL,
    CONSTRAINT [PK__PromotionItem] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK__PromotionItem_Client] FOREIGN KEY ([PromotionItemTypeId]) REFERENCES [dbo].[PromotionItemType] ([Id])
);


GO
CREATE NONCLUSTERED INDEX [IX_PormotionItem]
    ON [dbo].[PromotionItem]([Id] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [IX_ItemCode]
    ON [dbo].[PromotionItem]([Code] ASC) WITH (FILLFACTOR = 100);

