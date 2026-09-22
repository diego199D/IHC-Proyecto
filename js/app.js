/* =========================================================
   Gestor de Citas — lógica de toda la aplicación
   Todas las vistas viven en index.html (nada se genera por
   magia); este archivo solo llena listas, valida formularios
   y llama a Supabase. Los puntos marcados "SUPABASE" son las
   consultas reales a la base de datos.
   ========================================================= */

const HORARIOS = [
  '9:00 AM', '9:30 AM', '10:00 AM', '10:30 AM',
  '11:00 AM', '11:30 AM', '2:00 PM', '2:30 PM',
  '3:00 PM', '3:30 PM', '4:00 PM', '4:30 PM',
];

const estado = {
  servicios: [],
  bebidas: [],
  citas: [],          // citas de hoy con estado != 'cobrado'
  consumoActual: [],  // consumos de la cita que se está atendiendo
  borradorCita: null, // { id, nombre, telefono, servicioId } — null si es cita nueva
  citaId: null,       // cita seleccionada (popup / atender / cobrar)
  servicioId: null,   // servicio seleccionado (editar)
  bebidaId: null,     // bebida seleccionada (editar)
};

// ---------- Helpers ----------
const $ = (sel) => document.querySelector(sel);
const $$ = (sel) => Array.from(document.querySelectorAll(sel));

function setCargando(boton, cargando, texto = 'Cargando...') {
  if (cargando) {
    boton.dataset.texto = boton.textContent;
    boton.disabled = true;
    boton.innerHTML = `<span class="spinner" aria-hidden="true"></span>${texto}`;
  } else {
    boton.disabled = false;
    boton.textContent = boton.dataset.texto;
  }
}

function fechaDeHoy() {
  const txt = new Date().toLocaleDateString('es-BO', { weekday: 'long', day: 'numeric', month: 'long' });
  return txt.charAt(0).toLowerCase() + txt.slice(1);
}

function isoDeHoy() {
  const d = new Date();
  return `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, '0')}-${String(d.getDate()).padStart(2, '0')}`;
}

function valorRadio(form, nombre) {
  const marcado = form.querySelector(`input[name="${nombre}"]:checked`);
  return marcado ? marcado.value : '';
}

function servicioPorId(id) { return estado.servicios.find((s) => String(s.id) === String(id)); }
function bebidaPorId(id) { return estado.bebidas.find((b) => String(b.id) === String(id)); }
function citaPorId(id) { return estado.citas.find((c) => String(c.id) === String(id)); }

// ---------- Navegación entre vistas ----------
const VISTAS = {
  agenda:          { el: '#vista-agenda',          titulo: () => 'Agenda de hoy 🔥',   sub: fechaDeHoy },
  'cliente-nuevo':  { el: '#vista-cliente-nuevo',   titulo: () => 'Agregar una Cita',   sub: () => 'Rellene el formulario' },
  'horario-nuevo':  { el: '#vista-horario-nuevo',   titulo: () => 'Agregar una Cita',   sub: () => 'Rellene el formulario' },
  'cliente-editar': { el: '#vista-cliente-editar',  titulo: () => 'Editar cita',        sub: () => 'Rellene el formulario' },
  'horario-editar': { el: '#vista-horario-editar',  titulo: () => 'Editar Cita',        sub: () => 'Rellene el formulario' },
  atender:         { el: '#vista-atender',          titulo: () => 'Atendiendo al cliente', sub: fechaDeHoy },
  'consumo-nuevo':  { el: '#vista-consumo-nuevo',   titulo: () => 'Atendiendo al cliente', sub: fechaDeHoy },
  cobrar:          { el: '#vista-cobrar',           titulo: () => 'Atendiendo al cliente', sub: fechaDeHoy },
  servicios:       { el: '#vista-servicios',        titulo: () => 'Gestión de servicios', sub: () => 'Selecciona un servicio para editar o eliminar' },
  'servicio-editar':{ el: '#vista-servicio-editar', titulo: () => 'Gestión de servicios', sub: () => 'Rellene el formulario correctamente' },
  'servicio-nuevo': { el: '#vista-servicio-nuevo',  titulo: () => 'Agregar nuevo servicio', sub: () => 'Rellene los datos correctamente' },
  bebidas:         { el: '#vista-bebidas',          titulo: () => 'Inventario de bebidas', sub: () => 'Agregue o edite las bebidas' },
  'bebida-editar':  { el: '#vista-bebida-editar',   titulo: () => 'Editar bebida',       sub: fechaDeHoy },
  'bebida-nueva':   { el: '#vista-bebida-nueva',    titulo: () => 'Agregar bebida',      sub: () => 'Complete todos los datos' },
};

