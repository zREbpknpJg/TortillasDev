USE [LLAMA_BKL]
GO

/****** Object:  StoredProcedure [dbo].[ProccessTransactions]    Script Date: 5/7/2020 1:18:45 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[ProccessTransactions]
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
	--Selecciona nuevas transacciones DMZ sin procesar
		SELECT ID, FromAccount,ToAccount,Value,Status
		FROM "18.218.45.99".[LLAMA_BKL].[dbo].[PreTransfer]
		WHERE [ID] >= (select top 1 ID from [LLAMA_BKL].[dbo].[PreTransfer] order by ID desc) and Status = 0
		order by id asc

	OPEN CURSOR_AUX
	FETCH NEXT FROM CURSOR_AUX INTO @TransactionId,@FromAccount, @ToAccount, @Value, @Status
	WHILE @@FETCH_STATUS = 0
		--Inicia el ciclo para cada transacción.		
		BEGIN 
		--Caso 1: Cuando hay saldo suficiente para realizar la transacción		
		IF (CAST((SELECT [Value] FROM [LLAMA_BKL].[dbo].[Balancy] where account = @FromAccount) AS INT)  - CAST(@Value AS INT)) >= 0
			BEGIN
			--Update source account
			UPDATE  [LLAMA_BKL].[dbo].[Balancy] SET value = ((cast(value as int) - @Value)) WHERE Account = @FromAccount;
			--Update destination account
			UPDATE  [LLAMA_BKL].[dbo].[Balancy] SET value = ((cast(value as int) + @Value)) WHERE Account = @ToAccount;
			--Update transaction status
			UPDATE  [LLAMA_BKL].[dbo].[PreTransfer] SET status = 1 WHERE ID = @TransactionId;
			END
		else
		--Caso 2: No hay saldo suficiente para la transacción, actualice como no válido
			UPDATE  [LLAMA_BKL].[dbo].[PreTransfer] SET status = 2 WHERE ID = @TransactionId;	
		FETCH NEXT FROM CURSOR_AUX INTO @TransactionId,@FromAccount, @ToAccount, @Value, @Status
	END
	CLOSE CURSOR_AUX
	DEALLOCATE CURSOR_AUX
GO


