CREATE TABLE [dbo].[SegFieldType] (
    [FieldTypeId] TINYINT    NOT NULL,
    [Description] NCHAR (20) NULL,
    CONSTRAINT [PK_SegFieldType] PRIMARY KEY CLUSTERED ([FieldTypeId] ASC) WITH (FILLFACTOR = 100)
);

