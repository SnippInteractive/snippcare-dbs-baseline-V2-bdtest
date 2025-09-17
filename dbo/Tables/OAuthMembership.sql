CREATE TABLE [dbo].[OAuthMembership] (
    [Id]             INT           IDENTITY (1, 1) NOT NULL,
    [Provider]       VARCHAR (30)  NULL,
    [ProviderUserId] VARCHAR (100) NULL,
    [UserId]         INT           NOT NULL,
    [Version]        INT           CONSTRAINT [DF_OAuthMembership_Version] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_OAuthMembership] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_OAuthMembership_User] FOREIGN KEY ([UserId]) REFERENCES [dbo].[User] ([UserId]),
    CONSTRAINT [IX_OAuthMembership] UNIQUE NONCLUSTERED ([Provider] ASC, [ProviderUserId] ASC) WITH (FILLFACTOR = 100)
);

