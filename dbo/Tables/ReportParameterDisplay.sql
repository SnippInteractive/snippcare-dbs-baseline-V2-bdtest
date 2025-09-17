CREATE TABLE [dbo].[ReportParameterDisplay] (
    [ReportParameterId]        INT           NOT NULL,
    [Language]                 CHAR (2)      NULL,
    [Display]                  VARCHAR (100) NULL,
    [ReportParameterDisplayId] INT           IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [PK_ReportParameterDisplay] PRIMARY KEY CLUSTERED ([ReportParameterDisplayId] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON)
);

