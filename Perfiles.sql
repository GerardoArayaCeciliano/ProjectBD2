create or replace function  FUN_DESENCRIPTAR_CONTRASENA(contrasenna in varchar2) return varchar2 is
  FunctionResult varchar2(120);
begin
  declare
   descifrado RAW(120);
   begin
   descifrado := DBMS_CRYPTO.DECRYPT (
         src   => UTL_ENCODE.base64_decode (UTL_RAW.CAST_TO_RAW (contrasenna)),
         typ   => DBMS_CRYPTO.DES_CBC_PKCS5,
         key   => '314159265358979323846264338327950288419716939937',
         iv    => null);
    FunctionResult:=UTL_I18N.raw_to_char(descifrado,'AL32UTF8');
    end;
  return(FunctionResult);
end  FUN_DESENCRIPTAR_CONTRASENA;
/

create or replace noneditionable function FUN_ENCRIPTAR_CONTRASENA(contrasenna in varchar2) return varchar2 is
FunctionResult varchar2(120);
begin
Declare
  cifrado RAW (120);
  begin
    cifrado :=  DBMS_CRYPTO.encrypt (
                           src   => UTL_I18N.STRING_TO_RAW (contrasenna, 'AL32UTF8'), 
                           typ   => DBMS_CRYPTO.DES_CBC_PKCS5,
                           key   => '314159265358979323846264338327950288419716939937',
                           iv    => null);
       FunctionResult:= UTL_RAW.CAST_TO_VARCHAR2 (UTL_ENCODE.base64_encode (cifrado)); 
  end;
  return(FunctionResult); 
end FUN_ENCRIPTAR_CONTRASENA;
/

create or replace function FUN_EXISTE_ROL(nombre in varchar2) return varchar2 is
  FunctionResult varchar2(1);
begin
  declare
   existeRol number:=0;
   begin
  select count(rol.rol_id) into existeRol from pv_roles rol where rol.rol_nombre=nombre;
  if existeRol>0 then
    FunctionResult:='S';
  else
    FunctionResult:='N';
  end if; 
  end;
  return(FunctionResult);
end FUN_EXISTE_ROL;
/

create or replace function FUN_EXISTE_USUARIO(nombre in varchar2) return varchar2 is
  FunctionResult varchar2(1);
begin
   declare
   existeUsuario number:=0;
   begin
   select count(pm.par_id) into existeUsuario from pv_parametros pm where pm.par_usuario=nombre;
  if existeUsuario>0 then
    FunctionResult:='S';
  else
    FunctionResult:='N';
  end if; 
  end;
  return(FunctionResult);
  return(FunctionResult);
end FUN_EXISTE_USUARIO;
/

create or replace noneditionable procedure crear_roles(nombre varchar2,contrasenna varchar2) authid current_user is
encripCotrasenna varchar2(120);
begin
  declare
   existeRol number:=0;
   newRol varchar2(80);
  begin
   select count(rol.rol_id) into existeRol from pv_roles rol where lower(rol.rol_nombre)=lower(nombre);
  if existeRol=0 then 
  encripCotrasenna:=FUN_ENCRIPTAR_CONTRASENA(contrasenna);
  insert into pv_roles(rol_nombre,rol_contrasenna) values(lower(nombre),encripCotrasenna);
    commit;
  begin
    newRol:='CREATE ROLE ' || lower(nombre) || ' IDENTIFIED BY ' || contrasenna;
    execute immediate 'ALTER SESSION SET "_ORACLE_SCRIPT"=TRUE';
    execute immediate (newRol);
    --execute immediate 'create role casa identified by oracle'; 
  end;

  else
    dbms_output.put_line('Error al registrar');
  end if;
  end;
end crear_roles;
/

create or replace noneditionable procedure PROC_Registrar_Usuario(nombre in varchar2,contrasenna in varchar2,rol in varchar2,correo in varchar2) authid current_user is
existeUsuario varchar(1);
existeRol varchar(1);
idRol number;
newUser varchar(120);
permisoUsuario varchar2(120);
encripContrasenna varchar(120);
asignaRole varchar(120);
begin
  existeUsuario:=fun_existe_usuario(nombre);
  existeRol:=fun_existe_rol(rol);
  begin
    if existeUsuario='N' and existeRol='S' then
      
       encripContrasenna:=fun_encriptar_contrasena(contrasenna);
       select r.rol_id into idRol from pv_roles r where r.rol_nombre=rol;
       insert into pv_parametros (par_rol,par_usuario,par_contrasena,par_correo,par_estado)
       values (idRol,lower(nombre),encripContrasenna,correo,'A');
       commit;
      
       execute immediate 'ALTER SESSION SET "_ORACLE_SCRIPT"=TRUE';
       newUser:='create user '||lower(nombre)||' identified by '||contrasenna||' profile usuario';
       permisoUsuario:='grant alter session, create session to '||lower(nombre);
       asignaRole:='grant '||rol||' to '||lower(nombre);
       execute immediate (newUser);
       execute immediate (permisoUsuario);
       execute immediate  (asignaRole);
         execute immediate  'grant execute on pgerardo.activar_roles to '||lower(nombre);
         execute immediate 'grant select on pgerardo.pv_roles to '||lower(nombre);
         execute immediate 'grant select on pgerardo.pv_parametros to '|| lower(nombre);
       else 
         if existeUsuario='S' then
           dbms_output.put_line('El usuario ya existe');
           end if;
         if existeRol='N' then
           dbms_output.put_line('El Rol existe');
           end if;
    end if;
  end;
end PROC_Registrar_Usuario;
/

create or replace noneditionable procedure activar_roles authid current_user is
usuario_actual varchar(60);
contrasenna_Rol varchar(120);
contraDesifrada varchar(120);
rol varchar(60);
begin
 select sys_context('USERENV','SESSION_USER') into usuario_actual from dual;
 usuario_actual:='gece';
 select r.rol_nombre,r.rol_contrasenna into rol,contrasenna_Rol from pgerardo.pv_roles r inner join pgerardo.pv_parametros p on r.rol_id=p.par_rol where lower(p.par_usuario)=lower(usuario_actual); 
 
contraDesifrada:=fun_desencriptar_contrasena(contrasenna_Rol);
 
 execute immediate 'set role '|| lower(rol) ||' identified by '||contraDesifrada;
 
 dbms_output.put_line(contraDesifrada);
 
end activar_roles;
/
