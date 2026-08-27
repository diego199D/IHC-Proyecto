# Gestor de Citas — Flutter + SQLite local

App móvil que replica el prototipo: Inicio, Agregar Cita (cliente → servicio → horario)
y Cancelar Cita (con diálogo de confirmación). Persistencia 100% local con `sqflite`.

## Cómo instalarlo en tu proyecto

1. Crea el proyecto (si no lo tienes ya):
   ```
   flutter create gestor_citas
   ```
2. Copia el archivo `pubspec.yaml` de aquí, reemplazando el tuyo (o solo agrega
   las dependencias `sqflite`, `path` e `intl` a tu `pubspec.yaml` existente).
3. Copia toda la carpeta `lib/` de aquí dentro de tu proyecto, reemplazando el
   `lib/main.dart` que trae Flutter por defecto.
4. Instala dependencias:
   ```
   flutter pub get
   ```
5. Corre la app:
   ```
   flutter run
   ```
   (con un emulador Android/iOS abierto, o dispositivo físico conectado)

## Estructura

```
lib/
  main.dart                              punto de entrada
  theme/app_theme.dart                   colores y estilos (igual al prototipo)
  models/                                Cliente, Servicio, Cita
  db/database_helper.dart                SQLite local (sqflite) + datos semilla
  widgets/tarjeta_cita.dart              tarjeta reutilizable de cita
  screens/
    home_screen.dart                     INICIO (pantalla 1)
    agregar_cita_cliente_screen.dart     AGREGAR CITA - paso 1 (pantalla 2)
    agregar_cita_servicio_screen.dart    AGREGAR CITA - paso 2 (pantalla 3)
    agregar_cita_horario_screen.dart     AGREGAR CITA - paso 3 (pantalla 4)
    cancelar_cita_screen.dart            Cancelar cita + diálogo SI/NO (pantallas 5-7)
```

## Notas

- La base de datos se crea sola la primera vez que corres la app (`onCreate`),
  con clientes y servicios de ejemplo ya cargados (los mismos del prototipo).
- Para reiniciar los datos durante pruebas: desinstala la app del emulador o
  borra sus datos (Ajustes > Apps > gestor_citas > Borrar datos), porque el
  archivo `.db` vive en el almacenamiento del dispositivo/emulador.
- Agregué un ícono en la barra superior de INICIO (📅❌) para entrar a
  "Cancelar cita", ya que el prototipo no mostraba explícitamente ese botón.
- Si quieres que el diseño quede pixel-perfect (fuentes exactas, sombras,
  spacing), lo ajustamos entre los dos una vez que lo veas corriendo en tu
  emulador — es más fácil afinar viendo la app real que a ciegas.
