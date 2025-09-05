CREATE PROCEDURE [dbo].[API_SearchMemberKPI]
    @InputJSON NVARCHAR(MAX),
    @OutputJSON NVARCHAR(MAX) OUTPUT
AS
/*
Search KPI user inforamtion based on Keys for 
1. Tier Current and what is needed for the next Tier
2. the Count of Trx Redemptions the user has had
3. the Count of Trx Receipts the user has had


#EXECUTE
DECLARE @InputJSON NVARCHAR(MAX), @OutputJSON NVARCHAR(MAX);
SET @InputJSON = '{"UserId": 1403986, "Keys": "TrxValueFee,PointsNeedForNextTier,TrxCountCancelReservePoints,TrxCountRedeemPoints,TrxCountRefund,TrxCountShadowPurchase,TrxCountTransaction,TrxPointsPurchase,TrxPointsQualification,TrxPointsRedeemPoints,TrxPointsRedeemPoints,TrxPointsReservation,TrxPointsReturn,TrxPointsShadowPurchase,TrxValueVoid,TrxValueTransaction"}';
EXEC [dbo].[API_SearchMemberKPI] @InputJSON, @OutputJSON OUTPUT;
SELECT @OutputJSON AS Result;
*/
BEGIN
    DECLARE @userid INT,
            @Keys NVARCHAR(MAX);

    -- Extract UserId and Keys from input JSON
    SELECT @userid = JSON_VALUE(@InputJSON, '$.UserId'),
           @Keys = ISNULL(JSON_VALUE(@InputJSON, '$.Keys'), '');

    -- Table to store filtered keys
    DECLARE @FilteredKeys TABLE (PropertyName NVARCHAR(100));

    -- Parse and clean the keys
    ;WITH SplitKeys AS (
        SELECT DISTINCT value AS OriginalKey,
               CASE 
                   WHEN value LIKE 'TrxValue%' THEN SUBSTRING(value, 9, LEN(value))
                   WHEN value LIKE 'TrxPoints%' THEN SUBSTRING(value, 10, LEN(value))
                   WHEN value LIKE 'TrxCount%' THEN SUBSTRING(value, 9, LEN(value))
                   WHEN value LIKE 'TrxDetails%' THEN SUBSTRING(value, 11, LEN(value))
                   ELSE value
               END AS CleanKey
        FROM STRING_SPLIT(@Keys, ',')
        WHERE NULLIF(value, '') IS NOT NULL
    )
    INSERT INTO @FilteredKeys
    SELECT DISTINCT OriginalKey
    FROM SplitKeys;

    -- Table to store results
    DECLARE @ResultsTable TABLE (
        UserID INT NOT NULL,
        PropertyName NVARCHAR(50),
        PropertyValue NVARCHAR(MAX),
        ModifiedDate DATETIME
    );

    -- Get ClientId for the user
    DECLARE @Clientid INT;
    SELECT @Clientid = s.clientid
    FROM site s 
    JOIN client c ON c.clientid = s.clientid
    JOIN [user] u ON u.siteid = s.siteid 
    WHERE u.UserId = @userid;

    -- Process Tier-related data
    IF EXISTS (SELECT 1 FROM @FilteredKeys WHERE PropertyName IN ('TierPoints'))
    BEGIN
        DECLARE @TierPointsBalance DECIMAL(18,2);

        SELECT @TierPointsBalance = CAST(ISNULL(PropertyValue, 0) AS DECIMAL(18,2))
        FROM [User] U 
        INNER JOIN UserLoyaltyData ULD ON U.UserLoyaltyDataId = ULD.UserLoyaltyDataId
        INNER JOIN UserLoyaltyExtensionData ULED ON ULD.UserLoyaltyDataId = ULED.UserLoyaltyDataId
        WHERE UserId = @userid AND PropertyName = 'TierPoints';

        INSERT INTO @ResultsTable
        SELECT @userid, 'TierPoints', ISNULL(CAST(@TierPointsBalance AS NVARCHAR), ''), GETDATE();
    END;

    -- Current Tier related properties
    IF EXISTS (SELECT 1 FROM @FilteredKeys WHERE PropertyName IN ('CurrentTierDescription', 'CurrentTierThreshold', 'TierImageUrl'))
    BEGIN
        DECLARE @CurrentTierDescription NVARCHAR(150),
                @CurrentTierThreshold NVARCHAR(20),
                @TierImageUrl VARCHAR(MAX),
                @TierID INT;

        SELECT @TierID = ta.id, 
               @CurrentTierThreshold = CASE WHEN EXISTS (SELECT 1 FROM @FilteredKeys WHERE PropertyName = 'CurrentTierThreshold') 
                                          THEN ta.ThresholdTo ELSE NULL END,
               @CurrentTierDescription = CASE WHEN EXISTS (SELECT 1 FROM @FilteredKeys WHERE PropertyName = 'CurrentTierDescription') 
                                            THEN ta.Description ELSE NULL END,
               @TierImageUrl = CASE WHEN EXISTS (SELECT 1 FROM @FilteredKeys WHERE PropertyName = 'TierImageUrl') 
                                   THEN ta.ImageUrl ELSE NULL END
        FROM tieradmin ta 
        JOIN tierusers tu ON ta.Id = tu.TierId
        JOIN DeviceProfileTemplate dpt ON dpt.id = ta.loyaltyprofileid 
        WHERE tu.userid = @userid;

        INSERT INTO @ResultsTable
        SELECT @userid, PropertyName, PropertyValue, GETDATE()
        FROM (
            SELECT 'CurrentTierDescription' AS PropertyName, ISNULL(@CurrentTierDescription, '') AS PropertyValue 
            WHERE EXISTS (SELECT 1 FROM @FilteredKeys WHERE PropertyName = 'CurrentTierDescription')
            UNION ALL 
            SELECT 'CurrentTierThreshold', ISNULL(@CurrentTierThreshold, '') 
            WHERE EXISTS (SELECT 1 FROM @FilteredKeys WHERE PropertyName = 'CurrentTierThreshold')
            UNION ALL 
            SELECT 'TierImageUrl', ISNULL(@TierImageUrl, '') 
            WHERE EXISTS (SELECT 1 FROM @FilteredKeys WHERE PropertyName = 'TierImageUrl')
        ) t;
    END;

    -- Next Tier related properties
    IF EXISTS (SELECT 1 FROM @FilteredKeys WHERE PropertyName IN ('NextTierDescription', 'PointsNeedForNextTier'))
    BEGIN
        DECLARE @NextTierDescription NVARCHAR(150),
                @NextTierThreshold NVARCHAR(20),
                @PointsNeedForNextTier INT,
                @CurrentThreshold NVARCHAR(20);

        IF NOT EXISTS (SELECT 1 FROM @FilteredKeys WHERE PropertyName IN ('CurrentTierDescription', 'CurrentTierThreshold', 'TierImageUrl'))
        BEGIN
            SELECT @CurrentThreshold = ta.ThresholdTo
            FROM tieradmin ta 
            JOIN tierusers tu ON ta.Id = tu.TierId
            WHERE tu.userid = @userid;
        END
        ELSE
            SET @CurrentThreshold = @CurrentTierThreshold;

        -- Get next tier
        SELECT TOP 1 
               @NextTierDescription = CASE WHEN EXISTS (SELECT 1 FROM @FilteredKeys WHERE PropertyName = 'NextTierDescription') 
                                         THEN ta.description ELSE NULL END,
               @PointsNeedForNextTier = CASE WHEN EXISTS (SELECT 1 FROM @FilteredKeys WHERE PropertyName = 'PointsNeedForNextTier') 
                                            THEN ThresholdFrom - ISNULL(@TierPointsBalance, 0) ELSE NULL END
        FROM site s 
        JOIN DeviceProfileTemplate dpt ON dpt.siteid = s.siteid 
        JOIN tieradmin ta ON dpt.id = ta.loyaltyprofileid 
        WHERE clientid = @clientid AND ThresholdTo > @CurrentThreshold
        ORDER BY thresholdto ASC;

        INSERT INTO @ResultsTable
        SELECT @userid, PropertyName, PropertyValue, GETDATE()
        FROM (
            SELECT 'NextTierDescription' AS PropertyName, ISNULL(@NextTierDescription, '') AS PropertyValue
            WHERE EXISTS (SELECT 1 FROM @FilteredKeys WHERE PropertyName = 'NextTierDescription')
            UNION ALL 
            SELECT 'PointsNeedForNextTier', ISNULL(CAST(@PointsNeedForNextTier AS NVARCHAR), '') 
            WHERE EXISTS (SELECT 1 FROM @FilteredKeys WHERE PropertyName = 'PointsNeedForNextTier')
        ) t;
    END;

    -- Process Transaction data
    IF EXISTS (SELECT 1 FROM @FilteredKeys WHERE PropertyName LIKE 'Trx%')
    BEGIN
        DECLARE @TrxStatusid_Complete INT = (
            SELECT TrxstatusId 
            FROM trxstatus 
            WHERE name = 'Completed' 
            AND clientid = @Clientid
        );

        WITH RequestedMetrics AS (
            SELECT 
                PropertyName,
                CASE 
                    WHEN PropertyName LIKE 'TrxValue%' THEN SUBSTRING(PropertyName, 9, LEN(PropertyName))
                    WHEN PropertyName LIKE 'TrxPoints%' THEN SUBSTRING(PropertyName, 10, LEN(PropertyName))
                    WHEN PropertyName LIKE 'TrxCount%' THEN SUBSTRING(PropertyName, 9, LEN(PropertyName))
                END AS TrxType,
                CASE WHEN PropertyName LIKE 'TrxValue%' THEN 1 ELSE 0 END AS NeedValue,
                CASE WHEN PropertyName LIKE 'TrxPoints%' THEN 1 ELSE 0 END AS NeedPoints,
                CASE WHEN PropertyName LIKE 'TrxCount%' THEN 1 ELSE 0 END AS NeedCount
            FROM @FilteredKeys
            WHERE PropertyName LIKE 'Trx%'
        ),
        MetricsResult AS (
            SELECT 
                rm.PropertyName,
                ISNULL(
                    CAST(
                        CASE 
                            WHEN rm.NeedValue = 1 THEN SUM(td.Value)
                            WHEN rm.NeedPoints = 1 THEN SUM(td.Points)
                            ELSE COUNT(DISTINCT th.Trxid)
                        END AS NVARCHAR
                    ),
                    '0'
                ) AS PropertyValue
            FROM RequestedMetrics rm
            LEFT JOIN trxtype tt ON tt.name COLLATE database_default = rm.TrxType
            LEFT JOIN trxheader th ON th.trxtypeid = tt.TrxTypeId 
            AND th.TrxStatusTypeId = @TrxStatusid_Complete 
            LEFT JOIN device dv ON dv.deviceid = th.deviceid AND dv.userid = @userid
            LEFT JOIN trxdetail td ON td.trxid = th.trxid
            GROUP BY 
                rm.PropertyName,
                rm.NeedValue,
                rm.NeedPoints,
                rm.NeedCount
        )
        INSERT INTO @ResultsTable
        SELECT 
            @userid,
            rm.PropertyName,
            ISNULL(mr.PropertyValue, '0'),
            GETDATE()
        FROM RequestedMetrics rm
        LEFT JOIN MetricsResult mr ON mr.PropertyName = rm.PropertyName;
    END;

    -- Process Points Balance
    IF EXISTS (SELECT 1 FROM @FilteredKeys WHERE PropertyName = 'CurrentPointsBalance')
    BEGIN
        DECLARE @PointsBalance DECIMAL(18,2);

        SELECT @PointsBalance = SUM(pointsBalance) 
        FROM Account 
        WHERE userid = @userid;

        INSERT INTO @ResultsTable
        SELECT @userid, 'CurrentPointsBalance', ISNULL(CAST(@PointsBalance AS NVARCHAR), '0'), GETDATE();
    END;

    -- Process Tier Definition
    IF EXISTS (SELECT 1 FROM @FilteredKeys WHERE PropertyName = 'TierDefinition')
    BEGIN
        DECLARE @TierLogic NVARCHAR(MAX);

        SELECT @TierLogic = (
            SELECT DP.Name AS 'TierName',
                   TA.Description AS 'TierDesription',
                   TA.ThresholdFrom AS 'TierStartThreshold',
                   TA.ThresholdTo AS 'TierEndThreshold'
            FROM TierAdmin TA 
            INNER JOIN DeviceProfileTemplate DP ON TA.loyaltyprofileid = DP.Id
            INNER JOIN [Site] S ON S.SiteId = DP.SiteId
            WHERE S.ClientId = @Clientid 
            FOR JSON PATH
        );

        INSERT INTO @ResultsTable
        SELECT @userid, 'TierDefinition', ISNULL(@TierLogic, '0'), GETDATE();
    END;

    -- Set the output JSON
    SET @OutputJSON = (SELECT * FROM @ResultsTable FOR JSON AUTO);
END;