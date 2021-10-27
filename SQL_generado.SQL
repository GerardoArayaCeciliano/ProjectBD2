/*
Created: 20/8/2021
Modified: 27/10/2021
Model: Punto_Venta
Database: Oracle 19c
*/


-- Create sequences section -------------------------------------------------

CREATE SEQUENCE Sec_abonos
 INCREMENT BY 1
 START WITH 1
 NOMAXVALUE
 NOMINVALUE
 CACHE 20
;

CREATE SEQUENCE Sec_acciones
 INCREMENT BY 1
 START WITH 1
 NOMAXVALUE
 NOMINVALUE
 CACHE 20
;

CREATE SEQUENCE Sec_clientes
 INCREMENT BY 1
 START WITH 1
 NOMAXVALUE
 NOMINVALUE
 CACHE 20
;

CREATE SEQUENCE Sec_codigo_barras
 INCREMENT BY 1
 START WITH 1
 NOMAXVALUE
 NOMINVALUE
 CACHE 20
;

CREATE SEQUENCE Sec_compania
 INCREMENT BY 1
 START WITH 1
 NOMAXVALUE
 NOMINVALUE
 CACHE 20
;

CREATE SEQUENCE Sec_descuentos
 INCREMENT BY 1
 START WITH 1
 NOMAXVALUE
 NOMINVALUE
 CACHE 20
;

CREATE SEQUENCE Sec_familias
 INCREMENT BY 1
 START WITH 1
 NOMAXVALUE
 NOMINVALUE
 CACHE 20
;

CREATE SEQUENCE Sec_inventarios
 INCREMENT BY 1
 START WITH 1
 NOMAXVALUE
 NOMINVALUE
 CACHE 20
;

CREATE SEQUENCE Sec_facturas_venta
 INCREMENT BY 1
 START WITH 1
 NOMAXVALUE
 NOMINVALUE
 CACHE 20
;

CREATE SEQUENCE Sec_productos
 INCREMENT BY 1
 START WITH 1
 NOMAXVALUE
 NOMINVALUE
 CACHE 20
;

CREATE SEQUENCE Sec_promociones
 INCREMENT BY 1
 START WITH 1
 NOMAXVALUE
 NOMINVALUE
 CACHE 20
;

CREATE SEQUENCE Sec_proveedores
 INCREMENT BY 1
 START WITH 1
 NOMAXVALUE
 NOMINVALUE
 CACHE 20
;

CREATE SEQUENCE Sec_sedes
 INCREMENT BY 1
 START WITH 1
 NOMAXVALUE
 NOMINVALUE
 CACHE 20
;

CREATE SEQUENCE Sec_tipo_promocion
 INCREMENT BY 1
 START WITH 1
 NOMAXVALUE
 NOMINVALUE
 CACHE 20
;

CREATE SEQUENCE Sec_facturas_compra
 INCREMENT BY 1
 START WITH 1
 NOMAXVALUE
 NOMINVALUE
 CACHE 20
;

CREATE SEQUENCE Sec_notas_credito
 INCREMENT BY 1
 START WITH 1
 NOMAXVALUE
 NOMINVALUE
 CACHE 20
;

CREATE SEQUENCE Sec_tipo_pago
 INCREMENT BY 1
 START WITH 1
 NOMAXVALUE
 NOMINVALUE
 CACHE 20
;

CREATE SEQUENCE Sec_movimiento
 INCREMENT BY 1
 START WITH 1
 NOMAXVALUE
 NOMINVALUE
 CACHE 20
;

CREATE SEQUENCE Sec_precio
 INCREMENT BY 1
 START WITH 1
 NOMAXVALUE
 NOMINVALUE
 CACHE 20
;

CREATE SEQUENCE Sec_cuentas_cobrar
 INCREMENT BY 1
 START WITH 1
 NOMAXVALUE
 NOMINVALUE
 CACHE 20
;

CREATE SEQUENCE Sec_cuentas_pagar
 INCREMENT BY 1
 START WITH 1
 NOMAXVALUE
 NOMINVALUE
 CACHE 20
;

CREATE SEQUENCE Sec_abonos_venta
 INCREMENT BY 1
 START WITH 1
 NOMAXVALUE
 NOMINVALUE
 CACHE 20
;

CREATE SEQUENCE Sec_contactos_notificacion
 INCREMENT BY 1
 START WITH 1
 NOMAXVALUE
 NOMINVALUE
 CACHE 20
;

CREATE SEQUENCE Sec_padron
 INCREMENT BY 1
 START WITH 1
 NOMAXVALUE
 NOMINVALUE
 CACHE 20
;

CREATE SEQUENCE Sec_biticora
 INCREMENT BY 1
 START WITH 1
 NOMAXVALUE
 NOMINVALUE
 CACHE 20
;

CREATE SEQUENCE Sec_parametros
 INCREMENT BY 1
 START WITH 1
 NOMAXVALUE
 NOMINVALUE
 CACHE 20
;

-- Create tables section -------------------------------------------------

-- Table PV_COMPANIA

CREATE TABLE PV_COMPANIA(
  emp_id Number NOT NULL,
  emp_inventario Number NOT NULL,
  emp_nombre Varchar2(64 ) NOT NULL,
  emp_tipo Varchar2(3 ) NOT NULL,
  CONSTRAINT compania_ck_tipo CHECK (emp_tipo in ('SUP','SUM','FER'))
)
;

-- Add keys for table PV_COMPANIA

ALTER TABLE PV_COMPANIA ADD CONSTRAINT pk_compania PRIMARY KEY (emp_id)
;

-- Table and Columns comments section

COMMENT ON TABLE PV_COMPANIA IS 'Guarda los datos de la comania para la que se ejecuta esta base de datos'
;
COMMENT ON COLUMN PV_COMPANIA.emp_tipo IS 'Tipos admitidos(fer) Ferreteria, (sup) Super mercado, (sum) Suministro'
;

-- Table PV_SEDES

CREATE TABLE PV_SEDES(
  sed_id Number NOT NULL,
  sed_nombre Varchar2(64 ) NOT NULL,
  sed_direccion Varchar2(255 ) NOT NULL,
  sede_estado Char(1 ) NOT NULL,
  CONSTRAINT sedes_ck_estado CHECK (sede_estado in ('A','I'))
)
;

-- Add keys for table PV_SEDES

ALTER TABLE PV_SEDES ADD CONSTRAINT pk_sedes PRIMARY KEY (sed_id)
;

ALTER TABLE PV_SEDES ADD CONSTRAINT sed_nombre UNIQUE (sed_nombre)
;

-- Table and Columns comments section

COMMENT ON TABLE PV_SEDES IS 'Sedes de la empresa principal
'
;
COMMENT ON COLUMN PV_SEDES.sede_estado IS 'Inactivo(I), Activo(A)'
;

-- Table PV_INVENTARIOS

CREATE TABLE PV_INVENTARIOS(
  inv_id Number NOT NULL,
  inv_sede Number,
  inv_tipo Varchar2(3 ) NOT NULL,
  inv_oberservacion Varchar2(500 ) NOT NULL,
  inv_estado Char(1 ) NOT NULL,
  CONSTRAINT invenario_ck_tipo CHECK (inv_tipo in ('CEN','BOD','GON')),
  CONSTRAINT inventario_ck_estado CHECK (inv_estado in ('A','I'))
)
;

-- Create indexes for table PV_INVENTARIOS

CREATE INDEX inventario_idx_sede ON PV_INVENTARIOS (inv_sede)
;

-- Add keys for table PV_INVENTARIOS

ALTER TABLE PV_INVENTARIOS ADD CONSTRAINT pk_inventarios PRIMARY KEY (inv_id)
;

-- Table and Columns comments section

COMMENT ON COLUMN PV_INVENTARIOS.inv_sede IS 'Sede a la que pertenece. (En caso de pertenecer a una)'
;
COMMENT ON COLUMN PV_INVENTARIOS.inv_tipo IS 'Central(CEN), Bodega(BOD), Gondaola(GON)'
;
COMMENT ON COLUMN PV_INVENTARIOS.inv_estado IS 'Activo(A), Inactivo(I)'
;

-- Table PV_PRODUCTOS

CREATE TABLE PV_PRODUCTOS(
  pro_id Number NOT NULL,
  pro_inventario Number NOT NULL,
  pro_provedor Number NOT NULL,
  pro_familia Number NOT NULL,
  pro_nombre Varchar2(64 ) NOT NULL,
  pro_cantidad Number NOT NULL,
  pro_descuento_maximo Float NOT NULL,
  pro_vencimiento Date,
  pro_ingreso Date NOT NULL,
  pro_estado Char(1 ) NOT NULL,
  CONSTRAINT productos_ck_estado CHECK (pro_estado in ('A','I'))
)
;

-- Create indexes for table PV_PRODUCTOS

CREATE INDEX producto_idx_inventario ON PV_PRODUCTOS (pro_inventario)
;

CREATE INDEX producto_idx_proveedor ON PV_PRODUCTOS (pro_provedor)
;

CREATE INDEX producto_idx_familia ON PV_PRODUCTOS (pro_familia)
;

CREATE INDEX producto_idx_nombre ON PV_PRODUCTOS (pro_nombre)
;

