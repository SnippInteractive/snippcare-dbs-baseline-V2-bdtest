CREATE TABLE [dbo].[TitleType] (
    [TitleTypeId] INT          IDENTITY (1, 1) NOT NULL,
    [Version]     INT          CONSTRAINT [DF_TitleType_Version] DEFAULT ((0)) NOT NULL,
    [Name]        VARCHAR (50) NULL,
    [ClientId]    INT          CONSTRAINT [DF_TitleType_ClientId] DEFAULT ((1)) NOT NULL,
    [Display]     BIT          CONSTRAINT [DF_TitleType_Display] DEFAULT ((1)) NOT NULL,
    CONSTRAINT [PK_TitleType] PRIMARY KEY CLUSTERED ([TitleTypeId] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_TitleType_Client] FOREIGN KEY ([ClientId]) REFERENCES [dbo].[Client] ([ClientId])
);

