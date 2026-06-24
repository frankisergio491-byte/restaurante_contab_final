# Restaurante Contab

Proyecto basado en la opcion 3 del tablero:

- Frontend: Vue.js
- Backend: Django
- Tema: restaurante

Se respeta el orden de carpetas del ejemplo MVC:

```text
restaurante_contab/
  assets/
  controller/
  model/
  view/
```

Equivalencia:

- `model/`: modelos de Django.
- `controller/`: vistas/API de Django.
- `view/`: pantallas de Vue.js.
- `assets/`: CSS y JavaScript general.

Modulos incluidos:

- Sedes
- Empleados
- Usuarios
- Clientes
- Mesas
- Productos
- Pedidos
- Facturas
- Inventario / compras

Para revisar en local con MySQL:

1. Abrir XAMPP.
2. Prender `MySQL`.
3. Editar `email_config.bat` con el correo que enviara verificaciones.
4. Abrir `iniciar_backend.bat`.
5. Abrir `abrir_frontend_local.bat`.

El backend crea/importa la base `cadena_restaurantes` desde `database.sql` solo si no existe. Si la base ya existe, no borra usuarios.

Correo y seguridad:

- En `email_config.bat` coloca `EMAIL_HOST_USER` y `EMAIL_HOST_PASSWORD`.
- Para Gmail, `EMAIL_HOST_PASSWORD` debe ser una contrasena de aplicacion.
- Al registrarse, el sistema manda correo de confirmacion.
- Al iniciar sesion, el sistema manda codigo de 6 numeros al correo del usuario.
- El codigo de inicio de sesion vence en 5 minutos.
- Si falla la contrasena 5 veces, el usuario queda bloqueado.
- Para desbloquear, usa `Recuperar clave`: llega codigo al correo, cambia la contrasena y el usuario vuelve a `activo`.

Backend:

```text
http://127.0.0.1:8000
```

Frontend local:

```text
frontend_local.html
```

Si tienes Node.js instalado, tambien puedes abrir `iniciar_frontend.bat` y entrar a:

```text
http://127.0.0.1:5173
```

Paginas:

- Home: `http://127.0.0.1:5173/#/`
- Inicio de sesion: `http://127.0.0.1:5173/#/login`
- Registro: `http://127.0.0.1:5173/#/registro`
- Productos: `http://127.0.0.1:5173/#/productos`
- Pedidos: `http://127.0.0.1:5173/#/pedidos`