-- Add keys for table PV_PRODUCTOS

ALTER TABLE PV_PRODUCTOS ADD CONSTRAINT pk_productos PRIMARY KEY (pro_id)
;

-- Table and Columns comments section

COMMENT ON TABLE PV_PRODUCTOS IS 'Productos registrados dentro de los inventarios'
;
COMMENT ON COLUMN PV_PRODUCTOS.pro_inventario IS 'Inventario al que pertenece'
;
COMMENT ON COLUMN PV_PRODUCTOS.pro_estado IS 'Inactivo(I), Activo(A)'
;

-- Table PV_PROVEEDORES

CREATE TABLE PV_PROVEEDORES(
  pro_id Number NOT NULL,
  pro_nombre Varchar2(64 ) NOT NULL,
  pro_telefono Char(24 ) NOT NULL,
  pro_correo Varchar2(64 )
)
;

-- Create indexes for table PV_PROVEEDORES

CREATE UNIQUE INDEX proveedores_idx_nombre ON PV_PROVEEDORES (pro_nombre)
;

-- Add keys for table PV_PROVEEDORES

ALTER TABLE PV_PROVEEDORES ADD CONSTRAINT pk_proveedores PRIMARY KEY (pro_id)
;

ALTER TABLE PV_PROVEEDORES ADD CONSTRAINT unique_nombre_proveedores UNIQUE (pro_nombre)
;

-- Table and Columns comments section

COMMENT ON TABLE PV_PROVEEDORES IS 'Proveedores de la empresa'
;

-- Table PV_FAMILIAS

CREATE TABLE PV_FAMILIAS(
  fam_id Number NOT NULL,
  fam_nombre Varchar2(64 ) NOT NULL,
  fam_descripcion Varchar2(500 ),
  fam_estado Char(1 ) NOT NULL,
  CONSTRAINT familias_ck_estado CHECK (fam_estado in ('A','I'))
)
;

-- Create indexes for table PV_FAMILIAS

CREATE INDEX familias_idx_nombre ON PV_FAMILIAS (fam_nombre)
;

-- Add keys for table PV_FAMILIAS

ALTER TABLE PV_FAMILIAS ADD CONSTRAINT pk_familias PRIMARY KEY (fam_id)
;

ALTER TABLE PV_FAMILIAS ADD CONSTRAINT unique_nombre_familias UNIQUE (fam_nombre)
;

-- Table and Columns comments section

COMMENT ON TABLE PV_FAMILIAS IS 'Familias de productos dentro del sistema'
;
COMMENT ON COLUMN PV_FAMILIAS.fam_estado IS 'Estados Inactivo(I) Activo(A)'
;

-- Table PV_CODIGOS_BARRAS

CREATE TABLE PV_CODIGOS_BARRAS(
  cod_id Number NOT NULL,
  cod_producto Number NOT NULL,
  cod_codigo Varchar2(128 ) NOT NULL,
  cod_activo Char(1 ) NOT NULL,
  CONSTRAINT codigos_barras_ck_estado CHECK (cod_activo in ('A','I'))
)
;

-- Create indexes for table PV_CODIGOS_BARRAS

CREATE INDEX codigo_barras_idx_producto ON PV_CODIGOS_BARRAS (cod_producto)
;

CREATE INDEX codigo_barras_idx_codigo ON PV_CODIGOS_BARRAS (cod_codigo)
;

CREATE INDEX codigo_barras_idx_estado ON PV_CODIGOS_BARRAS (cod_activo)
;

-- Add keys for table PV_CODIGOS_BARRAS

ALTER TABLE PV_CODIGOS_BARRAS ADD CONSTRAINT pk_codigos_barras PRIMARY KEY (cod_id)
;

-- Table and Columns comments section

COMMENT ON TABLE PV_CODIGOS_BARRAS IS 'Codigos de barras de los productos'
;
COMMENT ON COLUMN PV_CODIGOS_BARRAS.cod_activo IS 'Inactivo(I), Activo(A)'
;

-- Table PV_FACTURAS_COMPRA

CREATE TABLE PV_FACTURAS_COMPRA(
  fac_id Number NOT NULL,
  fac_empresa Number NOT NULL,
  fac_provedor Number NOT NULL,
  fac_monto_total Float NOT NULL,
  fac_tipo Varchar2(3 ) NOT NULL,
  fac_estado Char(1 ) NOT NULL,
  CONSTRAINT facturas_ck_tipo CHECK (fac_tipo in ('CON','PLA')),
  CONSTRAINT fac_ck_estado CHECK (fac_estado in ('P','I', 'C'))
)
;

-- Create indexes for table PV_FACTURAS_COMPRA

CREATE INDEX factura_compra_idx_empresa ON PV_FACTURAS_COMPRA (fac_empresa)
;

CREATE INDEX factura_compra_idx_proveedor ON PV_FACTURAS_COMPRA (fac_provedor)
;

-- Add keys for table PV_FACTURAS_COMPRA

ALTER TABLE PV_FACTURAS_COMPRA ADD CONSTRAINT pk_facturas_compra PRIMARY KEY (fac_id)
;

-- Table and Columns comments section

COMMENT ON TABLE PV_FACTURAS_COMPRA IS 'Facturas de compra por parte de la empresa'
;
COMMENT ON COLUMN PV_FACTURAS_COMPRA.fac_tipo IS 'A plazo o a contado.(CON, PLA)'
;
COMMENT ON COLUMN PV_FACTURAS_COMPRA.fac_estado IS 'Si esta cancelada, pediente o fue inactivada debido a devolución(P, I, C)'
;

-- Table PV_DETALL_FAC_COMPRA

CREATE TABLE PV_DETALL_FAC_COMPRA(
  det_producto Number NOT NULL,
  det_factura Number NOT NULL,
  det_cantidad Float NOT NULL,
  det_precio_unidad Float NOT NULL
)
;

-- Create indexes for table PV_DETALL_FAC_COMPRA

CREATE INDEX detall_fac_compra ON PV_DETALL_FAC_COMPRA (det_factura)
;

-- Add keys for table PV_DETALL_FAC_COMPRA

ALTER TABLE PV_DETALL_FAC_COMPRA ADD CONSTRAINT pk_detall_fac_compra PRIMARY KEY (det_producto,det_factura)
;

-- Table and Columns comments section

COMMENT ON TABLE PV_DETALL_FAC_COMPRA IS 'Detalles de facturas de compra de la empresa'
;

-- Table PV_ABONOS

CREATE TABLE PV_ABONOS(
  abo_id Number NOT NULL,
  abo_fac_id Number NOT NULL,
  abo_monto Float NOT NULL,
  abo_fecha_abono Date NOT NULL,
  CONSTRAINT abonos_ck_monto CHECK (abo_monto > 0)
)
;

-- Create indexes for table PV_ABONOS

CREATE INDEX IX_Relationship6 ON PV_ABONOS (abo_fac_id)
;

-- Add keys for table PV_ABONOS

ALTER TABLE PV_ABONOS ADD CONSTRAINT pk_abonos PRIMARY KEY (abo_id)
;

-- Table and Columns comments section

COMMENT ON TABLE PV_ABONOS IS 'Abonos registrados en las facturas canceladas a tractos.'
;

-- Table PV_LIMITE_CREDITO

CREATE TABLE PV_LIMITE_CREDITO(
  lim_empresa Number NOT NULL,
  lim_proveedor Number NOT NULL,
  lim_limite_max Float NOT NULL,
  CONSTRAINT limite_credito_ck_limite CHECK (lim_limite_max >= 0)
)
;

-- Add keys for table PV_LIMITE_CREDITO

ALTER TABLE PV_LIMITE_CREDITO ADD CONSTRAINT pk_limite_credito PRIMARY KEY (lim_empresa,lim_proveedor)
;

-- Table and Columns comments section

COMMENT ON TABLE PV_LIMITE_CREDITO IS 'Guarda los limites de credito de la empresa con los diversos proveedores'
;

-- Table PV_CLIENTES

CREATE TABLE PV_CLIENTES(
  cli_id Number NOT NULL,
  cli_folio Varchar2(32 ) NOT NULL,
  cli_identificacion Varchar2(64 ) NOT NULL,
  cli_tipo Varchar2(3 ) NOT NULL,
  cli_nombre Varchar2(64 ) NOT NULL,
  cli_p_apellido Varchar2(62 ),
  cli_s_apellido Varchar2(32 ),
  cli_fax Varchar2(24 ),
  cli_telefono Varchar2(24 ),
  cli_email Varchar2(64 ),
  cli_sexo Char(1 ),
  cli_estado_civ Varchar2(20 ),
  cli_preferencial Char(1 ) NOT NULL,
  cli_direccion Varchar2(255 ) NOT NULL,
  cli_recidencia Varchar2(24 ),
  cli_nacionalidad Varchar2(24 ) NOT NULL,
  cli_fec_registro Date NOT NULL,
  cli_cred_max Float NOT NULL,
  cli_nacimiento Date NOT NULL,
  cli_escolaridad Varchar2(24 ),
  cli_puesto Varchar2(24 ),
  cli_empresa_labora Varchar2(64 ),
  cli_asegurado Char(1 ),
  cli_estado Char(1 ) NOT NULL,
  CONSTRAINT clientes_ck_tipo CHECK (cli_tipo in ('NAC','EXT','JUR')),
  CONSTRAINT clientes_ck_estado CHECK (cli_estado in ('I','A')),
  CONSTRAINT clientes_ck_sexo CHECK (cli_sexo in ('F','M')),
  CONSTRAINT clientes_ck_estado_civ CHECK (cli_estado_civ in ('SOLTERO', 'CASADO', 'UNION_LIBRE','SEPARADO', 'VIUDO')),
  CONSTRAINT clientes_ck_credito_max CHECK (cli_cred_max >= 0),
  CONSTRAINT clientes_ck_asegurado CHECK (cli_asegurado in ('S','N')),
  CONSTRAINT clientes_ck_escolaridad CHECK (cli_escolaridad in ('primaria','secundaria','tecnico','superior','ninguna')),
  CONSTRAINT clientes_ck_preferencial CHECK (cli_preferencial in ('S','N'))
)
;

