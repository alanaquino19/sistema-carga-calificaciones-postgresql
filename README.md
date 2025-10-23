# Sistema de Carga de Calificaciones (PostgreSQL)

Este proyecto implementa una base de datos relacional completa en PostgreSQL, diseñada para la gestión académica de calificaciones, evaluaciones, estudiantes, usuarios, configuraciones, etc.  
El modelo está documentado mediante un Diagrama Entidad-Relación (DER) generado con PlantUML.

------------------------------------------------------------

## Características principales

- Estructura completa de base de datos con claves primarias y foráneas.
- Módulos para estudiantes, secciones, asignaturas y evaluaciones.
- Tablas para auditoría, configuración institucional y escalas de conversión.
- Script para ejecutar en **pgAdmin**.
- Código DER en **PlantUML** y diagrama **PNG** del modelo relacional.

------------------------------------------------------------

## Tecnologías utilizadas

- **PostgreSQL 15+**: Motor de base de datos.
- **PlantUML**: Generación del DER.
- **UTF-8**: Codificación estándar.

------------------------------------------------------------

## Cómo usar el proyecto

1. Clona este repositorio:
   ```bash
   git clone https://github.com/alanaquino19/sistema-carga-calificaciones-postgresql.git
   ```
2. Abre **pgAdmin**.
3. Carga el archivo `sistema_carga_calificaciones.sql`.
4. Ejecuta el script en pgAdmin.
5. Visualiza el modelo relacional con el archivo **PlantUML** o el **PNG** incluido.

------------------------------------------------------------

## Estructura del proyecto

```
sistema-carga-calificaciones-postgresql
├── sistema_carga_calificaciones.sql
├── Código PlantUML del Sistema de Carga de Calificaciones.txt
├── DER Sistema de Carga de Calificaciones.png
└── README.md
```

------------------------------------------------------------

## Autor

**Alan Aquino**, estudiante de Ingeniería en Informática.

------------------------------------------------------------

## Licencia

Este proyecto se distribuye bajo la **Licencia MIT**.  
Eres libre de usarlo, modificarlo y compartirlo, siempre dando el crédito correspondiente.
