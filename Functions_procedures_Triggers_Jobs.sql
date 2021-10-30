--Punto 1 Trigger aumentar saldo de la cuenta por cobrar del cliente --

create or replace noneditionable trigger TRI_AUMENTAR_SALDO_PENDIENTE_CLIENTE
  after insert
  on pv_facturas_venta
  for each row
declare
  cuentaUsuario number;
  pragma autonomous_transaction;
begin
  select c.cue_id into cuentaUsuario from PV_CUENTAS_COBRAR c where c.cue_cliente = :new.fac_cliente;

  begin
    if(:new.fac_estado = 'P') then
      update PV_CUENTAS_COBRAR c
      set c.CUE_SALDO_PENDIENTE = (c.CUE_SALDO_PENDIENTE + :new.fac_total)
      where c.cue_id = cuentaUsuario;
      commit;
    end if;
  end;
end TRI_AUMENTAR_SALDO_PENDIENTE_CLIENTE;
/

--Trigger aumentar saldo de la cuenta por pagar

create or replace noneditionable trigger TRI_AUMENTAR_CUENTA_PAGAR
  after insert
  on PV_FACTURAS_COMPRA 
  for each row
declare
  -- local variables here
  cuenta_proveedor number;
  pragma autonomous_transaction;
begin
  select c.cue_id into cuenta_proveedor from PV_CUENTAS_PAGAR c where c.cue_proveedor = :new.fac_provedor;
  
  begin
    if(:new.fac_estado = 'P') then
      update PV_CUENTAS_PAGAR c
      set c.cue_monto = (c.cue_monto + :new.fac_monto_total)
      where c.cue_id = cuenta_proveedor;
      commit;
    end if;
  end;
  
end TRI_AUMENTAR_CUENTA_PAGAR;
/


--Trigger de cambiar el estado a cancelado de las facturas de venta

create or replace noneditionable trigger TRI_CAMBIAR_ESTADO_FAC_VENTA
  after insert
  on pv_abonos_ventas
  for each row
declare
  -- local variables here
  abonos float;
  montoTotal float;
  pragma autonomous_transaction;

begin
  begin
    select f.fac_total into montoTotal from PV_FACTURAS_VENTA f where f.fac_id = :new.abov_fac_id;
    select SUM(a.abov_monto) into abonos from PV_ABONOS_VENTAS a where a.abov_fac_id = :new.abov_fac_id;

    if (abonos = montoTotal) then
      begin
        UPDATE PV_FACTURAS_VENTA f set f.fac_estado = 'C' where f.fac_id = :new.abov_fac_id;
        commit;
      end;
    end if;

 end;
end TRI_CAMBIAR_ESTADO_FAC_VENTA;
/


--Trigger de cambiar el estado de las facturas de compra a canceladas

create or replace noneditionable trigger TRI_CAMBIAR_ESTADO_FACT_COMPRA
  after insert
  on pv_abonos
  for each row
declare

  abonos float;
  montoTotal float;
  pragma autonomous_transaction;
begin
  begin
    select f.fac_monto_total into montoTotal from PV_FACTURAS_COMPRA f where f.fac_id = :new.abo_fac_id;
    select SUM(a.abo_monto) into abonos from PV_ABONOS a where a.abo_fac_id = :new.abo_fac_id;

    if (abonos = montoTotal) then
      begin
        UPDATE PV_FACTURAS_COMPRA f set f.fac_estado = 'C' where f.fac_id = :new.abo_fac_id;
        commit;
      end;
    end if;
  end;

end TRI_CAMBIAR_ESTADO_FACT_COMPRA;
/


--Trigger para crear una cuenta general por cobrar para cada cliente despues de crear el cliente

create or replace noneditionable trigger TRI_CREAR_CUENTA_GENERAL_CLIENTE
  after insert
  on pv_clientes 
  for each row
declare
  -- local variables here
begin
  begin
     insert into PV_CUENTAS_COBRAR(CUE_CLIENTE,CUE_SALDO_PENDIENTE) VALUES(:new.cli_id,0);

  end;
end TRI_CREAR_CUENTA_GENERAL_CLIENTE;
/

