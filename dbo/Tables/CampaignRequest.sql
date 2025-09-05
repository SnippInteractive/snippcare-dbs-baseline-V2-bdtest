CREATE TABLE [dbo].[CampaignRequest] (
    [CampReqId]    INT            IDENTITY (1, 1) NOT NULL,
    [RequestType]  VARCHAR (10)   NULL,
    [CampaignId]   INT            NOT NULL,
    [SysuserId]    INT            NOT NULL,
    [StartTime]    DATETIME       NOT NULL,
    [Endtime]      DATETIME       NULL,
    [Status]       SMALLINT       DEFAULT ((0)) NOT NULL,
    [OutputCount]  INT            DEFAULT ((0)) NOT NULL,
    [FirstTrxDate] DATETIME       NULL,
    [LastTrxDate]  DATETIME       NULL,
    [old_id]       INT            NULL,
    [SelectionSQL] NVARCHAR (MAX) NULL,
    CONSTRAINT [PK_CampaignRequest] PRIMARY KEY CLUSTERED ([CampReqId] ASC) WITH (FILLFACTOR = 100)
);

