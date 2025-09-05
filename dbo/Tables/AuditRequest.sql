CREATE TABLE [dbo].[AuditRequest] (
    [Id]         INT              IDENTITY (1, 1) NOT NULL,
    [time_stamp] DATETIME         CONSTRAINT [DF_AuditRequest_time_stamp] DEFAULT (getdate()) NOT NULL,
    [host]       NVARCHAR (MAX)   NULL,
    [type]       NVARCHAR (50)    NULL,
    [source]     NVARCHAR (50)    NULL,
    [message]    NVARCHAR (MAX)   NULL,
    [level]      NVARCHAR (50)    NULL,
    [logger]     NVARCHAR (50)    NULL,
    [stacktrace] NVARCHAR (MAX)   NULL,
    [RequestId]  UNIQUEIDENTIFIER NULL,
    CONSTRAINT [PK_AuditRequest] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [ui_id]
    ON [dbo].[AuditRequest]([Id] ASC);

