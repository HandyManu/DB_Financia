//Tabla para diferenciar los tipos de usuario. Pueden ser Usuarios Normales o Administradores (quienes tienen sus privilegios)
create table tbTipoUsuario(
    id_TipoUsuario int generated always as identity primary key,
    nombreTipoUsuario varchar2(20) not null unique
);
 
//Tabla para almacenar los usuarios
create table tbUsuarios(
    UUID_Usuario varchar2(50) primary key,
    id_TipoUsuario int,
    nombreUsuario varchar2(100) not null unique,
    correoUsuario varchar2(100) not null,
    contrasenaUsuario varchar2(50) not null,
    huellaUsuario Varchar2(100) null unique,
    ----Llave foranea---
    constraint fk_UUID_TipoUsuario foreign key (id_TipoUsuario) references tbTipoUsuario (id_TipoUsuario),
    ----Restriccion para que la contraseña no sea menor a 8 caracteres----
    constraint chk_contrasena_min_length check (length(contrasenaUsuario) >= 8),                              
    ----Restriccion para que el correo tenga el formato correcto----
    constraint chk_correo_formato check (regexp_like(correoUsuario, '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$')),
    ----Restriccion para que el correo del usuario sea unico (importante al momento de recuperar contraseñas)---
    constraint uniq_correoUsuario unique (correoUsuario)
);

UPDATE tbUsuarios set UUID_Usuario = SYS_GUID()
 
 
//Tabla para identificar si la categoria es de gasto o ingreso
create table tbTipoClasificacion(
    id_TipoClasificacion int generated always as identity primary key,
    nombreTipoClasificacion varchar2(50) not null unique
);
 
//Tabla para definir las clasificaciones de los gastos e ingresos. (Alimentacion, transporte, etc.)
create table tbClasificaciones(
    UUID_CLASIFICACIONES varchar2(50) primary key,
    UUID_Usuario varchar2(50),
    id_TipoClasificacion int,
    nombreClasificacion varchar2(100) not null unique,
    ----Llave foranea para que cada usuario pueda tener sus propias categorias----    
    constraint fk_UUID_Usuarios foreign key (UUID_Usuario) references tbUsuarios (UUID_Usuario),
    ----Llave para que el usuario decida si la categoria es para ingresos o gastos----
    constraint fk_UUID_TipoClasificacion foreign key (id_TipoClasificacion) references tbTipoClasificacion (id_TipoClasificacion)
);

UPDATE tbClasificaciones set UUID_CLASIFICACIONES = SYS_GUID()
 
 
//Tabla para identificar los tipos de gastos e ingresos del usuario en el presupuesto. (Fijo o variable)
create table tbTipoGastoIngreso(
    id_TipoGastoIngreso int generated always as identity primary key,
    nombreTipoGastoIngreso varchar2(100) not null unique
);
 
//Tabla para identificar la fuente del gasto
create table tbFuenteGasto(
    UUID_FuenteGasto varchar2(50) primary key,
    nombreFuenteGasto varchar2(50) not null unique
);

UPDATE tbFuenteGasto set UUID_FuenteGasto = SYS_GUID()
 
