CREATE TABLE [dbo].[GiftCardAudit] (
    [AuditId]    INT            IDENTITY (1, 1) NOT NULL,
    [DeviceId]   VARCHAR (25)   NULL,
    [FieldName]  VARCHAR (50)   NULL,
    [NewValue]   VARCHAR (MAX)  NULL,
    [OldValue]   VARCHAR (MAX)  NULL,
    [ChangeDate] DATETIME       NULL,
    [ChangeBy]   INT            NULL,
    [Reason]     VARCHAR (1000) NULL,
    [SiteId]     INT            NULL,
    CONSTRAINT [PK_GiftCardAudit] PRIMARY KEY CLUSTERED ([AuditId] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_GiftCardAudit_SiteId] FOREIGN KEY ([SiteId]) REFERENCES [dbo].[Site] ([SiteId])
);

