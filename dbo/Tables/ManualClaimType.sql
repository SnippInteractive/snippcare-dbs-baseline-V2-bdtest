CREATE TABLE [dbo].[ManualClaimType] (
    [ManualClaimTypeId] INT           IDENTITY (1, 1) NOT NULL,
    [Version]           INT           CONSTRAINT [DF_ManualClaimType_Version] DEFAULT ((0)) NOT NULL,
    [Name]              VARCHAR (100) NULL,
    [ClientId]          INT           NOT NULL,
    [Display]           INT           CONSTRAINT [DF__ManualCla__Displ__63F8CA06] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_ManualClaimType] PRIMARY KEY CLUSTERED ([ManualClaimTypeId] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_ManualClaimType_ClientId] FOREIGN KEY ([ClientId]) REFERENCES [dbo].[Client] ([ClientId])
);

