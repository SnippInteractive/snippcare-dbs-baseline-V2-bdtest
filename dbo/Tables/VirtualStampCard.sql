﻿CREATE TABLE [dbo].[VirtualStampCard] (
    [Id]                 INT             IDENTITY (1, 1) NOT NULL,
    [PromotionId]        INT             NULL,
    [VoucherId]          VARCHAR (50)    NULL,
    [TrxId]              INT             NULL,
    [LineNumber]         INT             NULL,
    [PromotionValue]     DECIMAL (18, 2) NULL,
    [Quantity]           DECIMAL (18, 2) NULL,
    [NetValue]           DECIMAL (18, 2) NULL,
    [StampCardType]      NVARCHAR (25)   NULL,
    [PromotionOfferType] NVARCHAR (25)   NULL,
    [PromotionType]      NVARCHAR (20)   NULL,
    [ChildPromotionId]   INT             NULL,
    [ChildPunch]         FLOAT (53)      NULL,
    CONSTRAINT [PK_VirtualStampCard] PRIMARY KEY CLUSTERED ([Id] ASC)
);

