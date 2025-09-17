CREATE TABLE [dbo].[PersonalDetails] (
    [PersonalDetailsId]               INT           IDENTITY (1, 1) NOT NULL,
    [Version]                         INT           CONSTRAINT [DF_PersonalDetails_Version] DEFAULT ((0)) NOT NULL,
    [Firstname]                       NVARCHAR (50) NULL,
    [Lastname]                        NVARCHAR (70) NULL,
    [Middlename]                      VARCHAR (50)  NULL,
    [DateOfBirth]                     DATETIME      NULL,
    [GenderTypeId]                    INT           NULL,
    [TitleTypeId]                     INT           NULL,
    [SalutationId]                    INT           NULL,
    [NationalityId]                   INT           NULL,
    [ReferenceId]                     INT           NULL,
    [PhoneticFirstnamePrimaryKey]     VARCHAR (4)   NULL,
    [PhoneticFirstnameAlternativeKey] VARCHAR (4)   NULL,
    [PhoneticLastnamePrimaryKey]      VARCHAR (4)   NULL,
    [PhoneticLastnameAlternativeKey]  VARCHAR (4)   NULL,
    [LastUpdated]                     DATETIME      NULL,
    [Title]                           VARCHAR (25)  NULL,
    CONSTRAINT [PK_PersonalDetails] PRIMARY KEY CLUSTERED ([PersonalDetailsId] ASC) WITH (FILLFACTOR = 95),
    CONSTRAINT [FK_PersonalDetails_GenderType] FOREIGN KEY ([GenderTypeId]) REFERENCES [dbo].[GenderType] ([GenderTypeId]),
    CONSTRAINT [FK_PersonalDetails_Nationality] FOREIGN KEY ([NationalityId]) REFERENCES [dbo].[Nationality] ([NationalityId]),
    CONSTRAINT [FK_PersonalDetails_SalutationType] FOREIGN KEY ([SalutationId]) REFERENCES [dbo].[SalutationType] ([SalutationTypeId]),
    CONSTRAINT [FK_PersonalDetails_TitleType] FOREIGN KEY ([TitleTypeId]) REFERENCES [dbo].[TitleType] ([TitleTypeId])
);


GO
ALTER TABLE [dbo].[PersonalDetails] ENABLE CHANGE_TRACKING WITH (TRACK_COLUMNS_UPDATED = ON);


GO
CREATE NONCLUSTERED INDEX [PD_FLD]
    ON [dbo].[PersonalDetails]([Firstname] ASC, [Lastname] ASC, [DateOfBirth] ASC) WITH (FILLFACTOR = 95);

