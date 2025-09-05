CREATE TABLE [dbo].[WebServiceRequests] (
    [id]          INT            IDENTITY (1, 1) NOT NULL,
    [Request]     NVARCHAR (MAX) NULL,
    [Response]    NVARCHAR (MAX) NULL,
    [RequestDate] DATETIME       CONSTRAINT [DF_WebServiceRequests_RequestDate] DEFAULT (getdate()) NOT NULL,
    [Service]     NVARCHAR (50)  NULL,
    CONSTRAINT [PK_WebServiceRequests] PRIMARY KEY CLUSTERED ([id] ASC) WITH (FILLFACTOR = 100)
);

