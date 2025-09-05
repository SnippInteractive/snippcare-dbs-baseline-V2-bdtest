CREATE TABLE [dbo].[SegFields] (
    [SegFieldId]     SMALLINT      NOT NULL,
    [Name]           VARCHAR (20)  NULL,
    [TableName]      VARCHAR (50)  NULL,
    [FieldName]      VARCHAR (50)  NULL,
    [FieldType]      TINYINT       NOT NULL,
    [LookupTable]    VARCHAR (30)  NULL,
    [LookupName]     VARCHAR (30)  NULL,
    [LookupValue]    VARCHAR (30)  NULL,
    [LookupLang]     BIT           NULL,
    [LookupClientId] BIT           NULL,
    [DW_TableName]   NVARCHAR (50) NULL,
    [DW_FieldName]   NVARCHAR (50) NULL,
    CONSTRAINT [PK_SegFields] PRIMARY KEY CLUSTERED ([SegFieldId] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_SegFields_SegFieldType] FOREIGN KEY ([FieldType]) REFERENCES [dbo].[SegFieldType] ([FieldTypeId])
);

