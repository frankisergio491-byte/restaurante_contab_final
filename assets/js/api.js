const API_URL = "http://localhost:8000/api";

export async function listarProductos() {
  const respuesta = await fetch(`${API_URL}/productos/`);
  return respuesta.json();
}

export async function listarMesas() {
  const respuesta = await fetch(`${API_URL}/mesas/`);
  return respuesta.json();
}

export async function listarPedidos() {
  const respuesta = await fetch(`${API_URL}/pedidos/`);
  return respuesta.json();
}

