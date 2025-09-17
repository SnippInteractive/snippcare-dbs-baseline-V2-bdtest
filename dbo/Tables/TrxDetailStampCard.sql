CREATE TABLE [dbo].[TrxDetailStampCard] (
    [Id]               INT        IDENTITY (1, 1) NOT NULL,
    [Version]          INT        DEFAULT ((0)) NOT NULL,
    [PromotionId]      INT        NOT NULL,
    [TrxDetailId]      INT        NOT NULL,
    [ValueUsed]        FLOAT (53) NULL,
    [PunchTrXType]     INT        NULL,
    [ChildPromotionId] INT        NULL,
    [ChildPunch]       FLOAT (53) NULL,
    CONSTRAINT [PK_TrxDetailStampCard] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_TrxDetailStampCard_TrxDetail] FOREIGN KEY ([TrxDetailId]) REFERENCES [dbo].[TrxDetail] ([TrxDetailID])
);

