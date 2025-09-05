CREATE   PROCEDURE [dbo].[AssignSegment] 
( @UserId INT,
  @PromotionIds NVARCHAR(2000) =NULL,
  @Source VARCHAR(30),
  @SegmentName NVARCHAR(500) =NULL,
  @MessageType NVARCHAR(50) OUTPUT
  )
AS
BEGIN

	/**************************************************************************************    
	    
	Created By : Shivam Kislay    
	Task : AT-3277    
	  
	Also Copied for  AT-3894 - Modified By Abdul Wahab - 20-12-23  - Add validations  
	Sample Command :    
	    
DECLARE @MessageType nvarchar(50)
EXEC   [dbo].[AssignSegment] @UserId = 1420814,	@PromotionIds = N'1349', @Source = N'OFFER', 
@SegmentName = NULL,@MessageType = @MessageType OUTPUT
SELECT	@MessageType as N'@MessageType' 


DECLARE @MessageType nvarchar(50)
EXEC   [dbo].[AssignSegment] @UserId = 1420814,	@PromotionIds = null, @Source = N'OFFER', 
@SegmentName = 'Test Segment',@MessageType = @MessageType OUTPUT
SELECT	@MessageType as N'@MessageType' 
	    
	****************************************************************************************/

	DECLARE @SegmentId INT
		   ,@Index INT = 0
		   ,@TotalRecords INT
		   ,@PromotionId INT;

	DECLARE @TempPromotion TABLE (Id INT ,RowNo INT)

	--Atleast one of the PromotionIds and SegmentName is mandatory
	IF CONCAT(ISNULL(@PromotionIds, ''), ISNULL(@SegmentName, '')) <> '' AND @UserId > 0
	BEGIN
		INSERT @TempPromotion (Id, RowNo)
			SELECT	token ,ROW_NUMBER() OVER (ORDER BY token ASC) AS RowNo
			FROM SplitString(@PromotionIds, ',')
			WHERE token <> ''
		
		SELECT @TotalRecords = COUNT(*)
		FROM @TempPromotion

		IF NOT EXISTS (SELECT 1	FROM [User]	WHERE UserId = @UserId)
		BEGIN
			SET @MessageType = 'InvalidMemberId'
			RETURN
		END

		IF ISNULL(@PromotionIds,'') <> ''
		BEGIN
			IF NOT EXISTS (SELECT 1	FROM Promotion	WHERE Id IN (SELECT	Id FROM @TempPromotion))
			BEGIN
				SET @MessageType = 'InvalidPromotionIds'
				RETURN
			END
		END

		--If promotion is not provided and SegmentName is provided then set @TotalRecords from @SegmentName
		IF ISNULL(@PromotionIds,'') = '' AND @SegmentName IS NOT NULL 
		BEGIN  
        	IF EXISTS(SELECT TOP 1 SegmentId FROM SegmentAdmin 	WHERE Name = @SegmentName)
			BEGIN
				SET @TotalRecords = 1
			END
			ELSE
			BEGIN
            	SET @MessageType = 'InvalidSegment'
				RETURN
            END
        END
       
		WHILE @Index < @TotalRecords
		BEGIN
		
			SELECT @PromotionId = Id
			FROM @TempPromotion
			WHERE RowNo = @Index + 1

			SELECT TOP 1 @SegmentId = sa.segmentId
			FROM SegmentAdmin sa
			LEFT JOIN Promotion p ON sa.[Name] = p.[Name]
			WHERE (@PromotionId IS NULL OR p.Id = @PromotionId)
			AND (@SegmentName IS NULL OR sa.Name =@SegmentName)

		IF @SegmentId > 0
		BEGIN
			IF NOT EXISTS (SELECT 1	FROM SegmentUsers WHERE UserId = @UserId AND SegmentId = @SegmentId)
			BEGIN
				INSERT INTO SegmentUsers (SegmentId, UserId, Source, CreatedDate)
					VALUES (@SegmentId, @UserId, @Source, GETDATE())
			END
		END
		SET @Index += 1;
		END

	END
	ELSE
	BEGIN
		SET @MessageType = 'InvalidRequest'
	END
END




--The below code is specifically for Reckitt-MX  
--CREATE PROCEDURE AssignSegment (@Clientid int, @userid int) as     

--Begin    
--declare @BabiesDaysOld table (UserID int, DaysOld Int, propertyvalue nvarchar(100),SegmentID int);    

--if isnull(@userid,0) != 0    
--Begin    
-- insert into  @BabiesDaysOld (UserID,DaysOld,propertyvalue)    
-- select u.userid, datediff(day,uled.propertyvalue,Getdate() ) DaysOld , uled.propertyvalue     
--  from UserLoyaltyExtensionData uled join [user] u on u.UserLoyaltyDataId =uled.UserLoyaltyDataId     
-- join site s on s.siteid=u.siteid  where clientid = @Clientid    
-- and  propertyname ='Child_DoB' and isdate(uled.propertyvalue) =1 and userid=@userid    
--End    
--else    
--Begin     
-- insert into  @BabiesDaysOld (UserID,DaysOld,propertyvalue)    
-- select u.userid, datediff(day,uled.propertyvalue,Getdate() ) DaysOld , uled.propertyvalue     
-- from UserLoyaltyExtensionData uled join [user] u on u.UserLoyaltyDataId =uled.UserLoyaltyDataId     
-- join site s on s.siteid=u.siteid  where clientid = @Clientid    
-- and  propertyname ='Child_DoB' and isdate(uled.propertyvalue) =1    
--End    

