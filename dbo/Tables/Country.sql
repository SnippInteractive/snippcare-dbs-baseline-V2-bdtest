CREATE TABLE [dbo].[Country] (
    [CountryId]    INT          IDENTITY (1, 1) NOT NULL,
    [Version]      INT          CONSTRAINT [DF_Country_Version] DEFAULT ((0)) NOT NULL,
    [Name]         VARCHAR (80) NULL,
    [CountryCode]  VARCHAR (2)  NULL,
    [ClientId]     INT          CONSTRAINT [DF_Country_ClientId] DEFAULT ((1)) NOT NULL,
    [DisplayOrder] INT          NULL,
    [Display]      BIT          CONSTRAINT [DF_Country_Display] DEFAULT ((1)) NOT NULL,
    [MobilePrefix] VARCHAR (10) NULL,
    CONSTRAINT [PK_Country] PRIMARY KEY CLUSTERED ([CountryId] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_Country_ClientId] FOREIGN KEY ([ClientId]) REFERENCES [dbo].[Client] ([ClientId])
);

