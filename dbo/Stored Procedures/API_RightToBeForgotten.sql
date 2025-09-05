CREATE Procedure [dbo].[API_RightToBeForgotten](@deviceId nvarchar(25), @userid int,@remarks Varchar(max)) as   
  
Begin  
 Declare @nameIdentifier as varchar(250) = '';
		
		Select @nameIdentifier =  NameIdentifier from [User] U WHERE U.UserId = @userId 
		IF ISNULL(@nameIdentifier ,'') <> ''
		BEGIN
			Delete from AuthServer..[AspNetUsers] where Id = @nameIdentifier
		END

 EXEC [DBHelper].[RightToBeForgotten] @DeviceID,@userid,@remarks 
END