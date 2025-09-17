CREATE TABLE [dbo].[UserPets] (
    [UserPetId]       INT           IDENTITY (1, 1) NOT NULL,
    [UserId]          INT           NOT NULL,
    [IsPrimary]       BIT           NOT NULL,
    [DateOfBirth]     DATETIME      NULL,
    [BirthdayAwarded] DATETIME      NULL,
    [PetName]         VARCHAR (250) NULL,
    [PetType]         VARCHAR (50)  NULL,
    [ProfileUrl]      VARCHAR (250) NULL,
    [Reference]       VARCHAR (25)  NULL,
    [CreatedAt]       DATETIME      NULL,
    [ModifiedAt]      DATETIME      NULL,
    [Status]          VARCHAR (25)  NULL,
    CONSTRAINT [FK_UserPets] FOREIGN KEY ([UserId]) REFERENCES [dbo].[User] ([UserId])
);

