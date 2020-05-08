USE [LLAMA_BKL]
GO

/****** Object:  StoredProcedure [dbo].[UpdateDMZ_DB]    Script Date: 5/8/2020 5:19:47 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



ALTER PROCEDURE [dbo].[UpdateDMZ_DB]
AS   

--Limpa a tabela de DMZ, pra garantir que nenhum lixo deixado por atacantes permaneca
EXEC "3.22.85.163".[LLAMA_BKL].[sys].[sp_executesql] N'TRUNCATE TABLE dbo.Balancy'



--Atualiza a tabela da DMZ
--INSERT INTO "3.22.85.163".[LLAMA_BKL].[dbo].[Transfer]([FromAccount],[ToAccount],[Value],[Date])(SELECT [FromAccount],[ToAccount],[Value],[Date] FROM [LLAMA_BKL].[dbo].[PreTransfer])
INSERT INTO "3.22.85.163".[LLAMA_BKL].[dbo].[Balancy]([Account],[Value])(SELECT [Account],[Value] FROM [LLAMA_BKL].[dbo].[Balancy])


GO


