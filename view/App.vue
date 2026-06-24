<template>
  <div>
    <header class="barra">
      <h1>Restaurante Contab</h1>
      <nav>
        <a href="#/" @click="pagina = 'home'">Home</a>
        <a href="#/login" @click="pagina = 'login'">Inicio de sesion</a>
        <a href="#/registro" @click="pagina = 'registro'">Registro</a>
        <a href="#/productos" @click="pagina = 'productos'">Productos</a>
        <a href="#/pedidos" @click="pagina = 'pedidos'">Pedidos</a>
      </nav>
    </header>

    <main class="contenedor">
      <Home v-if="pagina === 'home'" />
      <Login v-if="pagina === 'login'" />
      <Registro v-if="pagina === 'registro'" />
      <Productos v-if="pagina === 'productos'" />
      <Pedidos v-if="pagina === 'pedidos'" />
    </main>
  </div>
</template>

<script>
import Home from "./pages/Home.vue";
import Login from "./pages/Login.vue";
import Pedidos from "./pages/Pedidos.vue";
import Productos from "./pages/Productos.vue";
import Registro from "./pages/Registro.vue";

export default {
  name: "App",
  components: {
    Home,
    Login,
    Pedidos,
    Productos,
    Registro,
  },
  data() {
    return {
      pagina: "home",
    };
  },
  mounted() {
    const ruta = window.location.hash.replace("#/", "");
    this.pagina = ruta || "home";
    window.addEventListener("hashchange", () => {
      const nuevaRuta = window.location.hash.replace("#/", "");
      this.pagina = nuevaRuta || "home";
    });
  },
};
</script>
