CREATE TABLE [dbo].[LoyaltyProgramme] (
    [ProgramId]               INT           IDENTITY (1, 1) NOT NULL,
    [Version]                 INT           CONSTRAINT [DF_LoyaltyProgramme_Version] DEFAULT ((0)) NOT NULL,
    [ClientId]                INT           NOT NULL,
    [Name]                    VARCHAR (100) NULL,
    [Active]                  INT           NOT NULL,
    [Tier]                    INT           NULL,
    [OffersAvailable]         INT           NULL,
    [DevicesPerMember]        INT           NOT NULL,
    [DefaultLoyaltyProfileId] INT           NULL,
    [DefaultProgramme]        INT           CONSTRAINT [DF_LoyaltyProgramme_DefaultProgramme] DEFAULT ((0)) NULL,
    CONSTRAINT [PK_LoyaltyProgramme] PRIMARY KEY CLUSTERED ([ProgramId] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_DefaultLoyaltyProfile_LoyaltyProgramme] FOREIGN KEY ([DefaultLoyaltyProfileId]) REFERENCES [dbo].[LoyaltyDeviceProfileTemplate] ([Id]),
    CONSTRAINT [FK_LoyaltyProgramme_Client] FOREIGN KEY ([ClientId]) REFERENCES [dbo].[Client] ([ClientId])
);

