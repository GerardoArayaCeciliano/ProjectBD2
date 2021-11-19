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
    if :new.abov_monto = montoTotal then
      UPDATE PV_FACTURAS_VENTA f set f.fac_estado = 'C' where f.fac_id = :new.abov_fac_id;
          commit;
    else
      select SUM(a.abov_monto) into abonos from PV_ABONOS_VENTAS a where a.abov_fac_id = :new.abov_fac_id;

      if (abonos = montoTotal) then
          UPDATE PV_FACTURAS_VENTA f set f.fac_estado = 'C' where f.fac_id = :new.abov_fac_id;
          commit;
      end if;
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
    if :new.abo_monto = montoTotal then
      UPDATE PV_FACTURAS_COMPRA f set f.fac_estado = 'C' where f.fac_id = :new.abo_fac_id;
        commit;
    else
      select SUM(a.abo_monto) into abonos from PV_ABONOS a where a.abo_fac_id = :new.abo_fac_id;

      if (abonos = montoTotal) then
          UPDATE PV_FACTURAS_COMPRA f set f.fac_estado = 'C' where f.fac_id = :new.abo_fac_id;
          commit;
      end if;
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
               values('INSERTAR','Facturación',concat(concat('Se insertó factura de compra id ',:new.fac_id),', en estado pendiente de pago'),usuario,sysdate);
        commit;

      when :new.fac_estado = 'C' then

        insert into PV_BITACORA(BIT_ACCION,BIT_TIPO,BIT_DETALLE,BIT_USUARIO,BIT_FECHA)
               values('INSERTAR','Facturación',concat(concat('Se insertó factura de compra id',:new.fac_id),', cancelada a contado'),usuario,sysdate);
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
                 values('MODIFICAR','Facturación',concat(concat('Se modificó la factura de compra id ',:old.fac_id),' y ahora se encuantra cancelada'),usuario,sysdate);
        commit;
      end if;
    elsif :new.fac_estado = 'I' then
      insert into PV_BITACORA(BIT_ACCION,BIT_TIPO,BIT_DETALLE,BIT_USUARIO,BIT_FECHA)
                 values('MODIFICAR','Facturación',concat(concat('Se modificó la factura de compra id ',:old.fac_id),' y su estado ahora es inactivo'),usuario,sysdate);
        commit;
    end if;

    if :old.fac_monto_total <> :new.fac_monto_total then
       insert into PV_BITACORA(BIT_ACCION,BIT_TIPO,BIT_DETALLE,BIT_USUARIO,BIT_FECHA)
                 values('MODIFICAR','Facturación',concat('Se modificó el monto de la factura de compra id ',:old.fac_id),usuario,sysdate);
        commit;
    else
      insert into PV_BITACORA(BIT_ACCION,BIT_TIPO,BIT_DETALLE,BIT_USUARIO,BIT_FECHA)
                 values('MODIFICAR','Facturación',concat('Se modificó factura de compra id ',:old.fac_id),usuario,sysdate);
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
               values('INSERTAR','Facturación',concat(concat('Se insertó factura de venta id ',:new.fac_id),' en estado pendiente de pago'),usuario,sysdate);
        commit;

      when :new.fac_estado = 'C' then

        case
          when :new.fac_tipo_pago = 'EFECTIVO' then
          insert into PV_BITACORA(BIT_ACCION,BIT_TIPO,BIT_DETALLE,BIT_USUARIO,BIT_FECHA)
               values('INSERTAR','Facturación',concat(concat('Se insertó factura de venta id ',:new.fac_id),' cancelada en efectivo'),usuario,sysdate);
               commit;

          when :new.fac_tipo_pago = 'SINPE' then
          insert into PV_BITACORA(BIT_ACCION,BIT_TIPO,BIT_DETALLE,BIT_USUARIO,BIT_FECHA)
               values('INSERTAR','Facturación',concat(concat('Se insertó factura de venta id ',:new.fac_id),' cancelada por sinpe'),usuario,sysdate);
               commit;
          when :new.fac_tipo_pago = 'TARJETA' then
          insert into PV_BITACORA(BIT_ACCION,BIT_TIPO,BIT_DETALLE,BIT_USUARIO,BIT_FECHA)
               values('INSERTAR','Facturación',concat(concat('Se insertó factura de venta id ',:new.fac_id),' cancelada en tarjeta'),usuario,sysdate);
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
                 values('MODIFICAR','Facturación',concat(concat('Se modificó la factura de venta id ',:old.fac_id),' y ahora se encuantra cancelada'),usuario,sysdate);
        commit;
      end if;
    elsif :new.fac_estado = 'I' then
      insert into PV_BITACORA(BIT_ACCION,BIT_TIPO,BIT_DETALLE,BIT_USUARIO,BIT_FECHA)
                 values('MODIFICAR','Facturación',concat(concat('Se modificó la factura de venta id ',:old.fac_id),' y su estado ahora es inactivo'),usuario,sysdate);
        commit;
    end if;
    

    if :old.fac_total <> :new.fac_total then
       insert into PV_BITACORA(BIT_ACCION,BIT_TIPO,BIT_DETALLE,BIT_USUARIO,BIT_FECHA)
                 values('MODIFICAR','Facturación',concat('Se modificó el monto de la factura de venta id ',:old.fac_id),usuario,sysdate);
        commit;
    else 
      insert into PV_BITACORA(BIT_ACCION,BIT_TIPO,BIT_DETALLE,BIT_USUARIO,BIT_FECHA)
                 values('MODIFICAR','Facturación',concat('Se modificó la factura de ventas id ',:old.fac_id),usuario,sysdate);
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
               values('INSERTAR','Cambio de precios',concat('Se insertó un nuevo precio del producto ',:new.pre_producto),usuario,sysdate);
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
               values('MODIFICAR','Cambio de precios',concat('Se insertó un nuevo precio del producto id ',:new.pre_producto),usuario,sysdate);
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
               values('MODIFICAR','Cambio de precios',concat('Se insertó un nuevo precio del producto id ',:new.pre_producto),usuario,sysdate);
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
               values('INSERTAR','Promociones',concat('Se insertó una nueva promocion id ',:new.pro_id),usuario,sysdate);
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
                 values('MODIFICAR','Promociones',concat('Se inactivó la promoción id ',:old.pro_id),usuario,sysdate);
       commit;
    end if;
    
    if (:old.pro_validez_hasta<>:new.pro_validez_hasta) then
      insert into PV_BITACORA(BIT_ACCION,BIT_TIPO,BIT_DETALLE,BIT_USUARIO,BIT_FECHA)
                 values('MODIFICAR','Promociones',concat('Se modificó la fecha de válidez de la promoción id ',:old.pro_id),usuario,sysdate);
       commit;
    else
      insert into PV_BITACORA(BIT_ACCION,BIT_TIPO,BIT_DETALLE,BIT_USUARIO,BIT_FECHA)
                 values('MODIFICAR','Promociones',concat('Se modificó la promoción id ',:old.pro_id),usuario,sysdate);
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
               values('INSERTAR','Proveedor',concat('Se registró un nuevo proveedor id ',:new.pro_id),usuario,sysdate);
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
                 values('MODIFICAR','Proveedores',concat('Se modificó el proveedor id ',:old.pro_id),usuario,sysdate);
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
                 values('MODIFICAR','Descuentos',concat(concat('Se modificó el descuento id ',:old.dec_id),' y ahora se encuentra inactivo'),usuario,sysdate);
       commit;  
    end if;
    
                               
    if(:old.dec_tipo <> :new.dec_tipo) then
      insert into PV_BITACORA(BIT_ACCION,BIT_TIPO,BIT_DETALLE,BIT_USUARIO,BIT_FECHA)
                 values('MODIFICAR','Descuentos',concat('Se modificó el tipo del descuento id ',:old.dec_id),usuario,sysdate);
       commit;
    else
       insert into PV_BITACORA(BIT_ACCION,BIT_TIPO,BIT_DETALLE,BIT_USUARIO,BIT_FECHA)
                 values('MODIFICAR','Descuentos',concat('Se modificó los datos del desceunto id ',:old.dec_id),usuario,sysdate);
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
  cursor roles is select p.par_correo,r.rol_nombre from pv_parametros p inner join pv_roles r on r.rol_id=p.par_rol where lower(r.rol_nombre)='coordinador';
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
          if(MONTHS_BETWEEN(var.pro_ingreso,sysdate)>6) then
             enBodega:= enBodega ||', '|| var.pro_id;
          end if;
      end if;
    end loop;

  end loop;

  if ((porVencer<>' ')and(enBodega<>' '))then
    mensaje:=mensj1||porVencer||'.  '|| mensj2||enBodega;
    for v in roles loop
        res := enviar_correo(v.par_correo,'Vencimiento de productos y productos en bodega',mensaje );--enviar correo al coordinador
    end loop;
  elsif ((porVencer<>' ')and(enBodega=' '))then
    mensaje:=mensj1||porVencer;
    for v in roles loop
         res := enviar_correo(v.par_correo,  'Vencimiento de productos',mensaje ); --enviar correo al coordinador
    end loop;
  elsif ((porVencer=' ')and(enBodega<>' '))then
    mensaje:=mensj2||enBodega;
    for v in roles loop
         res := enviar_correo(v.par_correo, 'Productos en bodega',mensaje );  --enviar correo al coordinador
    end loop;
  end if;


