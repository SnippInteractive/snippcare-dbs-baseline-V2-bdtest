CREATE TABLE [dbo].[receiptimageurl] (
    [ReceiptImageUrlId] INT            IDENTITY (1, 1) NOT NULL,
    [Url]               VARCHAR (2048) NULL,
    [MimeType]          VARCHAR (50)   NULL,
    [ReceiptId]         INT            NOT NULL,
    PRIMARY KEY CLUSTERED ([ReceiptImageUrlId] ASC),
    FOREIGN KEY ([ReceiptId]) REFERENCES [dbo].[Receipt] ([ReceiptId])
);

