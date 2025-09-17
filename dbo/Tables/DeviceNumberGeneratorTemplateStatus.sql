CREATE TABLE [dbo].[DeviceNumberGeneratorTemplateStatus] (
    [Id]       INT          IDENTITY (1, 1) NOT NULL,
    [Version]  INT          CONSTRAINT [DF_DeviceNumberGeneratorTemplateStatus_Version] DEFAULT ((0)) NOT NULL,
    [Name]     VARCHAR (50) NULL,
    [ClientId] INT          NOT NULL,
    [Display]  BIT          NOT NULL,
    CONSTRAINT [PK_DeviceNumberGeneratorTemplateStatus] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_Client_DeviceNumberGeneratorTemplateStatus] FOREIGN KEY ([ClientId]) REFERENCES [dbo].[Client] ([ClientId])
);

