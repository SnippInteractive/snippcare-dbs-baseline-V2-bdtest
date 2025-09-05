CREATE TABLE [dbo].[ReceiptHeader] (
    [ReceiptHeaderId] INT                IDENTITY (1, 1) NOT NULL,
    [Date]            DATETIMEOFFSET (7) NOT NULL,
    [Retailer]        VARCHAR (100)      NULL,
    [PostCode]        VARCHAR (20)       NULL,
    [ReceiptTrans]    UNIQUEIDENTIFIER   NOT NULL,
    [TotalPrice]      MONEY              NOT NULL,
    [ReceiptId]       INT                NOT NULL,
    PRIMARY KEY CLUSTERED ([ReceiptHeaderId] ASC),
    FOREIGN KEY ([ReceiptId]) REFERENCES [dbo].[Receipt] ([ReceiptId])
);

