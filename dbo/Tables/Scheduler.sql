CREATE TABLE [dbo].[Scheduler] (
    [SchedulerId]          INT           IDENTITY (1, 1) NOT NULL,
    [Name]                 VARCHAR (100) NULL,
    [Description]          VARCHAR (250) NULL,
    [UpdatedDate]          DATETIME      NULL,
    [UpdatedBy]            INT           NULL,
    [ClientId]             INT           NULL,
    [Version]              INT           NULL,
    [FrequencyTypeId]      INT           NULL,
    [RecursWeek]           INT           NULL,
    [RecursDays]           INT           NULL,
    [StartTime]            VARCHAR (10)  NULL,
    [EndTime]              VARCHAR (10)  NULL,
    [RecursMonthDay]       INT           NULL,
    [RecursMonth]          INT           NULL,
    [RecursMonthDaysOrder] INT           NULL,
    [IsActive]             BIT           CONSTRAINT [DF_Scheduler_IsActive] DEFAULT ((1)) NULL,
    [StartDate]            DATETIME      NULL,
    [EndDate]              DATETIME      NULL,
    CONSTRAINT [PK_Scheduler] PRIMARY KEY CLUSTERED ([SchedulerId] ASC),
    CONSTRAINT [FK_Scheduler_Scheduler_ClientId] FOREIGN KEY ([ClientId]) REFERENCES [dbo].[Client] ([ClientId])
);

