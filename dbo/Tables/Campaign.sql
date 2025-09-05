CREATE TABLE [dbo].[Campaign] (
    [CampaignId]             INT            IDENTITY (1, 1) NOT NULL,
    [ClientId]               INT            NULL,
    [CampaignName]           VARCHAR (100)  NULL,
    [Description]            VARCHAR (1000) NULL,
    [StartDate]              SMALLDATETIME  NULL,
    [EndDate]                SMALLDATETIME  NULL,
    [OutputType]             TINYINT        NULL,
    [OutputMsg]              VARCHAR (MAX)  NULL,
    [TemplateId]             INT            NULL,
    [Coordinator]            INT            NULL,
    [SiteId]                 INT            NULL,
    [TrackerId]              VARCHAR (20)   NULL,
    [PostDispatchType]       CHAR (3)       NULL,
    [PostReturnType]         SMALLINT       NULL,
    [TestRun]                BIT            CONSTRAINT [DF_Campaign_TestRun] DEFAULT ((1)) NULL,
    [ExportDirectory]        VARCHAR (100)  NULL,
    [OutputByMemberOrDevice] SMALLINT       NULL,
    [RoundOffType]           INT            CONSTRAINT [DF_Campaign_RoundOffType] DEFAULT ((0)) NULL,
    [RoundOffPlace]          INT            NULL,
    [old_id]                 INT            NULL,
    CONSTRAINT [PK_Campaign] PRIMARY KEY CLUSTERED ([CampaignId] ASC) WITH (FILLFACTOR = 100)
);

