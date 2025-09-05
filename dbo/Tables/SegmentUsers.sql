CREATE TABLE [dbo].[SegmentUsers] (
    [Id]          BIGINT        IDENTITY (1, 1) NOT NULL,
    [SegmentId]   INT           NOT NULL,
    [UserId]      INT           NOT NULL,
    [Source]      NVARCHAR (50) NULL,
    [CreatedDate] DATETIME      NULL,
    [DeviceId]    NVARCHAR (20) NULL,
    CONSTRAINT [PK_SegmentUsers] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FK_SegmentUsers_SegmentAdmin] FOREIGN KEY ([SegmentId]) REFERENCES [dbo].[SegmentAdmin] ([SegmentId]),
    CONSTRAINT [FK_SegmentUsers_User] FOREIGN KEY ([UserId]) REFERENCES [dbo].[User] ([UserId])
);


GO
ALTER TABLE [dbo].[SegmentUsers] ENABLE CHANGE_TRACKING WITH (TRACK_COLUMNS_UPDATED = ON);

