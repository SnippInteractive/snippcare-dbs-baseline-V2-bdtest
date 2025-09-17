CREATE TABLE [dbo].[MemberMasterData] (
    [Id]            INT           IDENTITY (1, 1) NOT NULL,
    [ExtReference]  VARCHAR (100) NULL,
    [FirstName]     VARCHAR (100) NULL,
    [LastName]      VARCHAR (100) NULL,
    [Email]         VARCHAR (100) NULL,
    [ClientId]      INT           NULL,
    [SiteId]        INT           NULL,
    [ExtensionData] VARCHAR (MAX) NULL,
    CONSTRAINT [PK_RegistrationMasterData_Id] PRIMARY KEY CLUSTERED ([Id] ASC)
);