const NAV_POR_VISTA = { agenda: 'nav-overview', servicios: 'nav-servicios', bebidas: 'nav-bebidas' };

function mostrarVista(nombre) {
  Object.entries(VISTAS).forEach(([key, v]) => { $(v.el).hidden = key !== nombre; });
  $('#header-titulo').textContent = VISTAS[nombre].titulo();
  $('#header-sub').textContent = VISTAS[nombre].sub();

  $$('.nav__item').forEach((a) => { a.classList.remove('nav__item--activo'); a.removeAttribute('aria-current'); });
  const navId = NAV_POR_VISTA[nombre] || (nombre.startsWith('servicio') ? 'nav-servicios'
    : nombre.startsWith('bebida') ? 'nav-bebidas' : 'nav-overview');
  const navActivo = document.getElementById(navId);
  if (navActivo) { navActivo.classList.add('nav__item--activo'); navActivo.setAttribute('aria-current', 'page'); }

  window.scrollTo(0, 0);
}

function cerrarPopup() { $('#popup-cita').hidden = true; }

// =========================================================
// Carga de datos (SUPABASE)
// =========================================================
async function cargarServicios() {
  if (!db) { estado.servicios = []; return; }
  const { data, error } = await db.from('servicios').select('*').order('id');
  if (error) { console.error(error); estado.servicios = []; return; }
  estado.servicios = data;
}

async function cargarBebidas() {
  if (!db) { estado.bebidas = []; return; }
  const { data, error } = await db.from('bebidas').select('*').order('id');
  if (error) { console.error(error); estado.bebidas = []; return; }
  estado.bebidas = data;
}

async function cargarCitas() {
  if (!db) { estado.citas = []; return; }
  const { data, error } = await db
    .from('citas')
    .select('*, servicios(nombre, duracion, precio)')
    .eq('fecha', isoDeHoy())
    .neq('estado', 'cobrado')
    .order('hora');
  if (error) { console.error(error); estado.citas = []; return; }
  estado.citas = data;
}

async function cargarConsumoActual() {
  if (!db || !estado.citaId) { estado.consumoActual = []; return; }
  const { data, error } = await db
    .from('consumos')
    .select('*, bebidas(nombre, precio)')
    .eq('cita_id', estado.citaId);
  if (error) { console.error(error); estado.consumoActual = []; return; }
  estado.consumoActual = data;
}

// =========================================================
// Render — Agenda
// =========================================================
function renderCitas() {
  const lista = $('#lista-citas');
  lista.innerHTML = estado.citas.map((c) => `
    <li class="cita" data-cita="${c.id}">
      <span class="cita__avatar" aria-hidden="true">😊</span>
      <div>
        <p class="cita__nombre">${c.nombre}</p>
        <p class="cita__servicio">${c.servicios ? c.servicios.nombre : ''}</p>
        <p class="cita__hora">${c.hora}</p>
      </div>
    </li>`).join('');
  lista.hidden = estado.citas.length === 0;
  $('#agenda-vacia').hidden = estado.citas.length > 0;

  $$('#lista-citas .cita').forEach((li) => {
    li.addEventListener('click', () => abrirPopupCita(li.dataset.cita));
  });
}

function abrirPopupCita(citaId) {
  const cita = citaPorId(citaId);
  if (!cita) return;
  estado.citaId = citaId;

  $('#popup-nombre').textContent = cita.nombre;
  $('#popup-servicio-mini').textContent = cita.servicios ? cita.servicios.nombre : '';
  $('#popup-telefono').textContent = cita.telefono;
  $('#popup-servicio').textContent = cita.servicios ? cita.servicios.nombre : '';
  $('#popup-horario').textContent = cita.hora;
  $('#popup-cita').hidden = false;
}

