CREATE TABLE [dbo].[TrxDetailItemProperties] (
    [Id]            INT            IDENTITY (1, 1) NOT NULL,
    [Version]       INT            CONSTRAINT [DF_TrxDetailItemProperties_Version] DEFAULT ((0)) NOT NULL,
    [PropertyKey]   NVARCHAR (50)  NULL,
    [PropertyValue] NVARCHAR (255) NULL,
    [TrxDetailId]   INT            NOT NULL,
    CONSTRAINT [PK_TrxDetailItemProperties] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 95),
    CONSTRAINT [FK_TrxDetailItemProperties_TrxDetail] FOREIGN KEY ([TrxDetailId]) REFERENCES [dbo].[TrxDetail] ([TrxDetailID])
);


GO
CREATE NONCLUSTERED INDEX [TrxDetailId]
    ON [dbo].[TrxDetailItemProperties]([TrxDetailId] DESC) WITH (FILLFACTOR = 95);

