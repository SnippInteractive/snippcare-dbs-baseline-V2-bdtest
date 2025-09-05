CREATE TABLE [dbo].[ZipCity] (
    [Id]       INT          IDENTITY (1, 1) NOT NULL,
    [Version]  INT          CONSTRAINT [DF_ZipCity_Version] DEFAULT ((0)) NOT NULL,
    [Country]  VARCHAR (3)  NULL,
    [Zip]      VARCHAR (10) NULL,
    [ZipExtra] VARCHAR (10) NULL,
    [City]     VARCHAR (50) NULL,
    CONSTRAINT [PK_ZipCity] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100)
);

