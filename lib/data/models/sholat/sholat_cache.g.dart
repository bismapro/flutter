// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sholat_cache.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SholatCacheAdapter extends TypeAdapter<SholatCache> {
  @override
  final int typeId = 7;

  @override
  SholatCache read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SholatCache(
      tanggal: fields[0] as String,
      wajib: fields[1] as SholatWajibCache,
      sunnah: fields[2] as SholatSunnahCache,
      cachedAt: fields[3] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, SholatCache obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.tanggal)
      ..writeByte(1)
      ..write(obj.wajib)
      ..writeByte(2)
      ..write(obj.sunnah)
      ..writeByte(3)
      ..write(obj.cachedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SholatCacheAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class SholatWajibCacheAdapter extends TypeAdapter<SholatWajibCache> {
  @override
  final int typeId = 8;

  @override
  SholatWajibCache read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SholatWajibCache(
      shubuh: fields[0] as String,
      dzuhur: fields[1] as String,
      ashar: fields[2] as String,
      maghrib: fields[3] as String,
      isya: fields[4] as String,
    );
  }

  @override
  void write(BinaryWriter writer, SholatWajibCache obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.shubuh)
      ..writeByte(1)
      ..write(obj.dzuhur)
      ..writeByte(2)
      ..write(obj.ashar)
      ..writeByte(3)
      ..write(obj.maghrib)
      ..writeByte(4)
      ..write(obj.isya);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SholatWajibCacheAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class SholatSunnahCacheAdapter extends TypeAdapter<SholatSunnahCache> {
  @override
  final int typeId = 9;

  @override
  SholatSunnahCache read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SholatSunnahCache(
      tahajud: fields[0] as String,
      witir: fields[1] as String,
      dhuha: fields[2] as String,
      qabliyahSubuh: fields[3] as String,
      qabliyahDzuhur: fields[4] as String,
      baDiyahDzuhur: fields[5] as String,
      qabliyahAshar: fields[6] as String,
      baDiyahMaghrib: fields[7] as String,
      qabliyahIsya: fields[8] as String,
      baDiyahIsya: fields[9] as String,
    );
  }

  @override
  void write(BinaryWriter writer, SholatSunnahCache obj) {
    writer
      ..writeByte(10)
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
      ..write(obj.baDiyahIsya);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SholatSunnahCacheAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
