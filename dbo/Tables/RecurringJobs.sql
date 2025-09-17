CREATE TABLE [dbo].[RecurringJobs] (
    [Id]                         INT           IDENTITY (1, 1) NOT NULL,
    [ClientId]                   INT           NOT NULL,
    [PreAPICallStoredProcedure]  VARCHAR (MAX) NULL,
    [APIConfiguration]           VARCHAR (MAX) NULL,
    [PostAPICallStoredProcedure] VARCHAR (MAX) NULL,
    [Frequency]                  VARCHAR (20)  NULL,
    [FrequencyValue]             VARCHAR (20)  NULL,
    [TimeToRun]                  VARCHAR (20)  NULL,
    [CampaignId]                 VARCHAR (50)  NULL,
    [ExtraInfo]                  VARCHAR (MAX) NULL,
    [StartDate]                  DATETIME      NOT NULL,
    [ExpiresOn]                  DATETIME      NULL,
    [Active]                     BIT           NOT NULL,
    [JobMethod]                  VARCHAR (MAX) NULL,
    CONSTRAINT [PK_RecurringJobs] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FK_RecurringJobs_Client] FOREIGN KEY ([ClientId]) REFERENCES [dbo].[Client] ([ClientId])
);

