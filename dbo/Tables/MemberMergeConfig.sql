CREATE TABLE [dbo].[MemberMergeConfig] (
    [MemberMergeConfigId]       INT        IDENTITY (1, 1) NOT NULL,
    [MinPotentialDupLevel]      FLOAT (53) NOT NULL,
    [MinActualDupLevel]         FLOAT (53) NOT NULL,
    [ScoreExactFirstname]       FLOAT (53) NOT NULL,
    [ScorePartialFirstname]     FLOAT (53) NOT NULL,
    [ScoreFirstLetterFirstname] FLOAT (53) NOT NULL,
    [ScoreExactLastname]        FLOAT (53) NOT NULL,
    [ScorePartialLastname]      FLOAT (53) NOT NULL,
    [ScoreDateOfBirth]          FLOAT (53) NOT NULL,
    [ScoreExactHouseNumber]     FLOAT (53) NOT NULL,
    [ScorePartialHouseNumber]   FLOAT (53) NOT NULL,
    [ScoreExactStreet]          FLOAT (53) NOT NULL,
    [ScorePartialStreet]        FLOAT (53) NOT NULL,
    [ScoreExactCity]            FLOAT (53) NOT NULL,
    [ScorePartialCity]          FLOAT (53) NOT NULL,
    [ScoreExactZip]             FLOAT (53) DEFAULT ((0)) NOT NULL,
    [ScorePartialZip]           FLOAT (53) DEFAULT ((0)) NOT NULL,
    PRIMARY KEY CLUSTERED ([MemberMergeConfigId] ASC),
    CHECK ([ScorePartialStreet]>=(0) AND [ScorePartialStreet]<=[ScoreExactStreet])
);

