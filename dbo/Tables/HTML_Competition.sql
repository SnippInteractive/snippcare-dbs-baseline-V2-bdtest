CREATE TABLE [dbo].[HTML_Competition] (
    [Id]          INT            IDENTITY (1, 1) NOT NULL,
    [Status]      INT            NOT NULL,
    [ClientId]    INT            NOT NULL,
    [PreviewHTML] NVARCHAR (MAX) NULL,
    [RenderHTML]  NVARCHAR (MAX) NULL,
    [CreatedDate] DATETIME       NOT NULL,
    [TemplateId]  INT            NOT NULL,
    [Version]     INT            NULL,
    CONSTRAINT [PK_HTML_Competition] PRIMARY KEY CLUSTERED ([Id] ASC)
);

