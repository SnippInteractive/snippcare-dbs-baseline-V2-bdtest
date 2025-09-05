CREATE TABLE [dbo].[MemberMergeStreetDictionary] (
    [Id]                   INT           IDENTITY (1, 1) NOT NULL,
    [StandardizedFormat]   NVARCHAR (50) NULL,
    [UnstandardizedFormat] NVARCHAR (50) NULL,
    [LanguageCode]         NVARCHAR (2)  NULL,
    PRIMARY KEY CLUSTERED ([Id] ASC)
);