--Trigger para crear cuenta general por pagar para cada proveedor despues de ingresar al proveedor

create or replace trigger TRI_CREAR_CUENTA_GENERAL_EMPRESA
  after insert
  on pv_proveedores 
  for each row
declare
  -- local variables here
begin
  begin
     insert into PV_CUENTAS_PAGAR(CUE_PROVEEDOR,CUE_MONTO) VALUES(:new.pro_id,0);

  end;
end TRI_CREAR_CUENTA_GENERAL_EMPRESA;
/


--Trigger para disminuir la cuenta por pagar despues de insertar un abono

create or replace trigger TRI_DISMINUIR_CUENTAS_PAGAR
  after insert
  on pv_abonos 
  for each row
declare
  -- local variables here
  cuentaProveed number;
begin
  select f.fac_provedor into cuentaProveed from PV_FACTURAS_COMPRA f where f.fac_id = :new.abo_fac_id;
  
  begin
    
     update PV_CUENTAS_PAGAR c set c.cue_monto = (c.cue_monto - :new.abo_monto) where c.cue_proveedor = cuentaProveed;

  end;
end TRI_DISMINUIR_CUENTAS_PAGAR;
/


--Trigger para disminuir las cuentas por cobrar despues de insertar un abono del cliente

create or replace noneditionable trigger TRI_DISMINUIR_SALDO_CLIENTE
  after insert
  on pv_abonos_ventas 
  for each row
declare
  -- local variables here
  cuentaCliente number;
begin
   select f.fac_cliente into cuentaCliente from PV_FACTURAS_VENTA f where f.fac_id = :new.abov_fac_id;
  
  begin
    
     update PV_CUENTAS_COBRAR c set c.cue_saldo_pendiente = (c.cue_saldo_pendiente - :new.abov_monto) where c.cue_cliente = cuentaCliente;

  end;
end TRI_DISMINUIR_SALDO_CLIENTE;
/


create or replace noneditionable trigger TRI_CANCELAR_MODIFICACION_PRECIOS
  before update or delete of pre_precio_costo, pre_impuesto, pre_utilidad, pre_fecha
  on pv_precios 
  for each row
declare

begin
  RAISE_APPLICATION_ERROR(-20010,'Editar o eliminar los precios no es una accion permitida');
end TRY_CANCELAR_MODIFICACION_PRECIOS;
/


create or replace noneditionable trigger TRI_ACTUALIZAR_HISTORIAL_PRECIOS
before insert on pv_precios
for each row
declare

begin
  --Desactiva todos los precios anteriores.
  update Pv_Precios p set p.pre_estado = 'ANT' where p.pre_producto = :new.pre_producto and p.pre_estado not like 'ANT';
  
  --Se cerciora de que el precio mas nuevo quede activo.
  if :new.pre_estado not like 'ACT' then
     :new.pre_estado := 'ACT';
  end if;   
end ACTUALIZAR_HISTORIAL_PRECIOS;
/


create or replace noneditionable trigger TRI_LIMITAR_FACTURAS_COMPRA_PENDIENTES
  before insert on pv_facturas_compra
  for each row
declare
  limite_cred pv_limite_credito%rowtype;
  acumulado_pediente pv_cuentas_pagar.cue_monto%type;
begin
  --ATENCION: Este disparador supone que la empresa cuenta con un limite de precio con cada proveedor.
  --ATENCION: Este disparador supone que el proveedor cuenta con una cuenta por pagar activa.
  
  if :new.fac_estado = 'P' then
    --Se obtiene limite de credito y acumulado aun pediente
    select * into limite_cred from pv_limite_credito lc where lc.lim_proveedor = :new.fac_provedor;
    select cp.cue_monto into acumulado_pediente from pv_cuentas_pagar cp where cp.cue_proveedor = :new.fac_provedor;
    --Se valida si rl acumulado mas la factura actual sobrepasan el limite de credito
    if (:new.fac_monto_total + acumulado_pediente) > limite_cred.lim_limite_max then
      RAISE_APPLICATION_ERROR(-20010,'Esta factura excede el del l�mite de cr�dito con este proveedor.');
    end if;
  end if;
  
