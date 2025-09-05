CREATE TABLE [dbo].[RegionZip] (
    [RegionZipID] INT            IDENTITY (1, 1) NOT NULL,
    [ClientID]    INT            NULL,
    [ZipCode]     NVARCHAR (10)  COLLATE Latin1_General_CI_AS NULL,
    [City]        NVARCHAR (100) NULL,
    [State]       NVARCHAR (2)   NULL,
    [StateName]   NVARCHAR (100) NULL,
    [CountryCode] NVARCHAR (2)   NULL,
    [Region]      NVARCHAR (100) NULL
);


GO
CREATE UNIQUE CLUSTERED INDEX [pk_ZipAndClient]
    ON [dbo].[RegionZip]([ClientID] ASC, [ZipCode] ASC);

