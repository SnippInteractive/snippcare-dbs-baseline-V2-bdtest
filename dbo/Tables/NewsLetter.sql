CREATE TABLE [dbo].[NewsLetter] (
    [Id]          INT            IDENTITY (1, 1) NOT NULL,
    [Name]        VARCHAR (50)   NULL,
    [Subject]     VARCHAR (50)   NULL,
    [Description] VARCHAR (200)  NULL,
    [CreatedBy]   INT            NOT NULL,
    [CreateDate]  DATETIME       NOT NULL,
    [UpdatedBy]   INT            NULL,
    [UpdateDate]  DATETIME       NULL,
    [Html]        NVARCHAR (MAX) NULL,
    [ClientId]    INT            NOT NULL,
    CONSTRAINT [PK_Templates] PRIMARY KEY CLUSTERED ([Id] ASC)
);

