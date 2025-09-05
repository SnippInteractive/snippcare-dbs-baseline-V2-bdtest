CREATE TABLE [dbo].[ActivityDefinition] (
    [Id]              INT            IDENTITY (1, 1) NOT NULL,
    [ActivityTypeId]  INT            NOT NULL,
    [Description]     NVARCHAR (50)  NULL,
    [TagLine]         NVARCHAR (50)  NULL,
    [Points]          INT            NULL,
    [Reference]       NVARCHAR (100) NULL,
    [Image]           NVARCHAR (MAX) NULL,
    [CategoryId]      INT            NULL,
    [PointTypeId]     INT            DEFAULT ((1)) NOT NULL,
    [PointAmount]     INT            DEFAULT ((0)) NULL,
    [StartDate]       DATETIME2 (7)  NULL,
    [EndDate]         DATETIME2 (7)  NULL,
    [Enable]          BIT            NULL,
    [OrdinalPosition] INT            NULL,
    [Location]        NVARCHAR (500) NULL,
    CONSTRAINT [PK_ActivityDefinition] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FK_ActivityDefinition_ActivityCategoryType] FOREIGN KEY ([CategoryId]) REFERENCES [dbo].[ActivityCategoryType] ([Id]),
    CONSTRAINT [FK_ActivityDefinition_ActivityType] FOREIGN KEY ([ActivityTypeId]) REFERENCES [dbo].[ActivityType] ([Id])
);

