CREATE TABLE [dbo].[FrequencyType] (
    [FrequencyTypeId] INT           IDENTITY (1, 1) NOT NULL,
    [Name]            NVARCHAR (50) NULL,
    [ClientId]        INT           NULL,
    [Display]         BIT           NULL,
    [Version]         INT           NULL,
    CONSTRAINT [PK_FrequencyType] PRIMARY KEY CLUSTERED ([FrequencyTypeId] ASC)
);

