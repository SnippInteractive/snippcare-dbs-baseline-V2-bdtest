CREATE TABLE [dbo].[UIGridConfigurations] (
    [GridConfigId] INT           IDENTITY (1, 1) NOT NULL,
    [Version]      INT           CONSTRAINT [DF_UIGridConfigurations_Version] DEFAULT ((0)) NOT NULL,
    [GridName]     VARCHAR (75)  NULL,
    [ColumnName]   VARCHAR (100) NULL,
    [Databinding]  VARCHAR (100) NULL,
    [DisplayOrder] INT           NOT NULL,
    [ClientId]     INT           NOT NULL,
    CONSTRAINT [PK_UIGridConfigurations] PRIMARY KEY CLUSTERED ([GridConfigId] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_UIGridConfigurations_Client] FOREIGN KEY ([ClientId]) REFERENCES [dbo].[Client] ([ClientId])
);