//Tabla para almacenar los gastos del usuario
create table tbGastos(
    UUID_Gasto varchar2(50) primary key,
    UUID_Usuario varchar2(50) not null,
    id_TipoGastoIngreso int not null,
    UUID_CLASIFICACIONES varchar2(50) not null,
    UUID_FuenteGasto varchar2(50) not null,
    montoGasto number(10,2) not null,
    fechaGasto varchar2(20) not null,
 
    ----Para evitar que el valor de los gastos sea un número negativo (menor a 0)----
    constraint chk_montoGasto_non_negative check (montoGasto >= 0),
    constraint fk_UUID_Usuario foreign key (UUID_Usuario) references tbUsuarios (UUID_Usuario),
 
    constraint fk_id_TipoGastoIngreso foreign key (id_TipoGastoIngreso) references tbTipoGastoIngreso (id_TipoGastoIngreso),
 
    constraint fk_UUID_Clasificacion foreign key (UUID_CLASIFICACIONES) references tbClasificaciones (UUID_CLASIFICACIONES),
    constraint fk_UUID_FuenteGasto foreign key (UUID_FuenteGasto) references tbFuenteGasto (UUID_FuenteGasto)
);
 
 
//Tabla para almacenar los ingresos
create table tbIngresos(
    UUID_Ingreso varchar2(50) primary key,
    UUID_Usuario varchar2(50) not null,
    id_TipoGastoIngreso int not null,
    UUID_Clasificacion varchar2(50) not null,
    montoIngreso number(10,2) not null,
    fechaIngreso varchar2(20) not null,
    ----Para evitar que el valor de los ingresos sea un número negativo (menor a 0)----
    constraint chk_montoIngreso_non_negative check (montoIngreso >= 0),
    constraint fk_UUID_Usuario1 foreign key (UUID_Usuario) references tbUsuarios (UUID_Usuario),
 
    constraint fk_id_TipoGastoIngreso1 foreign key (id_TipoGastoIngreso) references tbTipoGastoIngreso (id_TipoGastoIngreso),
 
    constraint fk_UUID_Clasificacion1 foreign key (UUID_Clasificacion) references tbClasificaciones (UUID_CLASIFICACIONES)
);
 
 
//Tabla para manejar los ahorros
create table tbAhorros(
    UUID_Ahorro varchar2(50) primary key,
    UUID_Usuario varchar2(50) not null,
    montoAhorro number (10,2) not null,
    fechaAhorro varchar2(50) not null,
 
----Para evitar que el valor de los ahorros sea un número negativo (menor a 0)----
    constraint chk_montoIngreso_non_negative1 check (montoAhorro >= 0),
    constraint fk_UUID_Usuario_2 foreign key (UUID_Usuario) references tbUsuarios (UUID_Usuario)
);
 
//Tabla para crear un nuevo presupuesto
create table tbPresupuestos(
    UUID_Presupuesto varchar2(50) primary key,
    UUID_Usuario varchar2(50) not null,
    fechaInicio varchar2(50) not null,
    fechaFinal varchar2(50) not null,
 
    constraint fk_UUID_Usuario3 foreign key (UUID_Usuario) references tbUsuarios (UUID_Usuario)
);
 
 
//Tabla para almacenar todos los detalles del presupuesto: ingresos, gastos y ahorros
create table tbDetallesPresupuesto(
    UUID_DetallePresupuesto varchar2(50) primary key,
    UUID_Presupuesto varchar2(50),
    UUID_Gasto varchar2(50) not null,
    UUID_Ingreso varchar2(50) not null,
    UUID_Ahorro varchar2(50) not null,
    constraint fk_UUID_Presupuesto foreign key (UUID_Presupuesto) references tbPresupuestos(UUID_Presupuesto),
    constraint fk_UUID_Gasto foreign key (UUID_Gasto) references tbGastos(UUID_Gasto),
 
    constraint fk_UUID_Ingreso foreign key (UUID_Ingreso) references tbIngresos(UUID_Ingreso),
 
    constraint fk_UUID_Ahorro foreign key (UUID_Ahorro) references tbAhorros (UUID_Ahorro)
);



//Tabla para definir tipo de recurso (video o lectura)
create table tbTipoRecursos(
    id_TipoRecurso int generated always as identity primary key,
    nombreTipoRecurso varchar2(50) not null unique
);
 
