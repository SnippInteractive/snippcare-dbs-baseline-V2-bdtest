CREATE TABLE [dbo].[NotificationTemplate] (
    [Id]                         INT             IDENTITY (1, 1) NOT NULL,
    [Version]                    INT             NOT NULL,
    [NotificationTemplateTypeId] INT             NOT NULL,
    [Name]                       NVARCHAR (50)   NULL,
    [Display]                    BIT             NOT NULL,
    [NotificareTemplateId]       NVARCHAR (100)  NULL,
    [Placeholders]               NVARCHAR (1000) NULL,
    [NotificationTypeId]         INT             NULL,
    CONSTRAINT [PK__NotificationTemplate] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_NotificationTemplate_NotificationTemplateType] FOREIGN KEY ([NotificationTemplateTypeId]) REFERENCES [dbo].[NotificationTemplateType] ([Id]),
    CONSTRAINT [FK_NotificationTemplate_NotificationType] FOREIGN KEY ([NotificationTypeId]) REFERENCES [dbo].[NotificationType] ([Id])
);