-- Create indexes for table PV_CLIENTES

CREATE INDEX clientes_idx_folio ON PV_CLIENTES (cli_folio)
;

CREATE INDEX clientes_idx_identificacion ON PV_CLIENTES (cli_identificacion)
;

CREATE INDEX clientes_idx_nacionalidad ON PV_CLIENTES (cli_nacionalidad)
;

CREATE INDEX clientes_idx_estado ON PV_CLIENTES (cli_estado)
;

CREATE INDEX clientes_idx_sexo ON PV_CLIENTES (cli_sexo)
;

CREATE INDEX clientes_idx_estado_civ ON PV_CLIENTES (cli_estado_civ)
;

-- Add keys for table PV_CLIENTES

ALTER TABLE PV_CLIENTES ADD CONSTRAINT pk_clientes PRIMARY KEY (cli_id)
;

ALTER TABLE PV_CLIENTES ADD CONSTRAINT unique_folio_clientes UNIQUE (cli_folio)
;

ALTER TABLE PV_CLIENTES ADD CONSTRAINT unique_identificacion_clientes UNIQUE (cli_identificacion)
;

-- Table and Columns comments section

COMMENT ON TABLE PV_CLIENTES IS 'Clientes fisicos o juridicos de la empresa'
;
COMMENT ON COLUMN PV_CLIENTES.cli_folio IS 'Folio de usuario'
;
COMMENT ON COLUMN PV_CLIENTES.cli_identificacion IS 'Numero de identificacion'
;
COMMENT ON COLUMN PV_CLIENTES.cli_tipo IS 'Persona nacional, extranjera o juridica (NAC, EXT, JUR, )'
;
COMMENT ON COLUMN PV_CLIENTES.cli_p_apellido IS 'Primer apellido'
;
COMMENT ON COLUMN PV_CLIENTES.cli_s_apellido IS 'Segundo apellido'
;
COMMENT ON COLUMN PV_CLIENTES.cli_fax IS 'Numero de fax'
;
COMMENT ON COLUMN PV_CLIENTES.cli_sexo IS 'Femenino(F), Masculino(M)'
;
COMMENT ON COLUMN PV_CLIENTES.cli_estado_civ IS 'SOLTERO, CASADO, UNION_LIBRE, SEPARADO, VIUDO'
;
COMMENT ON COLUMN PV_CLIENTES.cli_preferencial IS 'SI o NO (S, N)'
;
COMMENT ON COLUMN PV_CLIENTES.cli_fec_registro IS 'Fecha de registro dentro del sistema'
;
COMMENT ON COLUMN PV_CLIENTES.cli_cred_max IS 'Maximo de credito'
;
COMMENT ON COLUMN PV_CLIENTES.cli_escolaridad IS 'primaria, secundaria, tecnico, superior, ninguna'
;
COMMENT ON COLUMN PV_CLIENTES.cli_asegurado IS 'SI o NO (S, N)'
;
COMMENT ON COLUMN PV_CLIENTES.cli_estado IS 'Activo(A), Inactivo(I)'
;

-- Table PV_FACTURAS_VENTA

CREATE TABLE PV_FACTURAS_VENTA(
  fac_id Number NOT NULL,
  fac_sede Number NOT NULL,
  fac_cliente Number NOT NULL,
  fac_fecha Date NOT NULL,
  fac_subtotal Float NOT NULL,
  fac_total Float NOT NULL,
  fac_tipo_pago Varchar2(10 ) NOT NULL,
  fac_estado Char(3 ) NOT NULL,
  fac_codigo Varchar2(30 ) NOT NULL,
  CONSTRAINT facturas_ck_estado CHECK (fac_estado in ('C','P','I')),
  CONSTRAINT facturas_ck_tipo_pago CHECK (fac_tipo_pago in ('EFECTIVO','SINPE','TARJETA'))
)
;

-- Create indexes for table PV_FACTURAS_VENTA

CREATE INDEX factura_venta_idx_sede ON PV_FACTURAS_VENTA (fac_sede)
;

CREATE INDEX factura_venta_idx_cliente ON PV_FACTURAS_VENTA (fac_cliente)
;

CREATE INDEX factura_venta_idx_fecha ON PV_FACTURAS_VENTA (fac_fecha)
;

CREATE INDEX facturas_venta_idx_monto ON PV_FACTURAS_VENTA (fac_total)
;

CREATE INDEX facturas_venta_idx_estado ON PV_FACTURAS_VENTA (fac_estado)
;

-- Add keys for table PV_FACTURAS_VENTA

ALTER TABLE PV_FACTURAS_VENTA ADD CONSTRAINT pk_facturas_venta PRIMARY KEY (fac_id)
;

-- Table and Columns comments section

COMMENT ON TABLE PV_FACTURAS_VENTA IS 'Facturas de venta a clientes'
;
COMMENT ON COLUMN PV_FACTURAS_VENTA.fac_id IS 'id de factura'
;
COMMENT ON COLUMN PV_FACTURAS_VENTA.fac_estado IS 'cancelada, pendiente, inactiva (en caso dedevolucion)
(C,P, I)'
;
COMMENT ON COLUMN PV_FACTURAS_VENTA.fac_codigo IS 'año+id 
id=secuencia
'
;

-- Table PV_DETALL_FAC_VENTA

CREATE TABLE PV_DETALL_FAC_VENTA(
  det_producto Number NOT NULL,
  det_factura Number NOT NULL,
  det_precio Number NOT NULL,
  det_promocion Number,
  det_unidades Number NOT NULL,
  det_subtotal Float NOT NULL,
  det_descuento Float NOT NULL
)
;

-- Create indexes for table PV_DETALL_FAC_VENTA

CREATE INDEX detall_fac_venta ON PV_DETALL_FAC_VENTA (det_factura)
;

CREATE INDEX IX_Relationship11 ON PV_DETALL_FAC_VENTA (det_promocion)
;

-- Add keys for table PV_DETALL_FAC_VENTA

ALTER TABLE PV_DETALL_FAC_VENTA ADD CONSTRAINT pk_detall_fac_venta PRIMARY KEY (det_producto,det_factura,det_precio)
;

-- Table and Columns comments section

COMMENT ON TABLE PV_DETALL_FAC_VENTA IS 'Detalles de facturas de venta'
;

-- Table PV_ACCIONES

CREATE TABLE PV_ACCIONES(
  acc_codigo Number NOT NULL,
  acc_cliente Number NOT NULL,
  acc_promocion Number,
  acc_vencimiento Date NOT NULL,
  acc_estado Varchar2(30 ) NOT NULL,
  CONSTRAINT acciones_ck_estado CHECK (acc_estado in ('A','I'))
)
;

-- Create indexes for table PV_ACCIONES

CREATE INDEX acciones_idx_cliente ON PV_ACCIONES (acc_cliente)
;

CREATE INDEX acciones_idx_promocion ON PV_ACCIONES (acc_promocion)
;

CREATE INDEX acciones_vencimiento_vencimiento ON PV_ACCIONES (acc_vencimiento)
;

CREATE INDEX acciones_vencimiento_estado ON PV_ACCIONES (acc_estado)
;

-- Add keys for table PV_ACCIONES

ALTER TABLE PV_ACCIONES ADD CONSTRAINT pk_acciones PRIMARY KEY (acc_codigo)
;

-- Table and Columns comments section

COMMENT ON TABLE PV_ACCIONES IS 'Acciones de los clientes ganadas por concepto de promociones'
;
COMMENT ON COLUMN PV_ACCIONES.acc_cliente IS 'Cliente a la que pertenece'
;
COMMENT ON COLUMN PV_ACCIONES.acc_promocion IS 'Promocion en la que fue adquirida'
;
COMMENT ON COLUMN PV_ACCIONES.acc_estado IS 'Activo(A), Inactivo(I)'
;

-- Table PV_NOTAS_CRED

CREATE TABLE PV_NOTAS_CRED(
  not_id Number NOT NULL,
  not_monto Float NOT NULL,
  not_estado Char(1 ) NOT NULL,
  not_fecha_emision Date NOT NULL,
  CONSTRAINT notas_cred_ck_monto CHECK (not_monto > 0),
  CONSTRAINT notas_cred_ck_estado CHECK (not_estado in ('I','A'))
)
;