//Tabla para almacenar los recursos
create table tbRecursosEducativos(
    UUID_Recurso varchar2(50) primary key,
    id_TipoRecurso int not null unique,
    tituloRecurso varchar2(50) not null unique,
    descripcionRecurso varchar2(255) not null,
    urlRecurso varchar2(250) not null,
    miniaturaRecurso varchar2(100) not null,
 
    constraint fk_UUID_TipoRecurso foreign key (id_TipoRecurso) references tbTipoRecursos (id_TipoRecurso)
);
 
 
//Tabla para definir metas financieras
create table tbMetasFinancieras(
    UUID_Meta varchar2(50) primary key,
    UUID_Usuario varchar2(50) not null,
    nombreMeta varchar2(100) not null,
    montoAhorrado number(10,2) default 0,
    montoObjetivo number(10,2) not null,
    fechaMeta varchar2(50) not null,
----Para evitar que el valor del monto Objetivo sea un número negativo (menor a 0)----
    constraint chk_montoObjetivo_non_negative check (montoObjetivo >= 0),
    constraint fk_UUID_Usuario5 foreign key (UUID_Usuario) references tbUsuarios (UUID_Usuario)
);


 
//Tabla para que de los ahorros, se le asigne una parte a las metas financieras
create table tbAsignacionesAhorros(
    UUID_Asignacion varchar(50) primary key,
    UUID_Ahorro varchar(50) not null,
    UUID_Meta varchar2(50) not null,
    montoAsignado number(10,2) not null,
    fechaAsignacion varchar2(50) not null,
    ----Para evitar que el valor del monto Objetivo sea un número negativo (menor a 0)----
    constraint chk_montoAsignado_non_negative check (montoAsignado >= 0),
    constraint fk_UUID_Ahorro1 foreign key (UUID_Ahorro) REFERENCES tbAhorros (UUID_Ahorro),
    constraint fk_UUID_Meta foreign key (UUID_Meta) REFERENCES tbMetasFinancieras (UUID_Meta)
);


 
//Tabla para guardar las notificaciones, recordatorios y consejos
create table tbNotificaciones(
    UUID_Notificacion varchar2(50) primary key,
    UUID_Usuario varchar2(50) not null,
    UUID_Gasto varchar2(50) not null,
    fechaNotificacion varchar2(50) not null,
    horaNotificacion varchar2(50) not null,
    mensaje varchar2(255) not null,
 
    constraint fk_UUID_Usuario6 foreign key (UUID_Usuario) references tbUsuarios (UUID_Usuario),
 
    constraint fk_UUID_Gasto1 foreign key (UUID_Gasto) references tbGastos (UUID_Gasto)
);





//iNSERTS 

Insert into tbTipoUsuario ( nombreTipoUsuario)values ('Usuario');
Insert into tbTipoUsuario ( nombreTipoUsuario)values ('Administrador' );

select * from tbClasificaciones

Insert into tbUsuarios ( UUID_Usuario,id_TipoUsuario,nombreUsuario,correoUsuario,contrasenaUsuario,huellaUsuario )values (SYS_GUID(),2,'Manuel Ortega','20220416@ricaldone.edu.sv','123456789','');
Insert into tbUsuarios ( UUID_Usuario,id_TipoUsuario,nombreUsuario,correoUsuario,contrasenaUsuario,huellaUsuario )values (SYS_GUID(),2,'Daniel Granados','20200008@ricaldone.edu.sv','123456789','');
Insert into tbUsuarios ( UUID_Usuario,id_TipoUsuario,nombreUsuario,correoUsuario,contrasenaUsuario,huellaUsuario )values (SYS_GUID(),2,'Claudia Hernandez','20230019@ricaldone.edu.sv','123456789','');
Insert into tbUsuarios ( UUID_Usuario,id_TipoUsuario,nombreUsuario,correoUsuario,contrasenaUsuario,huellaUsuario )values (SYS_GUID(),2,'Jennifer Tejada','20210177@ricaldone.edu.sv','123456789','');
Insert into tbUsuarios ( UUID_Usuario,id_TipoUsuario,nombreUsuario,correoUsuario,contrasenaUsuario,huellaUsuario )values (SYS_GUID(),2,'Olga Mendez','20220525@ricaldone.edu.sv','123456789','');
Insert into tbUsuarios ( UUID_Usuario,id_TipoUsuario,nombreUsuario,correoUsuario,contrasenaUsuario,huellaUsuario )values (SYS_GUID(),1,'Bryan Miranda','bryan_miranda@ricaldone.edu.sv','123456789','');
Insert into tbUsuarios ( UUID_Usuario,id_TipoUsuario,nombreUsuario,correoUsuario,contrasenaUsuario,huellaUsuario )values (SYS_GUID(),1,'Mirna Espinoza','mirna_espinoza@ricaldone.edu.sv','123456789','');
Insert into tbUsuarios ( UUID_Usuario,id_TipoUsuario,nombreUsuario,correoUsuario,contrasenaUsuario,huellaUsuario )values (SYS_GUID(),1,'Emerson Gonzales','emerson_gonzalez@ricaldone.edu.sv','123456789','');
Insert into tbUsuarios ( UUID_Usuario,id_TipoUsuario,nombreUsuario,correoUsuario,contrasenaUsuario,huellaUsuario )values (SYS_GUID(),1,'Ricardo de Paz','ricardo_depaz@ricaldone.edu.sv','123456789','');
Insert into tbUsuarios ( UUID_Usuario,id_TipoUsuario,nombreUsuario,correoUsuario,contrasenaUsuario,huellaUsuario )values (SYS_GUID(),1,'Dina Alfaro','dina_alfaro@ricaldone.edu.sv','123456789','');

