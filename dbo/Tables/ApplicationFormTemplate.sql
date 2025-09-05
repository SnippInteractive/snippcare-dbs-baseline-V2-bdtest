CREATE TABLE [dbo].[ApplicationFormTemplate] (
    [ApplicationFormTemplateId] SMALLINT       IDENTITY (1, 1) NOT NULL,
    [Html]                      NVARCHAR (MAX) NULL,
    CONSTRAINT [PK_ApplicationForm] PRIMARY KEY CLUSTERED ([ApplicationFormTemplateId] ASC)
);