-- Add keys for table PV_NOTAS_CRED

ALTER TABLE PV_NOTAS_CRED ADD CONSTRAINT pk_notas_cred PRIMARY KEY (not_id)
;

-- Table and Columns comments section

COMMENT ON TABLE PV_NOTAS_CRED IS 'Notas crediticias para clientes y empresa'
;
COMMENT ON COLUMN PV_NOTAS_CRED.not_estado IS 'I, A'
;

-- Table PV_CLIEN_NOTA_CRD

CREATE TABLE PV_CLIEN_NOTA_CRD(
  cli_cliente Number NOT NULL,
  cli_nota_crd Number NOT NULL
)
;

-- Create indexes for table PV_CLIEN_NOTA_CRD

CREATE INDEX client_nota_crd_cliente ON PV_CLIEN_NOTA_CRD (cli_cliente)
;

-- Add keys for table PV_CLIEN_NOTA_CRD

ALTER TABLE PV_CLIEN_NOTA_CRD ADD CONSTRAINT pk_client_nota_cred PRIMARY KEY (cli_cliente,cli_nota_crd)
;

-- Table and Columns comments section

COMMENT ON TABLE PV_CLIEN_NOTA_CRD IS 'Notas crediticias asoacidas a los clientes'
;

-- Table PV_EMPR_NOTA_CRD

CREATE TABLE PV_EMPR_NOTA_CRD(
  emp_empresa Number NOT NULL,
  emp_nota_crd Number NOT NULL
)
;

-- Add keys for table PV_EMPR_NOTA_CRD

ALTER TABLE PV_EMPR_NOTA_CRD ADD CONSTRAINT pk_empr_nota_crd PRIMARY KEY (emp_empresa,emp_nota_crd)
;

-- Table PV_PROMOCIONES

CREATE TABLE PV_PROMOCIONES(
  pro_id Number NOT NULL,
  pro_tipo Number NOT NULL,
  pro_nombre Varchar2(64 ) NOT NULL,
  pro_descripcion Varchar2(512 ) NOT NULL,
  pro_validez_hasta Date NOT NULL,
  pro_estado Char(1 ) NOT NULL,
  CONSTRAINT promociones_ck_estado CHECK (pro_estado in ('A','I'))
)
;

-- Create indexes for table PV_PROMOCIONES

CREATE INDEX promociones_idx_producto ON PV_PROMOCIONES (pro_tipo)
;

CREATE INDEX promociones_idx_estado ON PV_PROMOCIONES (pro_estado)
;

-- Add keys for table PV_PROMOCIONES

ALTER TABLE PV_PROMOCIONES ADD CONSTRAINT pk_promociones PRIMARY KEY (pro_id)
;

-- Table and Columns comments section

COMMENT ON COLUMN PV_PROMOCIONES.pro_validez_hasta IS 'Fecha maxima de validez'
;
COMMENT ON COLUMN PV_PROMOCIONES.pro_estado IS 'A, I'
;

-- Table PV_PROD_PROMO

CREATE TABLE PV_PROD_PROMO(
  pro_producto Number NOT NULL,
  pro_promocion Number NOT NULL,
  pro_prod_accion Integer
)
;

-- Add keys for table PV_PROD_PROMO

ALTER TABLE PV_PROD_PROMO ADD CONSTRAINT pk_prod_promo PRIMARY KEY (pro_producto,pro_promocion)
;

-- Table and Columns comments section

COMMENT ON TABLE PV_PROD_PROMO IS 'Promociones aplicadas a productos'
;
COMMENT ON COLUMN PV_PROD_PROMO.pro_prod_accion IS 'Numero de productos para ganar una accion'
;

-- Table PV_DESCUENTOS

CREATE TABLE PV_DESCUENTOS(
  dec_id Number NOT NULL,
  dec_familia Number,
  dec_proveedor Number,
  dec_tipo Char(3 ) NOT NULL,
  dec_porc_desc Float NOT NULL,
  dec_estado Char(1 ) NOT NULL,
  dec_fec_validez Date NOT NULL,
  CONSTRAINT descuentos_ck_tipo CHECK (dec_tipo in ('FAM','PRO','LIQ')),
  CONSTRAINT descuentos_ck_estado CHECK (dec_estado in ('A','I')),
  CONSTRAINT descuentos_porc_desc CHECK (dec_porc_desc > 0)
)
;

-- Create indexes for table PV_DESCUENTOS

CREATE INDEX descuento_idx_familia ON PV_DESCUENTOS (dec_familia)
;

CREATE INDEX descuento_idx_proveedor ON PV_DESCUENTOS (dec_proveedor)
;

CREATE INDEX descuentos_idx_tipo ON PV_DESCUENTOS (dec_tipo)
;

-- Add keys for table PV_DESCUENTOS

ALTER TABLE PV_DESCUENTOS ADD CONSTRAINT pk_descuentos PRIMARY KEY (dec_id)
;

-- Table and Columns comments section

COMMENT ON TABLE PV_DESCUENTOS IS 'Guarda los descuentos que se aplican o aplicaron en la las sedes, que pueden ser por provedor, familia o aplicable a productos varios'
;
COMMENT ON COLUMN PV_DESCUENTOS.dec_tipo IS 'Por familia, proveedor, liquidacion (PRO, FAM, LIQ)'
;
COMMENT ON COLUMN PV_DESCUENTOS.dec_porc_desc IS 'Porcentaje de decuento'
;
COMMENT ON COLUMN PV_DESCUENTOS.dec_estado IS 'A, I'
;
COMMENT ON COLUMN PV_DESCUENTOS.dec_fec_validez IS 'Fecha maxima de validez'
;

-- Table PV_DESC_LIQUIDACION

CREATE TABLE PV_DESC_LIQUIDACION(
  des_producto Number NOT NULL,
  des_descuento Number NOT NULL,
  des_ingreso Date,
  des_vencimiento Date,
  des_estado Char(1 ) NOT NULL,
  CONSTRAINT desc_liquidacion_ck_estado CHECK (des_estado in ('A','I'))
)
;

-- Create indexes for table PV_DESC_LIQUIDACION

CREATE INDEX des_liquidacion_idx_vencimiento ON PV_DESC_LIQUIDACION (des_vencimiento)
;

CREATE INDEX desc_liquidacion_estado ON PV_DESC_LIQUIDACION (des_estado)
;

-- Add keys for table PV_DESC_LIQUIDACION

ALTER TABLE PV_DESC_LIQUIDACION ADD CONSTRAINT pk_desc_liquidacion PRIMARY KEY (des_producto,des_descuento)
;

-- Table and Columns comments section

COMMENT ON TABLE PV_DESC_LIQUIDACION IS 'Se relaciona a un descuento aplicable a productos varios. Los registros en esta tabla se aplican a productos para indicar que tiene un descuento por tema de liquidacion que puede aplicar ya sea por fecgha de ingreso o por fecha de vencimiento cercana'
;
COMMENT ON COLUMN PV_DESC_LIQUIDACION.des_ingreso IS 'Descuento por fecha de ingreso'
;
COMMENT ON COLUMN PV_DESC_LIQUIDACION.des_vencimiento IS 'Descuento por fecha de vencimiento'
;
COMMENT ON COLUMN PV_DESC_LIQUIDACION.des_estado IS 'A, I'
;

-- Table PV_PRECIOS

CREATE TABLE PV_PRECIOS(
  pre_id Number NOT NULL,
  pre_producto Number NOT NULL,
  pre_precio_costo Float NOT NULL,
  pre_impuesto Float NOT NULL,
  pre_utilidad Float NOT NULL,
  pre_fecha Date NOT NULL,
  pre_estado Varchar2(3 ) NOT NULL,
  CONSTRAINT precios_ck_impuestos CHECK (pre_impuesto >= 0),
  CONSTRAINT precios_ck_estado CHECK (pre_estado in ('ACT','ANT'))
)
;

-- Create indexes for table PV_PRECIOS

CREATE INDEX precio_idx_id ON PV_PRECIOS (pre_producto)
;

CREATE INDEX precio_idx_fecha ON PV_PRECIOS (pre_fecha)
;

CREATE INDEX estado_idx_estado ON PV_PRECIOS (pre_estado)
;

-- Add keys for table PV_PRECIOS

ALTER TABLE PV_PRECIOS ADD CONSTRAINT pk_precios PRIMARY KEY (pre_id)
;

-- Table and Columns comments section

COMMENT ON TABLE PV_PRECIOS IS 'Precios aplicados a productos'
;
COMMENT ON COLUMN PV_PRECIOS.pre_fecha IS 'Fecha en que empezó a regir'
;
COMMENT ON COLUMN PV_PRECIOS.pre_estado IS 'Actual(ACT), Anterior(ANT)'
;

-- Table PV_TIPO_PROMOCION

CREATE TABLE PV_TIPO_PROMOCION(
  tip_id Number NOT NULL,
  tip_nombre Varchar2(32 ) NOT NULL,
  tip_descripcion Char(512 ) NOT NULL
)
;

-- Add keys for table PV_TIPO_PROMOCION

