CREATE TABLE [dbo].[DeviceStatusHistory] (
    [DeviceStatusHistoryId]      INT            IDENTITY (1, 1) NOT NULL,
    [Version]                    INT            CONSTRAINT [DF_DeviceStatusHistory_Version] DEFAULT ((0)) NOT NULL,
    [DeviceId]                   NVARCHAR (25)  NULL,
    [DeviceStatusId]             INT            NOT NULL,
    [ChangeDate]                 DATETIME       NOT NULL,
    [Reason]                     NVARCHAR (150) NULL,
    [DeviceStatusTransitionType] INT            NULL,
    [ExtraInfo]                  NVARCHAR (50)  NULL,
    [UserId]                     INT            NOT NULL,
    [ActionId]                   INT            NULL,
    [DeviceTypeResult]           NVARCHAR (50)  NULL,
    [ActionResult]               BIT            NULL,
    [ActionDetail]               NVARCHAR (250) NULL,
    [OldValue]                   NVARCHAR (50)  NULL,
    [NewValue]                   NVARCHAR (50)  NULL,
    [SiteId]                     INT            NOT NULL,
    [Processed]                  INT            DEFAULT ((0)) NOT NULL,
    [DeviceIdentity]             INT            NULL,
    [OpId]                       NVARCHAR (100) NULL,
    [TerminalId]                 NVARCHAR (25)  NULL,
    CONSTRAINT [PK_DeviceStatusHistory] PRIMARY KEY CLUSTERED ([DeviceStatusHistoryId] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_DeviceStatusHistory_Device] FOREIGN KEY ([DeviceIdentity]) REFERENCES [dbo].[Device] ([Id]),
    CONSTRAINT [FK_DeviceStatusHistory_DeviceAction] FOREIGN KEY ([ActionId]) REFERENCES [dbo].[DeviceAction] ([DeviceActionId]),
    CONSTRAINT [FK_DeviceStatusHistory_DeviceStatusId] FOREIGN KEY ([DeviceStatusId]) REFERENCES [dbo].[DeviceStatus] ([DeviceStatusId]),
    CONSTRAINT [FK_Site_DeviceStatusHistory] FOREIGN KEY ([SiteId]) REFERENCES [dbo].[Site] ([SiteId]),
    CONSTRAINT [FK_User_DeviceStatusHistory] FOREIGN KEY ([UserId]) REFERENCES [dbo].[User] ([UserId])
);


GO
ALTER TABLE [dbo].[DeviceStatusHistory] ENABLE CHANGE_TRACKING WITH (TRACK_COLUMNS_UPDATED = ON);

