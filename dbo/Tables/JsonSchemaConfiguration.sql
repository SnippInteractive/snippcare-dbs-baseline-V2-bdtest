CREATE TABLE [dbo].[JsonSchemaConfiguration] (
    [id]                INT            NOT NULL,
    [JsonSchemaVersion] NVARCHAR (30)  NULL,
    [JsonSchemaType]    NVARCHAR (30)  NULL,
    [JsonSchema]        NVARCHAR (MAX) NULL
);

