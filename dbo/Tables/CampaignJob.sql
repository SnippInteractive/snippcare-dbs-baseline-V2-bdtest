CREATE TABLE [dbo].[CampaignJob] (
    [Id]          INT           NOT NULL,
    [Type]        VARCHAR (100) NULL,
    [CampaignId]  INT           NOT NULL,
    [CreateDate]  DATETIME      NULL,
    [Processed]   BIT           NULL,
    [ProcessDate] DATETIME      NULL,
    CONSTRAINT [PK_CampaignJob] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FK_CampaignJob_CampaignJob] FOREIGN KEY ([CampaignId]) REFERENCES [dbo].[Campaign] ([CampaignId])
);

