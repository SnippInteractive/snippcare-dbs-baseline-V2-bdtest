CREATE TABLE [dbo].[Address] (
    [AddressId]                    INT           IDENTITY (1, 1) NOT NULL,
    [Version]                      INT           CONSTRAINT [DF_Address_Version] DEFAULT ((0)) NOT NULL,
    [AddressTypeId]                INT           NOT NULL,
    [AddressStatusId]              INT           NOT NULL,
    [AddressLine1]                 VARCHAR (100) NULL,
    [AddressLine2]                 VARCHAR (100) NULL,
    [HouseName]                    VARCHAR (80)  NULL,
    [HouseNumber]                  VARCHAR (50)  NULL,
    [Street]                       VARCHAR (80)  NULL,
    [Locality]                     VARCHAR (80)  NULL,
    [City]                         VARCHAR (60)  NULL,
    [Zip]                          VARCHAR (50)  NULL,
    [CountryId]                    INT           NOT NULL,
    [ValidFromDate]                DATETIME      NULL,
    [AddressValidStatusId]         INT           NOT NULL,
    [PostBox]                      INT           NULL,
    [PostBoxNumber]                VARCHAR (50)  NULL,
    [ContactDetailsId]             INT           NULL,
    [LastUpdatedBy]                INT           NULL,
    [LastUpdated]                  DATETIME      NULL,
    [PhoneticStreetPrimaryKey]     VARCHAR (4)   NULL,
    [PhoneticStreetAlternativeKey] VARCHAR (4)   NULL,
    [PhoneticCityPrimaryKey]       VARCHAR (4)   NULL,
    [PhoneticCityAlternativeKey]   VARCHAR (4)   NULL,
    [Notes]                        VARCHAR (500) NULL,
    [StateId]                      INT           NULL,
    CONSTRAINT [PK_Address_1] PRIMARY KEY CLUSTERED ([AddressId] ASC) WITH (FILLFACTOR = 95),
    CONSTRAINT [FK_Address_AddressStatus] FOREIGN KEY ([AddressStatusId]) REFERENCES [dbo].[AddressStatus] ([AddressStatusId]),
    CONSTRAINT [FK_Address_AddressType] FOREIGN KEY ([AddressTypeId]) REFERENCES [dbo].[AddressType] ([AddressTypeId]),
    CONSTRAINT [FK_Address_AddressValidStatus] FOREIGN KEY ([AddressValidStatusId]) REFERENCES [dbo].[AddressValidStatus] ([AddressValidStatusId]),
    CONSTRAINT [FK_Address_ContactDetails] FOREIGN KEY ([ContactDetailsId]) REFERENCES [dbo].[ContactDetails] ([ContactDetailsId]),
    CONSTRAINT [FK_Address_Country] FOREIGN KEY ([CountryId]) REFERENCES [dbo].[Country] ([CountryId]),
    CONSTRAINT [FK_Address_LastUpdatedBy] FOREIGN KEY ([LastUpdatedBy]) REFERENCES [dbo].[User] ([UserId])
);


GO
ALTER TABLE [dbo].[Address] ENABLE CHANGE_TRACKING WITH (TRACK_COLUMNS_UPDATED = ON);


GO
CREATE NONCLUSTERED INDEX [Address_AddressStatusId]
    ON [dbo].[Address]([AddressStatusId] ASC)
    INCLUDE([AddressId], [AddressValidStatusId]) WITH (FILLFACTOR = 95);


GO
CREATE NONCLUSTERED INDEX [Address_Country]
    ON [dbo].[Address]([CountryId] ASC)
    INCLUDE([AddressId], [AddressStatusId], [AddressTypeId], [AddressValidStatusId]) WITH (FILLFACTOR = 95);


GO
CREATE NONCLUSTERED INDEX [IX_Address_AddressTypeId_AddressStatusId_City_CountryId]
    ON [dbo].[Address]([AddressTypeId] ASC, [AddressStatusId] ASC, [City] ASC, [CountryId] ASC)
    INCLUDE([AddressId], [HouseNumber], [Street], [Zip]);

