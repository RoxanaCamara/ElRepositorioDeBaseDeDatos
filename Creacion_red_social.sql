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

