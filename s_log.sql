
USE db_dev

GO

CREATE OR ALTER PROCEDURE s_log AS

	;WITH destino AS 
	(
		SELECT * FROM f_log
	)
	MERGE INTO destino 
	USING 
	(
		SELECT * FROM (
			SELECT *, n = ROW_NUMBER() OVER(PARTITION BY fonte, id_usuario, evento, inicio ORDER BY fim DESC) FROM(
				SELECT fonte = 'd_log_fontea', id_usuario, evento, inicio, fim, duracao = DATEDIFF(MINUTE, inicio, fim) FROM d_log_fontea
				UNION
				SELECT fonte = 'd_log_fonteb', id_usuario, evento, inicio, fim, duracao = DATEDIFF(MINUTE, inicio, fim) FROM d_log_fonteb
			)_
		)_ WHERE n = 1 

	) AS fonte
	ON  fonte.fonte = destino.fonte
	AND fonte.id_usuario = destino.id_usuario
	AND fonte.evento = destino.evento
	AND fonte.inicio = destino.inicio

	WHEN NOT MATCHED BY TARGET 
	THEN INSERT (fonte, id_usuario, evento, inicio) 
		VALUES (fonte.fonte, fonte.id_usuario, fonte.evento, fonte.inicio) 
	
	WHEN MATCHED	
	THEN UPDATE SET
		 destino.fim	 =	fonte.fim
		,destino.duracao =	fonte.duracao

	WHEN NOT MATCHED BY SOURCE THEN
		DELETE;

		SELECT * FROM f_log

GO

EXECUTE s_log
		