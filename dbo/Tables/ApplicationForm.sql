CREATE TABLE [dbo].[ApplicationForm] (
    [ApplicationFormId]         SMALLINT       IDENTITY (1, 1) NOT NULL,
    [Logo]                      NVARCHAR (256) NULL,
    [ApplicationFormTemplateId] SMALLINT       NULL,
    PRIMARY KEY CLUSTERED ([ApplicationFormId] ASC),
    FOREIGN KEY ([ApplicationFormTemplateId]) REFERENCES [dbo].[ApplicationFormTemplate] ([ApplicationFormTemplateId])
);

