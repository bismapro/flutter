// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'komunitas_cache.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class KomunitasArtikelCacheAdapter extends TypeAdapter<KomunitasArtikelCache> {
  @override
  final int typeId = 4;

  @override
  KomunitasArtikelCache read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return KomunitasArtikelCache(
      id: fields[0] as int,
      userId: fields[1] as int,
      kategoriId: fields[2] as int,
      judul: fields[3] as String,
      excerpt: fields[4] as String,
      cover: fields[5] as String,
      daftarGambar: (fields[6] as List).cast<String>(),
      totalLikes: fields[7] as int,
      totalKomentar: fields[8] as int,
      createdAt: fields[9] as DateTime,
      updatedAt: fields[10] as DateTime,
      cachedAt: fields[11] as DateTime,
      penulis: fields[12] as String,
      kategori: fields[13] as KategoriArtikelCache,
    );
  }

  @override
  void write(BinaryWriter writer, KomunitasArtikelCache obj) {
    writer
      ..writeByte(14)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.userId)
      ..writeByte(2)
      ..write(obj.kategoriId)
      ..writeByte(3)
      ..write(obj.judul)
      ..writeByte(4)
      ..write(obj.excerpt)
      ..writeByte(5)
      ..write(obj.cover)
      ..writeByte(6)
      ..write(obj.daftarGambar)
      ..writeByte(7)
      ..write(obj.totalLikes)
      ..writeByte(8)
      ..write(obj.totalKomentar)
      ..writeByte(9)
      ..write(obj.createdAt)
      ..writeByte(10)
      ..write(obj.updatedAt)
      ..writeByte(11)
      ..write(obj.cachedAt)
      ..writeByte(12)
      ..write(obj.penulis)
      ..writeByte(13)
      ..write(obj.kategori);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is KomunitasArtikelCacheAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
