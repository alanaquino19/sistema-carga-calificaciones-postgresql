SET search_path TO public;
SET client_min_messages TO WARNING;

DROP TRIGGER IF EXISTS trg_calificacion_modificada ON public.calificacion;
DROP FUNCTION IF EXISTS actualizar_fecha_modificacion;

DROP TABLE IF EXISTS public.boleta CASCADE;
DROP TABLE IF EXISTS public.calificacion CASCADE;
DROP TABLE IF EXISTS public.recuperacion CASCADE;
DROP TABLE IF EXISTS public.evaluacion CASCADE;
DROP TABLE IF EXISTS public.tipo_evaluacion CASCADE;
DROP TABLE IF EXISTS public.asignatura_grado CASCADE;
DROP TABLE IF EXISTS public.asignatura CASCADE;
DROP TABLE IF EXISTS public.matricula CASCADE;
DROP TABLE IF EXISTS public.estudiante CASCADE;
DROP TABLE IF EXISTS public.seccion CASCADE;
DROP TABLE IF EXISTS public.grado CASCADE;
DROP TABLE IF EXISTS public.nivel CASCADE;
DROP TABLE IF EXISTS public.periodo_academico CASCADE;
DROP TABLE IF EXISTS public.institucion CASCADE;
DROP TABLE IF EXISTS public.usuario CASCADE;
DROP TABLE IF EXISTS public.rol CASCADE;
DROP TABLE IF EXISTS public.escala_conversion CASCADE;
DROP TABLE IF EXISTS public.configuracion CASCADE;
DROP TABLE IF EXISTS public.observacion CASCADE;
DROP TABLE IF EXISTS public.auditoria CASCADE;

CREATE TABLE public.rol (
    id_rol INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nombre_rol VARCHAR(50) NOT NULL
);

CREATE TABLE public.usuario (
    id_usuario INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_rol INTEGER NOT NULL REFERENCES public.rol(id_rol) ON UPDATE CASCADE ON DELETE RESTRICT,
    nombre VARCHAR(50) NOT NULL,
    apellido VARCHAR(50) NOT NULL,
    correo VARCHAR(100) NOT NULL,
    contrasena VARCHAR(255) NOT NULL,
    activo BOOLEAN DEFAULT TRUE
);

CREATE TABLE public.institucion (
    id_institucion INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    direccion VARCHAR(150),
    telefono VARCHAR(20),
    id_usuario_creador INTEGER NOT NULL REFERENCES public.usuario(id_usuario) ON UPDATE CASCADE ON DELETE RESTRICT
);

CREATE TABLE public.nivel (
    id_nivel INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL
);

CREATE TABLE public.grado (
    id_grado INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_nivel INTEGER NOT NULL REFERENCES public.nivel(id_nivel) ON UPDATE CASCADE ON DELETE RESTRICT,
    nombre VARCHAR(50) NOT NULL
);

CREATE TABLE public.seccion (
    id_seccion INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_grado INTEGER NOT NULL REFERENCES public.grado(id_grado) ON UPDATE CASCADE ON DELETE RESTRICT,
    nombre VARCHAR(50) NOT NULL,
    UNIQUE (nombre, id_grado)
);

CREATE TABLE public.periodo_academico (
    id_periodo INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    anio INTEGER NOT NULL,
    descripcion VARCHAR(100),
    activo BOOLEAN DEFAULT TRUE
);

CREATE TABLE public.estudiante (
    id_estudiante INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nombres VARCHAR(100) NOT NULL,
    apellidos VARCHAR(100) NOT NULL,
    dni VARCHAR(15) UNIQUE,
    fecha_nacimiento DATE,
    direccion VARCHAR(150),
    telefono VARCHAR(20)
);

CREATE TABLE public.matricula (
    id_matricula INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_estudiante INTEGER NOT NULL REFERENCES public.estudiante(id_estudiante) ON UPDATE CASCADE ON DELETE RESTRICT,
    id_periodo INTEGER NOT NULL REFERENCES public.periodo_academico(id_periodo) ON UPDATE CASCADE ON DELETE RESTRICT,
    id_seccion INTEGER NOT NULL REFERENCES public.seccion(id_seccion) ON UPDATE CASCADE ON DELETE RESTRICT,
    fecha_matricula DATE DEFAULT CURRENT_DATE,
    UNIQUE (id_estudiante, id_periodo)
);

CREATE TABLE public.asignatura (
    id_asignatura INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL
);

