CREATE TABLE [dbo].[ProductInfo] (
    [ID]                 INT             IDENTITY (1, 1) NOT NULL,
    [Version]            INT             CONSTRAINT [DF_ProductInfo_Version] DEFAULT ((0)) NOT NULL,
    [ClientID]           INT             NOT NULL,
    [ProductID]          VARCHAR (75)    NULL,
    [ProductDescription] VARCHAR (250)   NULL,
    [AnalysisCode1]      VARCHAR (100)   NULL,
    [AnalysisCode2]      VARCHAR (100)   NULL,
    [AnalysisCode3]      VARCHAR (100)   NULL,
    [AnalysisCode4]      VARCHAR (100)   NULL,
    [AnalysisCode5]      VARCHAR (100)   NULL,
    [AnalysisCode6]      VARCHAR (100)   NULL,
    [AnalysisCode7]      VARCHAR (100)   NULL,
    [AnalysisCode8]      VARCHAR (100)   NULL,
    [AnalysisCode9]      VARCHAR (100)   NULL,
    [AnalysisCode10]     VARCHAR (100)   NULL,
    [AnalysisCode11]     VARCHAR (100)   NULL,
    [AnalysisCode12]     VARCHAR (100)   NULL,
    [AnalysisCode13]     VARCHAR (100)   NULL,
    [AnalysisCode14]     VARCHAR (100)   NULL,
    [AnalysisCode15]     VARCHAR (100)   NULL,
    [ImportDate]         DATETIME        NOT NULL,
    [BaseValue]          DECIMAL (18, 2) NULL,
    [RetailPrice]        DECIMAL (18, 2) NULL,
    CONSTRAINT [PK_ProductInfo] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO
ALTER TABLE [dbo].[ProductInfo] ENABLE CHANGE_TRACKING WITH (TRACK_COLUMNS_UPDATED = ON);

