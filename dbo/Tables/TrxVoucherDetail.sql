﻿CREATE TABLE [dbo].[TrxVoucherDetail] (
    [TrxDetailId]   INT             NOT NULL,
    [TrxVoucherId]  VARCHAR (25)    NULL,
    [Version]       INT             CONSTRAINT [DF_TrxVoucherDetail_Version] DEFAULT ((0)) NOT NULL,
    [VoucherAmount] DECIMAL (10, 2) NULL,
    [Id]            INT             IDENTITY (1, 1) NOT NULL,
    [DeviceId]      INT             NULL,
    CONSTRAINT [PK_TrxVoucherDetail_1] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_TrxVoucherDetail_Device] FOREIGN KEY ([DeviceId]) REFERENCES [dbo].[Device] ([Id]),
    CONSTRAINT [FK_TrxVoucherDetail_TrxDetailId] FOREIGN KEY ([TrxDetailId]) REFERENCES [dbo].[TrxDetail] ([TrxDetailID])
);


GO
ALTER TABLE [dbo].[TrxVoucherDetail] ENABLE CHANGE_TRACKING WITH (TRACK_COLUMNS_UPDATED = ON);

