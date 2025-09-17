CREATE TABLE [dbo].[TrxPointsAgePriority] (
    [ID]           INT          IDENTITY (1, 1) NOT NULL,
    [Version]      INT          NOT NULL,
    [SpendChannel] VARCHAR (50) NULL,
    [PriorityNo]   INT          NOT NULL,
    [EarnChannel]  VARCHAR (50) NULL
);

