CREATE TABLE [dbo].[NLog_Error] (
    [Id]         INT           IDENTITY (1, 1) NOT NULL,
    [time_stamp] DATETIME      CONSTRAINT [DF_NLog_Error_time_stamp] DEFAULT (getdate()) NOT NULL,
    [host]       VARCHAR (MAX) NULL,
    [type]       VARCHAR (50)  NULL,
    [source]     VARCHAR (50)  NULL,
    [message]    VARCHAR (MAX) NULL,
    [level]      VARCHAR (50)  NULL,
    [logger]     VARCHAR (50)  NULL,
    [stacktrace] VARCHAR (MAX) NULL,
    CONSTRAINT [PK_NLogError] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100)
);

