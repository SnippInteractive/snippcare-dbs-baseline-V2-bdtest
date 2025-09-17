CREATE TABLE [dbo].[DeviceProfileTemplateStatus] (
    [Id]       INT          IDENTITY (1, 1) NOT NULL,
    [Version]  INT          CONSTRAINT [DF_DeviceProfileStatus_Version] DEFAULT ((0)) NOT NULL,
    [Name]     VARCHAR (25) NULL,
    [ClientId] INT          NOT NULL,
    [Display]  BIT          NOT NULL,
    CONSTRAINT [PK_DeviceProfileStatus] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_Client_DeviceProfileTemplateStatus] FOREIGN KEY ([ClientId]) REFERENCES [dbo].[Client] ([ClientId])
);

