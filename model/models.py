from django.db import models


class Sede(models.Model):
    id_sed_pk = models.AutoField(primary_key=True, db_column="id_sed_pk")
    nom_sed = models.CharField(max_length=50)
    dir_sed = models.CharField(max_length=100)
    tel_sed = models.CharField(max_length=20)
    cap_sed = models.IntegerField()
    hrio_sed = models.CharField(max_length=50)
    mun_sed = models.CharField(max_length=50)

    class Meta:
        managed = False
        db_table = "sede"


class Empleado(models.Model):
    id_emp_pk = models.AutoField(primary_key=True, db_column="id_emp_pk")
    nom_emp = models.CharField(max_length=50)
    ape_emp = models.CharField(max_length=50)
    tel_emp = models.CharField(max_length=20)
    ema_emp = models.CharField(max_length=50)
    car_emp = models.CharField(max_length=50)
    sal_emp = models.IntegerField()
    fec_ing_emp = models.DateField()
    hro_emp = models.CharField(max_length=50)
    sede = models.ForeignKey(Sede, db_column="id_sed_fk", on_delete=models.RESTRICT)

    class Meta:
        managed = False
        db_table = "empleado"


class Usuario(models.Model):
    id_usu_pk = models.AutoField(primary_key=True, db_column="id_usu_pk")
    use_usu = models.CharField(max_length=50, unique=True)
    pas_usu = models.CharField(max_length=255)
    est_usu = models.CharField(max_length=20)
    intentos_fallidos = models.IntegerField(default=0)
    empleado = models.OneToOneField(Empleado, db_column="id_emp_fk", on_delete=models.CASCADE)

    class Meta:
        managed = False
        db_table = "usuario"


class VerificacionCorreo(models.Model):
    id_ver_pk = models.AutoField(primary_key=True, db_column="id_ver_pk")
    usuario = models.ForeignKey(Usuario, db_column="id_usu_fk", on_delete=models.CASCADE)
    token = models.CharField(max_length=100, unique=True)
    verificado = models.BooleanField(default=False)
    fec_cre = models.DateTimeField()

    class Meta:
        managed = False
        db_table = "verificacion_correo"


class RecuperacionContrasena(models.Model):
    id_rec_pk = models.AutoField(primary_key=True, db_column="id_rec_pk")
    usuario = models.ForeignKey(Usuario, db_column="id_usu_fk", on_delete=models.CASCADE)
    token = models.CharField(max_length=100, unique=True)
    usado = models.BooleanField(default=False)
    fec_cre = models.DateTimeField()

    class Meta:
        managed = False
        db_table = "recuperacion_contrasena"


class Cliente(models.Model):
    id_cli_pk = models.AutoField(primary_key=True, db_column="id_cli_pk")
    nom_cli = models.CharField(max_length=50)
    ape_cli = models.CharField(max_length=50)
    tel_cli = models.CharField(max_length=20, unique=True)
    ema_cli = models.CharField(max_length=50)
    pun_cli = models.IntegerField(default=0)
    val_acu_cli = models.IntegerField(default=0)

    class Meta:
        managed = False
        db_table = "cliente"


class Mesa(models.Model):
    id_mes_pk = models.AutoField(primary_key=True, db_column="id_mes_pk")
    num_mes = models.IntegerField()
    cap_mes = models.IntegerField()
    est_mes = models.CharField(max_length=20)
    sede = models.ForeignKey(Sede, db_column="id_sed_fk", on_delete=models.CASCADE)

    class Meta:
        managed = False
        db_table = "mesa"


class Categoria(models.Model):
    id_cat_pk = models.AutoField(primary_key=True, db_column="id_cat_pk")
    nom_cat = models.CharField(max_length=50, unique=True)
    des_cat = models.CharField(max_length=255, blank=True, null=True)

    class Meta:
        managed = False
        db_table = "categoria"


class Producto(models.Model):
    id_pro_pk = models.AutoField(primary_key=True, db_column="id_pro_pk")
    nom_pro = models.CharField(max_length=50)
    des_pro = models.TextField(blank=True, null=True)
    pre_pro = models.IntegerField()
    tie_pre_pro = models.IntegerField()
    dis_pro = models.CharField(max_length=20)
    categoria = models.ForeignKey(Categoria, db_column="id_cat_fk", on_delete=models.RESTRICT)

    class Meta:
        managed = False
        db_table = "producto"


class Pedido(models.Model):
    id_ped_pk = models.AutoField(primary_key=True, db_column="id_ped_pk")
    hor_ini_ped = models.TimeField()
    hor_fin_ped = models.TimeField(blank=True, null=True)
    mpa_ped = models.CharField(max_length=50)
    pro_ped = models.IntegerField(default=0)
    mesa = models.ForeignKey(Mesa, db_column="id_mes_fk", on_delete=models.RESTRICT)
    empleado = models.ForeignKey(Empleado, db_column="id_emp_fk", on_delete=models.RESTRICT)
    cliente = models.ForeignKey(Cliente, db_column="id_cli_fk", on_delete=models.SET_NULL, blank=True, null=True)

    class Meta:
        managed = False
        db_table = "pedido"


class Factura(models.Model):
    id_fac_pk = models.AutoField(primary_key=True, db_column="id_fac_pk")
    fec_fac = models.DateField()
    sub_fac = models.IntegerField()
    imp_fac = models.IntegerField()
    tot_fac = models.IntegerField()
    pedido = models.ForeignKey(Pedido, db_column="id_ped_fk", on_delete=models.RESTRICT)

    class Meta:
        managed = False
        db_table = "factura"


class Reserva(models.Model):
    id_res_pk = models.AutoField(primary_key=True, db_column="id_res_pk")
    fec_res = models.DateField()
    hor_res = models.TimeField()
    com_res = models.IntegerField()
    est_res = models.CharField(max_length=20)
    cliente = models.ForeignKey(Cliente, db_column="id_cli_fk", on_delete=models.RESTRICT)
    mesa = models.ForeignKey(Mesa, db_column="id_mes_fk", on_delete=models.RESTRICT)
    sede = models.ForeignKey(Sede, db_column="id_sed_fk", on_delete=models.RESTRICT)

    class Meta:
        managed = False
        db_table = "reserva"


class Proveedor(models.Model):
    id_prv_pk = models.AutoField(primary_key=True, db_column="id_prv_pk")
    nom_prv = models.CharField(max_length=50, unique=True)
    tel_prv = models.CharField(max_length=20)
    ema_prv = models.CharField(max_length=50)
    dir_prv = models.CharField(max_length=100)

    class Meta:
        managed = False
        db_table = "proveedor"


class Ingrediente(models.Model):
    id_ing_pk = models.AutoField(primary_key=True, db_column="id_ing_pk")
    nom_ing = models.CharField(max_length=50, unique=True)
    sto_ing = models.IntegerField()
    min_ing = models.IntegerField()
    fec_ven_ing = models.DateField(blank=True, null=True)
    uni_ing = models.CharField(max_length=20)

    class Meta:
        managed = False
        db_table = "ingrediente"
