<template>
  <form class="formulario" @submit.prevent="iniciarSesion">
    <h2>Iniciar sesion</h2>
    <input v-model="usuario" type="text" placeholder="Usuario" />
    <input v-model="contrasena" type="password" placeholder="Contrasena" />
    <button>Entrar</button>
    <p>{{ mensaje }}</p>
  </form>
</template>

<script>
export default {
  name: "Login",
  data() {
    return {
      usuario: "",
      contrasena: "",
      mensaje: "",
      rol: "",
      empleado: "",
    };
  },
  methods: {
    async iniciarSesion() {
      const respuesta = await fetch("http://127.0.0.1:8000/api/login/", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          usuario: this.usuario,
          contrasena: this.contrasena,
        }),
      });
      const datos = await respuesta.json();
      this.mensaje = datos.mensaje;
      this.rol = datos.rol || "";
      this.empleado = datos.empleado || "";
    },
  },
};
</script>