end TRI_LIMITAR_FACTURAS_COMPRA_PENDIENTES;
/


create or replace noneditionable trigger TRI_LIMITAR_FACTURAS_VENTA_PENDIENTES
  before insert on pv_facturas_venta 
  for each row
declare
  total_por_cobrar pv_cuentas_cobrar.cue_saldo_pendiente%type;
  limite_pago pv_clientes.cli_cred_max%type;                       
begin
  --ATENCION: este disparador supone que ya el cliente cuenta con una cuenta por cobrar registrada
  --Se lecciona el saldo pendiente y el credito maximo
  if :new.fac_estado = 'P' then
    
    select cc.cue_saldo_pendiente into total_por_cobrar 
    from pv_cuentas_cobrar cc where cc.cue_cliente = :new.fac_cliente;
    
    select c.cli_cred_max into limite_pago 
    from pv_clientes c where c.cli_id = :new.fac_cliente;
    
    if (total_por_cobrar + :new.fac_total) > limite_pago then
       RAISE_APPLICATION_ERROR(-20010,'Esta factura excede el del l�mite de cr�dito del cliente.');
    end if;
  end if;
end TRI_LIMITAR_FACTURAS_VENTA_PENDIENTES;
/


create or replace trigger TRI_BITACORA_FACTURAS_COMPRA_INSERT
  after insert
  on pv_facturas_compra 
  for each row
declare
  -- local variables here
  usuario varchar2(30);
  pragma autonomous_transaction;
  
begin
  
  Select user into usuario from dual;

  begin
      case
      when :new.fac_estado = 'P' then
        insert into PV_BITACORA(BIT_ACCION,BIT_TIPO,BIT_DETALLE,BIT_USUARIO,BIT_FECHA)
               values('INSERTAR','Facturaci�n',concat(concat('Se insert� factura de compra id ',:new.fac_id),', en estado pendiente de pago'),usuario,sysdate);
        commit;

      when :new.fac_estado = 'C' then

        insert into PV_BITACORA(BIT_ACCION,BIT_TIPO,BIT_DETALLE,BIT_USUARIO,BIT_FECHA)
               values('INSERTAR','Facturaci�n',concat(concat('Se insert� factura de compra id',:new.fac_id),', cancelada a contado'),usuario,sysdate);
        commit;


     end case;

  end;
end TRI_BITACORA_FACTURAS_COMPRA_INSERT;
/


create or replace trigger TRI_BITACORA_FACTURAS_COMPRA_UPDATE
  after update
  on pv_facturas_compra 
  for each row
declare
  usuario varchar2(30);
  pragma autonomous_transaction;
begin
  Select user into usuario from dual;

  begin

    if :old.fac_estado = 'P' then
      if :new.fac_estado = 'C' then
        insert into PV_BITACORA(BIT_ACCION,BIT_TIPO,BIT_DETALLE,BIT_USUARIO,BIT_FECHA)
                 values('MODIFICAR','Facturaci�n',concat(concat('Se modific� la factura de compra id ',:old.fac_id),' y ahora se encuantra cancelada'),usuario,sysdate);
        commit;
      end if;
    elsif :new.fac_estado = 'I' then
      insert into PV_BITACORA(BIT_ACCION,BIT_TIPO,BIT_DETALLE,BIT_USUARIO,BIT_FECHA)
                 values('MODIFICAR','Facturaci�n',concat(concat('Se modific� la factura de compra id ',:old.fac_id),' y su estado ahora es inactivo'),usuario,sysdate);
        commit;
    end if;

    if :old.fac_monto_total <> :new.fac_monto_total then
       insert into PV_BITACORA(BIT_ACCION,BIT_TIPO,BIT_DETALLE,BIT_USUARIO,BIT_FECHA)
                 values('MODIFICAR','Facturaci�n',concat('Se modific� el monto de la factura de compra id ',:old.fac_id),usuario,sysdate);
        commit;
    else
      insert into PV_BITACORA(BIT_ACCION,BIT_TIPO,BIT_DETALLE,BIT_USUARIO,BIT_FECHA)
                 values('MODIFICAR','Facturaci�n',concat('Se modific� factura de compra id ',:old.fac_id),usuario,sysdate);
        commit;
    end if;


  end;
  
