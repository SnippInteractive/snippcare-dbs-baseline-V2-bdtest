CREATE TABLE [dbo].[AspNet_SqlCacheTablesForChangeNotification] (
    [tableName]           NVARCHAR (450) COLLATE Latin1_General_CI_AS NOT NULL,
    [notificationCreated] DATETIME       DEFAULT (getdate()) NOT NULL,
    [changeId]            INT            DEFAULT ((0)) NOT NULL,
    PRIMARY KEY CLUSTERED ([tableName] ASC)
);

