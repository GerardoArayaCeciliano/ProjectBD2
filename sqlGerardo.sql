create or replace noneditionable trigger TRI_MODIFICAR_INVENTARIO_COMPRA
  after insert
  on pv_detall_fac_compra
  for each row
declare
  cantidadProducto number;
  pragma autonomous_transaction;
begin
    --Consultar la cantidad de productos--
         Select pr.pro_cantidad into cantidadProducto from
          pv_productos pr where pr.pro_id=:new.det_producto;
         --Editar cantidad de productos--
         update pv_productos pr set pr.pro_cantidad=(cantidadProducto+:new.det_cantidad) where
         pr.pro_id=:new.det_producto;
         commit;
end TRI_MODIFICAR_INVENTARIO_COMPRA;
/

create or replace noneditionable trigger TRI_MODOFICAR_INVENTARIO_VENTA
  after insert
  on pv_detall_fac_venta
  for each row
declare
cantidadProductos number;
pragma autonomous_transaction;
begin
        --Cantidad de productos--
        Select pr.pro_cantidad  into cantidadProductos from pv_productos pr where
        pr.pro_id=:new.det_producto;
        --Editar los productos existentes --
        update pv_productos pr set pr.pro_cantidad=(cantidadProductos-:new.det_unidades)
        where pr.pro_id=:new.det_producto;
        commit; 
commit;
end TRI_MODOFICAR_INVENTARIO_VENTA;
/


create or replace noneditionable trigger TRI_MODIFICAR_NOTA_CLIENTE_COMPRA
  after update
  on pv_detall_fac_compra
  for each row
declare
  montoNotaCredito float;
  pragma autonomous_transaction;
begin
   if :old.det_notas_credito is null then
    Select c.not_monto into montoNotaCredito from pv_notas_cred c where c.not_id=:new.det_notas_credito;
    --Actualizar nuevo monto de la nota de credito
    update pv_notas_cred c  set c.not_monto=(montoNotaCredito+:new.det_cantidad*:new.det_precio_unidad)
        where c.not_id=:new.det_notas_credito;
        commit;
 end if;
end TRI_MODIFICAR_NOTA_CLIENTE_COMPRA;
/

create or replace noneditionable trigger TRI_MODIFICAR_NOTA_CLIENTE_VENTA
  after update
  on pv_detall_fac_venta 
  for each row
declare
  montoNotaCredito float;
  pragma autonomous_transaction;
begin
 --Seleccionar el monto de credito actual--
 if :old.det_nota_credito is null then
    Select c.not_monto into montoNotaCredito from pv_notas_cred c where c.not_id=:new.det_nota_credito;
    --Actualizar nuevo monto de la nota de credito
    update pv_notas_cred c  set c.not_monto=(montoNotaCredito+:new.det_subtotal)
        where c.not_id=:new.det_nota_credito;
   commit;
 end if;
end TRI_MODIFICAR_NOTA_CLIENTE_VENTA;
/

create or replace noneditionable trigger TRI_FACTURAS_COMPRA_UPDATE
  after update
  on pv_facturas_compra
  for each row
declare
  usuario varchar2(30);
  montoProductos number;
  montoAbonos number;
  AUXID number;
  pragma autonomous_transaction;
begin
  Select user into usuario from dual;

  begin
  montoProductos:=0;
  montoAbonos:=0;
    if :new.fac_estado = 'I' then
        begin
        declare cursor cursor is select *from pv_detall_fac_compra dc where dc.det_factura=:new.fac_id;
        fila cursor%rowtype;
        productosInventario number;
        begin
          for fila in cursor
            loop
               select pr.pro_cantidad into productosInventario from pv_productos pr where pr.pro_id=fila.det_producto;
               update pv_productos pr set pr.pro_cantidad=(productosInventario-fila.det_cantidad) where pr.pro_id=fila.det_producto;
               commit;
            end loop;
        end;
        end;

        declare cursor cursor is  select *from pv_detall_fac_compra dc where dc.det_factura=:new.fac_id and dc.det_notas_credito is null;
          filaProdutosFac cursor%rowtype;
          --Filas de productos que asigna a la nueva factura
          begin
          for filaProdutosFac in cursor
          loop
             montoProductos:=montoProductos+(filaProdutosFac.det_cantidad*filaProdutosFac.det_precio_unidad);
          end loop;
          end;


          declare cursor cAbonos is  select *from pv_abonos ab where ab.abo_fac_id=:new.fac_id;
          filaAbonos cAbonos%rowtype;
          --Filas de abonos
          begin
          for filaAbonos in cAbonos
          loop
             montoAbonos:=montoAbonos+(filaAbonos.abo_monto);
          end loop;
          end;

          --insertar nueva factura--
          if :old.fac_estado='P' then --Pendiente

            if  montoAbonos<montoProductos then
               insert into pv_facturas_compra(fac_empresa,fac_provedor,fac_monto_total,fac_tipo,fac_estado)
               values(:old.fac_empresa,:old.fac_provedor,montoProductos,:old.fac_tipo,'P');
               commit;
               insert into pv_cuentas_pagar(cue_proveedor,cue_monto)values (:old.fac_provedor,montoProductos-montoAbonos);
               commit;
             end if;
          if montoAbonos>=montoProductos then
               insert into pv_facturas_compra(fac_empresa,fac_provedor,fac_monto_total,fac_tipo,fac_estado)
               values(:old.fac_empresa,:old.fac_provedor,montoProductos,:old.fac_tipo,'C');
               commit;

               insert into pv_cuentas_pagar(cue_proveedor,cue_monto)values (:old.fac_provedor,0);
               commit;
               -----------Notas de creadito------------------------
                update  pv_notas_cred notas set notas.not_monto=(0) where notas.not_id=1;
                commit;
          end if;

          else --Cancelada--
               insert into pv_facturas_compra(fac_empresa,fac_provedor,fac_monto_total,fac_tipo,fac_estado)
               values(:old.fac_empresa,:old.fac_provedor,montoProductos,:old.fac_tipo,'C');
               commit;
               ------------Nota de credito-------------------------
               update  pv_notas_cred notas set notas.not_monto=(0) where notas.not_id=1;
               commit;
          end if;
          --Asignar producto---
          begin
          select MAX(facMax.Fac_Id) into AUXID from pv_facturas_compra facMax;
           declare cursor cursor is  select *from pv_detall_fac_compra dc where dc.det_factura=:old.fac_id and dc.det_notas_credito is null;
           filaProdutosFac2 cursor%rowtype;
           begin
           for filaProdutosFac2 in cursor
           loop
            insert into PV_DETALL_FAC_COMPRA(DET_PRODUCTO,DET_FACTURA,DET_NOTAS_CREDITO,DET_CANTIDAD,DET_PRECIO_UNIDAD)
            VALUES(filaProdutosFac2.DET_PRODUCTO,AUXID,null,filaProdutosFac2.DET_CANTIDAD,filaProdutosFac2.DET_PRECIO_UNIDAD);
            commit;
          end loop;
          end;
          end;

    end if;
  end;