end TRI_BITACORA_FACTURAS_COMPRA_UPDATE;
/


create or replace trigger TRI_BITACORA_FACTURAS_VENTA_INSERT
  after insert
  on pv_facturas_venta
  for each row
declare
  -- local variables here
  usuario varchar2(30);
  pragma autonomous_transaction;
begin
  Select user into usuario from dual;

  begin
     case
      when :new.fac_estado = 'P' then
        insert into PV_BITACORA(BIT_ACCION,BIT_TIPO,BIT_DETALLE,BIT_USUARIO,BIT_FECHA)
               values('INSERTAR','Facturaci�n',concat(concat('Se insert� factura de venta id ',:new.fac_id),' en estado pendiente de pago'),usuario,sysdate);
        commit;

      when :new.fac_estado = 'C' then

        case
          when :new.fac_tipo_pago = 'EFECTIVO' then
          insert into PV_BITACORA(BIT_ACCION,BIT_TIPO,BIT_DETALLE,BIT_USUARIO,BIT_FECHA)
               values('INSERTAR','Facturaci�n',concat(concat('Se insert� factura de venta id ',:new.fac_id),' cancelada en efectivo'),usuario,sysdate);
               commit;

          when :new.fac_tipo_pago = 'SINPE' then
          insert into PV_BITACORA(BIT_ACCION,BIT_TIPO,BIT_DETALLE,BIT_USUARIO,BIT_FECHA)
               values('INSERTAR','Facturaci�n',concat(concat('Se insert� factura de venta id ',:new.fac_id),' cancelada por sinpe'),usuario,sysdate);
               commit;
          when :new.fac_tipo_pago = 'TARJETA' then
          insert into PV_BITACORA(BIT_ACCION,BIT_TIPO,BIT_DETALLE,BIT_USUARIO,BIT_FECHA)
               values('INSERTAR','Facturaci�n',concat(concat('Se insert� factura de venta id ',:new.fac_id),' cancelada en tarjeta'),usuario,sysdate);
               commit;

        end case;


    end case;
  end;

end TRI_BITACORA_FACTURAS_VENTA_INSERT;
/


create or replace noneditionable trigger TRI_BITACORA_FACTURAS_VENTAS_UPDATE
  after update
  on pv_facturas_venta
  for each row
declare
  -- local variables here
  usuario varchar2(30);
  pragma autonomous_transaction;
begin
  Select user into usuario from dual;

  begin

     if :old.fac_estado = 'P' then
      if :new.fac_estado = 'C' then
        insert into PV_BITACORA(BIT_ACCION,BIT_TIPO,BIT_DETALLE,BIT_USUARIO,BIT_FECHA)
                 values('MODIFICAR','Facturaci�n',concat(concat('Se modific� la factura de venta id ',:old.fac_id),' y ahora se encuantra cancelada'),usuario,sysdate);
        commit;
      end if;
    elsif :new.fac_estado = 'I' then
      insert into PV_BITACORA(BIT_ACCION,BIT_TIPO,BIT_DETALLE,BIT_USUARIO,BIT_FECHA)
                 values('MODIFICAR','Facturaci�n',concat(concat('Se modific� la factura de venta id ',:old.fac_id),' y su estado ahora es inactivo'),usuario,sysdate);
        commit;
    end if;
    

    if :old.fac_total <> :new.fac_total then
       insert into PV_BITACORA(BIT_ACCION,BIT_TIPO,BIT_DETALLE,BIT_USUARIO,BIT_FECHA)
                 values('MODIFICAR','Facturaci�n',concat('Se modific� el monto de la factura de venta id ',:old.fac_id),usuario,sysdate);
        commit;
    else 
      insert into PV_BITACORA(BIT_ACCION,BIT_TIPO,BIT_DETALLE,BIT_USUARIO,BIT_FECHA)
                 values('MODIFICAR','Facturaci�n',concat('Se modific� la factura de ventas id ',:old.fac_id),usuario,sysdate);
        commit;
    end if;

  end;

