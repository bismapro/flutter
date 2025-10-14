// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'progres_sholat_cache.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ProgresSholatCacheAdapter extends TypeAdapter<ProgresSholatCache> {
  @override
  final int typeId = 12;

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

class StatistikSholatWajibCacheAdapter
    extends TypeAdapter<StatistikSholatWajibCache> {
  @override
  final int typeId = 17;

  @override
  StatistikSholatWajibCache read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return StatistikSholatWajibCache(
      subuh: fields[0] as bool,
      dzuhur: fields[1] as bool,
      ashar: fields[2] as bool,
      maghrib: fields[3] as bool,
      isya: fields[4] as bool,
      cachedAt: fields[5] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, StatistikSholatWajibCache obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.subuh)
      ..writeByte(1)
      ..write(obj.dzuhur)
      ..writeByte(2)
      ..write(obj.ashar)
      ..writeByte(3)
      ..write(obj.maghrib)
      ..writeByte(4)
      ..write(obj.isya)
      ..writeByte(5)
      ..write(obj.cachedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StatistikSholatWajibCacheAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ProgresSholatWajibCacheAdapter
    extends TypeAdapter<ProgresSholatWajibCache> {
  @override
  final int typeId = 15;

  @override
  ProgresSholatWajibCache read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ProgresSholatWajibCache(
      total: fields[0] as int,
      statistik: fields[1] as StatistikSholatWajibCache,
      detail: (fields[2] as List).cast<ProgresSholatCache>(),
      cachedAt: fields[3] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, ProgresSholatWajibCache obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.total)
      ..writeByte(1)
      ..write(obj.statistik)
      ..writeByte(2)
      ..write(obj.detail)
      ..writeByte(3)
      ..write(obj.cachedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProgresSholatWajibCacheAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class StatistikSholatSunnahCacheAdapter
    extends TypeAdapter<StatistikSholatSunnahCache> {
  @override
  final int typeId = 18;

  @override
  StatistikSholatSunnahCache read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return StatistikSholatSunnahCache(
      tahajud: fields[0] as bool,
      witir: fields[1] as bool,
      dhuha: fields[2] as bool,
      qabliyahSubuh: fields[3] as bool,
      qabliyahDzuhur: fields[4] as bool,
      baDiyahDzuhur: fields[5] as bool,
      qabliyahAshar: fields[6] as bool,
      baDiyahMaghrib: fields[7] as bool,
      qabliyahIsya: fields[8] as bool,
      baDiyahIsya: fields[9] as bool,
      cachedAt: fields[10] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, StatistikSholatSunnahCache obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.tahajud)
      ..writeByte(1)
      ..write(obj.witir)
      ..writeByte(2)
      ..write(obj.dhuha)
      ..writeByte(3)
      ..write(obj.qabliyahSubuh)
      ..writeByte(4)
      ..write(obj.qabliyahDzuhur)
      ..writeByte(5)
      ..write(obj.baDiyahDzuhur)
      ..writeByte(6)
      ..write(obj.qabliyahAshar)
      ..writeByte(7)
      ..write(obj.baDiyahMaghrib)
      ..writeByte(8)
      ..write(obj.qabliyahIsya)
      ..writeByte(9)
      ..write(obj.baDiyahIsya)
      ..writeByte(10)
      ..write(obj.cachedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StatistikSholatSunnahCacheAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ProgresSholatSunnahCacheAdapter
    extends TypeAdapter<ProgresSholatSunnahCache> {
  @override
  final int typeId = 16;

  @override
  ProgresSholatSunnahCache read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ProgresSholatSunnahCache(
      total: fields[0] as int,
      statistik: fields[1] as StatistikSholatSunnahCache,
      detail: (fields[2] as List).cast<ProgresSholatCache>(),
      cachedAt: fields[3] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, ProgresSholatSunnahCache obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.total)
      ..writeByte(1)
      ..write(obj.statistik)
      ..writeByte(2)
      ..write(obj.detail)
      ..writeByte(3)
      ..write(obj.cachedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProgresSholatSunnahCacheAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class RiwayatProgresCacheAdapter extends TypeAdapter<RiwayatProgresCache> {
  @override
  final int typeId = 19;

  @override
  RiwayatProgresCache read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return RiwayatProgresCache(
      data: (fields[0] as Map).map((dynamic k, dynamic v) =>
          MapEntry(k as String, (v as List).cast<ProgresSholatCache>())),
      cachedAt: fields[1] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, RiwayatProgresCache obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.data)
      ..writeByte(1)
      ..write(obj.cachedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RiwayatProgresCacheAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
