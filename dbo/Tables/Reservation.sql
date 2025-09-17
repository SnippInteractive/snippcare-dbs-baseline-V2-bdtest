CREATE TABLE [dbo].[Reservation] (
    [ReservationId]       INT           IDENTITY (1, 1) NOT NULL,
    [Version]             INT           DEFAULT ((0)) NOT NULL,
    [ReservationNumber]   VARCHAR (50)  NULL,
    [ReservationStatusId] INT           NOT NULL,
    [ReservationTypeId]   INT           NOT NULL,
    [UserId]              INT           NOT NULL,
    [Notes]               VARCHAR (MAX) NULL,
    [LastUpdated]         DATETIME      DEFAULT (getdate()) NOT NULL,
    PRIMARY KEY CLUSTERED ([ReservationId] ASC),
    FOREIGN KEY ([ReservationStatusId]) REFERENCES [dbo].[ReservationStatus] ([ReservationStatusId]),
    FOREIGN KEY ([ReservationTypeId]) REFERENCES [dbo].[ReservationType] ([ReservationTypeId]),
    FOREIGN KEY ([UserId]) REFERENCES [dbo].[User] ([UserId]),
    FOREIGN KEY ([UserId]) REFERENCES [dbo].[User] ([UserId])
);


GO
CREATE NONCLUSTERED INDEX [IX_ReservationNumber]
    ON [dbo].[Reservation]([ReservationNumber] ASC);

