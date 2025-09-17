﻿CREATE TABLE [dbo].[DeviceProfileClientRestrictions] (
    [Id]       INT          IDENTITY (1, 1) NOT NULL,
    [Version]  INT          CONSTRAINT [DF_DeviceProfileClientRestrictions_Version] DEFAULT ((0)) NOT NULL,
    [Name]     VARCHAR (50) NULL,
    [Value]    VARCHAR (50) NULL,
    [ParentId] INT          NULL,
    [SiteId]   INT          NULL,
    CONSTRAINT [PK_DeviceProfileValidation] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_DeviceProfileValidationParent_DeviceProfileValidation] FOREIGN KEY ([ParentId]) REFERENCES [dbo].[DeviceProfileClientRestrictions] ([Id]),
    CONSTRAINT [FK_Site_DeviceProfileClientSpecificValidation] FOREIGN KEY ([SiteId]) REFERENCES [dbo].[Site] ([SiteId])
);

