CREATE TABLE [dbo].[TrxPointsAgeExpiry] (
    [ID]           INT           IDENTITY (1, 1) NOT NULL,
    [Version]      INT           NOT NULL,
    [Channel]      NVARCHAR (50) NULL,
    [PeriodType]   NVARCHAR (20) NULL,
    [PeriodAmount] INT           NULL,
    [EndOfMonth]   BIT           NULL,
    [EndOfYear]    BIT           NULL
);

