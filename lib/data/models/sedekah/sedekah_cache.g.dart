// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sedekah_cache.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SedekahCacheAdapter extends TypeAdapter<SedekahCache> {
  @override
  final int typeId = 8;

  @override
  SedekahCache read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SedekahCache(
      id: fields[0] as int,
      userId: fields[1] as int,
      jenisSedekah: fields[2] as String,
      tanggal: fields[3] as DateTime,
      jumlah: fields[4] as int,
      keterangan: fields[5] as String?,
      createdAt: fields[6] as DateTime,
      updatedAt: fields[7] as DateTime,
      cachedAt: fields[8] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, SedekahCache obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.userId)
      ..writeByte(2)
      ..write(obj.jenisSedekah)
      ..writeByte(3)
      ..write(obj.tanggal)
      ..writeByte(4)
      ..write(obj.jumlah)
      ..writeByte(5)
      ..write(obj.keterangan)
      ..writeByte(6)
      ..write(obj.createdAt)
      ..writeByte(7)
      ..write(obj.updatedAt)
      ..writeByte(8)
      ..write(obj.cachedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SedekahCacheAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class StatistikSedekahCacheAdapter extends TypeAdapter<StatistikSedekahCache> {
  @override
  final int typeId = 9;

  @override
  StatistikSedekahCache read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return StatistikSedekahCache(
      totalHariIni: fields[0] as int,
      totalBulanIni: fields[1] as int,
      riwayat: (fields[2] as List).cast<SedekahCache>(),
      cachedAt: fields[3] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, StatistikSedekahCache obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.totalHariIni)
      ..writeByte(1)
      ..write(obj.totalBulanIni)
      ..writeByte(2)
      ..write(obj.riwayat)
      ..writeByte(3)
      ..write(obj.cachedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StatistikSedekahCacheAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
