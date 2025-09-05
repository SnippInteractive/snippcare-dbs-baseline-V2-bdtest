CREATE TABLE [dbo].[ClassicalVoucherRedemptionCount] (
    [Id]                 INT          IDENTITY (1, 1) NOT NULL,
    [MemberId]           INT          NULL,
    [VoucherId]          VARCHAR (50) NULL,
    [LastRedemptionDate] DATETIME     NULL,
    [TrxId]              INT          NULL,
    CONSTRAINT [PK_ClassicalVoucherRedemptionCount] PRIMARY KEY CLUSTERED ([Id] ASC)
);

