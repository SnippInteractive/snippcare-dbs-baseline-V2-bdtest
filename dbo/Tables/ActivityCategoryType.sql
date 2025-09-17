CREATE TABLE [dbo].[ActivityCategoryType] (
    [Id]                 INT          IDENTITY (1, 1) NOT NULL,
    [Name]               VARCHAR (50) NULL,
    [ClientId]           INT          NULL,
    [Display]            BIT          NULL,
    [ActivityCategoryId] INT          NULL,
    CONSTRAINT [PK_ActivityCategory] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FK_ActivityCategoryType_ActivityCategory] FOREIGN KEY ([ActivityCategoryId]) REFERENCES [dbo].[ActivityCategory] ([Id])
);

