CREATE TABLE [dbo].[VoucherSubType] (
    [VoucherSubTypeId] INT          IDENTITY (1, 1) NOT NULL,
    [Version]          INT          CONSTRAINT [DF_VoucherSubType_Version] DEFAULT ((0)) NOT NULL,
    [Name]             VARCHAR (50) NULL,
    [ClientId]         INT          NOT NULL,
    [Display]          BIT          NOT NULL,
    CONSTRAINT [PK_VoucherSubType] PRIMARY KEY CLUSTERED ([VoucherSubTypeId] ASC) WITH (FILLFACTOR = 100)
);

