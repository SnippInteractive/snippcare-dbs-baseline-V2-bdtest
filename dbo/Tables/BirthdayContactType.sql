CREATE TABLE [dbo].[BirthdayContactType] (
    [BirthdayContactTypeId] INT           IDENTITY (1, 1) NOT NULL,
    [Version]               INT           NOT NULL,
    [Name]                  NVARCHAR (50) NULL,
    [ClientId]              INT           NOT NULL,
    [Display]               BIT           CONSTRAINT [DF_BirthdayContactType_Display] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_BirthdayContactType] PRIMARY KEY CLUSTERED ([BirthdayContactTypeId] ASC)
);

