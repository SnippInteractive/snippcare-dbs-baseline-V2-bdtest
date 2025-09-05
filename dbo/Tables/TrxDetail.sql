CREATE TABLE [dbo].[TrxDetail] (
    [TrxDetailID]         INT             IDENTITY (1, 1) NOT NULL,
    [Version]             INT             NOT NULL,
    [TrxID]               INT             NOT NULL,
    [LineNumber]          INT             NOT NULL,
    [ItemCode]            NVARCHAR (50)   NULL,
    [Description]         NVARCHAR (1000) NULL,
    [Anal1]               NVARCHAR (250)  NULL,
    [Anal2]               NVARCHAR (250)  NULL,
    [Anal3]               NVARCHAR (250)  NULL,
    [Anal4]               NVARCHAR (250)  NULL,
    [Quantity]            FLOAT (53)      NOT NULL,
    [Value]               MONEY           NOT NULL,
    [Points]              FLOAT (53)      NOT NULL,
    [PromotionID]         INT             NULL,
    [PromotionalValue]    MONEY           NULL,
    [EposDiscount]        MONEY           NULL,
    [LoyaltyDiscount]     MONEY           NULL,
    [AuthorisationNr]     NVARCHAR (50)   NULL,
    [status]              NVARCHAR (1)    NULL,
    [BonusPoints]         FLOAT (53)      NULL,
    [PromotionItemId]     INT             NULL,
    [VAT]                 MONEY           NULL,
    [VATPercentage]       FLOAT (53)      NULL,
    [OriginalTrxDetailId] INT             NULL,
    [Anal5]               NVARCHAR (50)   NULL,
    [Anal6]               NVARCHAR (50)   NULL,
    [Anal7]               NVARCHAR (50)   NULL,
    [Anal8]               NVARCHAR (50)   NULL,
    [Anal9]               NVARCHAR (50)   NULL,
    [Anal10]              NVARCHAR (50)   NULL,
    [HomeCurrencyCode]    NCHAR (3)       NULL,
    [ConvertedNetValue]   MONEY           NULL,
    [Anal11]              NVARCHAR (50)   NULL,
    [Anal12]              NVARCHAR (50)   NULL,
    [Anal13]              NVARCHAR (50)   NULL,
    [Anal14]              NVARCHAR (50)   NULL,
    [Anal15]              VARCHAR (50)    NULL,
    [Anal16]              VARCHAR (50)    NULL,
    CONSTRAINT [PK_TrxDetail] PRIMARY KEY CLUSTERED ([TrxDetailID] ASC) WITH (FILLFACTOR = 95, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_TrxDetail_TrxHeader] FOREIGN KEY ([TrxID]) REFERENCES [dbo].[TrxHeader] ([TrxId])
);


GO
ALTER TABLE [dbo].[TrxDetail] ENABLE CHANGE_TRACKING WITH (TRACK_COLUMNS_UPDATED = ON);


GO
CREATE NONCLUSTERED INDEX [index_trxid]
    ON [dbo].[TrxDetail]([TrxID] ASC) WITH (FILLFACTOR = 95);

