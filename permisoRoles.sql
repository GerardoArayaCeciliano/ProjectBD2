ALTER SESSION SET "_ORACLE_SCRIPT"=TRUE;


----inventario-------
grant select,update ,insert on  pgerardo.pv_productos to rol_inventario;
grant select,update ,insert on  pgerardo.pv_inventarios to rol_inventario;
grant select,update ,insert on  pgerardo.pv_sedes to rol_inventario;
grant select,update ,insert on  pgerardo.pv_productos to rol_inventario;
grant select,update ,insert on  pgerardo.pv_codigos_barras to rol_inventario;
grant select,update ,insert on  pgerardo.pv_precios to rol_inventario;
grant select,update ,insert on  pgerardo.pv_familias to rol_inventario;
grant select,update ,insert on  pgerardo.pv_descuentos to rol_inventario;
grant select,update ,insert on  pgerardo.pv_compania to rol_inventario;


----ROL CAJERO---
grant select,update ,insert on  pgerardo.pv_cuentas_conbrar to rol_cajero;
grant select,update ,insert on  pgerardo.pv_clientes to rol_cajero;
grant select,update ,insert on  pgerardo.pv_acciones to rol_cajero;
grant select,update ,insert on  pgerardo.pv_facturas_venta to rol_cajero;
grant select,update ,insert on  pgerardo.pv_detall_fac_venta to rol_cajero;
grant select,update ,insert on  pgerardo.pv_notas_cred to rol_cajero;
grant select,update ,insert on  pgerardo. to rol_cajero;