end PROC_VERIFICAR_FECHA_PRODUCTOS;
/



create or replace noneditionable procedure PROC_PREMIAR_CLIENTES(mensaje out varchar2) is
cursor clientes is select * from (select sum(f.fac_total),c.cli_id,f.fac_sede from PV_FACTURAS_VENTA f
     join PV_CLIENTES c on f.fac_cliente=c.cli_id where c.cli_estado='A' group by c.cli_id,f.fac_sede order by sum(f.fac_total) DESC) where Rownum<=10;
cursor empresas is select c.emp_id,i.inv_sede from PV_COMPANIA c join PV_INVENTARIOS i on c.emp_inventario=i.inv_id;
cursor roles is select p.par_correo,r.rol_nombre from pv_parametros p inner join pv_roles r on r.rol_id=p.par_rol where lower(r.rol_nombre)='coordinador';
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
      for v in roles loop
          res := enviar_correo(v.par_correo,  'Premiación de Clientes',mensaje );  --enviar correo al coordinador
       end loop;
    end if;

  end;

end PROC_PREMIAR_CLIENTES;
/

create or replace noneditionable function GET_DESCUENTOS_LIQUIDACION_ACTIVOS(producto_id pv_productos.pro_id%type) return number is
  resultado number;
begin
  select count(*) into resultado from pv_desc_liquidacion d
  join pv_productos p on p.pro_id = d.des_producto
  where p.pro_id = producto_id and  d.des_estado = 'A';
  return resultado;
