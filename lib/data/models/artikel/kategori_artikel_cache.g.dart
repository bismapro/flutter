// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'kategori_artikel_cache.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class KategoriArtikelCacheAdapter extends TypeAdapter<KategoriArtikelCache> {
  @override
  final int typeId = 1;

  @override
  KategoriArtikelCache read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return KategoriArtikelCache(
      id: fields[0] as int,
      nama: fields[1] as String,
      icon: fields[2] as String,
      cachedAt: fields[3] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, KategoriArtikelCache obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.nama)
      ..writeByte(2)
      ..write(obj.icon)
      ..writeByte(3)
      ..write(obj.cachedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is KategoriArtikelCacheAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
