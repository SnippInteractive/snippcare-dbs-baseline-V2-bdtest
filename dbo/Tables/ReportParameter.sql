﻿CREATE TABLE [dbo].[ReportParameter] (
    [RepParameterId] INT            IDENTITY (1, 1) NOT NULL,
    [ReportId]       INT            NOT NULL,
    [ParamType]      INT            NOT NULL,
    [ParamIndex]     INT            NOT NULL,
    [ParamName]      VARCHAR (100)  NULL,
    [ParamLink]      INT            NULL,
    [ParamQuery]     VARCHAR (1000) NULL,
    [ParamDisplay]   INT            NULL,
    CONSTRAINT [PK_ReportParameter] PRIMARY KEY CLUSTERED ([RepParameterId] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_ReportParameter_Report] FOREIGN KEY ([ReportId]) REFERENCES [dbo].[Report] ([ReportId]),
    CONSTRAINT [FK_ReportParameter_ReportParameterType] FOREIGN KEY ([ParamType]) REFERENCES [dbo].[ReportParameterType] ([ParamTypeID])
);