end GET_DESCUENTOS_LIQUIDACION_ACTIVOS;

/

create or replace noneditionable procedure proc_liquidar_inventario(sede_id in pv_sedes.sed_id%type ,id_inventario in pv_inventarios.inv_id%type) is
       
       cursor productos is select * from pv_productos p where p.pro_estado = 'A' and p.pro_inventario = id_inventario;
              
       liquid_activas number;
       descuento_liq pv_descuentos%rowtype;
       
begin
  
  select count(*) into liquid_activas from pv_descuentos d
         where d.dec_estado = 'A' and d.dec_tipo = 'LIQ' 
         and d.dec_sede = sede_id and sysdate between d.dec_vigencia_desde and d.dec_vigencia_hasta;
  
--Solo se realiza el proceso de liquidacion si hay 1 liquidacion activa en el momento dado para esta sede.
    if liquid_activas = 1 then
      begin
       select * into descuento_liq from pv_descuentos d
             where d.dec_estado = 'A' and d.dec_tipo = 'LIQ' and d.dec_sede = sede_id 
             and sysdate between d.dec_vigencia_desde and d.dec_vigencia_hasta;
--Se recorren los productos del inventario enviado por parametros         
        for producto in productos loop
          
--Se verifica si el producto ya cuenta con descuentos por liquidacion activos.
          if GET_DESCUENTOS_LIQUIDACION_ACTIVOS(producto.pro_id) = 0 then
            
--Se evalua si el descuento aplica ya sea por fecha de ingreso o de vencimiento       
            if descuento_liq.dec_ingreso is not null and producto.pro_ingreso < descuento_liq.dec_ingreso then
              
               insert into pv_desc_liquidacion(des_producto,des_descuento, des_estado)
               values (producto.pro_id, descuento_liq.dec_id, 'A');
               
            elsif descuento_liq.dec_vencimiento is not null and producto.pro_vencimiento < descuento_liq.dec_vencimiento then
              
               insert into pv_desc_liquidacion(des_producto, des_descuento, des_estado)
               values (producto.pro_id, descuento_liq.dec_id, 'A');
               
            end if;
          end if;  
        end loop;
        commit;
      exception
--Si algo sale mal se realiza un rollback de los cambios realizados
        when others then
          rollback;  
       end;
    end if;

