CREATE TABLE [dbo].[TrxStatus] (
    [TrxStatusId] INT          IDENTITY (1, 1) NOT NULL,
    [Version]     INT          CONSTRAINT [DF_TrxStatusType_Version] DEFAULT ((0)) NOT NULL,
    [Name]        VARCHAR (50) NULL,
    [ClientId]    INT          NOT NULL,
    [Display]     BIT          CONSTRAINT [DF_TrxStatus_Display] DEFAULT ((1)) NOT NULL,
    CONSTRAINT [PK_TrxStatusType] PRIMARY KEY CLUSTERED ([TrxStatusId] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_TrxStatusType_Client] FOREIGN KEY ([ClientId]) REFERENCES [dbo].[Client] ([ClientId])
);


GO
ALTER TABLE [dbo].[TrxStatus] ENABLE CHANGE_TRACKING WITH (TRACK_COLUMNS_UPDATED = ON);