--SELECT [SegmentId],sa.[Name] into #WhichSegment FROM [SegmentAdmin] sa join site s on s.siteid=sa.siteid  where clientid = @Clientid    
--Alter table #WhichSegment Add DaysFrom int    
--Alter table #WhichSegment Add DaysTo int     


--update #whichSegment set DaysFrom=-300, DaysTo=-271 where [name] = 'Pregnant Month 0'     
--update #whichSegment set DaysFrom=-270, DaysTo=-241 where [name] = 'Pregnant Month 1'     
--update #whichSegment set DaysFrom=-240, DaysTo=-211 where [name] = 'Pregnant Month 2'     
--update #whichSegment set DaysFrom=-210, DaysTo=-181 where [name] = 'Pregnant Month 3'     
--update #whichSegment set DaysFrom=-180, DaysTo=-151 where [name] = 'Pregnant Month 4'     
--update #whichSegment set DaysFrom=-150, DaysTo=-121 where [name] = 'Pregnant Month 5'     
--update #whichSegment set DaysFrom=-120, DaysTo=-91 where [name] = 'Pregnant Month 6'     
--update #whichSegment set DaysFrom=-90, DaysTo=-61 where [name] = 'Pregnant Month 7'     
--update #whichSegment set DaysFrom=-60, DaysTo=-31 where [name] = 'Pregnant Month 8'     
--update #whichSegment set DaysFrom=-30, DaysTo=-1 where [name] = 'Pregnant Month 9'     
--update #whichSegment set DaysFrom=0, DaysTo=30 where [name] = 'Baby Month 1'     
--update #whichSegment set DaysFrom=31, DaysTo=60 where [name] = 'Baby Month 2'     
--update #whichSegment set DaysFrom=61, DaysTo=90 where [name] = 'Baby Month 3'     
--update #whichSegment set DaysFrom=91, DaysTo=120 where [name] = 'Baby Month 4'     
--update #whichSegment set DaysFrom=121, DaysTo=150 where [name] = 'Baby Month 5'     
--update #whichSegment set DaysFrom=151, DaysTo=180 where [name] = 'Baby Month 6'     
--update #whichSegment set DaysFrom=181, DaysTo=210 where [name] = 'Baby Month 7'     
--update #whichSegment set DaysFrom=211, DaysTo=240 where [name] = 'Baby Month 8'     
--update #whichSegment set DaysFrom=241, DaysTo=270 where [name] = 'Baby Month 9'     
--update #whichSegment set DaysFrom=271, DaysTo=300 where [name] = 'Baby Month 10'     
--update #whichSegment set DaysFrom=301, DaysTo=330 where [name] = 'Baby Month 11'     
--update #whichSegment set DaysFrom=331, DaysTo=360 where [name] = 'Baby Month 12'     
--update #whichSegment set DaysFrom=361, DaysTo=390 where [name] = 'Toddler Month 13'     
--update #whichSegment set DaysFrom=391, DaysTo=420 where [name] = 'Toddler Month 14'     
--update #whichSegment set DaysFrom=421, DaysTo=450 where [name] = 'Toddler Month 15'     
--update #whichSegment set DaysFrom=451, DaysTo=480 where [name] = 'Toddler Month 16'     
--update #whichSegment set DaysFrom=481, DaysTo=510 where [name] = 'Toddler Month 17'     
--update #whichSegment set DaysFrom=511, DaysTo=540 where [name] = 'Toddler Month 18'     
--update #whichSegment set DaysFrom=541, DaysTo=570 where [name] = 'Toddler Month 19'     
--update #whichSegment set DaysFrom=571, DaysTo=600 where [name] = 'Toddler Month 20'     
--update #whichSegment set DaysFrom=601, DaysTo=630 where [name] = 'Toddler Month 21'     
--update #whichSegment set DaysFrom=631, DaysTo=660 where [name] = 'Toddler Month 22'     
--update #whichSegment set DaysFrom=661, DaysTo=690 where [name] = 'Toddler Month 23'     
--update #whichSegment set DaysFrom=691, DaysTo=720 where [name] = 'Toddler Month 24'     
------Put them into the segment based on days old    
--update b set b.SegmentID=w.SegmentID from @BabiesDaysOld b join #whichSegment w on b.DaysOld between w.daysfrom and w.daysto     

--delete from @BabiesDaysOld where segmentid is null    

--if isnull(@userid,0) = 0    
--Begin    
-- Delete from [SegmentUsers] where segmentid in (    
-- select segmentid from #WhichSegment where daysfrom is not null)    
--end    
--else    
--Begin    
-- Delete from [SegmentUsers] where segmentid in (    
-- select segmentid from #WhichSegment where daysfrom is not null) and userid = @userid    

--End    
--insert into [SegmentUsers] ([SegmentId],[UserId],[Source],[CreatedDate])    
--select distinct segmentid,userid, 'Backround Job',getdate() from @BabiesDaysOld    
--End