CREATE TABLE [dbo].[Audit] (
    [AuditId]       INT           IDENTITY (1, 1) NOT NULL,
    [Version]       INT           CONSTRAINT [DF_Audit_Version] DEFAULT ((0)) NOT NULL,
    [UserId]        INT           NOT NULL,
    [FieldName]     VARCHAR (50)  NULL,
    [NewValue]      VARCHAR (MAX) NULL,
    [OldValue]      VARCHAR (MAX) NULL,
    [ChangeDate]    DATETIME      NULL,
    [ChangeBy]      INT           NULL,
    [Reason]        VARCHAR (MAX) NULL,
    [ReferenceType] VARCHAR (75)  NULL,
    [OperatorId]    VARCHAR (50)  NULL,
    [SiteId]        INT           NULL,
    [AdminScreen]   VARCHAR (100) NULL,
    [SysUser]       INT           NULL,
    CONSTRAINT [PK_Audit] PRIMARY KEY CLUSTERED ([AuditId] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_Audit_Site] FOREIGN KEY ([SiteId]) REFERENCES [dbo].[Site] ([SiteId]),
    CONSTRAINT [FK_Audit_User] FOREIGN KEY ([UserId]) REFERENCES [dbo].[User] ([UserId]),
    CONSTRAINT [FK_Audit_User1] FOREIGN KEY ([ChangeBy]) REFERENCES [dbo].[User] ([UserId])
);


GO
ALTER TABLE [dbo].[Audit] NOCHECK CONSTRAINT [FK_Audit_Site];


GO
ALTER TABLE [dbo].[Audit] NOCHECK CONSTRAINT [FK_Audit_User];


GO
ALTER TABLE [dbo].[Audit] NOCHECK CONSTRAINT [FK_Audit_User1];

