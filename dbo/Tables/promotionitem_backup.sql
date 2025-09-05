CREATE TABLE [dbo].[promotionitem_backup] (
    [Id]                   INT            IDENTITY (1, 1) NOT NULL,
    [Version]              INT            NOT NULL,
    [PromotionId]          INT            NOT NULL,
    [PromotionItemTypeId]  INT            NOT NULL,
    [Code]                 NVARCHAR (150) NULL,
    [FilterType]           INT            NULL,
    [Quantity]             INT            NULL,
    [ItemIncludeExclude]   NVARCHAR (25)  NULL,
    [PromotionItemGroupId] INT            NULL,
    [LogicalAnd]           BIT            NULL,
    [Mode]                 NVARCHAR (20)  NULL
);

