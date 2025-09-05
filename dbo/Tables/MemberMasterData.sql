CREATE TABLE [dbo].[MemberMasterData] (
    [Id]            INT            IDENTITY (1, 1) NOT NULL,
    [ExtReference]  NVARCHAR (100) NULL,
    [FirstName]     NVARCHAR (100) NULL,
    [LastName]      NVARCHAR (100) NULL,
    [Email]         NVARCHAR (100) NULL,
    [ClientId]      INT            NULL,
    [SiteId]        INT            NULL,
    [ExtensionData] NVARCHAR (MAX) NULL,
    CONSTRAINT [PK_RegistrationMasterData_Id] PRIMARY KEY CLUSTERED ([Id] ASC)
);

