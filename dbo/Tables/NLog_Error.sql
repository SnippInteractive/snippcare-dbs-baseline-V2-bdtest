CREATE TABLE [dbo].[NLog_Error] (
    [Id]         INT            IDENTITY (1, 1) NOT NULL,
    [time_stamp] DATETIME       CONSTRAINT [DF_NLog_Error_time_stamp] DEFAULT (getdate()) NOT NULL,
    [host]       NVARCHAR (MAX) NULL,
    [type]       NVARCHAR (50)  NULL,
    [source]     NVARCHAR (50)  NULL,
    [message]    NVARCHAR (MAX) NULL,
    [level]      NVARCHAR (50)  NULL,
    [logger]     NVARCHAR (50)  NULL,
    [stacktrace] NVARCHAR (MAX) NULL,
    CONSTRAINT [PK_NLogError] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100)
);

