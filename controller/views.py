import json
import random
from datetime import timedelta

from django.conf import settings
from django.core.mail import send_mail
from django.db import DatabaseError, IntegrityError, transaction
from django.http import JsonResponse
from django.utils import timezone
from django.views.decorators.csrf import csrf_exempt

from model.models import (
    Cliente,
    Empleado,
    Mesa,
    Pedido,
    Producto,
    RecuperacionContrasena,
    Sede,
    Usuario,
    VerificacionCorreo,
)


def respuesta(data, status=200):
    res = JsonResponse(data, safe=False, status=status)
    res["Access-Control-Allow-Origin"] = "*"
    res["Access-Control-Allow-Headers"] = "Content-Type"
    res["Access-Control-Allow-Methods"] = "GET, POST, OPTIONS"
    return res


def home(request):
    return respuesta({"mensaje": "API Restaurante Contab funcionando"})


def sedes(request):
    data = [
        {
            "id": sede.id_sed_pk,
            "nombre": sede.nom_sed,
            "direccion": sede.dir_sed,
            "telefono": sede.tel_sed,
            "municipio": sede.mun_sed,
            "capacidad": sede.cap_sed,
        }
        for sede in Sede.objects.all()
    ]
    return respuesta(data)


def clientes(request):
    data = [
        {
            "id": cliente.id_cli_pk,
            "nombre": cliente.nom_cli,
            "apellido": cliente.ape_cli,
            "telefono": cliente.tel_cli,
            "correo": cliente.ema_cli,
        }
        for cliente in Cliente.objects.all()
    ]
    return respuesta(data)


def usuarios(request):
    data = [
        {
            "id": usuario.id_usu_pk,
            "usuario": usuario.use_usu,
            "estado": usuario.est_usu,
            "intentos_fallidos": usuario.intentos_fallidos,
            "rol": usuario.empleado.car_emp,
            "empleado": f"{usuario.empleado.nom_emp} {usuario.empleado.ape_emp}",
            "telefono": usuario.empleado.tel_emp,
            "correo": usuario.empleado.ema_emp,
            "sede": usuario.empleado.sede.nom_sed,
        }
        for usuario in Usuario.objects.select_related("empleado", "empleado__sede").order_by("-id_usu_pk")
    ]
    return respuesta(data)


def mesas(request):
    data = [
        {
            "id": mesa.id_mes_pk,
            "numero": mesa.num_mes,
            "capacidad": mesa.cap_mes,
            "estado": mesa.est_mes,
            "sede": mesa.sede.nom_sed,
        }
        for mesa in Mesa.objects.select_related("sede")
    ]
    return respuesta(data)


def productos(request):
    data = [
        {
            "id": producto.id_pro_pk,
            "nombre": producto.nom_pro,
            "descripcion": producto.des_pro,
            "precio": producto.pre_pro,
            "tiempo": producto.tie_pre_pro,
            "disponibilidad": producto.dis_pro,
            "categoria": producto.categoria.nom_cat,
        }
        for producto in Producto.objects.select_related("categoria")
    ]
    return respuesta(data)


def pedidos(request):
    data = [
        {
            "id": pedido.id_ped_pk,
            "mesa": pedido.mesa.num_mes,
            "empleado": f"{pedido.empleado.nom_emp} {pedido.empleado.ape_emp}",
            "cliente": f"{pedido.cliente.nom_cli} {pedido.cliente.ape_cli}" if pedido.cliente else "Sin cliente",
            "metodo_pago": pedido.mpa_ped,
            "propina": pedido.pro_ped,
            "hora_inicio": str(pedido.hor_ini_ped),
            "hora_fin": str(pedido.hor_fin_ped) if pedido.hor_fin_ped else "",
        }
        for pedido in Pedido.objects.select_related("mesa", "empleado", "cliente")
    ]
    return respuesta(data)


