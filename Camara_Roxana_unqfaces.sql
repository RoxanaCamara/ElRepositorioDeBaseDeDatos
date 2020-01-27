--TP DE SQL------
--EJERCICIO 1 listoo

CREATE TABLE carrera(
	id_carrera SERIAL,
	nombre VARCHAR(200) NOT NULL,
	PRIMARY KEY (id_carrera)
);

CREATE TABLE usuario(
	id SERIAL NOT NULL,
	nombre VARCHAR(100),
	apellido VARCHAR(100),
	username VARCHAR(100),
	contrasenia VARCHAR(100),
	fecha_nacimiento DATE,
	email VARCHAR(100),
	id_carrera INT,
	PRIMARY KEY (id),
	CONSTRAINT fk_usuario_id_carrera FOREIGN KEY (id_carrera)
	REFERENCES carrera(id_carrera) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE CASCADE
);

CREATE TABLE grupo(
	id_grupo SERIAL NOT NULL,
	nombre_grupo VARCHAR(100),
	requiere_invitacion BOOLEAN, 
	PRIMARY KEY(id_grupo)
);

CREATE TABLE grupo_usuario(
	id_grupo INT,
	id_user INT,
	PRIMARY KEY(id_grupo, id_user),
	CONSTRAINT fk_grupo_usuario_id_grupo FOREIGN KEY (id_grupo)
	REFERENCES grupo(id_grupo),
	CONSTRAINT fk_grupo_usuario_id_user FOREIGN KEY(id_user)
	REFERENCES usuario(id)
);

CREATE TABLE publicacion(
	id_public SERIAL ,
	id_user INT,
	id_grupo INT,
	titulo VARCHAR(100),
	contenido nchar varying ,
	fecha_publicacion TIMESTAMP,
	PRIMARY KEY(id_public),
	CONSTRAINT fk_publicacion_id_user FOREIGN KEY(id_user)
	REFERENCES usuario(id),
	CONSTRAINT fk_publicacion_id_grupo FOREIGN KEY(id_grupo)
	REFERENCES grupo(id_grupo)
);

CREATE TABLE comentario(
	id_coment SERIAL,
	id_public INT NOT NULL,
	id_user INT NOT NULL,
	contenido nchar varying ,
	fecha_comentario TIMESTAMP,
	PRIMARY KEY(id_coment),
	CONSTRAINT fk_comentario_id_public FOREIGN KEY(id_public)
	REFERENCES publicacion(id_public),
	CONSTRAINT fk_comentario_id_user FOREIGN KEY(id_user)
	REFERENCES usuario(id)
);

CREATE TABLE like_publicacion(
	id_public INT,
	id_user INT,
	positivo BOOLEAN,
	fecha TIMESTAMP,
	PRIMARY KEY(id_public, id_user),
	CONSTRAINT fk_like_publicacion_id_public FOREIGN KEY(id_public)
	REFERENCES publicacion(id_public),
	CONSTRAINT fk_like_publicacion_id_user FOREIGN KEY(id_user)
	REFERENCES usuario(id)
);

CREATE TABLE like_comentario(
	id_coment INT,
	id_user INT,
	positivo BOOLEAN,
	fecha TIMESTAMP,
	PRIMARY KEY(id_coment, id_user),
	CONSTRAINT fk_like_publicacion_id_public FOREIGN KEY(id_coment)
	REFERENCES comentario(id_coment),
	CONSTRAINT fk_like_publicacion_id_user FOREIGN KEY(id_user)
	REFERENCES usuario(id)
);

---EJERCICIO 2 
--Creo una tabla que seria id(de usuario) y id_carrera(de carrera)
CREATE TABLE carrera_usuario(
id_carrera INT,
id_user INT,
PRIMARY KEY ( id_carrera, id_user)
);

--Y elimino el atributo id_carrera de usuario
ALTER TABLE usuario DROP id_carrera;

---EJERCICIO 3 --listoo
INSERT INTO usuario VALUES(1,'Matias','Silvestre','canapedemondongo','Dal41lama', '9-11-2000');

INSERT INTO carrera_usuario VALUES ((SELECT id_carrera FROM carrera WHERE nombre='Tecnicatura en Programacion'), 101);

---EJERCICIO 4 --listoo

