CREATE FUNCTION [dbo].[GenerateRandomNumbers]
(@prefix NVARCHAR (4000) NULL, @numberLength INT NULL, @numberDevicesToGenerate NUMERIC (18) NULL, @suffix NVARCHAR (4000) NULL)
RETURNS 
     TABLE (
        [RandomNumber] NVARCHAR (50) COLLATE Latin1_General_CI_AS NULL)
AS
 EXTERNAL NAME [SQLExtensions].[RandomDeviceNumberGenerator].[GenerateRandomNumbers]

