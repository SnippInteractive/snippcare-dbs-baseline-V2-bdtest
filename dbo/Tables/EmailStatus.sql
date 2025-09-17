CREATE TABLE [dbo].[EmailStatus] (
    [EmailStatusId] INT          IDENTITY (1, 1) NOT NULL,
    [Version]       INT          CONSTRAINT [DF_EmailStatus_Version] DEFAULT ((0)) NOT NULL,
    [Name]          VARCHAR (50) NULL,
    [ClientId]      INT          NOT NULL,
    [Display]       INT          CONSTRAINT [DF_EmailStatus_Display] DEFAULT ((1)) NOT NULL,
    CONSTRAINT [PK_EmailStatus] PRIMARY KEY CLUSTERED ([EmailStatusId] ASC),
    CONSTRAINT [FK_EmailStatus_Client] FOREIGN KEY ([ClientId]) REFERENCES [dbo].[Client] ([ClientId])
);


GO
ALTER TABLE [dbo].[EmailStatus] ENABLE CHANGE_TRACKING WITH (TRACK_COLUMNS_UPDATED = ON);