--EJERCICIO 5 --listoo 
SELECT nombre, cantidad_de_alumnos 
FROM carrera AS c
NATURAL JOIN 
	( 
	SELECT id_carrera, count(id_user) AS cantidad_de_alumnos ---cuenta los id_user  
	FROM carrera_usuario 
	GROUP BY  id_carrera ---Se agrupa con carrera
	) AS axc
ORDER BY char_length(nombre) desc;

--EJERCICIO 6 listoo
--1-uso distinct porque la misma publicacion pueden tener mas de un dislike en un comentario o en sus comentarios.
SELECT username, nombre, apellido
FROM usuario As u
JOIN 
	(
	SELECT DISTINCT id_user 
	FROM publicacion 
	WHERE id_public IN
		(
 		SELECT id_public
		FROM like_publicacion
		WHERE positivo = true
		GROUP By id_public
		HAVING count(Positivo)>10
		)
	AND id_public NOT IN
		( ---devuelve los id_public de los comentarios que tuvieron un dislike 
		SELECT DISTINCT id_public --1
		FROM like_comentario AS lc
		JOIN comentario As c
		ON lc.id_coment= c.id_coment
		WHERE positivo=false
		) 
	) AS idf
ON u.id=idf.id_user
;

---EJERCICIO 7
--Suponiendo que el ejerciicio 6 este bien, creo una vista de una tabla similar a este y utilizo sus datos para encontrar los influencers premium

--1 Primero se realiza esto
CREATE VIEW influencers  AS
SELECT *
FROM usuario As u
JOIN 
	(
	SELECT DISTINCT id_user 
	FROM publicacion 
	WHERE id_public IN
		(---los id_public que tiene mas de 10 likes  
 		SELECT id_public
		FROM like_publicacion
		WHERE positivo = true
		GROUP By id_public
		HAVING count(Positivo)>10
		)
	AND id_public NOT IN
		(---los id_public que tuvieron alguna vez un dislike en sus comentarios
		SELECT DISTINCT id_public 
		FROM like_comentario AS lc
		JOIN comentario As c
		ON lc.id_coment= c.id_coment
		WHERE positivo=false
		) 
	) AS idf
ON u.id=idf.id_user
;

---2--Paso
--3 utilizo left join ya que me importa los likes si existe una publicacion con solo dislikes no aparecera y si una publicacion no tiene dislikes si aparecera en la tabla.
SELECT username, nombre, apellido, email
FROM influencers 
WHERE id NOT IN 
	(
	SELECT id_user
	FROM publicacion AS p
	JOIN
		( -- publicaciones con sus likes y sus dislikes  
		SELECT pl.id_public, likes, dislikes
		FROM
			(----Publicaciones con su cantidad de likes
	 		SELECT id_public, count(positivo) AS likes
			FROM like_publicacion
			WHERE positivo = true
			GROUP By id_public
			) AS pl 
		LEFT JOIN --3 
			(----Publicaciones con dislikes
	 		SELECT id_public, count(positivo) AS dislikes
			FROM like_publicacion
			WHERE positivo = false
			GROUP By id_public
			) AS pd 
		ON pl.id_public=pd.id_public 
		) AS pld 
	ON p.id_public=pld.id_public
	WHERE likes<dislikes
	GROUP BY id_user 
	)
;

--EJERCICIO 8 listoo
SELECT nombre_grupo, cantlikes, p.id_grupo
FROM grupo 
NATURAL JOIN
	(
	SELECT id_grupo, sum(likes) as cantlikes
	FROM publicacion AS p
	NATURAL JOIN	
		(
		SELECT id_public , count(positivo)as likes
		FROM like_publicacion
		WHERE positivo=true
		GROUP BY id_public 
		) AS pl ---cantidad de likes en cada publicacion 
	GROUP BY id_grupo
	) AS p
WHERE id_grupo NOT IN 
		(
		SELECT DISTINCT id_grupo --todos los grupos que tienen algun menor
		FROM usuario  
		NATURAL JOIN grupo_usuario
		WHERE date_part('year', fecha_nacimiento) >= date_part('year', now())-16 --1
		)  ---grupos de usuarios menores a 16
ORDER BY cantlikes desc
limit 6
;

--1-selecciona a los usuarios menores, que tienen su anio de nacimiento mayor al anio actual menos 16, ejemplo 2003 se proyecta y 1998 no.  


