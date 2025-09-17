CREATE TABLE [dbo].[Receipt] (
    [ReceiptId]        INT                IDENTITY (1, 1) NOT NULL,
    [ClientEventId]    UNIQUEIDENTIFIER   NOT NULL,
    [SnippEventId]     UNIQUEIDENTIFIER   NOT NULL,
    [TransTime]        DATETIMEOFFSET (7) NOT NULL,
    [CampaignId]       UNIQUEIDENTIFIER   NOT NULL,
    [ImageUrl]         VARCHAR (MAX)      NULL,
    [UserId]           VARCHAR (100)      NULL,
    [ValidationTypeId] VARCHAR (50)       NULL,
    [ProcessingTypeId] VARCHAR (50)       NULL,
    [ProcessingStatus] VARCHAR (50)       NULL,
    [ProcTime]         DATETIMEOFFSET (7) NOT NULL,
    [ImageStatus]      VARCHAR (50)       NULL,
    [CreatedDate]      DATETIMEOFFSET (7) NULL,
    [LastUpdatedDate]  DATETIMEOFFSET (7) NULL,
    [Version]          INT                NULL,
    [SnippUserId]      INT                NULL,
    [ExtraInfo]        VARCHAR (MAX)      NULL,
    [Response]         VARCHAR (MAX)      NULL,
    PRIMARY KEY CLUSTERED ([ReceiptId] ASC)
);

