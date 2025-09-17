CREATE TABLE [dbo].[UserProfileExtraInfo] (
    [UserProfileExtraInfoId] INT             IDENTITY (1, 1) NOT NULL,
    [UserId]                 INT             NULL,
    [SocialSecurity]         VARCHAR (50)    NULL,
    [Covercard]              VARCHAR (20)    NULL,
    [MpiId]                  VARCHAR (13)    NULL,
    [BodyWeight]             DECIMAL (18, 2) NULL,
    [BodyHeight]             DECIMAL (18, 2) NULL,
    [Waist]                  DECIMAL (18, 2) NULL,
    [Insurance]              VARCHAR (200)   NULL,
    [InsuranceNumber]        VARCHAR (50)    NULL,
    PRIMARY KEY CLUSTERED ([UserProfileExtraInfoId] ASC)
);

