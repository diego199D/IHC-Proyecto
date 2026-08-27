
## Persona v0.1

- **Usuario:** Administrador de citas de la barbería (el encargado que hoy organiza todo por WhatsApp).
- **Contexto:** Recibe mensajes de clientes por WhatsApp para pedir turno, y tiene que cruzar eso a mano con horarios disponibles, servicios y precios. Se le mezclan chats, se le olvidan citas y no tiene una vista clara del día.
- **Objetivo:** Agendar y organizar las citas de la barbería desde una sola app móvil, sin depender del caos del chat.
- **Dificultad:** Gestionar disponibilidad de horarios, tipos de servicio y precios manualmente, con alto riesgo de errores (choques de horario, olvidos, doble reserva).
- **Necesidad:** Una app móvil donde pueda ver, crear, modificar y confirmar citas de forma rápida y ordenada.

---

## App map v0.1

- **App del Administrador (móvil)** → parte principal del alcance de este proyecto.
  - Agenda de citas → ver citas del día / semana.
  - Gestión de servicios → tipos de servicio y precios.
  - Gestión de horarios → disponibilidad y bloqueos.
  - Confirmación de citas → aceptar / reprogramar / cancelar.
- **App del Cliente (móvil)** → existe pero **no** forma parte del alcance a evaluar.
  - Chat con el administrador → reemplaza al WhatsApp actual.
  - (No se profundiza en esta app: el foco de la persona es el administrador).

---

## Flujo v0.1 (camino normal de una sola tarea)

**Tarea: agendar una cita nueva**

Administrador abre la app → entra a "Nueva cita" → selecciona cliente / servicio → revisa horarios disponibles → elige un horario libre → confirma la cita → la cita queda guardada en la agenda del día

---

## Salida

Primera versión de los tres artefactos (Persona, App map, Flujo) para el Gestor de Citas de la barbería, enfocados en el administrador de citas como usuario principal.




# Segundo Flujo (cancelacion de citas)
## Persona v0.2

- **Usuario:** Administrador de citas de la barbería (el encargado que hoy organiza todo por WhatsApp).
- **Contexto:** Un cliente le avisa por WhatsApp que ya no puede asistir a su cita, o el administrador necesita liberar un horario por algún imprevisto. Hoy tiene que buscar el chat, borrar la cita a mano de donde la haya anotado, y a veces se le olvida liberar el horario, generando choques cuando alguien más quiere agendar esa misma franja.
- **Objetivo:** Cancelar una cita ya agendada de forma rápida y segura, liberando automáticamente ese horario para que vuelva a estar disponible.
- **Dificultad:** Ubicar rápido cuál cita corresponde cancelar entre varias del mismo día, evitar cancelar la equivocada por error, y asegurarse de que el horario liberado quede visible de inmediato para nuevas reservas.
- **Necesidad:** Una pantalla donde pueda ver las citas activas, seleccionar la que quiere cancelar, confirmar antes de eliminarla (para evitar cancelaciones accidentales), y que el sistema libere el horario automáticamente.


## App map v0.2

- **App del Administrador (móvil)** → parte principal del alcance de este proyecto.
  - Agenda de citas → ver citas activas del día / semana.
  - Cancelar cita → listar citas activas y elegir cuál cancelar.
    - Diálogo de confirmación ("¿Desea cancelar esta cita?") → evita cancelaciones accidentales.
  - Gestión de horarios → el horario cancelado vuelve a quedar disponible.
- **App del Cliente (móvil)** → existe pero **no** forma parte del alcance a evaluar.
  - Chat con el administrador → reemplaza al WhatsApp actual.
  - (No se profundiza en esta app: el foco de la persona es el administrador).


## Flujo v0.2 (camino normal de una sola tarea)

**Tarea: cancelar una cita existente**

Administrador abre la app → entra a "Cancelar cita" → ve la lista de citas activas → selecciona la cita que desea cancelar → aparece un diálogo de confirmación ("¿Desea Cancelar esta Cita?") → confirma con "SI" → la cita se marca como cancelada y el horario queda libre en la agenda


## Salida

Primera versión de los tres artefactos (Persona, App map, Flujo) para el flujo de **Cancelación de Citas** del Gestor de Citas de la barbería, enfocados en el administrador de citas como usuario principal.