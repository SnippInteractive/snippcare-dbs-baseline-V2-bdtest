CREATE TABLE [dbo].[TrxPointsAgeExpiry] (
    [ID]           INT          IDENTITY (1, 1) NOT NULL,
    [Version]      INT          NOT NULL,
    [Channel]      VARCHAR (50) NULL,
    [PeriodType]   VARCHAR (20) NULL,
    [PeriodAmount] INT          NULL,
    [EndOfMonth]   BIT          NULL,
    [EndOfYear]    BIT          NULL
);