ALTER TABLE PV_TIPO_PROMOCION ADD CONSTRAINT pk_tipo_promocion PRIMARY KEY (tip_id)
;

-- Table PV_MOVIMIENTOS

CREATE TABLE PV_MOVIMIENTOS(
  mov_id Number NOT NULL,
  mov_producto Number NOT NULL,
  mov_tipo Char(1 ) NOT NULL
        CONSTRAINT movimientos_ck_tipo CHECK (mov_tipo in ('E','S')),
  mov_fecha Date NOT NULL,
  mov_descripcion Varchar2(128 ) NOT NULL,
  mov_cantidad Number NOT NULL,
  CONSTRAINT movimientos_ck_tipo01 CHECK (mov_tipo in ('E','S'))
)
;

-- Create indexes for table PV_MOVIMIENTOS

CREATE INDEX movimientos_producto ON PV_MOVIMIENTOS (mov_producto)
;

-- Add keys for table PV_MOVIMIENTOS

ALTER TABLE PV_MOVIMIENTOS ADD CONSTRAINT PK_PV_MOVIMIENTOS PRIMARY KEY (mov_id)
;

-- Table and Columns comments section

COMMENT ON COLUMN PV_MOVIMIENTOS.mov_tipo IS 'tipo de movimiento Entrada(E)/Salidad(S)'
;
COMMENT ON COLUMN PV_MOVIMIENTOS.mov_fecha IS 'Fecha de movimiento'
;
COMMENT ON COLUMN PV_MOVIMIENTOS.mov_descripcion IS 'Descripcion de movimiento'
;
COMMENT ON COLUMN PV_MOVIMIENTOS.mov_cantidad IS 'Numero de items movidos'
;

-- Table PV_Tipos_Pago

CREATE TABLE PV_Tipos_Pago(
  tip_id Number NOT NULL,
  tip_nombre Varchar2(30 ) NOT NULL,
  tip_descripcion Varchar2(128 )
)
;

-- Add keys for table PV_Tipos_Pago

ALTER TABLE PV_Tipos_Pago ADD CONSTRAINT PK_PV_Tipos_Pago PRIMARY KEY (tip_id)
;

ALTER TABLE PV_Tipos_Pago ADD CONSTRAINT tp_nombre UNIQUE (tip_nombre)
;

-- Table and Columns comments section

COMMENT ON COLUMN PV_Tipos_Pago.tip_nombre IS 'Nombre del tipo de pago'
;

-- Table PV_PAGO_FACTURA

CREATE TABLE PV_PAGO_FACTURA(
  pag_factura Number NOT NULL,
  pag_tipo_pago Number NOT NULL,
  pag_monto_cancelado Float NOT NULL,
  pag_monto_cambio Float,
  CONSTRAINT pago_factura_ck_monto_cancelado CHECK (pag_monto_cancelado >=0)
)
;

-- Create indexes for table PV_PAGO_FACTURA

CREATE INDEX pago_factura_idx_factura ON PV_PAGO_FACTURA (pag_factura)
;

CREATE INDEX pago_factura_idx_tipo_pago ON PV_PAGO_FACTURA (pag_tipo_pago)
;

-- Add keys for table PV_PAGO_FACTURA

ALTER TABLE PV_PAGO_FACTURA ADD CONSTRAINT PK_PV_PAGO_FACTURA PRIMARY KEY (pag_factura,pag_tipo_pago)
;

-- Table PV_CUENTAS_COBRAR

CREATE TABLE PV_CUENTAS_COBRAR(
  cue_id Number NOT NULL,
  cue_cliente Number NOT NULL,
  cue_saldo_pendiente Float NOT NULL
)
;

-- Create indexes for table PV_CUENTAS_COBRAR

CREATE INDEX IX_Relationship2 ON PV_CUENTAS_COBRAR (cue_cliente)
;

-- Add keys for table PV_CUENTAS_COBRAR

ALTER TABLE PV_CUENTAS_COBRAR ADD CONSTRAINT PK_PV_CUENTAS_COBRAR PRIMARY KEY (cue_id)
;

-- Table PV_CUENTAS_PAGAR

CREATE TABLE PV_CUENTAS_PAGAR(
  cue_id Number NOT NULL,
  cue_proveedor Number NOT NULL,
  cue_monto Float NOT NULL
)
;

-- Create indexes for table PV_CUENTAS_PAGAR

CREATE INDEX IX_Relationship5 ON PV_CUENTAS_PAGAR (cue_proveedor)
;

-- Add keys for table PV_CUENTAS_PAGAR

ALTER TABLE PV_CUENTAS_PAGAR ADD CONSTRAINT PK_PV_CUENTAS_PAGAR PRIMARY KEY (cue_id)
;

-- Table PV_ABONOS_VENTAS

CREATE TABLE PV_ABONOS_VENTAS(
  abov_id Number NOT NULL,
  abov_fac_id Number,
  abov_monto Float NOT NULL,
  abov_fecha_abono Date NOT NULL
)
;

-- Create indexes for table PV_ABONOS_VENTAS

CREATE INDEX IX_Relationship7 ON PV_ABONOS_VENTAS (abov_fac_id)
;

-- Add keys for table PV_ABONOS_VENTAS

ALTER TABLE PV_ABONOS_VENTAS ADD CONSTRAINT PK_PV_ABONOS_VENTAS PRIMARY KEY (abov_id)
;

-- Table PV_CONTACTOS_NOTIFICACION

CREATE TABLE PV_CONTACTOS_NOTIFICACION(
  con_id Number NOT NULL,
  con_nombre_completo Varchar2(128 ) NOT NULL,
  con_puesto Varchar2(32 ) NOT NULL,
  con_email Varchar2(64 ) NOT NULL,
  con_estado Char(1 ) NOT NULL,
  CONSTRAINT contactos_notificacion_ck_estado CHECK (con_estado in ('A','I'))
)
;

-- Create indexes for table PV_CONTACTOS_NOTIFICACION

CREATE INDEX contactos_notificacion_idx_puesto ON PV_CONTACTOS_NOTIFICACION (con_puesto)
;

-- Add keys for table PV_CONTACTOS_NOTIFICACION

ALTER TABLE PV_CONTACTOS_NOTIFICACION ADD CONSTRAINT PK_PV_CONTACTOS_NOTIFICACION PRIMARY KEY (con_id)
;

ALTER TABLE PV_CONTACTOS_NOTIFICACION ADD CONSTRAINT con_email UNIQUE (con_email)
;

-- Table and Columns comments section

COMMENT ON COLUMN PV_CONTACTOS_NOTIFICACION.con_estado IS 'Activo (A), Inactivo(I)'
;

-- Table PV_PADRON

CREATE TABLE PV_PADRON(
  pad_id Number NOT NULL,
  pad_nombre Varchar2(64 ) NOT NULL,
  pad_apellidos1 Varchar2(32 ) NOT NULL,
  pad_apellidos2 Varchar2(32 ) NOT NULL,
  pad_cedula Varchar2(32 ) NOT NULL
)
;

-- Add keys for table PV_PADRON

ALTER TABLE PV_PADRON ADD CONSTRAINT PK_PV_PADRON PRIMARY KEY (pad_id)
;

-- Table PV_BITACORA

CREATE TABLE PV_BITACORA(
  bit_id Number NOT NULL,
  bit_accion Varchar2(10 ) NOT NULL,
  bit_tipo Varchar2(30 ) NOT NULL,
  bit_detalle Varchar2(512 ) NOT NULL,
  bit_usuario Varchar2(128 ) NOT NULL,
  bit_fecha Date NOT NULL,
  CONSTRAINT bitacora_ck_tipo_accion CHECK (bit_tipo_accion in ('INSERTAR', 'MODIFICAR'))
)
;

-- Create indexes for table PV_BITACORA

CREATE INDEX bitacora_idx_tipo_accion ON PV_BITACORA (bit_accion)
;

-- Add keys for table PV_BITACORA

ALTER TABLE PV_BITACORA ADD CONSTRAINT PK_PV_BITACORA PRIMARY KEY (bit_id)
;

-- Table and Columns comments section

COMMENT ON COLUMN PV_BITACORA.bit_accion IS '''INSERTAR'', ''MODIFICAR'''
;
COMMENT ON COLUMN PV_BITACORA.bit_tipo IS 'Clientes,productos,facturas,etc
'
;
COMMENT ON COLUMN PV_BITACORA.bit_detalle IS 'Detalles del evento'
;
COMMENT ON COLUMN PV_BITACORA.bit_usuario IS 'Usuario que realiza la accion'
;

-- Table PV_PARAMETROS

CREATE TABLE PV_PARAMETROS(
  par_id Number NOT NULL,
  par_contrasena Varchar2(160 ) NOT NULL,
  par_usuario Varchar2(30 ),
  par_estado Varchar2(1 ) NOT NULL
        CONSTRAINT parametros_ck_estado CHECK (par_estado in ('A','I'))
)
;

-- Add keys for table PV_PARAMETROS

ALTER TABLE PV_PARAMETROS ADD CONSTRAINT PK_PV_PARAMETROS PRIMARY KEY (par_id)
;

