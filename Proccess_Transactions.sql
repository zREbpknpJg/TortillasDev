USE [LLAMA_BKL]
GO

/****** Object:  StoredProcedure [dbo].[ProccessTransactions]    Script Date: 5/8/2020 5:18:03 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




ALTER PROCEDURE [dbo].[ProccessTransactions]
AS   
DECLARE @TransactionId int
DECLARE @FromAccount varchar (255)
DECLARE @ToAccount varchar (255)
DECLARE @Value varchar (255)
DECLARE @Status int

    SET NOCOUNT ON;  
	DECLARE CURSOR_AUX CURSOR 
    LOCAL STATIC READ_ONLY FORWARD_ONLY
    FOR 
	--Seleciona as novas transacoes nao processadas da DMZ
		SELECT ID, FromAccount,ToAccount,Value,Status
		FROM "3.22.85.163".[LLAMA_BKL].[dbo].[PreTransfer]
		WHERE Status = 0
		order by id asc

	OPEN CURSOR_AUX
	FETCH NEXT FROM CURSOR_AUX INTO @TransactionId,@FromAccount, @ToAccount, @Value, @Status
	WHILE @@FETCH_STATUS = 0
		--Inicia o loop para cada transacao		
		BEGIN 
		--Caso 1: Quando existe saldo suficiente para realizar a transacao		
		IF (CAST((SELECT [Value] FROM [LLAMA_BKL].[dbo].[Balancy] where account = @FromAccount) AS INT)  - CAST(@Value AS INT)) >= 0
			BEGIN
			--Update source account
			UPDATE  [LLAMA_BKL].[dbo].[Balancy] SET value = ((cast(value as int) - @Value)) WHERE Account = @FromAccount;
			--Update destination account
			UPDATE  [LLAMA_BKL].[dbo].[Balancy] SET value = ((cast(value as int) + @Value)) WHERE Account = @ToAccount;
			--Update transaction status
			UPDATE  "3.22.85.163".[LLAMA_BKL].[dbo].[PreTransfer] SET status = 1 WHERE ID = @TransactionId;
			END
		else
		--Caso 2: Naoo existe saldo suficiente para transacao, atualiza como invalido
			UPDATE  "3.22.85.163".[LLAMA_BKL].[dbo].[PreTransfer] SET status = 2 WHERE ID = @TransactionId;	
		FETCH NEXT FROM CURSOR_AUX INTO @TransactionId,@FromAccount, @ToAccount, @Value, @Status
	END
	CLOSE CURSOR_AUX
	DEALLOCATE CURSOR_AUX
GO


