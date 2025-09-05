CREATE TABLE [dbo].[ReferenceLookupi8n] (
    [Id]                INT            IDENTITY (1, 1) NOT NULL,
    [ReferenceLookupId] INT            NOT NULL,
    [Language]          CHAR (2)       NULL,
    [Description]       NVARCHAR (MAX) NULL,
    [Value]             NVARCHAR (100) NULL,
    PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FK_ReferenceLookup_ReferenceLookupId] FOREIGN KEY ([ReferenceLookupId]) REFERENCES [dbo].[ReferenceLookup] ([Id])
);

