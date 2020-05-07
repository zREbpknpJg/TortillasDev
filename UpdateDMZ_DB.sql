--Procedimiento utilizado para actualizar la base de datos DMZ con información de conciliación interna

USE [LLAMA_BKL]
GO

/****** Object:  StoredProcedure [dbo].[UpdateDMZ_DB]    Script Date: 5/7/2020 1:15:11 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[UpdateDMZ_DB]
AS   

--Limpie la base de DMZ, para asegurarse de que no quede informaciones erradas

EXEC "18.218.45.99".[LLAMA_BKL].[sys].[sp_executesql] N'TRUNCATE TABLE dbo.PreTransfer'
EXEC "18.218.45.99".[LLAMA_BKL].[sys].[sp_executesql] N'TRUNCATE TABLE dbo.Balancy'

--Actualiza la base de datos DMZ
INSERT INTO "18.218.45.99".[LLAMA_BKL].[dbo].[PreTransfer]([FromAccount],[ToAccount],[Value],[Date],[Status])(SELECT [FromAccount],[ToAccount],[Value],[Date],[Status] FROM [LLAMA_BKL].[dbo].[PreTransfer])
INSERT INTO "18.218.45.99".[LLAMA_BKL].[dbo].[Balancy]([Account],[Value])(SELECT [Account],[Value] FROM [LLAMA_BKL].[dbo].[Balancy])


GO

