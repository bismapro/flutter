// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'progres_puasa_cache.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ProgresPuasaWajibCacheAdapter
    extends TypeAdapter<ProgresPuasaWajibCache> {
  @override
  final int typeId = 18;

  @override
  ProgresPuasaWajibCache read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ProgresPuasaWajibCache(
      id: fields[0] as int,
      userId: fields[1] as int,
      jenis: fields[2] as String,
      tahunHijriah: fields[3] as int,
      createdAt: fields[4] as DateTime,
      updatedAt: fields[5] as DateTime,
      cachedAt: fields[6] as DateTime,
      tanggalRamadhan: fields[7] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, ProgresPuasaWajibCache obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.userId)
      ..writeByte(2)
      ..write(obj.jenis)
      ..writeByte(3)
      ..write(obj.tahunHijriah)
      ..writeByte(4)
      ..write(obj.createdAt)
      ..writeByte(5)
      ..write(obj.updatedAt)
      ..writeByte(6)
      ..write(obj.cachedAt)
      ..writeByte(7)
      ..write(obj.tanggalRamadhan);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProgresPuasaWajibCacheAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ProgresPuasaSunnahCacheAdapter
    extends TypeAdapter<ProgresPuasaSunnahCache> {
  @override
  final int typeId = 21;

  @override
  ProgresPuasaSunnahCache read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ProgresPuasaSunnahCache(
      id: fields[0] as int,
      userId: fields[1] as int,
      jenis: fields[2] as String,
      tahunHijriah: fields[3] as int,
      createdAt: fields[4] as DateTime,
      updatedAt: fields[5] as DateTime,
      cachedAt: fields[6] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, ProgresPuasaSunnahCache obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.userId)
      ..writeByte(2)
      ..write(obj.jenis)
      ..writeByte(3)
      ..write(obj.tahunHijriah)
      ..writeByte(4)
      ..write(obj.createdAt)
      ..writeByte(5)
      ..write(obj.updatedAt)
      ..writeByte(6)
      ..write(obj.cachedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProgresPuasaSunnahCacheAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ProgresPuasaWajibTahunIniCacheAdapter
    extends TypeAdapter<ProgresPuasaWajibTahunIniCache> {
  @override
  final int typeId = 19;

  @override
  ProgresPuasaWajibTahunIniCache read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ProgresPuasaWajibTahunIniCache(
      total: fields[0] as int,
      detailJson: fields[1] as String,
      cachedAt: fields[2] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, ProgresPuasaWajibTahunIniCache obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.total)
      ..writeByte(1)
      ..write(obj.detailJson)
      ..writeByte(2)
      ..write(obj.cachedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProgresPuasaWajibTahunIniCacheAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class RiwayatPuasaWajibCacheAdapter
    extends TypeAdapter<RiwayatPuasaWajibCache> {
  @override
  final int typeId = 20;

  @override
  RiwayatPuasaWajibCache read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return RiwayatPuasaWajibCache(
      tahun: fields[0] as int,
      data: (fields[1] as List).cast<ProgresPuasaWajibCache>(),
      cachedAt: fields[2] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, RiwayatPuasaWajibCache obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.tahun)
      ..writeByte(1)
      ..write(obj.data)
      ..writeByte(2)
      ..write(obj.cachedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RiwayatPuasaWajibCacheAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ProgresPuasaSunnahTahunIniCacheAdapter
    extends TypeAdapter<ProgresPuasaSunnahTahunIniCache> {
  @override
  final int typeId = 22;

  @override
  ProgresPuasaSunnahTahunIniCache read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ProgresPuasaSunnahTahunIniCache(
      total: fields[0] as int,
      detail: (fields[1] as List).cast<ProgresPuasaSunnahCache>(),
      cachedAt: fields[2] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, ProgresPuasaSunnahTahunIniCache obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.total)
      ..writeByte(1)
      ..write(obj.detail)
      ..writeByte(2)
      ..write(obj.cachedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProgresPuasaSunnahTahunIniCacheAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class RiwayatPuasaSunnahCacheAdapter
    extends TypeAdapter<RiwayatPuasaSunnahCache> {
  @override
  final int typeId = 23;

  @override
  RiwayatPuasaSunnahCache read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return RiwayatPuasaSunnahCache(
      total: fields[0] as int,
      detail: (fields[1] as List).cast<ProgresPuasaSunnahCache>(),
      cachedAt: fields[2] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, RiwayatPuasaSunnahCache obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.total)
      ..writeByte(1)
      ..write(obj.detail)
      ..writeByte(2)
      ..write(obj.cachedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RiwayatPuasaSunnahCacheAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
