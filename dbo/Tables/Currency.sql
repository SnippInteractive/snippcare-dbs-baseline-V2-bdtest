CREATE TABLE [dbo].[Currency] (
    [Id]           INT           IDENTITY (1, 1) NOT NULL,
    [Version]      INT           CONSTRAINT [DF_Currency_Version] DEFAULT ((0)) NOT NULL,
    [Code]         NCHAR (3)     NULL,
    [Name]         VARCHAR (100) NULL,
    [ModifiedDate] DATETIME2 (7) CONSTRAINT [DF_Currency_ModifiedDate] DEFAULT (getdate()) NOT NULL,
    [ClientId]     INT           NOT NULL,
    [Display]      BIT           NOT NULL,
    CONSTRAINT [PK_Currency] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_Currency_Client] FOREIGN KEY ([ClientId]) REFERENCES [dbo].[Client] ([ClientId])
);


GO
ALTER TABLE [dbo].[Currency] ENABLE CHANGE_TRACKING WITH (TRACK_COLUMNS_UPDATED = ON);

