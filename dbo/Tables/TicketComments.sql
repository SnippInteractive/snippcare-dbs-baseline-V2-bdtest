﻿CREATE TABLE [dbo].[TicketComments] (
    [id]          BIGINT          IDENTITY (1, 1) NOT NULL,
    [TicketId]    INT             NULL,
    [SysUsedId]   INT             NULL,
    [Comments]    VARCHAR (1024)  NULL,
    [CreatedDate] DATETIME        NULL,
    [Filepath]    VARCHAR (100)   NULL,
    [UserType]    INT             NULL,
    [FileContent] VARBINARY (MAX) NULL,
    [FileType]    VARCHAR (5)     NULL,
    [Version]     INT             CONSTRAINT [DF_TicketComments_Version] DEFAULT ((0)) NULL,
    CONSTRAINT [PK_TicketComments] PRIMARY KEY CLUSTERED ([id] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_TicketComments_SysUsedId] FOREIGN KEY ([SysUsedId]) REFERENCES [dbo].[User] ([UserId]),
    CONSTRAINT [FK_TicketComments_TicketId] FOREIGN KEY ([TicketId]) REFERENCES [dbo].[Ticket] ([TicketId])
);

