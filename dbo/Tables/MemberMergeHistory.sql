CREATE TABLE [dbo].[MemberMergeHistory] (
    [Id]             INT           IDENTITY (1, 1) NOT NULL,
    [UserId]         INT           NULL,
    [MergedUserId]   INT           NULL,
    [MergedDeviceId] VARCHAR (50)  NULL,
    [Notes]          VARCHAR (MAX) NULL,
    [MergeDate]      DATETIME      NULL,
    PRIMARY KEY CLUSTERED ([Id] ASC)
);

