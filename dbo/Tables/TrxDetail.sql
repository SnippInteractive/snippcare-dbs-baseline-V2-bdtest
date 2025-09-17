CREATE TABLE [dbo].[TrxDetail] (
    [TrxDetailID]         INT            IDENTITY (1, 1) NOT NULL,
    [Version]             INT            NOT NULL,
    [TrxID]               INT            NOT NULL,
    [LineNumber]          INT            NOT NULL,
    [ItemCode]            VARCHAR (50)   NULL,
    [Description]         VARCHAR (1000) NULL,
    [Anal1]               VARCHAR (250)  NULL,
    [Anal2]               VARCHAR (250)  NULL,
    [Anal3]               VARCHAR (250)  NULL,
    [Anal4]               VARCHAR (250)  NULL,
    [Quantity]            FLOAT (53)     NOT NULL,
    [Value]               MONEY          NOT NULL,
    [Points]              FLOAT (53)     NOT NULL,
    [PromotionID]         INT            NULL,
    [PromotionalValue]    MONEY          NULL,
    [EposDiscount]        MONEY          NULL,
    [LoyaltyDiscount]     MONEY          NULL,
    [AuthorisationNr]     VARCHAR (50)   NULL,
    [status]              VARCHAR (1)    NULL,
    [BonusPoints]         FLOAT (53)     NULL,
    [PromotionItemId]     INT            NULL,
    [VAT]                 MONEY          NULL,
    [VATPercentage]       FLOAT (53)     NULL,
    [OriginalTrxDetailId] INT            NULL,
    [Anal5]               VARCHAR (50)   NULL,
    [Anal6]               VARCHAR (50)   NULL,
    [Anal7]               VARCHAR (50)   NULL,
    [Anal8]               VARCHAR (50)   NULL,
    [Anal9]               VARCHAR (50)   NULL,
    [Anal10]              VARCHAR (50)   NULL,
    [HomeCurrencyCode]    NCHAR (3)      NULL,
    [ConvertedNetValue]   MONEY          NULL,
    [Anal11]              VARCHAR (50)   NULL,
    [Anal12]              VARCHAR (50)   NULL,
    [Anal13]              VARCHAR (50)   NULL,
    [Anal14]              VARCHAR (50)   NULL,
    [Anal15]              VARCHAR (50)   NULL,
    [Anal16]              VARCHAR (50)   NULL,
    CONSTRAINT [PK_TrxDetail] PRIMARY KEY CLUSTERED ([TrxDetailID] ASC) WITH (FILLFACTOR = 95, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_TrxDetail_TrxHeader] FOREIGN KEY ([TrxID]) REFERENCES [dbo].[TrxHeader] ([TrxId])
);


GO
ALTER TABLE [dbo].[TrxDetail] ENABLE CHANGE_TRACKING WITH (TRACK_COLUMNS_UPDATED = ON);


GO
CREATE NONCLUSTERED INDEX [index_trxid]
    ON [dbo].[TrxDetail]([TrxID] ASC) WITH (FILLFACTOR = 95);

