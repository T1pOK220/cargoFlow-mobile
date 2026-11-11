enum VehicleStatus {
  available,
  inTransit;

  String get dbValue {
    switch (this) {
      case VehicleStatus.available:
        return 'Доступний';
      case VehicleStatus.inTransit:
        return 'В дорозі';
    }
  }

  static VehicleStatus fromString(String value) {
    switch (value) {
      case 'Доступний':
        return VehicleStatus.available;
      case 'В дорозі':
        return VehicleStatus.inTransit;
      default:
        throw Exception('Невідомий статус: $value');
    }
  }
}
