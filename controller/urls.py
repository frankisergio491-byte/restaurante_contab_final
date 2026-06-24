from django.urls import path

from . import views

urlpatterns = [
    path("", views.home),
    path("api/sedes/", views.sedes),
    path("api/clientes/", views.clientes),
    path("api/mesas/", views.mesas),
    path("api/productos/", views.productos),
    path("api/pedidos/", views.pedidos),
    path("api/login/", views.login),
    path("api/verificar-login/", views.verificar_login),
    path("api/solicitar-recuperacion/", views.solicitar_recuperacion),
    path("api/cambiar-contrasena/", views.cambiar_contrasena),
    path("api/registro/", views.registro),
    path("api/verificar-correo/<str:token>/", views.verificar_correo),
]
