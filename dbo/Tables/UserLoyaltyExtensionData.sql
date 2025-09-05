CREATE TABLE [dbo].[UserLoyaltyExtensionData] (
    [ID]                INT            IDENTITY (1, 1) NOT NULL,
    [Version]           INT            CONSTRAINT [DF_UserLoyaltyExtensionData_Version] DEFAULT ((0)) NOT NULL,
    [UserLoyaltyDataId] INT            NOT NULL,
    [PropertyName]      NVARCHAR (50)  NULL,
    [PropertyValue]     NVARCHAR (MAX) NULL,
    [GroupId]           INT            CONSTRAINT [ExtensionData_Default_GroupId] DEFAULT ((1)) NULL,
    [DisplayOrder]      INT            CONSTRAINT [ExtensionData_Default_DisplayOrder] DEFAULT ((1)) NULL,
    [Deleted]           BIT            CONSTRAINT [ExtensionData_Default_Deleted] DEFAULT ((0)) NULL,
    CONSTRAINT [PK_UserLoyaltyExtensionData] PRIMARY KEY CLUSTERED ([ID] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_UserLoyaltyExtensionData_UserLoyaltyData] FOREIGN KEY ([UserLoyaltyDataId]) REFERENCES [dbo].[UserLoyaltyData] ([UserLoyaltyDataId])
);


GO
ALTER TABLE [dbo].[UserLoyaltyExtensionData] ENABLE CHANGE_TRACKING WITH (TRACK_COLUMNS_UPDATED = ON);

