CREATE TABLE [dbo].[ReportParameterType] (
    [ParamTypeID] INT          NOT NULL,
    [Description] VARCHAR (50) NULL,
    CONSTRAINT [PK_ReportParameterType] PRIMARY KEY CLUSTERED ([ParamTypeID] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON)
);

