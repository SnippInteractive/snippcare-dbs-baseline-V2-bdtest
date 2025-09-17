CREATE TABLE [dbo].[ActivityType] (
    [Id]       INT           IDENTITY (1, 1) NOT NULL,
    [Name]     VARCHAR (50)  NULL,
    [Image]    VARCHAR (MAX) NULL,
    [ClientId] INT           NULL,
    [Display]  BIT           NULL,
    CONSTRAINT [PK_ActivityType] PRIMARY KEY CLUSTERED ([Id] ASC)
);