end TRI_BITACORA_FACTURAS_VENTAS_UPDATE;
/


create or replace trigger TRI_BITACORA_PRECIOS
  after insert
  on pv_precios 
  for each row
declare
  -- local variables here
  usuario varchar2(30);
  pragma autonomous_transaction;
begin
  Select user into usuario from dual;
  
  begin
    insert into PV_BITACORA(BIT_ACCION,BIT_TIPO,BIT_DETALLE,BIT_USUARIO,BIT_FECHA)
               values('INSERTAR','Cambio de precios',concat('Se insert� un nuevo precio del producto ',:new.pre_producto),usuario,sysdate);
        commit;
  end; 

end TRI_BITACORA_PRECIOS;
/


create or replace trigger TRI_BITACORA_PRECIOS_UPDATE
  after update
  on pv_precios 
  for each row
declare
  -- local variables here
  usuario varchar2(30);
  pragma autonomous_transaction;
  
begin
  Select user into usuario from dual;
  
  begin
    if (:new.pre_estado = 'ACT') then
      insert into PV_BITACORA(BIT_ACCION,BIT_TIPO,BIT_DETALLE,BIT_USUARIO,BIT_FECHA)
               values('MODIFICAR','Cambio de precios',concat('Se insert� un nuevo precio del producto id ',:new.pre_producto),usuario,sysdate);
        commit;
    end if;
    
  end; 
end TRI_BITACORA_PRECIOS_UPDATE;
/


create or replace noneditionable trigger TRI_BITACORA_PRECIOS_UPDATE
  after update
  on pv_precios
  for each row
declare
  -- local variables here
  usuario varchar2(30);
  pragma autonomous_transaction;

begin
  Select user into usuario from dual;

  begin
    if (:new.pre_estado = 'ACT') then
      insert into PV_BITACORA(BIT_ACCION,BIT_TIPO,BIT_DETALLE,BIT_USUARIO,BIT_FECHA)
               values('MODIFICAR','Cambio de precios',concat('Se insert� un nuevo precio del producto id ',:new.pre_producto),usuario,sysdate);
        commit;
    end if;

  end;
end TRI_BITACORA_PRECIOS_UPDATE;
/


create or replace noneditionable trigger TRI_BITACORA_PROMOCIONES_INSERT
  after insert
  on pv_promociones 
  for each row
declare
  -- local variables here
  usuario varchar2(30);
  pragma autonomous_transaction;
begin
  Select user into usuario from dual;

  begin
    insert into PV_BITACORA(BIT_ACCION,BIT_TIPO,BIT_DETALLE,BIT_USUARIO,BIT_FECHA)
               values('INSERTAR','Promociones',concat('Se insert� una nueva promocion id ',:new.pro_id),usuario,sysdate);
        commit;
  end;
end TRI_BITACORA_PROMOCIONES_INSERT;
/


create or replace noneditionable trigger TRI_BITACORA_PROMOCION_UPDATE
  after update
  on pv_promociones 
  for each row
declare
  usuario varchar2(30);
  pragma autonomous_transaction;
begin
  Select user into usuario from dual;
  
  begin
                         
    if(:old.pro_estado = 'I')then
      insert into PV_BITACORA(BIT_ACCION,BIT_TIPO,BIT_DETALLE,BIT_USUARIO,BIT_FECHA)
                 values('MODIFICAR','Promociones',concat('Se inactiv� la promoci�n id ',:old.pro_id),usuario,sysdate);
       commit;
    end if;
    
    if (:old.pro_validez_hasta<>:new.pro_validez_hasta) then
      insert into PV_BITACORA(BIT_ACCION,BIT_TIPO,BIT_DETALLE,BIT_USUARIO,BIT_FECHA)
                 values('MODIFICAR','Promociones',concat('Se modific� la fecha de v�lidez de la promoci�n id ',:old.pro_id),usuario,sysdate);
       commit;
    else
      insert into PV_BITACORA(BIT_ACCION,BIT_TIPO,BIT_DETALLE,BIT_USUARIO,BIT_FECHA)
                 values('MODIFICAR','Promociones',concat('Se modific� la promoci�n id ',:old.pro_id),usuario,sysdate);
       commit;
    end if;
  end;
