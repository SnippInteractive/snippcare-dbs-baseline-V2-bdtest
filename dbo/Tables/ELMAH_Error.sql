CREATE TABLE [dbo].[ELMAH_Error] (
    [ErrorId]     UNIQUEIDENTIFIER CONSTRAINT [DF_ELMAH_Error_ErrorId] DEFAULT (newid()) NOT NULL,
    [Application] NVARCHAR (60)    NULL,
    [Host]        NVARCHAR (50)    NULL,
    [Type]        NVARCHAR (100)   NULL,
    [Source]      NVARCHAR (60)    NULL,
    [Message]     NVARCHAR (500)   NULL,
    [User]        NVARCHAR (50)    NULL,
    [StatusCode]  INT              NOT NULL,
    [TimeUtc]     DATETIME         NOT NULL,
    [Sequence]    INT              IDENTITY (1, 1) NOT NULL,
    [AllXml]      VARCHAR (MAX)    NULL,
    CONSTRAINT [PK_ELMAH_Error] PRIMARY KEY NONCLUSTERED ([ErrorId] ASC) WITH (FILLFACTOR = 100)
);

