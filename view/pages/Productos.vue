<template>
  <section>
    <h2>Productos</h2>
    <table>
      <thead>
        <tr>
          <th>Nombre</th>
          <th>Precio</th>
          <th>Disponibilidad</th>
        </tr>
      </thead>
      <tbody>
        <tr v-for="producto in productos" :key="producto.id">
          <td>{{ producto.nom_pro }}</td>
          <td>{{ producto.pre_pro }}</td>
          <td>{{ producto.dis_pro }}</td>
        </tr>
      </tbody>
    </table>
  </section>
</template>

<script>
export default {
  name: "Productos",
  data() {
    return {
      productos: [],
    };
  },
  async mounted() {
    const respuesta = await fetch("http://localhost:8000/api/productos/");
    this.productos = await respuesta.json();
  },
};
</script>

