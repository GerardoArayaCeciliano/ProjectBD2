--Punto 1 Trigger aumentar saldo de la cuenta por cobrar del cliente --

create or replace noneditionable trigger TRI_AUMENTAR_SALDO_PENDIENTE_CLIENTE
  after insert
  on pv_facturas_venta
  for each row
declare
  cuentaUsuario number;
begin
  select c.cue_id into cuentaUsuario from PV_CUENTAS_COBRAR c where c.cue_cliente = :new.fac_cliente;

  begin
    if(:new.fac_estado = 'P') then
      update PV_CUENTAS_COBRAR c
      set c.CUE_SALDO_PENDIENTE = (c.CUE_SALDO_PENDIENTE + :new.fac_total)
      where c.cue_id = cuentaUsuario;
    end if;
  end;
end TRI_AUMENTAR_SALDO_PENDIENTE_CLIENTE;
/