// =========================================================
// Render — selección de servicio (tarjetas tipo radio)
// =========================================================
function renderServiciosOpciones(contenedorId, servicioIdSeleccionado) {
  $(contenedorId).innerHTML = estado.servicios.map((s) => `
    <div class="opcion">
      <input type="radio" name="servicio" id="${contenedorId.slice(1)}-srv-${s.id}" value="${s.id}"
        ${String(s.id) === String(servicioIdSeleccionado) ? 'checked' : ''}>
      <label for="${contenedorId.slice(1)}-srv-${s.id}" class="servicio">
        <span class="servicio__icono" aria-hidden="true">✂️</span>
        <span>
          <span class="servicio__nombre">${s.nombre}</span>
          <span class="servicio__duracion">${s.duracion}</span>
          <span class="servicio__precio">Bs. ${s.precio}</span>
        </span>
      </label>
    </div>`).join('');
}

// =========================================================
// Render — horarios disponibles
// =========================================================
function renderHoras(contenedorId, citaIdExcluida, horaSeleccionada) {
  const ocupadas = estado.citas
    .filter((c) => String(c.id) !== String(citaIdExcluida))
    .map((c) => c.hora);

  $(contenedorId).innerHTML = HORARIOS.map((h, i) => {
    const ocupada = ocupadas.includes(h);
    return `
    <div class="opcion">
      <input type="radio" name="horario" id="${contenedorId.slice(1)}-h-${i}" value="${h}"
        ${ocupada ? 'disabled' : ''} ${h === horaSeleccionada ? 'checked' : ''}>
      <label for="${contenedorId.slice(1)}-h-${i}" class="hora ${ocupada ? 'hora--ocupada' : ''}">${h}</label>
    </div>`;
  }).join('');
}

// =========================================================
// FLUJO 1: Agregar cita
// =========================================================
$('#btn-agregar').addEventListener('click', () => {
  estado.borradorCita = null;
  $('#form-cliente-nuevo').reset();
  $('#error-cliente-nuevo').hidden = true;
  renderServiciosOpciones('#nc-servicios', null);
  mostrarVista('cliente-nuevo');
});

$('#form-cliente-nuevo').addEventListener('submit', async (e) => {
  e.preventDefault();
  const form = e.target;
  const nombre = form.nombre.value.trim();
  const telefono = form.telefono.value.trim();
  const servicioId = valorRadio(form, 'servicio');

  if (!nombre || !telefono || !servicioId) {
    $('#error-cliente-nuevo').hidden = false;
    return;
  }
  $('#error-cliente-nuevo').hidden = true;

  estado.borradorCita = { nombre, telefono, servicioId };
  renderHoras('#nh-horas', null, null);
  $('#error-horario-nuevo').hidden = true;
  mostrarVista('horario-nuevo');
});

$('#form-horario-nuevo').addEventListener('submit', async (e) => {
  e.preventDefault();
  const hora = valorRadio(e.target, 'horario');
  if (!hora) { $('#error-horario-nuevo').hidden = false; return; }
  $('#error-horario-nuevo').hidden = true;

  const btn = $('#btn-horario-nuevo-guardar');
  setCargando(btn, true, 'Guardando...');
  try {
    const nuevaCita = {
      nombre: estado.borradorCita.nombre,
      telefono: estado.borradorCita.telefono,
      servicio_id: estado.borradorCita.servicioId,
      fecha: isoDeHoy(),
      hora,
      estado: 'pendiente',
    };
    if (!db) throw new Error('Supabase no está configurado todavía.');
    const { error } = await db.from('citas').insert(nuevaCita);
    if (error) throw error;

    await cargarCitas();
    renderCitas();
    estado.borradorCita = null;
    mostrarVista('agenda');
  } catch (err) {
    console.error(err);
  } finally {
    setCargando(btn, false);
  }
});

// =========================================================
// FLUJO 2: Editar cita
// =========================================================
$('#popup-btn-editar').addEventListener('click', () => {
  const cita = citaPorId(estado.citaId);
  if (!cita) return;
  cerrarPopup();

  $('#ec-nombre').value = cita.nombre;
  $('#ec-telefono').value = cita.telefono;
  renderServiciosOpciones('#ec-servicios', cita.servicio_id);
  $('#error-cliente-editar').hidden = true;
  mostrarVista('cliente-editar');
});

