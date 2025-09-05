CREATE TABLE [dbo].[CommunicationPlaceholderMapping] (
    [Id]            INT            IDENTITY (1, 1) NOT NULL,
    [PropertyKey]   NVARCHAR (255) NOT NULL,
    [PropertyValue] NVARCHAR (MAX) NOT NULL,
    [TableName]     NVARCHAR (255) NOT NULL,
    [CreatedDate]   DATETIME       DEFAULT (getdate()) NULL,
    [ExtraInfo]     NVARCHAR (MAX) NULL,
    [SQLQuery]      NVARCHAR (500) NULL,
    [Display]       INT            NULL,
    [ClientId]      INT            NULL,
    PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FK_ClientId] FOREIGN KEY ([ClientId]) REFERENCES [dbo].[Client] ([ClientId])
);