-- Trigger for sequence Sec_compania for column emp_id in table PV_COMPANIA ---------
CREATE OR REPLACE TRIGGER ts_PV_COMPANIA_Sec_compania BEFORE INSERT
ON PV_COMPANIA FOR EACH ROW
BEGIN
  :new.emp_id := Sec_compania.nextval;
END;
/
CREATE OR REPLACE TRIGGER tsu_PV_COMPANIA_Sec_compania AFTER UPDATE OF emp_id
ON PV_COMPANIA FOR EACH ROW
BEGIN
  RAISE_APPLICATION_ERROR(-20010,'Cannot update column emp_id in table PV_COMPANIA as it uses sequence.');
END;
/

-- Trigger for sequence Sec_sedes for column sed_id in table PV_SEDES ---------
CREATE OR REPLACE TRIGGER ts_PV_SEDES_Sec_sedes BEFORE INSERT
ON PV_SEDES FOR EACH ROW
BEGIN
  :new.sed_id := Sec_sedes.nextval;
END;
/
CREATE OR REPLACE TRIGGER tsu_PV_SEDES_Sec_sedes AFTER UPDATE OF sed_id
ON PV_SEDES FOR EACH ROW
BEGIN
  RAISE_APPLICATION_ERROR(-20010,'Cannot update column sed_id in table PV_SEDES as it uses sequence.');
END;
/

-- Trigger for sequence Sec_inventarios for column inv_id in table PV_INVENTARIOS ---------
CREATE OR REPLACE TRIGGER ts_PV_INVENTARIOS_Sec_inventarios BEFORE INSERT
ON PV_INVENTARIOS FOR EACH ROW
BEGIN
  :new.inv_id := Sec_inventarios.nextval;
END;
/
CREATE OR REPLACE TRIGGER tsu_PV_INVENTARIOS_Sec_inventarios AFTER UPDATE OF inv_id
ON PV_INVENTARIOS FOR EACH ROW
BEGIN
  RAISE_APPLICATION_ERROR(-20010,'Cannot update column inv_id in table PV_INVENTARIOS as it uses sequence.');
END;
/

-- Trigger for sequence Sec_productos for column pro_id in table PV_PRODUCTOS ---------
CREATE OR REPLACE TRIGGER ts_PV_PRODUCTOS_Sec_productos BEFORE INSERT
ON PV_PRODUCTOS FOR EACH ROW
BEGIN
  :new.pro_id := Sec_productos.nextval;
END;
/
CREATE OR REPLACE TRIGGER tsu_PV_PRODUCTOS_Sec_productos AFTER UPDATE OF pro_id
ON PV_PRODUCTOS FOR EACH ROW
BEGIN
  RAISE_APPLICATION_ERROR(-20010,'Cannot update column pro_id in table PV_PRODUCTOS as it uses sequence.');
END;
/

-- Trigger for sequence Sec_proveedores for column pro_id in table PV_PROVEEDORES ---------
CREATE OR REPLACE TRIGGER ts_PV_PROVEEDORES_Sec_proveedores BEFORE INSERT
ON PV_PROVEEDORES FOR EACH ROW
BEGIN
  :new.pro_id := Sec_proveedores.nextval;
END;
/
CREATE OR REPLACE TRIGGER tsu_PV_PROVEEDORES_Sec_proveedores AFTER UPDATE OF pro_id
ON PV_PROVEEDORES FOR EACH ROW
BEGIN
  RAISE_APPLICATION_ERROR(-20010,'Cannot update column pro_id in table PV_PROVEEDORES as it uses sequence.');
END;
/

-- Trigger for sequence Sec_familias for column fam_id in table PV_FAMILIAS ---------
CREATE OR REPLACE TRIGGER ts_PV_FAMILIAS_Sec_familias BEFORE INSERT
ON PV_FAMILIAS FOR EACH ROW
BEGIN
  :new.fam_id := Sec_familias.nextval;
END;
/
CREATE OR REPLACE TRIGGER tsu_PV_FAMILIAS_Sec_familias AFTER UPDATE OF fam_id
ON PV_FAMILIAS FOR EACH ROW
BEGIN
  RAISE_APPLICATION_ERROR(-20010,'Cannot update column fam_id in table PV_FAMILIAS as it uses sequence.');
END;
/

-- Trigger for sequence Sec_codigo_barras for column cod_id in table PV_CODIGOS_BARRAS ---------
CREATE OR REPLACE TRIGGER ts_PV_CODIGOS_BARRAS_Sec_codigo_barras BEFORE INSERT
ON PV_CODIGOS_BARRAS FOR EACH ROW
BEGIN
  :new.cod_id := Sec_codigo_barras.nextval;
END;
/
CREATE OR REPLACE TRIGGER tsu_PV_CODIGOS_BARRAS_Sec_codigo_barras AFTER UPDATE OF cod_id
ON PV_CODIGOS_BARRAS FOR EACH ROW
BEGIN
  RAISE_APPLICATION_ERROR(-20010,'Cannot update column cod_id in table PV_CODIGOS_BARRAS as it uses sequence.');
END;
/

-- Trigger for sequence Sec_facturas_compra for column fac_id in table PV_FACTURAS_COMPRA ---------
CREATE OR REPLACE TRIGGER ts_PV_FACTURAS_COMPRA_Sec_facturas_compra BEFORE INSERT
ON PV_FACTURAS_COMPRA FOR EACH ROW
BEGIN
  :new.fac_id := Sec_facturas_compra.nextval;
END;
/
CREATE OR REPLACE TRIGGER tsu_PV_FACTURAS_COMPRA_Sec_facturas_compra AFTER UPDATE OF fac_id
ON PV_FACTURAS_COMPRA FOR EACH ROW
BEGIN
  RAISE_APPLICATION_ERROR(-20010,'Cannot update column fac_id in table PV_FACTURAS_COMPRA as it uses sequence.');
END;
/

-- Trigger for sequence Sec_abonos for column abo_id in table PV_ABONOS ---------
CREATE OR REPLACE TRIGGER ts_PV_ABONOS_Sec_abonos BEFORE INSERT
ON PV_ABONOS FOR EACH ROW
BEGIN
  :new.abo_id := Sec_abonos.nextval;
END;
/
CREATE OR REPLACE TRIGGER tsu_PV_ABONOS_Sec_abonos AFTER UPDATE OF abo_id
ON PV_ABONOS FOR EACH ROW
BEGIN
  RAISE_APPLICATION_ERROR(-20010,'Cannot update column abo_id in table PV_ABONOS as it uses sequence.');
END;
/

-- Trigger for sequence Sec_clientes for column cli_id in table PV_CLIENTES ---------
CREATE OR REPLACE TRIGGER ts_PV_CLIENTES_Sec_clientes BEFORE INSERT
ON PV_CLIENTES FOR EACH ROW
BEGIN
  :new.cli_id := Sec_clientes.nextval;
END;
/
CREATE OR REPLACE TRIGGER tsu_PV_CLIENTES_Sec_clientes AFTER UPDATE OF cli_id
ON PV_CLIENTES FOR EACH ROW
BEGIN
  RAISE_APPLICATION_ERROR(-20010,'Cannot update column cli_id in table PV_CLIENTES as it uses sequence.');
END;
/

-- Trigger for sequence Sec_facturas_venta for column fac_id in table PV_FACTURAS_VENTA ---------
CREATE OR REPLACE TRIGGER ts_PV_FACTURAS_VENTA_Sec_facturas_venta BEFORE INSERT
ON PV_FACTURAS_VENTA FOR EACH ROW
BEGIN
  :new.fac_id := Sec_facturas_venta.nextval;
END;
/
CREATE OR REPLACE TRIGGER tsu_PV_FACTURAS_VENTA_Sec_facturas_venta AFTER UPDATE OF fac_id
ON PV_FACTURAS_VENTA FOR EACH ROW
BEGIN
  RAISE_APPLICATION_ERROR(-20010,'Cannot update column fac_id in table PV_FACTURAS_VENTA as it uses sequence.');
END;
/

-- Trigger for sequence Sec_acciones for column acc_codigo in table PV_ACCIONES ---------
CREATE OR REPLACE TRIGGER ts_PV_ACCIONES_Sec_acciones BEFORE INSERT
ON PV_ACCIONES FOR EACH ROW
BEGIN
  :new.acc_codigo := Sec_acciones.nextval;
END;
/
CREATE OR REPLACE TRIGGER tsu_PV_ACCIONES_Sec_acciones AFTER UPDATE OF acc_codigo
ON PV_ACCIONES FOR EACH ROW
BEGIN
  RAISE_APPLICATION_ERROR(-20010,'Cannot update column acc_codigo in table PV_ACCIONES as it uses sequence.');
END;
/

-- Trigger for sequence Sec_notas_credito for column not_id in table PV_NOTAS_CRED ---------
CREATE OR REPLACE TRIGGER ts_PV_NOTAS_CRED_Sec_notas_credito BEFORE INSERT
ON PV_NOTAS_CRED FOR EACH ROW
BEGIN
  :new.not_id := Sec_notas_credito.nextval;
