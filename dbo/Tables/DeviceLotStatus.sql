CREATE TABLE [dbo].[DeviceLotStatus] (
    [Id]       INT          IDENTITY (1, 1) NOT NULL,
    [Version]  INT          CONSTRAINT [DF_DeviceLotStatus_Version] DEFAULT ((0)) NOT NULL,
    [Name]     VARCHAR (50) NULL,
    [ClientId] INT          CONSTRAINT [DF_DeviceLotStatus_ClientId] DEFAULT ((1)) NOT NULL,
    [Display]  BIT          CONSTRAINT [DF_DeviceLotStatus_Display] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_DeviceLotStatus] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_DeviceLotStatus_Client] FOREIGN KEY ([ClientId]) REFERENCES [dbo].[Client] ([ClientId])
);

