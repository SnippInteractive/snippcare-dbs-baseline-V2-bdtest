﻿CREATE TABLE [dbo].[HtmlContent] (
    [ContentId]     INT           IDENTITY (0, 1) NOT NULL,
    [Version]       INT           NOT NULL,
    [ClientId]      INT           NOT NULL,
    [ApplicationId] INT           NOT NULL,
    [LanguageCode]  VARCHAR (50)  NULL,
    [ContentGroup]  VARCHAR (50)  NULL,
    [ContentTypeId] INT           NOT NULL,
    [Content]       VARCHAR (MAX) NULL,
    [Editable]      INT           NOT NULL,
    CONSTRAINT [PK_dbo.HtmlContent] PRIMARY KEY CLUSTERED ([ContentId] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_HtmlContent_Application] FOREIGN KEY ([ApplicationId]) REFERENCES [dbo].[Application] ([ApplicationId]),
    CONSTRAINT [FK_HtmlContent_Client] FOREIGN KEY ([ClientId]) REFERENCES [dbo].[Client] ([ClientId]),
    CONSTRAINT [FK_HtmlContent_ContentType] FOREIGN KEY ([ContentTypeId]) REFERENCES [dbo].[ContentType] ([ContentTypeId])
);

