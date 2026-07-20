import '../utils/app_constants.dart';

class FacilityModel {
  final int facilityId;
  final String facilityName;
  final String facilityType;
  final String? phone;
  final String? workingHours;
  final String? sector;
  final String? neighborhood;
  final String? street;
  final String? landmark;
  final double? latitude;
  final double? longitude;
  final List<String> services;
  final List<String> specialties;

  const FacilityModel({
    required this.facilityId,
    required this.facilityName,
    required this.facilityType,
    this.phone,
    this.workingHours,
    this.sector,
    this.neighborhood,
    this.street,
    this.landmark,
    this.latitude,
    this.longitude,
    this.services = const [],
    this.specialties = const [],
  });

  String get imagePath => AppAssets.getFacilityImageById(facilityId);

  String get addressLine {
    final parts = <String>[];
    if (neighborhood != null && neighborhood!.isNotEmpty) {
      parts.add(neighborhood!);
    }
    if (street != null && street!.isNotEmpty) {
      parts.add(street!);
    }
    if (landmark != null && landmark!.isNotEmpty) {
      parts.add(landmark!);
    }
    return parts.join(' - ');
  }

  factory FacilityModel.fromMap(Map<String, dynamic> map) {
    final rawId = map['facility_id'];
    if (rawId == null) {
      throw FormatException('facility_id مفقود في صف المنشأة: $map');
    }
    return FacilityModel(
      facilityId: rawId as int,
      facilityName: map['facility_name'] ?? '',
      facilityType: map['facility_type'] ?? '',
      phone: map['phone']?.toString(),
      workingHours: map['working_hours']?.toString(),
      sector: map['sector']?.toString(),
      neighborhood: map['neighborhood']?.toString(),
      street: map['street']?.toString(),
      landmark: map['landmark']?.toString(),
      latitude: (map['latitude'] as num?)?.toDouble(),
      longitude: (map['longitude'] as num?)?.toDouble(),
    );
  }

  FacilityModel copyWith({List<String>? services, List<String>? specialties}) {
    return FacilityModel(
      facilityId: facilityId,
      facilityName: facilityName,
      facilityType: facilityType,
      phone: phone,
      workingHours: workingHours,
      sector: sector,
      neighborhood: neighborhood,
      street: street,
      landmark: landmark,
      latitude: latitude,
      longitude: longitude,
      services: services ?? this.services,
      specialties: specialties ?? this.specialties,
    );
  }
}
