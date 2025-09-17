CREATE TABLE [dbo].[JobStatus] (
    [JobStatusId] INT           IDENTITY (1, 1) NOT NULL,
    [Version]     INT           NOT NULL,
    [Name]        VARCHAR (150) NULL,
    [ClientId]    INT           NOT NULL,
    [Display]     BIT           NOT NULL,
    CONSTRAINT [PK_JobStatus] PRIMARY KEY CLUSTERED ([JobStatusId] ASC) WITH (FILLFACTOR = 100)
);

