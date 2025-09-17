CREATE TABLE [dbo].[ApiErrorLog] (
    [Id]                BIGINT        IDENTITY (1, 1) NOT NULL,
    [RequestId]         VARCHAR (50)  NULL,
    [Request]           VARCHAR (MAX) NULL,
    [Response]          VARCHAR (MAX) NULL,
    [CreateDate]        DATETIME      NULL,
    [Reference]         VARCHAR (100) NULL,
    [StatusCode]        INT           NULL,
    [StatusDescription] VARCHAR (200) NULL,
    [Method]            VARCHAR (50)  NULL,
    [Source]            VARCHAR (50)  NULL,
    [Deviceid]          VARCHAR (25)  NULL,
    [Type]              VARCHAR (50)  NULL,
    [Processed]         INT           NULL,
    CONSTRAINT [PK_ApiErrorLog] PRIMARY KEY CLUSTERED ([Id] ASC)
);