$('#form-cliente-editar').addEventListener('submit', async (e) => {
  e.preventDefault();
  const form = e.target;
  const nombre = form.nombre.value.trim();
  const telefono = form.telefono.value.trim();
  const servicioId = valorRadio(form, 'servicio');

  if (!nombre || !telefono || !servicioId) {
    $('#error-cliente-editar').hidden = false;
    return;
  }
  $('#error-cliente-editar').hidden = true;

  estado.borradorCita = { id: estado.citaId, nombre, telefono, servicioId };
  const cita = citaPorId(estado.citaId);
  renderHoras('#eh-horas', estado.citaId, cita ? cita.hora : null);
  $('#error-horario-editar').hidden = true;
  mostrarVista('horario-editar');
});

$('#btn-cita-eliminar').addEventListener('click', async () => {
  const btn = $('#btn-cita-eliminar');
  setCargando(btn, true, 'Eliminando...');
  try {
    if (!db) throw new Error('Supabase no está configurado todavía.');
    const { error } = await db.from('citas').delete().eq('id', estado.citaId);
    if (error) throw error;
    await cargarCitas();
    renderCitas();
    estado.citaId = null;
    mostrarVista('agenda');
  } catch (err) {
    console.error(err);
  } finally {
    setCargando(btn, false);
  }
});

$('#form-horario-editar').addEventListener('submit', async (e) => {
  e.preventDefault();
  const hora = valorRadio(e.target, 'horario');
  if (!hora) { $('#error-horario-editar').hidden = false; return; }
  $('#error-horario-editar').hidden = true;

  const btn = $('#btn-horario-editar-guardar');
  setCargando(btn, true, 'Guardando...');
  try {
    if (!db) throw new Error('Supabase no está configurado todavía.');
    const { error } = await db.from('citas').update({
      nombre: estado.borradorCita.nombre,
      telefono: estado.borradorCita.telefono,
      servicio_id: estado.borradorCita.servicioId,
      hora,
    }).eq('id', estado.borradorCita.id);
    if (error) throw error;

    await cargarCitas();
    renderCitas();
    estado.borradorCita = null;
    mostrarVista('agenda');
  } catch (err) {
    console.error(err);
  } finally {
    setCargando(btn, false);
  }
});

// =========================================================
// FLUJO 4: Atender cliente / consumo / cobrar
// =========================================================
async function abrirAtender() {
  const cita = citaPorId(estado.citaId);
  if (!cita) return;

  if (cita.estado !== 'atendiendo') {
    if (db) {
      const { error } = await db.from('citas').update({ estado: 'atendiendo' }).eq('id', cita.id);
      if (!error) cita.estado = 'atendiendo';
    }
  }

  $('#atender-avatar').textContent = '😊';
  $('#atender-nombre').textContent = cita.nombre;
  $('#atender-servicio').textContent = cita.servicios ? cita.servicios.nombre : '';
  $('#atender-hora').textContent = cita.hora;

  await cargarConsumoActual();
  renderConsumo('#atender-consumo-lista');
  $('#atender-consumo-titulo').hidden = estado.consumoActual.length === 0;
  $('#atender-consumo-vacio').hidden = estado.consumoActual.length > 0;

  mostrarVista('atender');
}

function renderConsumo(listaSelector) {
  $(listaSelector).innerHTML = estado.consumoActual.map((c) => `
    <li class="cita">
      <span class="cita__avatar" aria-hidden="true">🥤</span>
      <div>
        <p class="cita__nombre">${c.bebidas ? c.bebidas.nombre : ''}</p>
        <p class="cita__servicio">Bs. ${c.precio_unitario}</p>
      </div>
    </li>`).join('');
}

$('#popup-btn-atender').addEventListener('click', () => { cerrarPopup(); abrirAtender(); });

$('#btn-atender-agregar-consumo').addEventListener('click', () => {
  $('#error-consumo-nuevo').hidden = true;
  $('#lista-bebidas-disponibles').innerHTML = estado.bebidas.map((b) => `
    <div class="opcion">
      <input type="checkbox" name="bebidas" id="cb-bebida-${b.id}" value="${b.id}" ${b.cantidad <= 0 ? 'disabled' : ''}>
      <label for="cb-bebida-${b.id}" class="servicio ${b.cantidad <= 0 ? 'hora--ocupada' : ''}">
        <span class="servicio__icono" aria-hidden="true">🥤</span>
        <span>
          <span class="servicio__nombre">${b.nombre}</span>
          <span class="servicio__duracion">Bs. ${b.precio}</span>
        </span>
      </label>
    </div>`).join('');
  mostrarVista('consumo-nuevo');
});

