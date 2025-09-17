CREATE TABLE [dbo].[DeviceProfileExpirationType] (
    [Id]       INT          IDENTITY (1, 1) NOT NULL,
    [Version]  INT          CONSTRAINT [DF_DeviceProfileExpirationTypeVersion] DEFAULT ((0)) NOT NULL,
    [Name]     VARCHAR (50) NULL,
    [ClientId] INT          NOT NULL,
    [Display]  BIT          CONSTRAINT [DF_DeviceProfileExpirationType_Display] DEFAULT ((1)) NOT NULL,
    CONSTRAINT [PK_DeviceProfileExpirationType] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_DeviceProfileExpirationType_ClientId] FOREIGN KEY ([ClientId]) REFERENCES [dbo].[Client] ([ClientId])
);

