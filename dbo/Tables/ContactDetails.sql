CREATE TABLE [dbo].[ContactDetails] (
    [ContactDetailsId]     INT           IDENTITY (1, 1) NOT NULL,
    [Version]              INT           CONSTRAINT [DF_ContactDetails_Version] DEFAULT ((0)) NOT NULL,
    [Email]                NVARCHAR (80) NULL,
    [Phone]                VARCHAR (50)  NULL,
    [MobilePhone]          VARCHAR (50)  NULL,
    [Fax]                  VARCHAR (50)  NULL,
    [ContactDetailsTypeId] INT           NOT NULL,
    [EmailStatusId]        INT           CONSTRAINT [DF_ContactDetails_EmailStatus] DEFAULT ((1)) NULL,
    [LastUpdated]          DATETIME      NULL,
    [EmailAlias]           VARCHAR (80)  NULL,
    CONSTRAINT [PK_ContactDetails] PRIMARY KEY CLUSTERED ([ContactDetailsId] ASC) WITH (FILLFACTOR = 95),
    CONSTRAINT [FK_ContactDetails_ContactDetailsType] FOREIGN KEY ([ContactDetailsTypeId]) REFERENCES [dbo].[ContactDetailsType] ([ContactDetailsTypeId]),
    CONSTRAINT [FK_ContactDetails_EmailStatus] FOREIGN KEY ([EmailStatusId]) REFERENCES [dbo].[EmailStatus] ([EmailStatusId])
);


GO
ALTER TABLE [dbo].[ContactDetails] ENABLE CHANGE_TRACKING WITH (TRACK_COLUMNS_UPDATED = ON);

