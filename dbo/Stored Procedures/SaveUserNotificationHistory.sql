
CREATE PROCEDURE SaveUserNotificationHistory
(
	@NotificationId			INT,
	@NotificationStatusId	INT,
	@ClientId				INT
)
AS
BEGIN

	DECLARE @NotificationStatus NVARCHAR(100) = ''

	SELECT @NotificationStatus = Name 
	FROM NotificationStatus 
	WHERE NotificationStatusId = @NotificationStatusId

	BEGIN TRY
		IF ISNULL(@NotificationId,0) > 0 AND ISNULL(@NotificationStatusId,0) > 0 AND @NotificationStatus = 'Publish'
		BEGIN
			INSERT INTO UserNotificationHistory(UserId,UserNotificationId,PublishDateTime,NotificationStatusId)

			SELECT		su.UserId,un.UserNotificationId, GETDATE() AS PublishDateTime,@NotificationStatusId
			FROM		UserNotifications un
			INNER JOIN	SegmentUsers su
			ON			un.UserSegmentId = su.SegmentId
			WHERE		un.NotificationId = @NotificationId 

			UNION ALL

			SELECT		u.UserId,unot.UserNotificationId,GETDATE() AS PublishDateTime,@NotificationStatusId
			FROM
			(
				SELECT		DISTINCT un.UserNotificationId 
				FROM		UserNotifications un
				WHERE		un.NotificationId = @NotificationId
				AND			un.UserSegmentId = -1
			) unot

			CROSS JOIN
			(
				SELECT		u.UserId
				FROM		[User] u
				INNER JOIN  UserStatus us
				ON			u.UserStatusId = us.UserStatusId
				INNER JOIN  UserType ut
				ON			u.UserTypeId = ut.UserTypeId
				WHERE		us.ClientId = @ClientId
				AND			ut.ClientId = @ClientId
				AND			us.Name = 'Active'
				AND			ut.Name = 'LoyaltyMember'

			)u

		END
		SELECT '1' AS Result
	END TRY
	BEGIN CATCH
		SELECT '0' AS Result
	END CATCH
END
