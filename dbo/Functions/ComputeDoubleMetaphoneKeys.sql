CREATE FUNCTION [dbo].[ComputeDoubleMetaphoneKeys]
(@word NVARCHAR (4000) NULL)
RETURNS 
     TABLE (
        [Word]         NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
        [PrimaryKey]   NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
        [SecondaryKey] NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL)
AS
 EXTERNAL NAME [SQLExtensions].[SqlDoubleMetaphone].[ComputeDoubleMetaphoneKeys]

