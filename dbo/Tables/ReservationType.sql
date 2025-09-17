CREATE TABLE [dbo].[ReservationType] (
    [ReservationTypeId] INT          IDENTITY (1, 1) NOT NULL,
    [Version]           INT          NOT NULL,
    [Name]              VARCHAR (50) NULL,
    [ClientId]          INT          NOT NULL,
    [Display]           BIT          NOT NULL,
    PRIMARY KEY CLUSTERED ([ReservationTypeId] ASC),
    FOREIGN KEY ([ClientId]) REFERENCES [dbo].[Client] ([ClientId])
);

