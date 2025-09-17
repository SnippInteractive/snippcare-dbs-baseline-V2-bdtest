CREATE TABLE [dbo].[ELMAH_Error] (
    [ErrorId]     UNIQUEIDENTIFIER CONSTRAINT [DF_ELMAH_Error_ErrorId] DEFAULT (newid()) NOT NULL,
    [Application] VARCHAR (60)     NULL,
    [Host]        VARCHAR (50)     NULL,
    [Type]        VARCHAR (100)    NULL,
    [Source]      VARCHAR (60)     NULL,
    [Message]     VARCHAR (500)    NULL,
    [User]        VARCHAR (50)     NULL,
    [StatusCode]  INT              NOT NULL,
    [TimeUtc]     DATETIME         NOT NULL,
    [Sequence]    INT              IDENTITY (1, 1) NOT NULL,
    [AllXml]      VARCHAR (MAX)    NULL,
    CONSTRAINT [PK_ELMAH_Error] PRIMARY KEY NONCLUSTERED ([ErrorId] ASC) WITH (FILLFACTOR = 100)
);


GO
CREATE NONCLUSTERED INDEX [IX_ELMAH_Error_App_Time_Seq]
    ON [dbo].[ELMAH_Error]([Application] ASC, [TimeUtc] DESC, [Sequence] DESC) WITH (FILLFACTOR = 100);

