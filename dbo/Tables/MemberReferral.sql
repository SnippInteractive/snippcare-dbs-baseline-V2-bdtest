CREATE TABLE [dbo].[MemberReferral] (
    [MemberReferralId] INT          IDENTITY (1, 1) NOT NULL,
    [ReferrerId]       INT          NULL,
    [ReferredEmail]    VARCHAR (50) NULL,
    [ReferralDate]     DATETIME     DEFAULT (getdate()) NULL,
    [ActivatedDate]    DATETIME     NULL,
    [ActivationCode]   VARCHAR (50) NULL,
    PRIMARY KEY CLUSTERED ([MemberReferralId] ASC),
    FOREIGN KEY ([ReferrerId]) REFERENCES [dbo].[User] ([UserId])
);


GO
ALTER TABLE [dbo].[MemberReferral] ENABLE CHANGE_TRACKING WITH (TRACK_COLUMNS_UPDATED = ON);