end proc_liquidar_inventario;


/

create or replace noneditionable procedure PROC_APLICAR_DESCUENTOS_LIQUIDACION is

     cursor sedes is select * from Pv_Sedes s where s.sede_estado = 'A';
     inventarios_por_sede SYS_REFCURSOR;
     invetario_aux pv_inventarios%rowtype;
     
begin

--Se recorren las sedes  
  for sede in sedes loop
    
    open inventarios_por_sede for select * from pv_inventarios i
         where i.inv_sede = sede.sed_id and i.inv_estado = 'A' and i.inv_tipo = 'GON';

--Por cada sede se recorren todos sus inventarios tipo Gondola
    loop
      fetch inventarios_por_sede into invetario_aux;
      exit when inventarios_por_sede%notfound;
      proc_liquidar_inventario(sede.sed_id, invetario_aux.inv_id);
    end loop;
    close inventarios_por_sede;
        
  end loop;
end PROC_APLICAR_DESCUENTOS_LIQUIDACION;

/





---------------------------------notificaciones-----------------------------------


create or replace noneditionable procedure PROC_NOTIFICAR_COORDINADOR_LIMITE(mensaje out varchar2) is
cursor notCredito is select sum(cc.cue_saldo_pendiente) as total,c.cli_id,c.cli_cred_max,c.cli_email from PV_CUENTAS_COBRAR cc
       join PV_CLIENTES c on cc.cue_cliente=c.cli_id group by c.cli_id,c.cli_cred_max,c.cli_email;
porcentaje number;
cursor roles is select p.par_correo,r.rol_nombre from pv_parametros p inner join pv_roles r on r.rol_id=p.par_rol where lower(r.rol_nombre)='coordinador';
res varchar2(100);
clientes varchar2(100);

begin
  clientes:=' ';
  
  begin
    for var in notCredito loop
      porcentaje:=((var.cli_cred_max*85)/100);  --limite maximo 85% de las cuentas por cobrar
      if(var.total>=porcentaje) then
         clientes :=clientes ||', '|| var.cli_id;
      end if;
    end loop;
    
    begin
      if clientes<>' ' then
        mensaje:= 'Los clientes que cuentan con un 85% o más de su límite de crédito máximo son los siguientes, id'||clientes;
        for v in roles loop
             res := enviar_correo(v.par_correo, 'Límite del crédito máximo de los clientes',mensaje );  --enviar correo al coordinador
        end loop;
      end if;
    end;

  end;

end PROC_NOTIFICAR_COORDINADOR_LIMITE;
/



create or replace noneditionable procedure PROC_NOTIFICAR_LIMITE_CLIENTE(mensaje out varchar2) is
cursor notCredito is select sum(cc.cue_saldo_pendiente) as total,c.cli_id,c.cli_cred_max,c.cli_email from PV_CUENTAS_COBRAR cc 
       join PV_CLIENTES c on cc.cue_cliente=c.cli_id group by c.cli_id,c.cli_cred_max,c.cli_email;
porcentaje number;
res varchar2(100);
begin
  
  begin
    for var in notCredito loop
      porcentaje:=((var.cli_cred_max*85)/100);  --85% del saldo permitido en cuentas por cobrar
      if(var.total>=porcentaje) then
         if(var.cli_email<>' ') then
             mensaje:='Su crédito máximo ya casi llega al límite permitido, debe un total de '|| var.total;
             res := enviar_correo(var.cli_email, 'Límite del crédito máximo',mensaje );
         end if;
      end if;
    end loop; 
  end;
end PROC_NOTIFICAR_LIMITE_CLIENTE;
/


create or replace noneditionable procedure PROC_NOTIFICAR_LIMITE_PROVEEDORES(mensaje out varchar2) is
cursor credito is select * from PV_LIMITE_CREDITO l join PV_PROVEEDORES p on l.lim_proveedor=p.pro_id;
cursor roles is select p.par_correo,r.rol_nombre from pv_parametros p inner join pv_roles r on r.rol_id=p.par_rol where lower(r.rol_nombre)='gerente';
total float;
porcentaje number;
res varchar2(100);
prov varchar2(100);

