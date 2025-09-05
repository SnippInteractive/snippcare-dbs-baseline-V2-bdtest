CREATE TABLE [dbo].[MemberNews] (
    [Id]          INT            IDENTITY (1, 1) NOT NULL,
    [Name]        VARCHAR (50)   NULL,
    [Description] VARCHAR (MAX)  NULL,
    [UrlText]     VARCHAR (100)  NULL,
    [Image]       NVARCHAR (500) NULL,
    [MemberId]    INT            NULL,
    [NewsMedium]  VARCHAR (50)   NULL,
    [Link]        VARCHAR (250)  NULL,
    CONSTRAINT [PK_MemberNews] PRIMARY KEY CLUSTERED ([Id] ASC)
);