Insert into tbTipoClasificacion ( nombreTipoClasificacion )values ('Gastos');
Insert into tbTipoClasificacion ( nombreTipoClasificacion )values ('Ingresos');

Insert into tbClasificaciones ( UUID_CLASIFICACIONES,UUID_Usuario,id_TipoClasificacion,nombreClasificacion )values (SYS_GUID(),'B9F9FFE047454340B8FC5B61154344ED',1,'Alimentacion');
Insert into tbClasificaciones ( UUID_CLASIFICACIONES,UUID_Usuario,id_TipoClasificacion,nombreClasificacion )values (SYS_GUID(), 'EAF32AC692E24F5E8051D2269DA315CD',2,'Transporte');
Insert into tbClasificaciones ( UUID_CLASIFICACIONES,UUID_Usuario,id_TipoClasificacion,nombreClasificacion )values (SYS_GUID(), 'B9BE6057A42A4693BBE2C88BA3123D2A',2,'Seguro de vida');
Insert into tbClasificaciones ( UUID_CLASIFICACIONES,UUID_Usuario,id_TipoClasificacion,nombreClasificacion )values (SYS_GUID(), '29D8E94F2F8C4315A28D61AB39FE769F',1,'Arrendamiento');
Insert into tbClasificaciones ( UUID_CLASIFICACIONES,UUID_Usuario,id_TipoClasificacion,nombreClasificacion )values (SYS_GUID(), '61A2A3A565E84D16B5366FF1941B2D41',2,'Internet');
Insert into tbClasificaciones ( UUID_CLASIFICACIONES,UUID_Usuario,id_TipoClasificacion,nombreClasificacion )values (SYS_GUID(), 'E5689EB3E1E147BDA5E0683119621F0E',1,'Teléfono');
Insert into tbClasificaciones ( UUID_CLASIFICACIONES,UUID_Usuario,id_TipoClasificacion,nombreClasificacion )values (SYS_GUID(), '1FAA09AC5A634D509E289021D04D889E',2,'Educacion');
Insert into tbClasificaciones ( UUID_CLASIFICACIONES,UUID_Usuario,id_TipoClasificacion,nombreClasificacion )values (SYS_GUID(), '38770A48F8E542F18122BFE119A5CFA1',1,'Salud');
Insert into tbClasificaciones ( UUID_CLASIFICACIONES,UUID_Usuario,id_TipoClasificacion,nombreClasificacion )values (SYS_GUID(), '5910AF6314D2472BA63A1AA4A371FB74',2,'Impuestos');
Insert into tbClasificaciones ( UUID_CLASIFICACIONES,UUID_Usuario,id_TipoClasificacion,nombreClasificacion )values (SYS_GUID(), 'B53006C921D54D66B86674153F2D43DF',2,'Servicios básicos');

Insert into tbTipoGastoIngreso ( nombreTipoGastoIngreso )values ('Gasto Fijo');
Insert into tbTipoGastoIngreso ( nombreTipoGastoIngreso )values ('Gasto Variable');
Insert into tbTipoGastoIngreso ( nombreTipoGastoIngreso )values ('Ingreso Fijo');
Insert into tbTipoGastoIngreso ( nombreTipoGastoIngreso )values ('Ingreso Variable');


Insert into tbFuenteGasto ( UUID_FuenteGasto,nombreFuenteGasto )values (SYS_GUID(),'Tarjeta');
Insert into tbFuenteGasto ( UUID_FuenteGasto,nombreFuenteGasto )values (SYS_GUID(),'Efectivo');