begin
  prov:=' ';

  begin
    for var in credito loop
      select sum(c.cue_monto) into total from PV_CUENTAS_PAGAR c where c.cue_proveedor=var.lim_proveedor;
      porcentaje:=((var.lim_limite_max * 70)/100);  --70% del saldo permitido en cuentas por pagar
      if(total>=porcentaje) then
           prov:= prov||', ' || var.pro_id;

      end if;

      if prov <> ' ' then
        mensaje:='El crédito máximo ya casi llega al límite permitido de cuentas por pagar de los siguientes proveedores, id'||prov;
        for v in roles loop
             res := enviar_correo(v.par_correo, 'Límite del crédito máximo de cuentas por pagar',mensaje );   --notificar al gerente
        end loop;
      end if;

    end loop;
  end;

end PROC_NOTIFICAR_LIMITE_PROVEEDORES;
/



create or replace noneditionable procedure PROC_NOTIFICAR_PRODUCTOS_VENCIDOS(mensaje out varchar2) is
cursor productos is select * from PV_PRODUCTOS p where p.pro_vencimiento <= sysdate;  --productos vencidos
cursor roles is select p.par_correo,r.rol_nombre from pv_parametros p inner join pv_roles r on r.rol_id=p.par_rol where lower(r.rol_nombre)='coordinador';
total float;
res varchar2(100);
precio float;
product varchar2(100);

begin
  total:=0;
  product:=' ';
  begin
    for var in productos loop
      select p.pre_precio_costo into precio from PV_PRECIOS p where p.pre_estado='ACT' and p.pre_producto=var.pro_id;
      total:=total+precio;
      product:=product||', '||var.pro_id;
    end loop;

    if product<> ' ' then
      mensaje:='Lista de productos vencidos, id'||product|| ' , para un total de '||total;
      for v in roles loop
         res := enviar_correo(v.par_correo, 'Lista de productos vencidos',mensaje );   --notificar al coordinador
      end loop;
    end if;

  end;

end PROC_NOTIFICAR_PRODUCTOS_VENCIDOS;
/


create or replace noneditionable procedure PROC_NOTIFICAR_ULTIMO_PAGO(mensaje out varchar2) is
cursor abonos is select distinct a.abov_fac_id,f.fac_cliente from PV_ABONOS_VENTAS a join PV_FACTURAS_VENTA f on a.abov_fac_id=f.fac_id where f.fac_estado='P';
cursor roles is select p.par_correo,r.rol_nombre from pv_parametros p inner join pv_roles r on r.rol_id=p.par_rol where lower(r.rol_nombre)='coordinador' or lower(r.rol_nombre)='gerente';
fecha date;
res varchar2(100);
client varchar2(100);
begin
  client:= ' ';
  begin

    for var in abonos loop
      select a.abov_fecha_abono into fecha from PV_ABONOS_VENTAS a
         where a.abov_fecha_abono=(select max(v.abov_fecha_abono) from PV_ABONOS_VENTAS v where  v.abov_fac_id = var.abov_fac_id) ; --ultimo fecha del abono del cliente

      if(MONTHS_BETWEEN(sysdate,fecha)>1) then  --si el ultimo abono tiene mas de un mes
         client:= client ||', ' ||var.fac_cliente;
      end if;
    end loop;

    if client<>' ' then
      mensaje:='Los siguientes clientes tienen cuentas pendientes de pago y su último abono fue hace un mes o más, id'||client;
      for v in roles loop
           res := enviar_correo(v.par_correo, 'Clientes morosos',mensaje );  --notificar al coordinador y al gerente
      end loop;
    end if;
  end;

end PROC_NOTIFICAR_ULTIMO_PAGO;
/



create or replace noneditionable procedure PROC_CIERRES_DIARIOS(mensaje out varchar2) is
cursor facturas is select * from PV_FACTURAS_VENTA f where TO_DATE(f.fac_fecha,'DD/MM/YYYY')=TO_DATE(sysdate,'DD/MM/YYYY');
cursor detalles is select * from PV_DETALL_FAC_VENTA d;
cursor roles is select p.par_correo,r.rol_nombre from pv_parametros p inner join pv_roles r on r.rol_id=p.par_rol where lower(r.rol_nombre)='coordinador' or lower(r.rol_nombre)='gerente';

total float;
cantProduc number;
cantDevoluc number;