@csrf_exempt
def login(request):
    if request.method == "OPTIONS":
        return respuesta({})
    if request.method != "POST":
        return respuesta({"error": "Use POST"}, status=405)

    datos = json.loads(request.body or "{}")
    usuario = datos.get("usuario")
    contrasena = datos.get("contrasena")

    cuenta = Usuario.objects.select_related("empleado").filter(use_usu=usuario).first()
    if not cuenta:
        return respuesta({"ok": False, "mensaje": "Usuario o contrasena incorrectos"}, status=401)

    if cuenta.est_usu == "bloqueado":
        return respuesta({
            "ok": False,
            "mensaje": "Usuario bloqueado por 5 intentos fallidos. Usa recuperar contrasena.",
        }, status=403)

    if cuenta.est_usu != "activo":
        return respuesta({"ok": False, "mensaje": "Usuario inactivo"}, status=403)

    if cuenta.pas_usu != contrasena:
        cuenta.intentos_fallidos += 1
        if cuenta.intentos_fallidos >= 5:
            cuenta.est_usu = "bloqueado"
            cuenta.save(update_fields=["intentos_fallidos", "est_usu"])
            return respuesta({
                "ok": False,
                "mensaje": "Usuario bloqueado por 5 intentos fallidos.",
            }, status=403)
        cuenta.save(update_fields=["intentos_fallidos"])
        restantes = 5 - cuenta.intentos_fallidos
        return respuesta({
            "ok": False,
            "mensaje": f"Contrasena incorrecta. Intentos restantes: {restantes}",
        }, status=401)

    cuenta.intentos_fallidos = 0
    cuenta.save(update_fields=["intentos_fallidos"])

    codigo = f"{random.randint(100000, 999999)}"
    VerificacionCorreo.objects.filter(usuario=cuenta, verificado=False).delete()
    VerificacionCorreo.objects.create(
        usuario=cuenta,
        token=codigo,
        verificado=False,
        fec_cre=timezone.now(),
    )

    try:
        send_mail(
            "Codigo de acceso - Restaurante Contab",
            f"Tu codigo de verificacion es: {codigo}. Expira en 5 minutos.",
            settings.DEFAULT_FROM_EMAIL,
            [cuenta.empleado.ema_emp],
            fail_silently=False,
        )
    except Exception as exc:
        return respuesta({
            "ok": False,
            "mensaje": f"No se pudo enviar el codigo al correo: {exc}",
        }, status=500)

    return respuesta({
        "ok": True,
        "requiere_codigo": True,
        "mensaje": "Codigo enviado al correo registrado",
        "usuario": cuenta.use_usu,
        "rol": cuenta.empleado.car_emp,
        "empleado": f"{cuenta.empleado.nom_emp} {cuenta.empleado.ape_emp}",
    })


@csrf_exempt
def verificar_login(request):
    if request.method == "OPTIONS":
        return respuesta({})
    if request.method != "POST":
        return respuesta({"error": "Use POST"}, status=405)

    datos = json.loads(request.body or "{}")
    usuario = datos.get("usuario", "").strip()
    codigo = datos.get("codigo", "").strip()

    cuenta = Usuario.objects.select_related("empleado").filter(use_usu=usuario).first()
    if not cuenta:
        return respuesta({"ok": False, "mensaje": "Usuario no encontrado"}, status=404)

    limite = timezone.now() - timedelta(minutes=5)
    verificacion = VerificacionCorreo.objects.filter(
        usuario=cuenta,
        token=codigo,
        verificado=False,
        fec_cre__gte=limite,
    ).first()

    if not verificacion:
        return respuesta({"ok": False, "mensaje": "Codigo invalido o vencido"}, status=400)

    verificacion.verificado = True
    verificacion.save(update_fields=["verificado"])

    return respuesta({
        "ok": True,
        "mensaje": "Autenticacion completada",
        "usuario": cuenta.use_usu,
        "rol": cuenta.empleado.car_emp,
        "empleado": f"{cuenta.empleado.nom_emp} {cuenta.empleado.ape_emp}",
    })


@csrf_exempt
def solicitar_recuperacion(request):
    if request.method == "OPTIONS":
        return respuesta({})
    if request.method != "POST":
        return respuesta({"error": "Use POST"}, status=405)

    datos = json.loads(request.body or "{}")
    usuario = datos.get("usuario", "").strip()
    cuenta = Usuario.objects.select_related("empleado").filter(use_usu=usuario).first()

    if not cuenta:
        return respuesta({"ok": False, "mensaje": "Usuario no encontrado"}, status=404)

    codigo = f"{random.randint(100000, 999999)}"
    RecuperacionContrasena.objects.filter(usuario=cuenta, usado=False).delete()
    RecuperacionContrasena.objects.create(
        usuario=cuenta,
        token=codigo,
        usado=False,
        fec_cre=timezone.now(),
    )

    try:
        send_mail(
            "Recuperacion de contrasena - Restaurante Contab",
            f"Tu codigo para recuperar la contrasena es: {codigo}. Expira en 5 minutos.",
            settings.DEFAULT_FROM_EMAIL,
            [cuenta.empleado.ema_emp],
            fail_silently=False,
        )
    except Exception as exc:
        return respuesta({"ok": False, "mensaje": f"No se pudo enviar el correo: {exc}"}, status=500)

    return respuesta({"ok": True, "mensaje": "Codigo de recuperacion enviado al correo"})


