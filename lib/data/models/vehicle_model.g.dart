// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vehicle_model.dart';

// ***************************************************************************
// TypeAdapterGenerator
// ***************************************************************************

class VehicleModelAdapter extends TypeAdapter<VehicleModel> {
  @override
  final int typeId = 1;

  @override
  VehicleModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return VehicleModel(
      brand: fields[3] as String,
      model: fields[4] as String,
      year: fields[5] as int,
      purchaseCost: fields[6] as double,
      currentKm: fields[0] as int,
      lastUpdate: fields[1] as DateTime,
      dailyKmAverage: fields[2] as double,
    );
  }

  @override
  void write(BinaryWriter writer, VehicleModel obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.currentKm)
      ..writeByte(1)
      ..write(obj.lastUpdate)
      ..writeByte(2)
      ..write(obj.dailyKmAverage)
      ..writeByte(3)
      ..write(obj.brand)
      ..writeByte(4)
      ..write(obj.model)
      ..writeByte(5)
      ..write(obj.year)
      ..writeByte(6)
      ..write(obj.purchaseCost);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VehicleModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
