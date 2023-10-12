-- Definición triggers
CREATE OR REPLACE FUNCTION DEPARTAMENTO_TRIGGER_FUNC()
  RETURNS trigger
  LANGUAGE 'plpgsql'
  AS $function$
DECLARE
    servidorData SERVIDOR%ROWTYPE;

BEGIN
    SELECT * INTO servidorData FROM SERVIDOR WHERE SERVIDOR.CIUDAD = NEW.CIUDAD;
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