$('#form-consumo-nuevo').addEventListener('submit', async (e) => {
  e.preventDefault();
  const seleccionadas = $$('#lista-bebidas-disponibles input[name="bebidas"]:checked').map((i) => i.value);
  if (seleccionadas.length === 0) { $('#error-consumo-nuevo').hidden = false; return; }
  $('#error-consumo-nuevo').hidden = true;

  const btn = $('#btn-consumo-guardar');
  setCargando(btn, true, 'Agregando...');
  try {
    if (!db) throw new Error('Supabase no está configurado todavía.');
    const filas = seleccionadas.map((id) => ({
      cita_id: estado.citaId,
      bebida_id: id,
      precio_unitario: bebidaPorId(id).precio,
    }));
    const { error } = await db.from('consumos').insert(filas);
    if (error) throw error;

    for (const id of seleccionadas) {
      const bebida = bebidaPorId(id);
      await db.from('bebidas').update({ cantidad: bebida.cantidad - 1 }).eq('id', id);
    }
    await cargarBebidas();
    await cargarConsumoActual();
    renderConsumo('#atender-consumo-lista');
    $('#atender-consumo-titulo').hidden = estado.consumoActual.length === 0;
    $('#atender-consumo-vacio').hidden = estado.consumoActual.length > 0;
    mostrarVista('atender');
  } catch (err) {
    console.error(err);
  } finally {
    setCargando(btn, false);
  }
});

$('#btn-atender-cobrar').addEventListener('click', () => {
  const cita = citaPorId(estado.citaId);
  const filas = [...estado.consumoActual.map((c) => ({
    nombre: c.bebidas ? c.bebidas.nombre : '',
    precio: Number(c.precio_unitario),
    icono: '🥤',
  }))];
  if (cita && cita.servicios) {
    filas.push({ nombre: cita.servicios.nombre, precio: Number(cita.servicios.precio), icono: '✂️' });
  }

  $('#lista-cobrar').innerHTML = filas.map((f) => `
    <li class="cita">
      <span class="cita__avatar" aria-hidden="true">${f.icono}</span>
      <div>
        <p class="cita__nombre">${f.nombre}</p>
        <p class="cita__servicio">Bs. ${f.precio}</p>
      </div>
    </li>`).join('');

  const total = filas.reduce((acc, f) => acc + f.precio, 0);
  $('#cobrar-total').textContent = total;

  mostrarVista('cobrar');
});

$('#btn-cobrar-confirmar').addEventListener('click', async () => {
  const btn = $('#btn-cobrar-confirmar');
  setCargando(btn, true, 'Cobrando...');
  try {
    if (!db) throw new Error('Supabase no está configurado todavía.');
    const { error } = await db.from('citas').update({ estado: 'cobrado' }).eq('id', estado.citaId);
    if (error) throw error;

    await cargarCitas();
    renderCitas();
    estado.citaId = null;
    estado.consumoActual = [];
    mostrarVista('agenda');
  } catch (err) {
    console.error(err);
  } finally {
    setCargando(btn, false);
  }
});

// =========================================================
// FLUJO 3: Gestión de servicios
// =========================================================
function renderServiciosAdmin() {
  const lista = $('#lista-servicios-admin');
  lista.innerHTML = estado.servicios.map((s) => `
    <li class="opcion">
      <button type="button" class="servicio" data-servicio="${s.id}">
        <span class="servicio__icono" aria-hidden="true">✂️</span>
        <span>
          <span class="servicio__nombre">${s.nombre}</span>
          <span class="servicio__duracion">${s.duracion}</span>
          <span class="servicio__precio">Bs. ${s.precio}</span>
        </span>
      </button>
    </li>`).join('');
  lista.hidden = estado.servicios.length === 0;
  $('#servicios-vacio').hidden = estado.servicios.length > 0;

  $$('#lista-servicios-admin [data-servicio]').forEach((b) => {
    b.addEventListener('click', () => abrirServicioEditar(b.dataset.servicio));
  });
}