--EJERCICIO 9 --listo
SELECT username, cantDeGrupos, nombre
FROM usuario
JOIN 
	(
	SELECT id_user, count(id_grupo) AS cantDeGrupos 
	FROM grupo_usuario  
	GROUP BY id_user
	) AS ucg
ON id=id_user
ORDER BY cantDeGrupos DESC;

-----EJERCICIO 10 listoooo
SELECT 	contenido_Public,contenido_Coment,fecha_comentario, dis_likes_Coment, likes_Coment
FROM	
	(
	SELECT c.id_coment, p.contenido as contenido_Public, c.contenido as contenido_Coment, fecha_comentario
	FROM comentario AS c
	JOIN publicacion AS p
	ON c.id_public=p.id_public
	) AS c
JOIN
	(
	SELECT d.id_coment, dis_likes_Coment, likes_Coment
	FROM 
		(--comentarios con su cantidad y con dislikes mayor a 3
			SELECT id_coment, count(positivo) AS dis_likes_Coment 
			FROM like_comentario 
			WHERE positivo=false 	
			GROUP BY id_coment 
			HAVING count(id_user)>3
		) AS d
	LEFT JOIN
		( ---comentarios con su cantidad de likes
			SELECT id_coment, count(positivo) AS likes_Coment 
			FROM like_comentario 
			WHERE positivo=true
		 	GROUP BY id_coment
		) AS l
	ON d.id_coment=l.id_coment
	) id
ON c.id_coment=id.id_coment
ORDER BY dis_likes_Coment DESC, fecha_comentario
;		

---EJERCICIO 11 listoo
SELECT nombre, apellido, titulo, contenido, fecha_publicacion
FROM usuario 
JOIN 
	(
	SELECT id_user, titulo, contenido, fecha_publicacion
	FROM publicacion AS p
	JOIN  
		( ---id_pubic de publicaciones con dislike
		SELECT DISTINCT id_public 
		FROM like_publicacion 
		WHERE positivo=false
		) AS dp
	ON p.id_public=dp.id_public 
	) AS pd
ON id=id_user
;

---EJERCICIO 12 --listoo
SELECT id_grupo, max(edad) AS adulto, min(edad) AS joven, avg(edad) AS promedio
FROM grupo_usuario
JOIN 
	( 
	SELECT id, date_part('year', now()) - date_part('year', fecha_nacimiento) AS edad 
	FROM usuario
	) AS eu
ON id=id_user
GROUP BY id_grupo
;

----EJERCICIO 13
--identificar a los usuarios que hayan hecho likes a usuarios que no cursen su carrera

---1 hago un join con like publicacion asi me aseguro que son de usuarios que dieron like alguna vez, es decir aquellos usuarios que no hayan hecho like a nada no apareceran en esta tabla

SELECT u.*
FROM usuario AS u
JOIN
	(
	SELECT DISTINCT id_user 
	FROM like_publicacion ---1
	WHERE id_user NOT IN 
		( ---LIKEADORES DE USUARIOS CON SU MISMA CARRERA
		SELECT DISTINCT likeador 
		FROM
			(---TODOS LOS USUARIOS DE LAS PUBLICACIONES CON SUS CARRERAS 
			SELECT id_public,id_user AS likeado, id_carrera AS id_carrera_likeado 
			FROM publicacion
			NATURAL JOIN carrera_usuario
			) AS pcu
		JOIN
			(---TODOS LOS LIKES PUBLICACION CON SUS LIKEADORES CON SUS RESPECTIVAS CARRERAS 
			SELECT id_public,id_user AS likeador, id_carrera AS id_carrera_likeador 
			FROM like_publicacion
			NATURAL JOIN carrera_usuario
			) AS lpcu
		ON pcu.id_public=lpcu.id_public
		AND id_carrera_likeado=id_carrera_likeador 
		) 
	) AS uc
ON id=uc.id_user
;

---EJERCICIO 14 listoooo
SELECT c.*
FROM comentario As c
JOIN
	(
	SELECT id_user, max(fecha_comentario) as ultimoComentario
	FROM comentario
	GROUP BY id_user
	) AS cm 
ON c.id_user=cm.id_user AND c.fecha_comentario= cm.ultimoComentario
;