res varchar2(100);
begin
  total:=0;
  cantProduc:=0;
  cantDevoluc:=0;
  
  begin
    for var in facturas loop
      total:=total+var.fac_total;
      for v in detalles loop
        if var.fac_id = v.det_factura then
           cantProduc:=cantProduc+v.det_unidades;
           if v.det_nota_credito is not null then
             cantDevoluc:=cantDevoluc+1;
           end if;
        end if;
      end loop;
    end loop;
    
    mensaje:='Cierre diario'||chr(10)||'Fecha :'||sysdate||chr(10)||'Cantidad de productos vendidos :'||cantProduc||chr(10)||'Cantidad de devoluciones :'||cantDevoluc||chr(10)||'Total obtenido :'||total;
    for v in roles loop
         res := enviar_correo(v.par_correo, 'Cierre diario',mensaje );   --enviar al coordinador y al gerente
    end loop;

  end;
  
end PROC_CIERRES_DIARIOS;
/


create or replace procedure PROC_NOTIFICAR_OBJETOS_INVALIDOS(mensaje out varchar2) is
cursor roles is select p.par_correo,r.rol_nombre from pv_parametros p inner join pv_roles r on r.rol_id=p.par_rol where lower(r.rol_nombre)='coordinador';
cursor objetos is select OBJECT_NAME,OBJECT_TYPE from dba_objects
               where status = 'INVALID' order by OWNER,OBJECT_TYPE,OBJECT_NAME;
errores varchar2(500);
res varchar2(100);
begin
  errores:=' ';
  begin
    for v in objetos loop
      errores:=errores||chr(10)||v.object_type||'-'||v.object_name;
    end loop;
    
    if errores<>' ' then
      for v in roles loop
        mensaje:='Se encontraron los siguientes errores de objetos invalidos'||errores;
        res := enviar_correo(v.par_correo, 'Límite del crédito máximo de los clientes',mensaje );  --enviar correo al coordinador
      end loop;
    end if;
    
  end;
end PROC_NOTIFICAR_OBJETOS_INVALIDOS;
/


create or replace procedure PROC_NOTIFICAR_INDICES_DANADOS(mensaje out varchar2) is
cursor indiceDanados is SELECT err_timestamp, err_text FROM ctx_user_index_errors 
                               ORDER BY err_timestamp DESC;
                               
cursor roles is select p.par_correo,r.rol_nombre from pv_parametros p inner join pv_roles r on r.rol_id=p.par_rol where lower(r.rol_nombre)='coordinador';
errores varchar2(100);
res varchar2(100);
begin
  errores:=' ';
  
  begin
    for v in indiceDanados loop
      errores:=errores || v.err_timestamp||'-'||v.err_text||chr(10);
    end loop;
  end;
  
  if errores<>' ' then
    mensaje:='Indices dañados'||chr(10)||errores;
    for v in roles loop
             res := enviar_correo(v.par_correo, 'Indices dañados',mensaje );  --enviar correo al coordinador
        end loop;
  end if;
  
end PROC_NOTIFICAR_INDICES_DANADOS;
/


create or replace noneditionable procedure PROC_VERIFICAR_TABLESPACE(mensaje out varchar) is
cursor roles is select p.par_correo,r.rol_nombre from pv_parametros p inner join pv_roles r on r.rol_id=p.par_rol where lower(r.rol_nombre)='coordinador';
CURSOR c_espacio_total
IS select tablespace_name, round(sum(BYTES/1024/1024),0) FROM dba_data_files b
       WHERE tablespace_name NOT LIKE 'TEMP%' GROUP BY b.tablespace_name;

CURSOR c_espacio_libre IS SELECT tablespace_name,ROUND(sum(bytes)/1024/1024,0) FROM dba_free_space
       WHERE tablespace_name NOT LIKE 'TEMP%' GROUP BY tablespace_name;

c_nombre VARCHAR2(20);
c_libre NUMBER(10);
c_total NUMBER(10);
tablespaces varchar2(100);
res varchar2(100);

BEGIN
  tablespaces:= ' ';

  OPEN c_espacio_libre;
  OPEN c_espacio_total;
  FETCH c_espacio_libre INTO c_nombre,c_libre;
  FETCH c_espacio_total INTO c_nombre,c_total;
  WHILE c_espacio_libre%found
    LOOP
      IF (TRUNC((100-((c_libre/c_total)*100)),2) >= 85) THEN
         tablespaces:=tablespaces||', '||c_nombre;
      END IF;
      FETCH c_espacio_libre INTO c_nombre, c_libre;
      FETCH c_espacio_total INTO c_nombre,c_total;
    END LOOP;
  CLOSE c_espacio_libre;
  CLOSE c_espacio_total;
  
  if tablespaces<> ' ' then
    mensaje:='Los siguientes tablesspace ya cuenta con un 85% o más del límite permitido'||tablespaces;
       for v in roles loop
           res := enviar_correo(v.par_correo, 'Límite del  los tablespace',mensaje );  --enviar correo al coordinador
      end loop;
  end if;