function abrirServicioEditar(servicioId) {
  const s = servicioPorId(servicioId);
  if (!s) return;
  estado.servicioId = servicioId;

  $('#se-preview-nombre').textContent = s.nombre;
  $('#se-preview-duracion').textContent = s.duracion;
  $('#se-preview-precio').textContent = `Bs. ${s.precio}`;
  $('#se-nombre').value = s.nombre;
  $('#se-tiempo').value = s.duracion;
  $('#se-precio').value = s.precio;
  $('#error-servicio-editar').hidden = true;

  mostrarVista('servicio-editar');
}

$('#nav-servicios').addEventListener('click', (e) => { e.preventDefault(); renderServiciosAdmin(); mostrarVista('servicios'); });

$('#btn-servicio-agregar').addEventListener('click', () => {
  $('#form-servicio-nuevo').reset();
  $('#error-servicio-nuevo').hidden = true;
  mostrarVista('servicio-nuevo');
});

$('#form-servicio-nuevo').addEventListener('submit', async (e) => {
  e.preventDefault();
  const form = e.target;
  const nombre = form.nombre.value.trim();
  const tiempo = form.tiempo.value.trim();
  const precio = form.precio.value;

  if (!nombre || !tiempo || !precio) { $('#error-servicio-nuevo').hidden = false; return; }
  $('#error-servicio-nuevo').hidden = true;

  const btn = $('#btn-servicio-nuevo-guardar');
  setCargando(btn, true, 'Agregando...');
  try {
    if (!db) throw new Error('Supabase no está configurado todavía.');
    const { error } = await db.from('servicios').insert({ nombre, duracion: tiempo, precio: Number(precio) });
    if (error) throw error;

    await cargarServicios();
    renderServiciosAdmin();
    mostrarVista('servicios');
  } catch (err) {
    console.error(err);
  } finally {
    setCargando(btn, false);
  }
});

$('#form-servicio-editar').addEventListener('submit', async (e) => {
  e.preventDefault();
  const form = e.target;
  const nombre = form.nombre.value.trim();
  const tiempo = form.tiempo.value.trim();
  const precio = form.precio.value;

  if (!nombre || !tiempo || !precio) { $('#error-servicio-editar').hidden = false; return; }
  $('#error-servicio-editar').hidden = true;

  const btn = $('#btn-servicio-editar-guardar');
  setCargando(btn, true, 'Guardando...');
  try {
    if (!db) throw new Error('Supabase no está configurado todavía.');
    const { error } = await db.from('servicios')
      .update({ nombre, duracion: tiempo, precio: Number(precio) })
      .eq('id', estado.servicioId);
    if (error) throw error;

    await cargarServicios();
    renderServiciosAdmin();
    mostrarVista('servicios');
  } catch (err) {
    console.error(err);
  } finally {
    setCargando(btn, false);
  }
});

$('#btn-servicio-eliminar').addEventListener('click', async () => {
  const btn = $('#btn-servicio-eliminar');
  setCargando(btn, true, 'Eliminando...');
  try {
    if (!db) throw new Error('Supabase no está configurado todavía.');
    const { error } = await db.from('servicios').delete().eq('id', estado.servicioId);
    if (error) throw error;

    await cargarServicios();
    renderServiciosAdmin();
    mostrarVista('servicios');
  } catch (err) {
    console.error(err);
  } finally {
    setCargando(btn, false);
  }
});

// =========================================================
// FLUJO 5: Inventario de bebidas
// =========================================================
function renderBebidasAdmin() {
  const lista = $('#lista-bebidas-admin');
  lista.innerHTML = estado.bebidas.map((b) => `
    <li class="opcion">
      <button type="button" class="servicio" data-bebida="${b.id}">
        <span class="servicio__icono" aria-hidden="true">🥤</span>
        <span>
          <span class="servicio__nombre">${b.nombre}</span>
          <span class="servicio__duracion">cantidad: ${b.cantidad}</span>
          <span class="servicio__precio">Bs. ${b.precio}</span>
        </span>
      </button>
    </li>`).join('');
  lista.hidden = estado.bebidas.length === 0;
  $('#bebidas-vacio').hidden = estado.bebidas.length > 0;

  $$('#lista-bebidas-admin [data-bebida]').forEach((b) => {
    b.addEventListener('click', () => abrirBebidaEditar(b.dataset.bebida));
  });
}

