CREATE TABLE [dbo].[MailMerge] (
    [Id]          INT           IDENTITY (1, 1) NOT NULL,
    [Version]     INT           NOT NULL,
    [Name]        VARCHAR (50)  NULL,
    [Description] VARCHAR (100) NULL,
    [CreatedOn]   DATETIME      NOT NULL,
    [CreatedBy]   INT           NOT NULL,
    [UpdatedOn]   DATETIME      NOT NULL,
    [UpdatedBy]   INT           NOT NULL,
    [HtmlContent] VARCHAR (1)   NULL,
    [ClientId]    INT           NOT NULL,
    CONSTRAINT [PK_MailMerge] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FK_MailMerge_Client] FOREIGN KEY ([ClientId]) REFERENCES [dbo].[Client] ([ClientId])
);

