/*---------------------------------- 
Written : Sreejith
Date : 25 Jan 2024
Details : used in catalyst->Prog.Admin->receipt validation
-----------------------------------*/
CREATE PROCEDURE [dbo].[PostReceiptValidation]
(
	@ReceiptId			INT,/*Table Id*/
	@MemberId			INT,
	@TrxId				INT,
	@ClientId			INT,
	@Reference			NVARCHAR(50),
	@ByUserId			INT
)
AS
BEGIN
	-- update receipt to processed after successful epos call
	UPDATE	Receipt 
	Set		ProcessingStatus = 'processed', 
			SnippUserId=@MemberId 
	WHERE	ReceiptId = @ReceiptId
	-- update createdby catalyst user on transaction
	update trxheader set Memberid=@ByUserId where TrxId=@TrxId

	--Audit the change 
	Insert into Audit (Version,FieldName,UserId,NewValue,OldValue,ChangeBy,ChangeDate,Reason)
	values(1,'Receipt',@MemberId,'processed','onhold',@ByUserId,getdate(),'SnippReceiptId :'+CAST(@ReceiptId as varchar(10))+'- IPEReceiptId :'+@Reference+'- SnippTrxId :'+ CAST(@TrxId as varchar(10)))
END
