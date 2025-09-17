CREATE TABLE [dbo].[HtmlMessage] (
    [HtmlMessageId] INT           IDENTITY (0, 1) NOT NULL,
    [Version]       INT           NOT NULL,
    [ClientId]      INT           NOT NULL,
    [ApplicationId] INT           NOT NULL,
    [LanguageCode]  VARCHAR (50)  NULL,
    [Description]   VARCHAR (50)  NULL,
    [Message]       VARCHAR (MAX) NULL,
    [Editable]      INT           NOT NULL,
    [MessageType]   VARCHAR (100) NULL,
    CONSTRAINT [PK_dbo.HtmlMessage] PRIMARY KEY CLUSTERED ([HtmlMessageId] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_HtmlMessage_Client] FOREIGN KEY ([ClientId]) REFERENCES [dbo].[Client] ([ClientId])
);

