CREATE TABLE [dbo].[MailCampaignTemplate] (
    [MailCampaignTemplateId] INT           IDENTITY (1, 1) NOT NULL,
    [Name]                   VARCHAR (50)  NULL,
    [Html]                   VARCHAR (MAX) NULL,
    [Type]                   VARCHAR (50)  NULL,
    [LanguageCulture]        VARCHAR (5)   NULL,
    [SubmissionType]         VARCHAR (50)  NULL,
    [MessageType]            VARCHAR (50)  NULL,
    [Message]                VARCHAR (MAX) NULL,
    PRIMARY KEY CLUSTERED ([MailCampaignTemplateId] ASC)
);

