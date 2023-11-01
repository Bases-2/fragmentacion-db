-- Definición triggers
--Proyectos
CREATE OR REPLACE FUNCTION PROYECTO_TRIGGER_FUNC()
  RETURNS trigger
  LANGUAGE 'plpgsql'
  AS $function$
DECLARE
    servidorData SERVIDOR%ROWTYPE;

BEGIN
    SELECT * INTO servidorData FROM SERVIDOR WHERE SERVIDOR.SERV_ID = NEW.SERV_ID;
    raise notice 'Select Servidor: %',servidorData;
    PERFORM dblink_exec(
        FORMAT('host=%s port=%s dbname=%s user=%s password=%s', servidorData.HOST, servidorData.PUERTO, servidorData.USUARIO, servidorData.USUARIO, servidorData.CONTRASENA),
        FORMAT('INSERT INTO public.PROYECTO (ID_PROY, NOMBRE, SERV_ID) VALUES(''%s'', ''%s'', ''%s'')', NEW.ID_PROY, NEW.NOMBRE, NEW.SERV_ID),
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

--Estudiantes

CREATE OR REPLACE FUNCTION ESTUDIANTE_TRIGGER_FUNC()
  RETURNS trigger
  LANGUAGE 'plpgsql'
  AS $function$
DECLARE
    servidorData SERVIDOR%ROWTYPE;
    servId varchar(3);
BEGIN
    SELECT p.SERV_ID into servId FROM PROYECTO p where p.ID_PROY = NEW.ID_PROY;
    SELECT * INTO servidorData FROM SERVIDOR WHERE SERVIDOR.SERV_ID = servId;
    PERFORM dblink_exec(
        FORMAT('host=%s port=%s dbname=%s user=%s password=%s', servidorData.HOST, servidorData.PUERTO, servidorData.USUARIO, servidorData.USUARIO, servidorData.CONTRASENA),
        FORMAT('INSERT INTO public.ESTUDIANTE (NOMBRE, ID_PROY) VALUES(''%s'', ''%s'')', NEW.NOMBRE, NEW.ID_PROY),
        true
    );
    RETURN NEW;
END;
$function$;

CREATE TRIGGER ESTUDIANTE_TRIGGER
  AFTER INSERT
  ON ESTUDIANTE
  FOR EACH ROW
  EXECUTE PROCEDURE ESTUDIANTE_TRIGGER_FUNC();