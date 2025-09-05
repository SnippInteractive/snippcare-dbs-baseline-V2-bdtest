﻿CREATE TABLE [dbo].[ExportField] (
    [ExportFieldId] INT           NOT NULL,
    [TableName]     VARCHAR (50)  NULL,
    [FieldName]     VARCHAR (500) NULL,
    [FieldType]     TINYINT       NOT NULL,
    [FieldAlias]    VARCHAR (50)  NULL,
    CONSTRAINT [PK_ExportField] PRIMARY KEY CLUSTERED ([ExportFieldId] ASC) WITH (FILLFACTOR = 100)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'1 = string, 2= number, 3 = date, 4 = computed', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ExportField', @level2type = N'COLUMN', @level2name = N'FieldType';

