CREATE TABLE [dbo].[Client] (
    [ClientId]                 INT              IDENTITY (1, 1) NOT NULL,
    [Version]                  INT              CONSTRAINT [DF_Client_Version] DEFAULT ((0)) NOT NULL,
    [Name]                     VARCHAR (100)    NULL,
    [Domain]                   VARCHAR (100)    NULL,
    [DefaultStylesheet]        VARCHAR (100)    NULL,
    [ContactHistoryDateRange]  INT              NULL,
    [TrxDateRange]             INT              NULL,
    [SearchCount]              INT              NULL,
    [QueueSearchCount]         INT              NULL,
    [AuditDateRange]           INT              NULL,
    [MobileStrFormat]          VARCHAR (50)     NULL,
    [PhoneStrFormat]           VARCHAR (50)     NULL,
    [MobileRegexFormat]        VARCHAR (100)    NULL,
    [PhoneRegexFormat]         VARCHAR (100)    NULL,
    [ApiKey]                   UNIQUEIDENTIFIER CONSTRAINT [DF_Client_ApiKey] DEFAULT (newid()) NULL,
    [ApiSecret]                VARCHAR (50)     NULL,
    [LeadingDigits]            NVARCHAR (20)    NULL,
    [MaximumLoginAttempts]     INT              CONSTRAINT [DF_Client_MaximumLoginAttempts] DEFAULT ((-1)) NOT NULL,
    [AccountLockoutDuration]   INT              CONSTRAINT [DF_Client_AccountLockoutDuration] DEFAULT ((0)) NOT NULL,
    [ManualClaimPoints]        INT              NULL,
    [NotificareApplicationKey] NVARCHAR (200)   NULL,
    [NotificareMasterSecret]   NVARCHAR (200)   NULL,
    [ExtraInfo]                NVARCHAR (MAX)   NULL,
    CONSTRAINT [PK_Client] PRIMARY KEY CLUSTERED ([ClientId] ASC) WITH (FILLFACTOR = 100)
);


GO
ALTER TABLE [dbo].[Client] ENABLE CHANGE_TRACKING WITH (TRACK_COLUMNS_UPDATED = ON);