end TRI_BITACORA_PROMOCION_UPDATE;
/


create or replace noneditionable trigger TRI_BITACORA_PROVEEDOR_INSERT
  after insert
  on pv_proveedores 
  for each row
declare
  usuario varchar2(30);
  pragma autonomous_transaction;
begin
  Select user into usuario from dual;
  
  begin
    insert into PV_BITACORA(BIT_ACCION,BIT_TIPO,BIT_DETALLE,BIT_USUARIO,BIT_FECHA)
               values('INSERTAR','Proveedor',concat('Se registr� un nuevo proveedor id ',:new.pro_id),usuario,sysdate);
        commit;
  end;
  
end TRI_BITACORA_PROVEEDOR_INSERT;
/


create or replace noneditionable trigger TRI_BITACORA_PROVEEDOR_UPDATE
  after update
  on pv_proveedores 
  for each row
declare
  -- local variables here
  usuario varchar2(30);
  pragma autonomous_transaction;
begin
  Select user into usuario from dual;
  
  begin
                             
    if((:old.pro_nombre <> :new.pro_nombre)or (:old.pro_telefono<>:new.pro_telefono) or (:old.pro_correo<>:new.pro_correo)) then
      insert into PV_BITACORA(BIT_ACCION,BIT_TIPO,BIT_DETALLE,BIT_USUARIO,BIT_FECHA)
                 values('MODIFICAR','Proveedores',concat('Se modific� el proveedor id ',:old.pro_id),usuario,sysdate);
       commit;
                              
    end if;
    

  end;
end TRI_BITACORA_PROVEEDOR_UPDATE;
/


create or replace noneditionable trigger TRI_BITACORAS_DESCUENTOS_UPDATE
  after update
  on pv_descuentos 
  for each row
declare
  usuario varchar2(30);
  pragma autonomous_transaction;
  
begin
  Select user into usuario from dual;
  
  begin
    
    if(:new.dec_estado = 'I') then
       insert into PV_BITACORA(BIT_ACCION,BIT_TIPO,BIT_DETALLE,BIT_USUARIO,BIT_FECHA)
                 values('MODIFICAR','Descuentos',concat(concat('Se modific� el descuento id ',:old.dec_id),' y ahora se encuentra inactivo'),usuario,sysdate);
       commit;  
    end if;
    
                               
    if(:old.dec_tipo <> :new.dec_tipo) then
      insert into PV_BITACORA(BIT_ACCION,BIT_TIPO,BIT_DETALLE,BIT_USUARIO,BIT_FECHA)
                 values('MODIFICAR','Descuentos',concat('Se modific� el tipo del descuento id ',:old.dec_id),usuario,sysdate);
       commit;
    else
       insert into PV_BITACORA(BIT_ACCION,BIT_TIPO,BIT_DETALLE,BIT_USUARIO,BIT_FECHA)
                 values('MODIFICAR','Descuentos',concat('Se modific� los datos del desceunto id ',:old.dec_id),usuario,sysdate);
       commit;                              
    end if;
    

  end;
end TRI_BITACORAS_DESCUENTOS_UPDATE;
/

create or replace noneditionable trigger TRI_BITACORA_CLIENTE_INSERT
  after insert
  on pv_clientes 
  for each row
declare
  -- local variables here
  usuario varchar2(30);
  pragma autonomous_transaction;
begin
  Select user into usuario from dual;
  
  begin
    insert into PV_BITACORA(BIT_ACCION,BIT_TIPO,BIT_DETALLE,BIT_USUARIO,BIT_FECHA)
               values('INSERTAR','Clientes',concat('Se registró un nuevo cliente id=',:new.cli_id),usuario,sysdate);
        commit;
  end;


end TRI_BITACORA_CLIENTE_INSERT;
/

create or replace noneditionable trigger TRI_BITACORA_CLIENTE_UPDATE
  after update
  on pv_clientes 
  for each row
declare
  -- local variables here
  usuario varchar2(30);
  pragma autonomous_transaction;