CREATE TABLE public.asignatura_grado (
    id_asignatura_grado INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_asignatura INTEGER NOT NULL REFERENCES public.asignatura(id_asignatura) ON UPDATE CASCADE ON DELETE CASCADE,
    id_grado INTEGER NOT NULL REFERENCES public.grado(id_grado) ON UPDATE CASCADE ON DELETE CASCADE,
    carga_horaria INTEGER,
    UNIQUE (id_asignatura, id_grado)
);

CREATE TABLE public.tipo_evaluacion (
    id_tipo_evaluacion INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL
);

CREATE TABLE public.evaluacion (
    id_evaluacion INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_tipo_evaluacion INTEGER NOT NULL REFERENCES public.tipo_evaluacion(id_tipo_evaluacion) ON UPDATE CASCADE ON DELETE RESTRICT,
    id_asignatura INTEGER NOT NULL REFERENCES public.asignatura(id_asignatura) ON UPDATE CASCADE ON DELETE RESTRICT,
    nombre VARCHAR(100) NOT NULL,
    ponderacion NUMERIC(5,2) CHECK (ponderacion >= 0 AND ponderacion <= 100)
);

CREATE TABLE public.calificacion (
    id_calificacion INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_estudiante INTEGER NOT NULL REFERENCES public.estudiante(id_estudiante) ON UPDATE CASCADE ON DELETE CASCADE,
    id_evaluacion INTEGER NOT NULL REFERENCES public.evaluacion(id_evaluacion) ON UPDATE CASCADE ON DELETE CASCADE,
    nota_escala NUMERIC(3,2) CHECK (nota_escala >= 1 AND nota_escala <= 5),
    fecha_modificacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE public.recuperacion (
    id_recuperacion INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_calificacion INTEGER NOT NULL REFERENCES public.calificacion(id_calificacion) ON UPDATE CASCADE ON DELETE CASCADE,
    nota NUMERIC(3,2) CHECK (nota >= 1 AND nota <= 5)
);

CREATE TABLE public.escala_conversion (
    id_conversion INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nota_minima NUMERIC(3,2),
    nota_maxima NUMERIC(3,2),
    descripcion VARCHAR(50)
);

CREATE TABLE public.configuracion (
    id_configuracion INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nombre_institucion VARCHAR(100),
    anio_lectivo INTEGER,
    id_conversion INTEGER REFERENCES public.escala_conversion(id_conversion) ON UPDATE CASCADE ON DELETE RESTRICT,
    activo BOOLEAN DEFAULT TRUE
);

CREATE TABLE public.boleta (
    id_boleta INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_estudiante INTEGER NOT NULL REFERENCES public.estudiante(id_estudiante) ON UPDATE CASCADE ON DELETE CASCADE,
    id_periodo INTEGER NOT NULL REFERENCES public.periodo_academico(id_periodo) ON UPDATE CASCADE ON DELETE RESTRICT,
    promedio_final NUMERIC(4,2)
);

CREATE TABLE public.observacion (
    id_observacion INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_estudiante INTEGER NOT NULL REFERENCES public.estudiante(id_estudiante) ON UPDATE CASCADE ON DELETE CASCADE,
    texto TEXT
);

CREATE TABLE public.auditoria (
    id_auditoria INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    usuario_id INTEGER REFERENCES public.usuario(id_usuario) ON UPDATE CASCADE ON DELETE SET NULL,
    tabla_afectada VARCHAR(100),
    accion VARCHAR(50),
    registro_id INTEGER,
    fecha TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    descripcion TEXT
);

INSERT INTO public.rol (nombre_rol) VALUES ('Administrador'), ('Docente'), ('Estudiante');

INSERT INTO public.configuracion (nombre_institucion, anio_lectivo, activo)
VALUES ('Institución Educativa Modelo', EXTRACT(YEAR FROM CURRENT_DATE)::INTEGER, TRUE);

CREATE FUNCTION actualizar_fecha_modificacion() RETURNS TRIGGER AS $$
BEGIN
  NEW.fecha_modificacion := NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_calificacion_modificada
BEFORE UPDATE ON public.calificacion
FOR EACH ROW
EXECUTE FUNCTION actualizar_fecha_modificacion();

CREATE INDEX idx_estudiante_dni ON public.estudiante(dni);
CREATE INDEX idx_matricula_estudiante ON public.matricula(id_estudiante);
CREATE INDEX idx_matricula_periodo ON public.matricula(id_periodo);
CREATE INDEX idx_evaluacion_asignatura ON public.evaluacion(id_asignatura);
CREATE INDEX idx_calificacion_estudiante ON public.calificacion(id_estudiante);
CREATE INDEX idx_calificacion_evaluacion ON public.calificacion(id_evaluacion);