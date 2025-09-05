CREATE TABLE [dbo].[ReportStyles] (
    [ClientId]    INT          NOT NULL,
    [RepLogo]     IMAGE        NULL,
    [BkColour1]   VARCHAR (20) NULL,
    [FontColour1] VARCHAR (20) NULL,
    [BkColour2]   VARCHAR (20) NULL,
    [FontColour2] VARCHAR (20) NULL,
    [BkColour3]   VARCHAR (20) NULL,
    [FontColour3] VARCHAR (20) NULL,
    [BkColour4]   VARCHAR (20) NULL,
    [FontColour4] VARCHAR (20) NULL,
    [BkColour5]   VARCHAR (20) NULL,
    [FontColour5] VARCHAR (20) NULL,
    CONSTRAINT [PK_ReportStyles] PRIMARY KEY CLUSTERED ([ClientId] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON)
);

