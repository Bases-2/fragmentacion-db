-- Definición triggers
--Departamentos
CREATE OR REPLACE FUNCTION DEPARTAMENTO_TRIGGER_FUNC()
  RETURNS trigger
  LANGUAGE 'plpgsql'
  AS $function$
DECLARE
    servidorData SERVIDOR%ROWTYPE;

BEGIN
    SELECT * INTO servidorData FROM SERVIDOR WHERE SERVIDOR.CIUDAD = NEW.CIUDAD;
    raise notice 'Select Servidor: %',servidorData;
    PERFORM dblink_exec(
        FORMAT('host=%s port=%s dbname=%s user=%s password=%s', servidorData.HOST, servidorData.PUERTO, servidorData.USUARIO, servidorData.USUARIO, servidorData.CONTRASENA),
        FORMAT('INSERT INTO public.departamento (id_dep, nombre, ciudad) VALUES(''%s'', ''%s'', ''%s'')', NEW.ID_DEP, NEW.NOMBRE, NEW.CIUDAD),
        true
    );
    RETURN NEW;
END;
$function$;

CREATE TRIGGER DEPARTAMENTO_TRIGGER
  AFTER INSERT
  ON DEPARTAMENTO
  FOR EACH ROW
  EXECUTE PROCEDURE DEPARTAMENTO_TRIGGER_FUNC();

--Proyectos
CREATE OR REPLACE FUNCTION PROYECTO_TRIGGER_FUNC()
  RETURNS trigger
  LANGUAGE 'plpgsql'
  AS $function$
DECLARE
    servidorData SERVIDOR%ROWTYPE;
    cityProyect varchar(3);
BEGIN
    SELECT d.ciudad into cityProyect FROM DEPARTAMENTO d INNER JOIN PROYECTO p ON d.id_dep = p.id_dep where p.id_proy = NEW.id_proy;
    SELECT * INTO servidorData FROM SERVIDOR WHERE SERVIDOR.CIUDAD = cityProyect;
    PERFORM dblink_exec(
        FORMAT('host=%s port=%s dbname=%s user=%s password=%s', servidorData.HOST, servidorData.PUERTO, servidorData.USUARIO, servidorData.USUARIO, servidorData.CONTRASENA),
        FORMAT('INSERT INTO public.proyecto (id_proy, nombre, presupuesto, id_dep) VALUES(''%s'', ''%s'', %s, ''%s'')', NEW.id_proy, NEW.nombre, NEW.presupuesto,NEW.id_dep),
        true
    );
    RETURN NEW;
END;
$function$;

CREATE TRIGGER PROYECTO_TRIGGER
  AFTER INSERT
  ON PROYECTO
  FOR EACH ROW
  EXECUTE PROCEDURE PROYECTO_TRIGGER_FUNC();

--Empleados

CREATE OR REPLACE FUNCTION EMPLEADOS_TRIGGER_FUNC()
  RETURNS trigger
  LANGUAGE 'plpgsql'
  AS $function$
DECLARE
    servidorData SERVIDOR%ROWTYPE;
    cityProyect varchar(3);
BEGIN
    SELECT d.ciudad into cityProyect FROM DEPARTAMENTO d INNER JOIN EMPLEADO e ON d.id_dep = e.id_dep where e.id_emp = NEW.id_emp;
    SELECT * INTO servidorData FROM SERVIDOR WHERE SERVIDOR.CIUDAD = cityProyect;
    PERFORM dblink_exec(
        FORMAT('host=%s port=%s dbname=%s user=%s password=%s', servidorData.HOST, servidorData.PUERTO, servidorData.USUARIO, servidorData.USUARIO, servidorData.CONTRASENA),
        FORMAT('INSERT INTO public.empleado (nombre, salario, id_dep) VALUES(''%s'', %s,''%s'')', NEW.nombre, NEW.salario, NEW.id_dep),
        true
    );
    RETURN NEW;
END;
$function$;

CREATE TRIGGER EMPLEADO_TRIGGER
  AFTER INSERT
  ON EMPLEADO
  FOR EACH ROW
  EXECUTE PROCEDURE EMPLEADOS_TRIGGER_FUNC();
