﻿CREATE TABLE [dbo].[AspNetRoles] (
    [Id]   NVARCHAR (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [Name] NVARCHAR (256) NULL,
    CONSTRAINT [PK_dbo.AspNetRoles] PRIMARY KEY CLUSTERED ([Id] ASC)
);

