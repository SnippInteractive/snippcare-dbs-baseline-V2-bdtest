CREATE TABLE [dbo].[TrxHeader] (
    [TrxId]                INT                IDENTITY (1, 1) NOT NULL,
    [Version]              INT                CONSTRAINT [DF_TrxHeader_Version] DEFAULT ((0)) NOT NULL,
    [DeviceId]             VARCHAR (25)       NULL,
    [TrxTypeId]            INT                NOT NULL,
    [TrxDate]              DATETIMEOFFSET (7) NOT NULL,
    [ClientId]             INT                NULL,
    [SiteId]               INT                NULL,
    [TerminalId]           VARCHAR (25)       NULL,
    [Reference]            NVARCHAR (50)      NULL,
    [OpId]                 VARCHAR (100)      NULL,
    [TrxStatusTypeId]      INT                NULL,
    [CreateDate]           DATETIME           CONSTRAINT [DF_TrxHeader_CreateDate] DEFAULT (getdate()) NOT NULL,
    [TerminalDescription]  VARCHAR (100)      NULL,
    [BatchId]              VARCHAR (100)      NULL,
    [Batch_Urn]            VARCHAR (100)      NULL,
    [TrxCommitDate]        DATETIMEOFFSET (7) NULL,
    [InitialTransaction]   INT                NULL,
    [DeviceIdentity]       INT                NULL,
    [CallContextId]        UNIQUEIDENTIFIER   NULL,
    [TerminalExtra]        VARCHAR (100)      NULL,
    [AccountCashBalance]   FLOAT (53)         NULL,
    [AccountPointsBalance] FLOAT (53)         NULL,
    [ImportUniqueId]       VARCHAR (50)       NULL,
    [EposTrxId]            BIGINT             NULL,
    [TerminalExtra2]       VARCHAR (MAX)      NULL,
    [TerminalExtra3]       VARCHAR (1000)     NULL,
    [MemberId]             INT                NULL,
    [TotalPoints]          FLOAT (53)         NULL,
    [OLD_TrxId]            INT                NULL,
    [LastUpdatedDate]      DATETIMEOFFSET (7) NULL,
    [IsAnonymous]          BIT                NULL,
    [ReservationId]        INT                NULL,
    [IsTransferred]        BIT                NULL,
    [ReceiptId]            INT                NULL,
    [Region]               VARCHAR (100)      NULL,
    [Location]             VARCHAR (100)      NULL,
    CONSTRAINT [PK_TrxHeader] PRIMARY KEY CLUSTERED ([TrxId] ASC) WITH (FILLFACTOR = 95),
    FOREIGN KEY ([ReceiptId]) REFERENCES [dbo].[Receipt] ([ReceiptId]),
    FOREIGN KEY ([ReservationId]) REFERENCES [dbo].[Reservation] ([ReservationId]),
    CONSTRAINT [FK_TrxHeader_ClientId] FOREIGN KEY ([ClientId]) REFERENCES [dbo].[Client] ([ClientId]),
    CONSTRAINT [FK_TrxHeader_Device] FOREIGN KEY ([DeviceIdentity]) REFERENCES [dbo].[Device] ([Id]),
    CONSTRAINT [FK_TrxHeader_SiteId] FOREIGN KEY ([SiteId]) REFERENCES [dbo].[Site] ([SiteId]),
    CONSTRAINT [FK_TrxHeader_TrxHeader] FOREIGN KEY ([InitialTransaction]) REFERENCES [dbo].[TrxHeader] ([TrxId]),
    CONSTRAINT [FK_TrxHeader_TrxHeader_DeviceId] FOREIGN KEY ([DeviceId]) REFERENCES [dbo].[Device] ([DeviceId]),
    CONSTRAINT [FK_TrxHeader_TrxStatusType] FOREIGN KEY ([TrxStatusTypeId]) REFERENCES [dbo].[TrxStatus] ([TrxStatusId]),
    CONSTRAINT [FK_TrxHeader_TrxType] FOREIGN KEY ([TrxTypeId]) REFERENCES [dbo].[TrxType] ([TrxTypeId])
);


GO
ALTER TABLE [dbo].[TrxHeader] ENABLE CHANGE_TRACKING WITH (TRACK_COLUMNS_UPDATED = ON);


GO
CREATE NONCLUSTERED INDEX [DeviceId]
    ON [dbo].[TrxHeader]([DeviceId] ASC) WITH (FILLFACTOR = 95);


GO
CREATE NONCLUSTERED INDEX [idx_BatchID]
    ON [dbo].[TrxHeader]([BatchId] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_Reference]
    ON [dbo].[TrxHeader]([Reference] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_terminalextra3]
    ON [dbo].[TrxHeader]([TerminalExtra3] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_DeviceIdentity]
    ON [dbo].[TrxHeader]([DeviceIdentity] DESC) WITH (FILLFACTOR = 95);


GO
CREATE NONCLUSTERED INDEX [IX_MemberId]
    ON [dbo].[TrxHeader]([MemberId] DESC) WITH (FILLFACTOR = 95);


GO
CREATE NONCLUSTERED INDEX [idx_trxTypewithRef]
    ON [dbo].[TrxHeader]([TrxTypeId] ASC)
    INCLUDE([Reference]);


GO
CREATE NONCLUSTERED INDEX [TrxDate_DeviceIdentity]
    ON [dbo].[TrxHeader]([TrxDate] ASC)
    INCLUDE([DeviceIdentity]) WITH (FILLFACTOR = 95);


GO
CREATE NONCLUSTERED INDEX [IX_SiteStatusType]
    ON [dbo].[TrxHeader]([SiteId] ASC, [TrxStatusTypeId] ASC, [TrxTypeId] ASC)
    INCLUDE([AccountCashBalance], [AccountPointsBalance], [DeviceId], [OpId], [Reference], [TerminalExtra], [TerminalId], [TrxDate], [TrxId]) WITH (FILLFACTOR = 95);

