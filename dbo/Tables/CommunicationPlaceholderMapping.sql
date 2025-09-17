CREATE TABLE [dbo].[CommunicationPlaceholderMapping] (
    [Id]            INT           IDENTITY (1, 1) NOT NULL,
    [PropertyKey]   VARCHAR (255) NULL,
    [PropertyValue] VARCHAR (MAX) NULL,
    [TableName]     VARCHAR (255) NULL,
    [CreatedDate]   DATETIME      DEFAULT (getdate()) NULL,
    [ExtraInfo]     VARCHAR (MAX) NULL,
    [SQLQuery]      VARCHAR (500) NULL,
    [Display]       INT           NULL,
    [ClientId]      INT           NULL,
    PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FK_ClientId] FOREIGN KEY ([ClientId]) REFERENCES [dbo].[Client] ([ClientId])
);

