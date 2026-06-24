<template>
  <form class="formulario" @submit.prevent="registrar">
    <h2>Registro</h2>
    <input v-model="nombre" type="text" placeholder="Nombre" />
    <input v-model="apellido" type="text" placeholder="Apellido" />
    <input v-model="telefono" type="text" placeholder="Telefono" />
    <input v-model="correo" type="email" placeholder="Correo" />
    <input v-model="usuario" type="text" placeholder="Usuario" />
    <input v-model="contrasena" type="password" placeholder="Contrasena" />
    <select v-model="rol">
      <option>Administrador</option>
      <option>Mesero</option>
      <option>Chef</option>
      <option>Cajero</option>
      <option>Bodeguero</option>
      <option>Cliente</option>
    </select>
    <button>Registrar</button>
    <p>{{ mensaje }}</p>
  </form>
</template>

<script>
export default {
  name: "Registro",
  data() {
    return {
      nombre: "",
      apellido: "",
      telefono: "",
      correo: "",
      usuario: "",
      contrasena: "",
      rol: "Cliente",
      mensaje: "",
    };
  },
  methods: {
    async registrar() {
      const respuesta = await fetch("http://127.0.0.1:8000/api/registro/", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          nombre: this.nombre,
          apellido: this.apellido,
          telefono: this.telefono,
          correo: this.correo,
          usuario: this.usuario,
          contrasena: this.contrasena,
          rol: this.rol,
        }),
      });
      const datos = await respuesta.json();
      this.mensaje = datos.mensaje || (datos.ok ? "Registro guardado" : "No se pudo registrar");
    },
  },
};
</script>
