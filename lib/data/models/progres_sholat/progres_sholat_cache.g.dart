// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'progres_sholat_cache.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ProgresSholatCacheAdapter extends TypeAdapter<ProgresSholatCache> {
  @override
  final int typeId = 10;

  @override
  ProgresSholatCache read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ProgresSholatCache(
      id: fields[0] as int,
      userId: fields[1] as int,
      jenis: fields[2] as String,
      sholat: fields[3] as String,
      isOnTime: fields[4] as bool,
      isJamaah: fields[5] as bool,
      lokasi: fields[6] as String,
      createdAt: fields[7] as DateTime,
      updatedAt: fields[8] as DateTime,
      cachedAt: fields[9] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, ProgresSholatCache obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.userId)
      ..writeByte(2)
      ..write(obj.jenis)
      ..writeByte(3)
      ..write(obj.sholat)
      ..writeByte(4)
      ..write(obj.isOnTime)
      ..writeByte(5)
      ..write(obj.isJamaah)
      ..writeByte(6)
      ..write(obj.lokasi)
      ..writeByte(7)
      ..write(obj.createdAt)
      ..writeByte(8)
      ..write(obj.updatedAt)
      ..writeByte(9)
      ..write(obj.cachedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProgresSholatCacheAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
