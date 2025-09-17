CREATE TABLE [dbo].[AspNet_SqlCacheTablesForChangeNotification] (
    [tableName]           VARCHAR (450) NOT NULL,
    [notificationCreated] DATETIME      DEFAULT (getdate()) NOT NULL,
    [changeId]            INT           DEFAULT ((0)) NOT NULL,
    PRIMARY KEY CLUSTERED ([tableName] ASC)
);

