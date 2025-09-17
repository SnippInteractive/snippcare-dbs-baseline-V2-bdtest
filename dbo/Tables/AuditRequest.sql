CREATE TABLE [dbo].[AuditRequest] (
    [Id]         INT              IDENTITY (1, 1) NOT NULL,
    [time_stamp] DATETIME         CONSTRAINT [DF_AuditRequest_time_stamp] DEFAULT (getdate()) NOT NULL,
    [host]       VARCHAR (MAX)    NULL,
    [type]       VARCHAR (50)     NULL,
    [source]     VARCHAR (50)     NULL,
    [message]    VARCHAR (MAX)    NULL,
    [level]      VARCHAR (50)     NULL,
    [logger]     VARCHAR (50)     NULL,
    [stacktrace] VARCHAR (MAX)    NULL,
    [RequestId]  UNIQUEIDENTIFIER NULL,
    CONSTRAINT [PK_AuditRequest] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [ui_id]
    ON [dbo].[AuditRequest]([Id] ASC);