function abrirBebidaEditar(bebidaId) {
  const b = bebidaPorId(bebidaId);
  if (!b) return;
  estado.bebidaId = bebidaId;

  $('#be-preview-nombre').textContent = b.nombre;
  $('#be-preview-cantidad').textContent = `cantidad: ${b.cantidad}`;
  $('#be-preview-precio').textContent = `Bs. ${b.precio}`;
  $('#be-nombre').value = b.nombre;
  $('#be-precio').value = b.precio;
  $('#be-cantidad-extra').value = '';
  $('#error-bebida-editar').hidden = true;

  mostrarVista('bebida-editar');
}

$('#nav-bebidas').addEventListener('click', (e) => { e.preventDefault(); renderBebidasAdmin(); mostrarVista('bebidas'); });

$('#btn-bebida-agregar').addEventListener('click', () => {
  $('#form-bebida-nueva').reset();
  $('#error-bebida-nueva').hidden = true;
  mostrarVista('bebida-nueva');
});

$('#form-bebida-nueva').addEventListener('submit', async (e) => {
  e.preventDefault();
  const form = e.target;
  const nombre = form.nombre.value.trim();
  const precio = form.precio.value;
  const cantidad = form.cantidad.value;

  if (!nombre || !precio || !cantidad) { $('#error-bebida-nueva').hidden = false; return; }
  $('#error-bebida-nueva').hidden = true;

  const btn = $('#btn-bebida-nueva-guardar');
  setCargando(btn, true, 'Agregando...');
  try {
    if (!db) throw new Error('Supabase no está configurado todavía.');
    const { error } = await db.from('bebidas').insert({ nombre, precio: Number(precio), cantidad: Number(cantidad) });
    if (error) throw error;

    await cargarBebidas();
    renderBebidasAdmin();
    mostrarVista('bebidas');
  } catch (err) {
    console.error(err);
  } finally {
    setCargando(btn, false);
  }
});

$('#form-bebida-editar').addEventListener('submit', async (e) => {
  e.preventDefault();
  const form = e.target;
  const nombre = form.nombre.value.trim();
  const precio = form.precio.value;
  const extra = Number(form.cantidadExtra.value || 0);

  if (!nombre || !precio) { $('#error-bebida-editar').hidden = false; return; }
  $('#error-bebida-editar').hidden = true;

  const btn = $('#btn-bebida-editar-guardar');
  setCargando(btn, true, 'Guardando...');
  try {
    if (!db) throw new Error('Supabase no está configurado todavía.');
    const bebida = bebidaPorId(estado.bebidaId);
    const { error } = await db.from('bebidas')
      .update({ nombre, precio: Number(precio), cantidad: bebida.cantidad + extra })
      .eq('id', estado.bebidaId);
    if (error) throw error;

    await cargarBebidas();
    renderBebidasAdmin();
    mostrarVista('bebidas');
  } catch (err) {
    console.error(err);
  } finally {
    setCargando(btn, false);
  }
});

$('#btn-bebida-eliminar').addEventListener('click', async () => {
  const btn = $('#btn-bebida-eliminar');
  setCargando(btn, true, 'Eliminando...');
  try {
    if (!db) throw new Error('Supabase no está configurado todavía.');
    const { error } = await db.from('bebidas').delete().eq('id', estado.bebidaId);
    if (error) throw error;

    await cargarBebidas();
    renderBebidasAdmin();
    mostrarVista('bebidas');
  } catch (err) {
    console.error(err);
  } finally {
    setCargando(btn, false);
  }
});

// =========================================================
// Navegación general (overview, cancelar, cerrar popup)
// =========================================================
$('#nav-overview').addEventListener('click', (e) => { e.preventDefault(); mostrarVista('agenda'); });

$$('[data-cancelar]').forEach((b) => {
  b.addEventListener('click', () => {
    const destino = b.dataset.cancelar;
    if (destino === 'agenda') { estado.borradorCita = null; estado.citaId = null; }
    mostrarVista(destino);
  });
});

$('[data-cerrar-popup]').addEventListener('click', cerrarPopup);
document.addEventListener('keydown', (e) => { if (e.key === 'Escape') cerrarPopup(); });

// ---------- Inicio ----------
async function iniciar() {
  await Promise.all([cargarServicios(), cargarBebidas(), cargarCitas()]);
  renderCitas();
  mostrarVista('agenda');
}
iniciar();