begin
  Select user into usuario from dual;
  
  begin
    
    if(:new.cli_estado = 'I') then
       insert into PV_BITACORA(BIT_ACCION,BIT_TIPO,BIT_DETALLE,BIT_USUARIO,BIT_FECHA)
                 values('MODIFICAR','Clientes',concat(concat('Se modificó el cliente id=',:old.cli_id),' y ahora se encuentra inactivo'),usuario,sysdate);
       commit;  
    end if;
    
                                
    if(:old.cli_cred_max <> :new.cli_cred_max) then
      insert into PV_BITACORA(BIT_ACCION,BIT_TIPO,BIT_DETALLE,BIT_USUARIO,BIT_FECHA)
                 values('MODIFICAR','Clientes',concat('Se modificó el crédito máximo del cliente id=',:old.cli_id),usuario,sysdate);
       commit;
    else
       insert into PV_BITACORA(BIT_ACCION,BIT_TIPO,BIT_DETALLE,BIT_USUARIO,BIT_FECHA)
                 values('MODIFICAR','Clientes',concat('Se modificó los datos del cliente id=',:old.cli_id),usuario,sysdate);
       commit;                              
    end if;
    

  end;
  
end TRI_BITACORA_CLIENTE_UPDATE;
/


--Funcion de envio de correos electronicos. Envia correos desde la direccion pruebas123pz@gmail.com
create or replace function enviar_correo(destinarios in varchar2, concepto in varchar2, cuerpo in varchar2) return varchar2 is


      destinatarios varchar2(512) := trim(lower(destinarios));
      email_regex CONSTANT VARCHAR2(300) := '^(([a-zA-Z0-9"_\-])((\.?[a-zA-Z0-9_\/%+="''\-]+)\.?[a-zA-Z0-9+-]*)@(\[((25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9][0-9]|[0-9])\.){3}|((([a-zA-Z0-9\-]+)\.)+))([a-zA-Z]{2,}|(25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9][0-9]|[0-9])\]))$';
      c utl_smtp.connection;
      l_mailhost VARCHAR2 (64) := 'smtp.gmail.com';
      l_from VARCHAR2 (64) := 'pruebas123pz@gmail.com'; -- EMISOR
      crlf varchar2(2) := UTL_TCP.CRLF;    
      
      
begin

  if destinatarios is not null and regexp_like(destinarios, email_regex) then
     begin
        c := utl_smtp.open_connection(
        host => l_mailhost,
        port => 587,
        wallet_path => 'file:C:\wallet\', -- RUTA DEL WALLET (Debe ser cambiada segun la ubucaion en cada base de datos en la que se ejecuta)
        wallet_password => 'abcd1234', -- CLAVE DE WALLET
        secure_connection_before_smtp => FALSE);
        UTL_SMTP.EHLO(c, 'smtp.gmail.com'); -- SERVIDOR SMTP
        UTL_SMTP.STARTTLS(c);
        utl_smtp.command( c, 'AUTH LOGIN');
        utl_smtp.command( c, 'cHJ1ZWJhczEyM3B6QGdtYWlsLmNvbQ=='); -- USUARIO ENCRIPTADO base64 ANTERIOR
        utl_smtp.command( c, 'MUFCQzJ4eXo='); -- CONTRASENA DEL SCRIPT base64 ANTERIOR
        UTL_SMTP.mail (c, l_from);
        UTL_SMTP.rcpt (c, destinatarios);
        UTL_SMTP.open_data (c);
        UTL_SMTP.write_data (c, 'Date: ' || TO_CHAR (SYSDATE, 'DD-MON-YYYY HH24:MI:SS') || crlf);
        UTL_SMTP.write_data (c, 'From: ' || l_from || crlf);
        UTL_SMTP.write_data (c, 'Subject: ' || concepto || crlf);
        UTL_SMTP.write_data (c, 'To: ' || destinatarios || crlf);
        UTL_SMTP.write_data (c, '' || crlf);
        
        UTL_SMTP.write_data (c, cuerpo || crlf);--Cuerpo del mensaje
         
        UTL_SMTP.close_data (c);
        UTL_SMTP.quit (c);
        return 'Correo enviado';
     exception
       when utl_smtp.Transient_Error OR utl_smtp.Permanent_Error then
         return 'No se ha sido posible enviar el email.';
       when others then
         return 'Error interno: ' || SQLCODE || ' ' || SQLERRM;
     end;
     else
        return 'Correo invalido';  
  end if;
