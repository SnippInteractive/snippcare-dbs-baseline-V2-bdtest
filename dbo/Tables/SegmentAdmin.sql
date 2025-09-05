CREATE TABLE [dbo].[SegmentAdmin] (
    [SegmentId]   INT            IDENTITY (1, 1) NOT NULL,
    [Version]     INT            NOT NULL,
    [Name]        NVARCHAR (100) NULL,
    [Description] NVARCHAR (250) NULL,
    [ValidFrom]   DATE           NULL,
    [ValidTo]     DATE           NULL,
    [EndTime]     TIME (7)       NULL,
    [Tier]        BIT            NULL,
    [SiteId]      INT            NULL,
    [Createdby]   INT            NULL,
    [CreatedDate] DATETIME       NULL,
    [UpdatedDate] DATETIME       NULL,
    CONSTRAINT [PK_SegmentAdmin] PRIMARY KEY CLUSTERED ([SegmentId] ASC),
    CONSTRAINT [FK_SegmentAdmin_Site] FOREIGN KEY ([SiteId]) REFERENCES [dbo].[Site] ([SiteId])
);


GO
ALTER TABLE [dbo].[SegmentAdmin] ENABLE CHANGE_TRACKING WITH (TRACK_COLUMNS_UPDATED = ON);