----EJERCICIO 15 --listo
--Inserto para probar si funciona la consulta
INSERT INTO usuario VALUES(101,'Rosa','Melano','MagikarpDeFuego','w99p1nb9ll', '1-12-1995','MelanoRosa153@gmail.com');
INSERT INTO carrera_usuario VALUES (1, 101);
INSERT INTO carrera_usuario VALUES (5, 101);
--Falta hacer que cuando curse mas de una carrera se una en una fila 
SELECT nombre, apellido, username, email, cu.id_carrera 
FROM usuario
JOIN carrera_usuario AS cu
ON id=id_user
AND id NOT IN 
	(SELECT id_user
	FROM publicacion
	UNION
	SELECT id_user
	FROM comentario
	UNION
	SELECT id_user
	FROM like_comentario
	UNION
	SELECT id_user
	FROM like_publicacion
	)
;

---EJERCICIO 16 --listo
SELECT (nombre ||' '|| apellido) AS Nombre_y_Apellido, date_part('year', now()) - date_part('year',fecha_nacimiento) AS edad
FROM usuario
;

----EJERCICIO 17 listooo
CREATE VIEW ultima_publicacion_de_usuarios (username, contenido, fecha_publicacion) AS
SELECT username, contenido, fecha_publicacion
FROM usuario
JOIN
	(
	SELECT p.id_user, contenido, fecha_publicacion
	FROM publicacion As p
	JOIN
		(
		SELECT id_user, max(fecha_publicacion) as ultima_publicacion
		FROM publicacion
		GROUP BY id_user
		) AS up 
	ON p.id_user=up.id_user AND p.fecha_publicacion= up.ultima_publicacion
	) cf
ON id=id_user 
;

---EJERCICIO 18 listoo
SELECT ulti.id_public, username, nombre AS autor, ulti.contenido, fecha_publicacion, likes, dislikes, Cant_comet
FROM
	(
	SELECT *
	FROM publicacion AS p
	JOIN 
		(
		SELECT  max(fecha_publicacion) AS ultima_publicacion
		FROM publicacion
		) AS f
	ON p.fecha_publicacion=f.ultima_publicacion
	) AS ulti
JOIN
	(---CANITiDAD DE DISLIKES
	SELECT p.id_public, count(positivo) AS dislikes
	FROM like_publicacion AS lp
	JOIN publicacion AS p
	ON lp.id_public=p.id_public
	WHERE positivo=false
	GROUP BY p.id_public
	) AS d
ON ulti.id_public=d.id_public
JOIN
	(---CANTIDAD DE LIKES
	SELECT p.id_public, count(positivo) AS likes
	FROM like_publicacion AS lp
	JOIN publicacion AS p
	ON lp.id_public=p.id_public
	WHERE positivo=true
	GROUP BY p.id_public
	) AS l
ON ulti.id_public=l.id_public
JOIN
	(---CANTIDAD DE COMENTARIOS
	SELECT p.id_public, count(id_coment) AS Cant_comet
	FROM publicacion AS p
	JOIN comentario AS c
	ON p.id_public=c.id_public
	GROUP BY p.id_public
	) AS c 
ON ulti.id_public=c.id_public
JOIN	----USUARIO
	usuario AS u
ON ulti.id_user=u.id
;

---EJERCICIO 19 listooo
SELECT username, likes, dislikes, diferencia
FROM usuario 
FULL JOIN
	(
	SELECT ul.id_user, likes, dislikes, likes-dislikes As diferencia
	FROM
		(
		SELECT pl.id_user, (lp+lc) AS likes
		FROM
			(---CUENTA LOS LIKES POSITIVOS DE PUBLICACION 
			SELECT p.id_user, count(positivo) AS lp
			FROM like_publicacion AS lp
			JOIN publicacion AS p
			ON lp.id_public=p.id_public
			WHERE positivo=true
			GROUP BY p.id_user
			) AS pl
		FULL JOIN
			(----CUENTA LOOS COMENTARIOS LIKE DE CADA USUARIO 
			SELECT c.id_user, count(positivo) AS lc
			FROM like_comentario AS lc
			JOIN comentario AS c
			ON lc.id_coment=c.id_coment
			WHERE positivo=true
			GROUP BY c.id_user
			) AS cl
		ON pl.id_user=cl.id_user
		) AS ul
	FULL JOIN
		(------LA CANTIDAD DE DISLIKES DE CADA USUARIO
		SELECT pd.id_user, (dp+dc) AS dislikes
		FROM	
			(			--CUENTA LOS DISLIKES DE UNA PUBLICACION	
			SELECT p.id_user, count(positivo) AS dp
			FROM like_publicacion AS lp
			JOIN publicacion AS p
			ON lp.id_public=p.id_public
			WHERE positivo=false
			GROUP BY p.id_user
			) AS pd
		FULL JOIN
			( 			---CUENTA LOS COMENTARIOS DISLIKES
			SELECT c.id_user, count(positivo) AS dc
			FROM like_comentario AS lc
			JOIN comentario AS c
			ON lc.id_coment=c.id_coment
			WHERE positivo=false
			GROUP BY c.id_user
			) AS cd
		ON pd.id_user=cd.id_user
		) AS ud
	ON ul.id_user=ud.id_user
	) AS uld
