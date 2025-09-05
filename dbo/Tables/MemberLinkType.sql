CREATE TABLE [dbo].[MemberLinkType] (
    [MemberLinkTypeId] INT           IDENTITY (1, 1) NOT NULL,
    [Version]          INT           CONSTRAINT [DF_MemberLinkType_Version] DEFAULT ((0)) NOT NULL,
    [Name]             NVARCHAR (75) NULL,
    [ClientId]         INT           NOT NULL,
    [Display]          BIT           CONSTRAINT [DF_MemberLinkType_Display] DEFAULT ((1)) NOT NULL,
    CONSTRAINT [PK_MemberLinkType] PRIMARY KEY CLUSTERED ([MemberLinkTypeId] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_MemberLinkType_ClientId] FOREIGN KEY ([ClientId]) REFERENCES [dbo].[Client] ([ClientId])
);