@csrf_exempt
def cambiar_contrasena(request):
    if request.method == "OPTIONS":
        return respuesta({})
    if request.method != "POST":
        return respuesta({"error": "Use POST"}, status=405)

    datos = json.loads(request.body or "{}")
    usuario = datos.get("usuario", "").strip()
    codigo = datos.get("codigo", "").strip()
    nueva = datos.get("nueva_contrasena", "").strip()

    if not all([usuario, codigo, nueva]):
        return respuesta({"ok": False, "mensaje": "Faltan datos"}, status=400)

    cuenta = Usuario.objects.filter(use_usu=usuario).first()
    if not cuenta:
        return respuesta({"ok": False, "mensaje": "Usuario no encontrado"}, status=404)

    limite = timezone.now() - timedelta(minutes=5)
    recuperacion = RecuperacionContrasena.objects.filter(
        usuario=cuenta,
        token=codigo,
        usado=False,
        fec_cre__gte=limite,
    ).first()

    if not recuperacion:
        return respuesta({"ok": False, "mensaje": "Codigo invalido o vencido"}, status=400)

    cuenta.pas_usu = nueva
    cuenta.intentos_fallidos = 0
    cuenta.est_usu = "activo"
    cuenta.save(update_fields=["pas_usu", "intentos_fallidos", "est_usu"])

    recuperacion.usado = True
    recuperacion.save(update_fields=["usado"])

    return respuesta({"ok": True, "mensaje": "Contrasena actualizada. Ya puedes iniciar sesion."})


@csrf_exempt
def registro(request):
    if request.method == "OPTIONS":
        return respuesta({})
    if request.method != "POST":
        return respuesta({"error": "Use POST"}, status=405)

    datos = json.loads(request.body or "{}")
    nombre = datos.get("nombre", "").strip()
    apellido = datos.get("apellido", "").strip()
    telefono = datos.get("telefono", "").strip()
    correo = datos.get("correo", "").strip()
    usuario = datos.get("usuario", "").strip()
    contrasena = datos.get("contrasena", "").strip()
    rol = datos.get("rol", "Cliente").strip()

    if not all([nombre, apellido, telefono, correo, usuario, contrasena, rol]):
        return respuesta({"ok": False, "mensaje": "Faltan datos obligatorios"}, status=400)

    if Usuario.objects.filter(use_usu=usuario).exists():
        return respuesta({"ok": False, "mensaje": "Ese usuario ya existe"}, status=400)

    if rol.lower() == "cliente" and Cliente.objects.filter(tel_cli=telefono).exists():
        return respuesta({"ok": False, "mensaje": "Ese telefono ya existe como cliente"}, status=400)

    sede = Sede.objects.first()
    if not sede:
        return respuesta({"ok": False, "mensaje": "No existe una sede para asignar el usuario"}, status=400)

    try:
        with transaction.atomic():
            empleado = Empleado.objects.create(
                nom_emp=nombre,
                ape_emp=apellido,
                tel_emp=telefono,
                ema_emp=correo,
                car_emp=rol,
                sal_emp=0,
                fec_ing_emp="2026-06-22",
                hro_emp="Sin asignar",
                sede=sede,
            )
            cuenta = Usuario.objects.create(
                use_usu=usuario,
                pas_usu=contrasena,
                est_usu="activo",
                empleado=empleado,
            )
            cliente = None
            if rol.lower() == "cliente":
                cliente = Cliente.objects.create(
                    nom_cli=nombre,
                    ape_cli=apellido,
                    tel_cli=telefono,
                    ema_cli=correo,
                )
    except IntegrityError:
        return respuesta({"ok": False, "mensaje": "Dato repetido. Cambia usuario o telefono."}, status=400)
    except DatabaseError as exc:
        return respuesta({"ok": False, "mensaje": f"Error de base de datos: {exc}"}, status=500)

    try:
        send_mail(
            "Registro creado - Restaurante Contab",
            (
                f"Hola {nombre} {apellido}.\n\n"
                f"Tu usuario fue creado correctamente.\n"
                f"Usuario: {usuario}\n"
                f"Rol: {rol}\n\n"
                "Cuando inicies sesion recibiras un codigo de verificacion en este correo."
            ),
            settings.DEFAULT_FROM_EMAIL,
            [correo],
            fail_silently=False,
        )
        mensaje = "Usuario registrado. Se envio confirmacion al correo."
    except Exception as exc:
        mensaje = f"Usuario registrado, pero no se pudo enviar el correo de registro: {exc}"

    return respuesta({
        "ok": True,
        "mensaje": mensaje,
        "id_usuario": cuenta.id_usu_pk,
        "id_empleado": empleado.id_emp_pk,
        "id_cliente": cliente.id_cli_pk if cliente else None,
        "rol": rol,
    })


def verificar_correo(request, token):
    verificacion = VerificacionCorreo.objects.select_related("usuario").filter(
        token=token,
        verificado=False,
    ).first()

    if not verificacion:
        return respuesta({"ok": False, "mensaje": "Token invalido o ya usado"}, status=400)

    verificacion.verificado = True
    verificacion.save(update_fields=["verificado"])

    usuario = verificacion.usuario
    usuario.est_usu = "activo"
    usuario.save(update_fields=["est_usu"])

    return respuesta({"ok": True, "mensaje": "Correo verificado. Ya puedes iniciar sesion."})