ON id=id_user
ORDER BY diferencia ASC	
;

--EJERCICIO 20
--No me anda el trigger solo escribi el codigo como supongo que deberia ser   
---1 CREAMOS LAS TABLAS NUEVAS
CREATE TABLE log_publicacion(
	id_log SERIAL ,
	id_user INT,
	id_grupo INT,
	titulo VARCHAR(300),
	contenido nchar varying ,
	fecha_log TIMESTAMP,
	fecha_publicacion TIMESTAMP,
	id_public SERIAL, ----ID SERIA EL ID_PUBLIC 
	accion_log VARCHAR(1),
	PRIMARY KEY(id_log),
	CONSTRAINT fk_log_publicacion_id_public FOREIGN KEY(id_public)
	REFERENCES publicacion(id_public),
	CONSTRAINT fk_publicacion_id_user FOREIGN KEY(id_user)
	REFERENCES usuario(id),
	CONSTRAINT fk_publicacion_id_grupo FOREIGN KEY(id_grupo)
	REFERENCES grupo(id_grupo)
);

CREATE TABLE log_comentario(
	id_log SERIAL,
	id_coment SERIAL,	-----ID SERIA EL ID COMENT
	fecha_log TIMESTAMP,
	accion_log VARCHAR(1),
	id_public INT NOT NULL,
	id_user INT NOT NULL,
	contenido nchar varying ,
	fecha_comentario TIMESTAMP,
	PRIMARY KEY(id_log),
	CONSTRAINT fk_comentario_id_public FOREIGN KEY(id_public)
	REFERENCES publicacion(id_public),
	CONSTRAINT fk_log_comentario_id_coment FOREIGN KEY(id)
	REFERENCES comentario(id_coment),
	CONSTRAINT fk_comentario_id_user FOREIGN KEY(id_user)
	REFERENCES usuario(id)
);
---No hice el trigger de comentario porque tampoco iba a funcionar :(

---2 Creamos las funciones
----Mi idea era hacer un if elseif else segun que tipo de comportamiento insert/update /delete y darle el valor a accion_log 
CREATE FUNCTION modificaciones_bd() RETURNS TRIGGER AS $$ 
BEGIN
	IF (TG_OP=INSERT) THEN
	NEW.accion_log:= 'I'
	;
	ELSEIF(TG_OP=UPDATE) THEN
	NEW.accion_log:= 'U'
	;
	ELSE(TG_OP=DELETE) THEN
	NEW.accion_log:= 'D'
	;
INSERT INTO log_publicacion(id_pubic,id_user,id_grupo,titulo,contenido,fecha_publicacion)
VALUES ( old.id_pubic , old.id_user, old.id_grupo, old.titulo,old.contenido, old.fecha_publicacion);
RETURN NEW; 
END
$$ LANGUAGE plpgsql;

--3 Creamos el disparador
CREATE TRIGGER cambios_en_bd AFTER INSERT ON publicacion
FOR EACH ROW 
EXECUTE PROCEDURE modificaciones_bd();
----Podrian mandar la solucion de este ejercico despues de corregido el tp?

----EJERCICIO 21
INSERT INTO publicacion
VALUES ( 2727, 1, 9 ,'nada podria malir sal','Macri gato','2013-8-30 01:02:22');

INSERT INTO publicacion
VALUES ( 2828, 1, 8 ,'ahre', 'Desearia poder salvar este cuatrimestre :;(','2017-12-30 09:09:42');

INSERT INTO comentario VALUES (1993, 318, 67, 'eWe', '2014-05-01 10:48:37');

INSERT INTO comentario VALUES (1992, 318, 67, 'uWu', '2015-02-06 12:16:35');

