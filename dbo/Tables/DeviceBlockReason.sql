CREATE TABLE [dbo].[DeviceBlockReason] (
    [DeviceBlockReasonId] INT          IDENTITY (1, 1) NOT NULL,
    [Version]             INT          CONSTRAINT [DF_DeviceBlockReason_Version] DEFAULT ((0)) NULL,
    [ReasonDescription]   VARCHAR (50) NULL,
    [ReasonType]          VARCHAR (50) NULL,
    [ClientId]            INT          NULL,
    [Display]             BIT          CONSTRAINT [DF_DeviceBlockReason_Display] DEFAULT ((1)) NOT NULL,
    CONSTRAINT [PK_DeviceBlockReason] PRIMARY KEY CLUSTERED ([DeviceBlockReasonId] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_DeviceBlockReason_ClientId] FOREIGN KEY ([ClientId]) REFERENCES [dbo].[Client] ([ClientId])
);

