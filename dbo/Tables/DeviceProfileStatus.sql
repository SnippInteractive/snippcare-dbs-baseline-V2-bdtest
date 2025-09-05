CREATE TABLE [dbo].[DeviceProfileStatus] (
    [DeviceProfileStatusId] INT           IDENTITY (1, 1) NOT NULL,
    [Version]               INT           CONSTRAINT [DF_Device_DeviceProfileStatus_Version] DEFAULT ((0)) NOT NULL,
    [Name]                  NVARCHAR (50) NULL,
    [ClientId]              INT           NOT NULL,
    [Display]               INT           CONSTRAINT [DF_DeviceProfileStatus_Display] DEFAULT ((1)) NOT NULL,
    CONSTRAINT [PK_Device_DeviceProfileStatus] PRIMARY KEY CLUSTERED ([DeviceProfileStatusId] ASC) WITH (FILLFACTOR = 100)
);

