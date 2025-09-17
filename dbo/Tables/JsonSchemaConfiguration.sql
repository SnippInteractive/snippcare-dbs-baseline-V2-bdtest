CREATE TABLE [dbo].[JsonSchemaConfiguration] (
    [id]                INT           NOT NULL,
    [JsonSchemaVersion] VARCHAR (30)  NULL,
    [JsonSchemaType]    VARCHAR (30)  NULL,
    [JsonSchema]        VARCHAR (MAX) NULL
);

