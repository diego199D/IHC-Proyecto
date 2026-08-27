class Cita {
  final int? id;
  final int clienteId;
  final String clienteNombre;
  final String servicios; // nombres de servicios separados por coma
  final String horario; // ej: "9:00 AM - 10:00 AM"
  final String estado; // 'activa' | 'cancelada'

  Cita({
    this.id,
    required this.clienteId,
    required this.clienteNombre,
    required this.servicios,
    required this.horario,
    this.estado = 'activa',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'clienteId': clienteId,
      'clienteNombre': clienteNombre,
      'servicios': servicios,
      'horario': horario,
      'estado': estado,
    };
  }

  factory Cita.fromMap(Map<String, dynamic> map) {
    return Cita(
      id: map['id'] as int?,
      clienteId: map['clienteId'] as int,
      clienteNombre: map['clienteNombre'] as String,
      servicios: map['servicios'] as String,
      horario: map['horario'] as String,
      estado: map['estado'] as String,
    );
  }
}
