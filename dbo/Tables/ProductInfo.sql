CREATE TABLE [dbo].[ProductInfo] (
    [ID]                 INT             IDENTITY (1, 1) NOT NULL,
    [Version]            INT             CONSTRAINT [DF_ProductInfo_Version] DEFAULT ((0)) NOT NULL,
    [ClientID]           INT             NOT NULL,
    [ProductID]          NVARCHAR (75)   NULL,
    [ProductDescription] NVARCHAR (250)  NULL,
    [AnalysisCode1]      NVARCHAR (100)  NULL,
    [AnalysisCode2]      NVARCHAR (100)  NULL,
    [AnalysisCode3]      NVARCHAR (100)  NULL,
    [AnalysisCode4]      NVARCHAR (100)  NULL,
    [AnalysisCode5]      NVARCHAR (100)  NULL,
    [AnalysisCode6]      NVARCHAR (100)  NULL,
    [AnalysisCode7]      NVARCHAR (100)  NULL,
    [AnalysisCode8]      NVARCHAR (100)  NULL,
    [AnalysisCode9]      NVARCHAR (100)  NULL,
    [AnalysisCode10]     NVARCHAR (100)  NULL,
    [AnalysisCode11]     NVARCHAR (100)  NULL,
    [AnalysisCode12]     NVARCHAR (100)  NULL,
    [AnalysisCode13]     NVARCHAR (100)  NULL,
    [AnalysisCode14]     NVARCHAR (100)  NULL,
    [AnalysisCode15]     NVARCHAR (100)  NULL,
    [ImportDate]         DATETIME        NOT NULL,
    [BaseValue]          DECIMAL (18, 2) NULL,
    [RetailPrice]        DECIMAL (18, 2) NULL,
    CONSTRAINT [PK_ProductInfo] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO
ALTER TABLE [dbo].[ProductInfo] ENABLE CHANGE_TRACKING WITH (TRACK_COLUMNS_UPDATED = ON);

