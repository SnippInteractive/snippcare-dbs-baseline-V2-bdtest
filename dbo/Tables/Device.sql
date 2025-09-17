CREATE TABLE [dbo].[Device] (
    [Id]                   INT           IDENTITY (1, 1) NOT NULL,
    [DeviceId]             VARCHAR (25)  NULL,
    [Version]              INT           CONSTRAINT [DF_Device_Version] DEFAULT ((0)) NOT NULL,
    [DeviceStatusId]       INT           NOT NULL,
    [DeviceTypeId]         INT           NOT NULL,
    [UserId]               INT           NULL,
    [HomeSiteId]           INT           NOT NULL,
    [CreateDate]           DATETIME      NOT NULL,
    [Owner]                VARCHAR (50)  NULL,
    [Reference]            VARCHAR (500) NULL,
    [EmbossLine1]          VARCHAR (50)  NULL,
    [EmbossLine2]          VARCHAR (50)  NULL,
    [EmbossLine3]          VARCHAR (50)  NULL,
    [EmbossLine4]          VARCHAR (50)  NULL,
    [EmbossLine5]          VARCHAR (50)  NULL,
    [Pin]                  VARCHAR (4)   NULL,
    [DeviceNumberPoolId]   INT           NULL,
    [ExpirationDate]       DATETIME2 (7) NULL,
    [AccountId]            INT           NULL,
    [StartDate]            DATETIME2 (7) NULL,
    [PinFailedAttempts]    INT           CONSTRAINT [DF_Device_PinFailedAttempts] DEFAULT ((0)) NOT NULL,
    [DeviceLotId]          INT           NULL,
    [ExtraInfo]            VARCHAR (100) NULL,
    [LotSequenceNo]        VARCHAR (12)  NULL,
    [OLD_AccountID]        INT           NULL,
    [OLD_MemberID]         INT           NULL,
    [AssignedBy]           VARCHAR (100) NULL,
    [Deleted]              BIT           DEFAULT ((0)) NULL,
    [CVC]                  VARCHAR (3)   NULL,
    [PINVerificationValue] VARCHAR (5)   NULL,
    [ImageUrl]             VARCHAR (500) NULL,
    CONSTRAINT [PK_Device_1] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 95),
    CONSTRAINT [FK_Account_Device] FOREIGN KEY ([AccountId]) REFERENCES [dbo].[Account] ([AccountId]),
    CONSTRAINT [FK_Device_DeviceLot] FOREIGN KEY ([DeviceLotId]) REFERENCES [dbo].[DeviceLot] ([Id]),
    CONSTRAINT [FK_Device_DeviceStatus] FOREIGN KEY ([DeviceStatusId]) REFERENCES [dbo].[DeviceStatus] ([DeviceStatusId]),
    CONSTRAINT [FK_Device_DeviceType] FOREIGN KEY ([DeviceTypeId]) REFERENCES [dbo].[DeviceType] ([DeviceTypeId]),
    CONSTRAINT [FK_Device_Site] FOREIGN KEY ([HomeSiteId]) REFERENCES [dbo].[Site] ([SiteId]),
    CONSTRAINT [FK_Device_User] FOREIGN KEY ([UserId]) REFERENCES [dbo].[User] ([UserId]),
    CONSTRAINT [FK_DeviceNumber_Device] FOREIGN KEY ([DeviceNumberPoolId]) REFERENCES [dbo].[DeviceNumberPool] ([Id])
);


GO
ALTER TABLE [dbo].[Device] ENABLE CHANGE_TRACKING WITH (TRACK_COLUMNS_UPDATED = ON);


GO
CREATE NONCLUSTERED INDEX [Device_Account]
    ON [dbo].[Device]([AccountId] ASC)
    INCLUDE([Id]) WITH (FILLFACTOR = 95);


GO
CREATE NONCLUSTERED INDEX [Device_DeviceStatus]
    ON [dbo].[Device]([DeviceStatusId] ASC) WITH (FILLFACTOR = 95);


GO
CREATE NONCLUSTERED INDEX [Device_UserId]
    ON [dbo].[Device]([UserId] ASC) WITH (FILLFACTOR = 95);


GO
CREATE NONCLUSTERED INDEX [idx_ExtraInfo]
    ON [dbo].[Device]([ExtraInfo] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_Device_DeviceStatusId]
    ON [dbo].[Device]([DeviceStatusId] ASC);


GO
CREATE NONCLUSTERED INDEX [NonClusteredIndex-20170908-104400]
    ON [dbo].[Device]([UserId] ASC) WITH (FILLFACTOR = 95);


GO
CREATE NONCLUSTERED INDEX [IX_Device_DeviceId]
    ON [dbo].[Device]([DeviceId] ASC)
    INCLUDE([Id], [UserId]);


GO
CREATE NONCLUSTERED INDEX [IX_Device_DeviceLotId_LotSequenceNo]
    ON [dbo].[Device]([DeviceLotId] ASC, [LotSequenceNo] ASC)
    INCLUDE([DeviceStatusId]) WITH (FILLFACTOR = 95);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_DeviceId]
    ON [dbo].[Device]([DeviceId] ASC) WITH (FILLFACTOR = 95);