end TRI_FACTURAS_COMPRA_UPDATE;
/ 

create or replace noneditionable trigger TRI_FACTURAS_VENTAS_UPDATE
  after update
  on pv_facturas_venta
  for each row
declare
  -- local variables here
  usuario varchar2(30);
   AUXID number;
   montoAux float:=0;
   abono float:=0;
   idNotaCredito number;
  pragma autonomous_transaction;
begin

  Select user into usuario from dual;

  begin
    
    if :new.fac_estado = 'I' then
        begin
        declare cursor cursor is  select *from pv_detall_fac_venta dv where dv.det_factura=:new.fac_id;
        fila cursor%rowtype;

        productosDevolucion number;
        begin
          for fila in cursor
            loop
             select pr.pro_cantidad into productosDevolucion from pv_productos pr where pr.pro_id=fila.det_producto;
             update pv_productos pr set pr.pro_cantidad=(productosDevolucion+fila.det_unidades)where pr.pro_id=fila.det_producto;
             commit;
            end loop;
        end;
        end;
        declare cursor cursor is  select *from pv_detall_fac_venta dv where dv.det_factura=:new.fac_id and dv.det_nota_credito is null;
        montoProductos cursor%rowtype;
         begin
         for montoProductos in cursor
          loop
             montoAux:=montoAux+montoProductos.det_subtotal;
          end loop;
          end;

       ---suma--
       select sum(pv.abov_monto) into abono from pv_abonos_ventas pv where pv.abov_fac_id=:old.fac_id;

       --Actualizar nota de creadito--
       select max(nc.not_id) into idNotaCredito  from pv_clientes cl,pv_notas_cred nc
           where cl.cli_id=:old.fac_id and nc.not_cliente=cl.cli_id  ;
        --Crear Factura Nueva

        if :old.fac_estado='C'then
           insert into PV_FACTURAS_VENTA (fac_sede, fac_cliente, fac_fecha, fac_subtotal, fac_total, fac_tipo_pago, fac_estado, fac_codigo)
           values  (:old.fac_sede,:old.fac_sede,sysdate,montoAux, 200,:old.fac_tipo_pago,:old.fac_estado, '1234');
           commit;
            update pv_notas_cred nc set nc.not_monto=nc.not_monto+(abono-montoAux)
            where nc.not_id=idNotaCredito;
            commit;
        else
             if abono>montoAux then --si el abono es mayor que el aux entonces cancelada
             insert into PV_FACTURAS_VENTA (fac_sede, fac_cliente, fac_fecha,
              fac_subtotal, fac_total, fac_tipo_pago, fac_estado, fac_codigo)
              values  (:old.fac_sede,:old.fac_sede,sysdate,montoAux, 200,:old.fac_tipo_pago,'C', '1234');
              commit;
              --nota credito
              update pv_notas_cred nc set nc.not_monto=nc.not_monto+(abono-montoAux) where nc.not_id=idNotaCredito;
              commit;
           end if;
        end if;
        ----Asignar productos a Factura---
        begin
        select MAX(facMax.Fac_Id) into AUXID from pv_facturas_venta facMax;
         declare cursor cursor is  select *from pv_detall_fac_venta dv where dv.det_factura=:new.fac_id and dv.det_nota_credito is null;
        prodFactura cursor%rowtype;
         begin
         for prodFactura in cursor
          loop
            insert into PV_DETALL_FAC_VENTA (det_producto, det_factura, det_precio,det_promocion, det_unidades, det_subtotal, det_descuento, det_nota_credito)values
             (prodFactura.det_producto, AUXID,prodFactura.det_precio,prodFactura.det_promocion,prodFactura.det_unidades,prodFactura.det_subtotal,prodFactura.det_descuento,null);
             commit;
          end loop;
          end;
        end;
    end if;
  end;

end TRI_FACTURAS_VENTAS_UPDATE;
/