END;
/



create or replace noneditionable function calcular_acciones_ganadas(factura_id in pv_facturas_venta.fac_id%type) return float is

  cursor detalles is select * from pv_detall_fac_venta det where det.det_factura = factura_id;
  promociones_producto SYS_REFCURSOR;
  
  factura pv_facturas_venta%rowtype;
  acciones_totales float := 0;
  prod_promo_aux pv_prod_promo%rowtype;
  
begin
  begin
    select * into factura from pv_facturas_venta f where f.fac_id = factura_id;
    for det in detalles loop
      
      open promociones_producto for select pm.pro_producto, pm.pro_promocion, pm.pro_prod_accion
      from pv_prod_promo pm join pv_promociones prom on prom.pro_id = pm.pro_promocion
      where prom.pro_estado = 'A' and prom.pro_validez_hasta >= sysdate
      and pm.pro_prod_accion is not null and pm.pro_prod_accion > 0
      and pm.pro_producto = det.det_producto;
      
      loop
         fetch promociones_producto into prod_promo_aux;
         exit when promociones_producto%notfound;
         
         if det.det_unidades >= prod_promo_aux.pro_prod_accion then
            acciones_totales := acciones_totales + round(det.det_unidades / prod_promo_aux.pro_prod_accion);
         end if;
      end loop;
      
      close promociones_producto;
    end loop;
    
  exception
    when NO_DATA_FOUND then
      return -1;
  end;
  return acciones_totales;
end calcular_acciones_ganadas;

/


-------jobs----------

declare
         a number;
begin
  sys.dbms_job.submit(a,'PROC_APLICAR_DESCUENTOS_LIQUIDACION;', sysdate, 'SYSDATE + 7');
  commit;
end;

/


declare
         a number;
begin
  sys.dbms_job.submit(a,'PROC_VERIFICAR_FECHA_PRODUCTOS;', sysdate, 'SYSDATE + 7');
  commit;
end;

/



--cada 6meses

declare
         a number;
begin
  sys.dbms_job.submit(a,'PROC_PREMIAR_CLIENTES;', sysdate, 'ADD_MONTHS(sysdate,+6)');
  commit;
end;

/


declare
         a number;
begin
  sys.dbms_job.submit(a,'PROC_NOTIFICAR_LIMITE_CLIENTE;', sysdate, 'SYSDATE + 1');
  commit;
end;

/


declare
         a number;
begin
  sys.dbms_job.submit(a,'PROC_NOTIFICAR_COORDINADOR_LIMITE;', sysdate, 'SYSDATE + 1');
  commit;
end;

/


declare
         a number;
begin
  sys.dbms_job.submit(a,'PROC_NOTIFICAR_LIMITE_PROVEEDORES;', sysdate, 'SYSDATE + 1');
  commit;
end;

/


declare
         a number;
begin
  sys.dbms_job.submit(a,'PROC_NOTIFICAR_ULTIMO_PAGO;', sysdate, 'SYSDATE + 1');
  commit;
end;

/


declare
         a number;
begin
  sys.dbms_job.submit(a,'PROC_VERIFICAR_FECHA_PRODUCTOS;', sysdate, 'SYSDATE + 1');
  commit;
end;

/


declare
         a number;
begin
  sys.dbms_job.submit(a,'PROC_VERIFICAR_TABLESPACE;', sysdate, 'SYSDATE + 1');
  commit;
end;

/


declare
         a number;
begin
  sys.dbms_job.submit(a,'PROC_NOTIFICAR_OBJETOS_INVALIDOS;', sysdate, 'SYSDATE + 1');
  commit;
end;

/


declare
         a number;
begin
  sys.dbms_job.submit(a,'PROC_CIERRES_DIARIOS;', To_date('18/11/21 23:00:00','dd/mm/yyyy hh24:mi:ss'), 'SYSDATE + 1');
  commit;
end;

/


declare
         a number;
begin
  sys.dbms_job.submit(a,'PROC_NOTIFICAR_INDICES_DANADOS;', sysdate, 'SYSDATE + 1');
  commit;
end;

/