end enviar_correo;
/

--envia correo de los productos por vencer o qu estan en bodega

create or replace noneditionable procedure PROC_VERIFICAR_FECHA_PRODUCTOS(mensaje out varchar2) is
  cursor productos is select p.pro_id,p.pro_vencimiento,p.pro_ingreso,p.pro_inventario from Pv_Productos p;
  cursor inventario is select i.inv_id from PV_INVENTARIOS i where i.inv_tipo='BOD';
  res varchar2(100);
  porVencer varchar2(100);
  enBodega varchar2(100);
  mensj1 varchar2(100);
  mensj2 varchar2(100);

begin
  porVencer:= ' ';
  enBodega := ' ';
  mensj1 := 'Los siguientes productos están por vencer id';
  mensj2 := 'Los siguientes productos llevan 6 meses o más de estar en bodega id';
  
  --productos por vencer 
  for var in productos loop
    if((var.pro_vencimiento)<=sysdate+8) then 
          porVencer:= porVencer ||', '|| var.pro_id;           
    end if;
    
    --productos que se encuentran en bodega
    for v in inventario loop
      if(var.pro_inventario=v.inv_id) then
          if(MONTHS_BETWEEN(sysdate,var.pro_ingreso)>6) then 
             enBodega:= enBodega ||', '|| var.pro_id;                                           
          end if;                            
      end if;
    end loop;

  end loop;
  
  if ((porVencer<>' ')and(enBodega<>' '))then
    mensaje:=mensj1||porVencer||'.  '|| mensj2||enBodega;
    res := enviar_correo('cordobaangie98@gmail.com', 'Vencimiento de productos y productos en bodega',mensaje );
  elsif ((porVencer<>' ')and(enBodega=' '))then
    mensaje:=mensj1||porVencer;
    res := enviar_correo('cordobaangie98@gmail.com', 'Vencimiento de productos',mensaje );
  elsif ((porVencer=' ')and(enBodega<>' '))then
    mensaje:=mensj2||enBodega;
    res := enviar_correo('cordobaangie98@gmail.com', 'Productos en bodega',mensaje );
  end if;

  
end PROC_VERIFICAR_FECHA_PRODUCTOS;

/


create or replace procedure PROC_PREMIAR_CLIENTES(mensaje out varchar2) is
cursor clientes is select * from (select sum(f.fac_total),c.cli_id,f.fac_sede from PV_FACTURAS_VENTA f 
     join PV_CLIENTES c on f.fac_cliente=c.cli_id where c.cli_estado='A' group by c.cli_id,f.fac_sede order by sum(f.fac_total) DESC) where Rownum<=10; 
cursor empresas is select c.emp_id,i.inv_sede from PV_COMPANIA c join PV_INVENTARIOS i on c.emp_inventario=i.inv_id;
clientesSeleccionados varchar2(100);
res varchar2(100);
begin
  clientesSeleccionados:=' ';
     
  begin
    for v in empresas loop
     for var in clientes loop
       if(v.inv_sede=var.fac_sede) then
          clientesSeleccionados := clientesSeleccionados || ', ' || var.cli_id;
          insert into PV_NOTAS_CRED(NOT_EMPRESA,NOT_CLIENTE,NOT_MONTO,NOT_ESTADO,NOT_FECHA_EMISION) 
                 values(v.emp_id,var.cli_id,100000,'A',ADD_MONTHS(sysdate,2));     --nota de crédito solo válido solo por 2 meses      
       end if;
     end loop;
      
    end loop;
    
    if clientesSeleccionados <> ' ' then
      mensaje:='Los siguientes clientes fueron ganadores de una nota de crédito de 100 mil colones, id '||clientesSeleccionados;
      res := enviar_correo('cordobaangie98@gmail.com', 'Premiación de Clientes',mensaje );
    end if;
    
  end;
  
end PROC_PREMIAR_CLIENTES;

/
