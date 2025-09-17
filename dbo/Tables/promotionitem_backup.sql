CREATE TABLE [dbo].[promotionitem_backup] (
    [Id]                   INT           IDENTITY (1, 1) NOT NULL,
    [Version]              INT           NOT NULL,
    [PromotionId]          INT           NOT NULL,
    [PromotionItemTypeId]  INT           NOT NULL,
    [Code]                 VARCHAR (150) NULL,
    [FilterType]           INT           NULL,
    [Quantity]             INT           NULL,
    [ItemIncludeExclude]   VARCHAR (25)  NULL,
    [PromotionItemGroupId] INT           NULL,
    [LogicalAnd]           BIT           NULL,
    [Mode]                 VARCHAR (20)  NULL
);

