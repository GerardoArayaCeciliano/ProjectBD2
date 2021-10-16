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
  select c.cue_id into cuenta_proveedor from PEV_CUENTAS_PAGAR c where c.cue_proveedor = :new.fac_provedor;
  
  begin
    if(:new.fac_estado = 'P') then
      update PEV_CUENTAS_PAGAR c
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
    select f.fac_total into montoTotal from PV_FACTURAS_VENTA f where f.fac_id = :new.fac_id;
    select SUM(a.abov_monto) into abonos from PV_ABONOS_VENTAS a where a.fac_id = :new.fac_id;

    if (abonos = montoTotal) then
      begin
        UPDATE PV_FACTURAS_VENTA f set f.fac_estado = 'C' where f.fac_id = :new.fac_id;
        commit;
      end;
    end if;

 end;
end TRI_CAMBIAR_ESTADO_FAC_VENTA;
/


--Trigger de cambiar el estado de las facturas de compra a canceladas

create or replace trigger TRI_CAMBIAR_ESTADO_FACT_COMPRA
  after insert
  on pv_abonos 
  for each row
declare

  abonos float;
  montoTotal float;
  pragma autonomous_transaction;
begin
  begin
    select f.fac_monto_total into montoTotal from PV_FACTURAS_COMPRA f where f.fac_id = :new.fac_id;
    select SUM(a.abo_monto) into abonos from PV_ABONOS a where a.fac_id = :new.fac_id;

    if (abonos = montoTotal) then
      begin
        UPDATE PV_FACTURAS_COMPRA f set f.fac_estado = 'C' where f.fac_id = :new.fac_id;
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
     insert into PEV_CUENTAS_PAGAR(CUE_PROVEEDOR,CUE_MONTO) VALUES(:new.pro_id,0);

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
  select f.fac_provedor into cuentaProveed from PV_FACTURAS_COMPRA f where f.fac_id = :new.fac_id;
  
  begin
    
     update PEV_CUENTAS_PAGAR c set c.cue_monto = (c.cue_monto - :new.abo_monto) where c.cue_proveedor = cuentaProveed;

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
   select f.fac_cliente into cuentaCliente from PV_FACTURAS_VENTA f where f.fac_id = :new.fac_id;
  
  begin
    
     update PV_CUENTAS_COBRAR c set c.cue_saldo_pendiente = (c.cue_saldo_pendiente - :new.abov_monto) where c.cue_cliente = cuentaCliente;

  end;
end TRI_DISMINUIR_SALDO_CLIENTE;
/