END;
/
CREATE OR REPLACE TRIGGER tsu_PV_NOTAS_CRED_Sec_notas_credito AFTER UPDATE OF not_id
ON PV_NOTAS_CRED FOR EACH ROW
BEGIN
  RAISE_APPLICATION_ERROR(-20010,'Cannot update column not_id in table PV_NOTAS_CRED as it uses sequence.');
END;
/

-- Trigger for sequence Sec_promociones for column pro_id in table PV_PROMOCIONES ---------
CREATE OR REPLACE TRIGGER ts_PV_PROMOCIONES_Sec_promociones BEFORE INSERT
ON PV_PROMOCIONES FOR EACH ROW
BEGIN
  :new.pro_id := Sec_promociones.nextval;
END;
/
CREATE OR REPLACE TRIGGER tsu_PV_PROMOCIONES_Sec_promociones AFTER UPDATE OF pro_id
ON PV_PROMOCIONES FOR EACH ROW
BEGIN
  RAISE_APPLICATION_ERROR(-20010,'Cannot update column pro_id in table PV_PROMOCIONES as it uses sequence.');
END;
/

-- Trigger for sequence Sec_descuentos for column dec_id in table PV_DESCUENTOS ---------
CREATE OR REPLACE TRIGGER ts_PV_DESCUENTOS_Sec_descuentos BEFORE INSERT
ON PV_DESCUENTOS FOR EACH ROW
BEGIN
  :new.dec_id := Sec_descuentos.nextval;
END;
/
CREATE OR REPLACE TRIGGER tsu_PV_DESCUENTOS_Sec_descuentos AFTER UPDATE OF dec_id
ON PV_DESCUENTOS FOR EACH ROW
BEGIN
  RAISE_APPLICATION_ERROR(-20010,'Cannot update column dec_id in table PV_DESCUENTOS as it uses sequence.');
END;
/

-- Trigger for sequence Sec_precio for column pre_id in table PV_PRECIOS ---------
CREATE OR REPLACE TRIGGER ts_PV_PRECIOS_Sec_precio BEFORE INSERT
ON PV_PRECIOS FOR EACH ROW
BEGIN
  :new.pre_id := Sec_precio.nextval;
END;
/
CREATE OR REPLACE TRIGGER tsu_PV_PRECIOS_Sec_precio AFTER UPDATE OF pre_id
ON PV_PRECIOS FOR EACH ROW
BEGIN
  RAISE_APPLICATION_ERROR(-20010,'Cannot update column pre_id in table PV_PRECIOS as it uses sequence.');
END;
/

-- Trigger for sequence Sec_tipo_promocion for column tip_id in table PV_TIPO_PROMOCION ---------
CREATE OR REPLACE TRIGGER ts_PV_TIPO_PROMOCION_Sec_tipo_promocion BEFORE INSERT
ON PV_TIPO_PROMOCION FOR EACH ROW
BEGIN
  :new.tip_id := Sec_tipo_promocion.nextval;
END;
/
CREATE OR REPLACE TRIGGER tsu_PV_TIPO_PROMOCION_Sec_tipo_promocion AFTER UPDATE OF tip_id
ON PV_TIPO_PROMOCION FOR EACH ROW
BEGIN
  RAISE_APPLICATION_ERROR(-20010,'Cannot update column tip_id in table PV_TIPO_PROMOCION as it uses sequence.');
END;
/

-- Trigger for sequence Sec_movimiento for column mov_id in table PV_MOVIMIENTOS ---------
CREATE OR REPLACE TRIGGER ts_PV_MOVIMIENTOS_Sec_movimiento BEFORE INSERT
ON PV_MOVIMIENTOS FOR EACH ROW
BEGIN
  :new.mov_id := Sec_movimiento.nextval;
END;
/
CREATE OR REPLACE TRIGGER tsu_PV_MOVIMIENTOS_Sec_movimiento AFTER UPDATE OF mov_id
ON PV_MOVIMIENTOS FOR EACH ROW
BEGIN
  RAISE_APPLICATION_ERROR(-20010,'Cannot update column mov_id in table PV_MOVIMIENTOS as it uses sequence.');
END;
/

-- Trigger for sequence Sec_tipo_pago for column tip_id in table PV_Tipos_Pago ---------
CREATE OR REPLACE TRIGGER ts_PV_Tipos_Pago_Sec_tipo_pago BEFORE INSERT
ON PV_Tipos_Pago FOR EACH ROW
BEGIN
  :new.tip_id := Sec_tipo_pago.nextval;
END;
/
CREATE OR REPLACE TRIGGER tsu_PV_Tipos_Pago_Sec_tipo_pago AFTER UPDATE OF tip_id
ON PV_Tipos_Pago FOR EACH ROW
BEGIN
  RAISE_APPLICATION_ERROR(-20010,'Cannot update column tip_id in table PV_Tipos_Pago as it uses sequence.');
END;
/

-- Trigger for sequence Sec_cuentas_cobrar for column cue_id in table PV_CUENTAS_COBRAR ---------
CREATE OR REPLACE TRIGGER ts_PV_CUENTAS_COBRAR_Sec_cuentas_cobrar BEFORE INSERT
ON PV_CUENTAS_COBRAR FOR EACH ROW
BEGIN
  :new.cue_id := Sec_cuentas_cobrar.nextval;
END;
/
CREATE OR REPLACE TRIGGER tsu_PV_CUENTAS_COBRAR_Sec_cuentas_cobrar AFTER UPDATE OF cue_id
ON PV_CUENTAS_COBRAR FOR EACH ROW
BEGIN
  RAISE_APPLICATION_ERROR(-20010,'Cannot update column cue_id in table PV_CUENTAS_COBRAR as it uses sequence.');
END;
/

-- Trigger for sequence Sec_cuentas_pagar for column cue_id in table PV_CUENTAS_PAGAR ---------
CREATE OR REPLACE TRIGGER ts_PV_CUENTAS_PAGAR_Sec_cuentas_pagar BEFORE INSERT
ON PV_CUENTAS_PAGAR FOR EACH ROW
BEGIN
  :new.cue_id := Sec_cuentas_pagar.nextval;
END;
/
CREATE OR REPLACE TRIGGER tsu_PV_CUENTAS_PAGAR_Sec_cuentas_pagar AFTER UPDATE OF cue_id
ON PV_CUENTAS_PAGAR FOR EACH ROW
BEGIN
  RAISE_APPLICATION_ERROR(-20010,'Cannot update column cue_id in table PV_CUENTAS_PAGAR as it uses sequence.');
END;
/

-- Trigger for sequence Sec_abonos_venta for column abov_id in table PV_ABONOS_VENTAS ---------
CREATE OR REPLACE TRIGGER ts_PV_ABONOS_VENTAS_Sec_abonos_venta BEFORE INSERT
ON PV_ABONOS_VENTAS FOR EACH ROW
BEGIN
  :new.abov_id := Sec_abonos_venta.nextval;
END;
/
CREATE OR REPLACE TRIGGER tsu_PV_ABONOS_VENTAS_Sec_abonos_venta AFTER UPDATE OF abov_id
ON PV_ABONOS_VENTAS FOR EACH ROW
BEGIN
  RAISE_APPLICATION_ERROR(-20010,'Cannot update column abov_id in table PV_ABONOS_VENTAS as it uses sequence.');
END;
/

-- Trigger for sequence Sec_contactos_notificacion for column con_id in table PV_CONTACTOS_NOTIFICACION ---------
CREATE OR REPLACE TRIGGER ts_PV_CONTACTOS_NOTIFICACION_Sec_contactos_notificacion BEFORE INSERT
ON PV_CONTACTOS_NOTIFICACION FOR EACH ROW
BEGIN
  :new.con_id := Sec_contactos_notificacion.nextval;
END;
/
CREATE OR REPLACE TRIGGER tsu_PV_CONTACTOS_NOTIFICACION_Sec_contactos_notificacion AFTER UPDATE OF con_id
ON PV_CONTACTOS_NOTIFICACION FOR EACH ROW
BEGIN
  RAISE_APPLICATION_ERROR(-20010,'Cannot update column con_id in table PV_CONTACTOS_NOTIFICACION as it uses sequence.');
END;
/

-- Trigger for sequence Sec_padron for column pad_id in table PV_PADRON ---------
CREATE OR REPLACE TRIGGER ts_PV_PADRON_Sec_padron BEFORE INSERT
ON PV_PADRON FOR EACH ROW
BEGIN
  :new.pad_id := Sec_padron.nextval;
END;
/
CREATE OR REPLACE TRIGGER tsu_PV_PADRON_Sec_padron AFTER UPDATE OF pad_id
ON PV_PADRON FOR EACH ROW
BEGIN
  RAISE_APPLICATION_ERROR(-20010,'Cannot update column pad_id in table PV_PADRON as it uses sequence.');
END;
/

-- Trigger for sequence Sec_biticora for column bit_id in table PV_BITACORA ---------
CREATE OR REPLACE TRIGGER ts_PV_BITACORA_Sec_biticora BEFORE INSERT
ON PV_BITACORA FOR EACH ROW
BEGIN
  :new.bit_id := Sec_biticora.nextval;
