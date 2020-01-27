
-- TABLAS NOMBRE Y CANTIDAD
SELECT 'TABLAS NOMBRE Y CANTIDAD' as test, COUNT(*) = 9 as passed
FROM information_schema.tables  
WHERE table_catalog = current_catalog
AND  table_schema = 'public'
AND table_name IN ('carrera', 'carrera_usuario', 'comentario', 'grupo', 'grupo_usuario', 'usuario', 'like_comentario', 'like_publicacion', 'publicacion')
UNION 
--columnas por tabla
SELECT 'Columnas por tabla',count(*) = 9 FROM (
SELECT table_name, count(*) 
FROM information_schema.columns  
WHERE table_catalog = current_catalog
AND  table_schema = 'public'
AND table_name IN ('carrera', 'carrera_usuario', 'comentario', 'grupo', 'grupo_usuario', 'usuario', 'like_comentario', 'like_publicacion', 'publicacion')
GROUP BY table_name
HAVING 
(table_name = 'carrera' AND count(*)=2 )
OR (table_name = 'like_publicacion' AND count(*)=4 )
OR (table_name = 'carrera_usuario' AND count(*)=2 )
OR (table_name = 'grupo' AND count(*)=3 )
OR (table_name = 'like_comentario' AND count(*)=4 )
OR (table_name = 'publicacion' AND count(*)=6 )
OR (table_name = 'usuario' AND count(*)=7 )
OR (table_name = 'comentario' AND count(*)=5 )
OR (table_name = 'grupo_usuario' AND count(*)=2 )) t
UNION
-- PKs
 SELECT 'PKs', count(*) = 9 FROM
(SELECT kc.table_name, count(*)
FROM information_schema.table_constraints tc  
JOIN information_schema.key_column_usage kc  ON kc.table_name = tc.table_name AND kc.table_schema = tc.table_schema AND kc.constraint_name = tc.constraint_name
WHERE tc.constraint_type = 'PRIMARY KEY' 
AND tc.table_name IN ('carrera', 'carrera_usuario', 'comentario', 'grupo', 'grupo_usuario', 'usuario', 'like_comentario', 'like_publicacion', 'publicacion')
GROUP BY kc.table_name
HAVING (kc.table_name = 'carrera' AND count(*)=1 )
OR (kc.table_name = 'like_publicacion' AND count(*)=2 )
OR (kc.table_name = 'carrera_usuario' AND count(*)=2 )
OR (kc.table_name = 'grupo' AND count(*)=1 )
OR (kc.table_name = 'like_comentario' AND count(*)=2 )
OR (kc.table_name = 'publicacion' AND count(*)=1 )
OR (kc.table_name = 'usuario' AND count(*)=1 )
OR (kc.table_name = 'comentario' AND count(*)=1 )
OR (kc.table_name = 'grupo_usuario' AND count(*)=2 )) t