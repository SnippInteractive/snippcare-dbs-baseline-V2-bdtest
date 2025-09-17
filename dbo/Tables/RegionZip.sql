CREATE TABLE [dbo].[RegionZip] (
    [RegionZipID] INT           IDENTITY (1, 1) NOT NULL,
    [ClientID]    INT           NULL,
    [ZipCode]     VARCHAR (10)  NULL,
    [City]        VARCHAR (100) NULL,
    [State]       VARCHAR (2)   NULL,
    [StateName]   VARCHAR (100) NULL,
    [CountryCode] VARCHAR (2)   NULL,
    [Region]      VARCHAR (100) NULL
);


GO
CREATE UNIQUE CLUSTERED INDEX [pk_ZipAndClient]
    ON [dbo].[RegionZip]([ClientID] ASC, [ZipCode] ASC);