END;
/
CREATE OR REPLACE TRIGGER tsu_PV_BITACORA_Sec_biticora AFTER UPDATE OF bit_id
ON PV_BITACORA FOR EACH ROW
BEGIN
  RAISE_APPLICATION_ERROR(-20010,'Cannot update column bit_id in table PV_BITACORA as it uses sequence.');
END;
/

-- Trigger for sequence Sec_parametros for column par_id in table PV_PARAMETROS ---------
CREATE OR REPLACE TRIGGER ts_PV_PARAMETROS_Sec_parametros BEFORE INSERT
ON PV_PARAMETROS FOR EACH ROW
BEGIN
  :new.par_id := Sec_parametros.nextval;
END;
/
CREATE OR REPLACE TRIGGER tsu_PV_PARAMETROS_Sec_parametros AFTER UPDATE OF par_id
ON PV_PARAMETROS FOR EACH ROW
BEGIN
  RAISE_APPLICATION_ERROR(-20010,'Cannot update column par_id in table PV_PARAMETROS as it uses sequence.');
END;
/


-- Create foreign keys (relationships) section ------------------------------------------------- 

ALTER TABLE PV_COMPANIA ADD CONSTRAINT compania_invenarios FOREIGN KEY (emp_inventario) REFERENCES PV_INVENTARIOS (inv_id)
;



ALTER TABLE PV_PRODUCTOS ADD CONSTRAINT inventarios_productos FOREIGN KEY (pro_inventario) REFERENCES PV_INVENTARIOS (inv_id)
;



ALTER TABLE PV_PRODUCTOS ADD CONSTRAINT provedores_productos FOREIGN KEY (pro_provedor) REFERENCES PV_PROVEEDORES (pro_id)
;



ALTER TABLE PV_PRODUCTOS ADD CONSTRAINT familias_productos FOREIGN KEY (pro_familia) REFERENCES PV_FAMILIAS (fam_id)
;



ALTER TABLE PV_CODIGOS_BARRAS ADD CONSTRAINT productos_cod_barras FOREIGN KEY (cod_producto) REFERENCES PV_PRODUCTOS (pro_id)
;



ALTER TABLE PV_FACTURAS_COMPRA ADD CONSTRAINT facturas_compra_compania FOREIGN KEY (fac_empresa) REFERENCES PV_COMPANIA (emp_id)
;



ALTER TABLE PV_DETALL_FAC_COMPRA ADD CONSTRAINT facturas_compra_detall_fac_compra FOREIGN KEY (det_factura) REFERENCES PV_FACTURAS_COMPRA (fac_id)
;



ALTER TABLE PV_DETALL_FAC_COMPRA ADD CONSTRAINT productos_detall_fac_compra FOREIGN KEY (det_producto) REFERENCES PV_PRODUCTOS (pro_id)
;



ALTER TABLE PV_FACTURAS_COMPRA ADD CONSTRAINT provedores_facturas_compra FOREIGN KEY (fac_provedor) REFERENCES PV_PROVEEDORES (pro_id)
;



ALTER TABLE PV_LIMITE_CREDITO ADD CONSTRAINT compania_limite_credito FOREIGN KEY (lim_empresa) REFERENCES PV_COMPANIA (emp_id)
;



ALTER TABLE PV_LIMITE_CREDITO ADD CONSTRAINT proveedores_limite_credito FOREIGN KEY (lim_proveedor) REFERENCES PV_PROVEEDORES (pro_id)
;



ALTER TABLE PV_FACTURAS_VENTA ADD CONSTRAINT sedes_facturas_venta FOREIGN KEY (fac_sede) REFERENCES PV_SEDES (sed_id)
;



ALTER TABLE PV_FACTURAS_VENTA ADD CONSTRAINT facturas_clientes FOREIGN KEY (fac_cliente) REFERENCES PV_CLIENTES (cli_id)
;



ALTER TABLE PV_DETALL_FAC_VENTA ADD CONSTRAINT productos_detall_fac_venta FOREIGN KEY (det_producto) REFERENCES PV_PRODUCTOS (pro_id)
;



ALTER TABLE PV_DETALL_FAC_VENTA ADD CONSTRAINT facturas_venta_detall_fac_venta FOREIGN KEY (det_factura) REFERENCES PV_FACTURAS_VENTA (fac_id)
;



ALTER TABLE PV_ACCIONES ADD CONSTRAINT clientes_acciones FOREIGN KEY (acc_cliente) REFERENCES PV_CLIENTES (cli_id)
;



ALTER TABLE PV_CLIEN_NOTA_CRD ADD CONSTRAINT clientes_clien_nota_cred FOREIGN KEY (cli_cliente) REFERENCES PV_CLIENTES (cli_id)
;



ALTER TABLE PV_CLIEN_NOTA_CRD ADD CONSTRAINT notas_cred_clien_nota_crd FOREIGN KEY (cli_nota_crd) REFERENCES PV_NOTAS_CRED (not_id)
;



ALTER TABLE PV_EMPR_NOTA_CRD ADD CONSTRAINT compania_empe_nota_crd FOREIGN KEY (emp_empresa) REFERENCES PV_COMPANIA (emp_id)
;



ALTER TABLE PV_EMPR_NOTA_CRD ADD CONSTRAINT empr_nota_crd_nota_credito FOREIGN KEY (emp_nota_crd) REFERENCES PV_NOTAS_CRED (not_id)
;



ALTER TABLE PV_PROD_PROMO ADD CONSTRAINT prod_promo_productos FOREIGN KEY (pro_producto) REFERENCES PV_PRODUCTOS (pro_id)
;



ALTER TABLE PV_PROD_PROMO ADD CONSTRAINT promociones_prod_promo FOREIGN KEY (pro_promocion) REFERENCES PV_PROMOCIONES (pro_id)
;



ALTER TABLE PV_ACCIONES ADD CONSTRAINT promociones_acciones FOREIGN KEY (acc_promocion) REFERENCES PV_PROMOCIONES (pro_id)
;



ALTER TABLE PV_DESCUENTOS ADD CONSTRAINT descuentos_familias FOREIGN KEY (dec_familia) REFERENCES PV_FAMILIAS (fam_id)
;



ALTER TABLE PV_DESCUENTOS ADD CONSTRAINT descuentos_proveedores FOREIGN KEY (dec_proveedor) REFERENCES PV_PROVEEDORES (pro_id)
;



ALTER TABLE PV_DESC_LIQUIDACION ADD CONSTRAINT des_liquidacion_productos FOREIGN KEY (des_producto) REFERENCES PV_PRODUCTOS (pro_id)
;



ALTER TABLE PV_DESC_LIQUIDACION ADD CONSTRAINT descuentos_des_liquidacion FOREIGN KEY (des_descuento) REFERENCES PV_DESCUENTOS (dec_id)
;



ALTER TABLE PV_PRECIOS ADD CONSTRAINT productos_precios FOREIGN KEY (pre_producto) REFERENCES PV_PRODUCTOS (pro_id)
;



ALTER TABLE PV_PROMOCIONES ADD CONSTRAINT promociones_tipo_promocion FOREIGN KEY (pro_tipo) REFERENCES PV_TIPO_PROMOCION (tip_id)
;



ALTER TABLE PV_INVENTARIOS ADD CONSTRAINT inventarios_sedes FOREIGN KEY (inv_sede) REFERENCES PV_SEDES (sed_id)
;



ALTER TABLE PV_MOVIMIENTOS ADD CONSTRAINT movimientos_productos FOREIGN KEY (mov_producto) REFERENCES PV_PRODUCTOS (pro_id)
;



ALTER TABLE PV_PAGO_FACTURA ADD CONSTRAINT factura_venta_pago FOREIGN KEY (pag_factura) REFERENCES PV_FACTURAS_VENTA (fac_id)
;



ALTER TABLE PV_PAGO_FACTURA ADD CONSTRAINT tipo_pago_factura FOREIGN KEY (pag_tipo_pago) REFERENCES PV_Tipos_Pago (tip_id)
;



ALTER TABLE PV_DETALL_FAC_VENTA ADD CONSTRAINT precio_detall_fac_venta FOREIGN KEY (det_precio) REFERENCES PV_PRECIOS (pre_id)
;



ALTER TABLE PV_DETALL_FAC_VENTA ADD CONSTRAINT promociones_det_factura_venta FOREIGN KEY (det_promocion) REFERENCES PV_PROMOCIONES (pro_id)
;



ALTER TABLE PV_CUENTAS_COBRAR ADD CONSTRAINT cuentas_cobrar_clientes FOREIGN KEY (cue_cliente) REFERENCES PV_CLIENTES (cli_id)
;



ALTER TABLE PV_CUENTAS_PAGAR ADD CONSTRAINT cuentas_pagar_proveedor FOREIGN KEY (cue_proveedor) REFERENCES PV_PROVEEDORES (pro_id)
;



ALTER TABLE PV_ABONOS ADD CONSTRAINT abonos_factura_compra FOREIGN KEY (abo_fac_id) REFERENCES PV_FACTURAS_COMPRA (fac_id)
;



ALTER TABLE PV_ABONOS_VENTAS ADD CONSTRAINT abonos_facturas_venta FOREIGN KEY (abov_fac_id) REFERENCES PV_FACTURAS_VENTA (fac_id)
;





