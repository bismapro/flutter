// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'komunitas_cache.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class KomunitasArtikelCacheAdapter extends TypeAdapter<KomunitasArtikelCache> {
  @override
  final int typeId = 0;

  @override
  KomunitasArtikelCache read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return KomunitasArtikelCache(
      id: fields[0] as String,
      userId: fields[1] as int,
      kategori: fields[2] as String,
      judul: fields[3] as String,
      excerpt: fields[4] as String,
      isi: fields[5] as String?,
      gambar: (fields[6] as List).cast<String>(),
      isAnonymous: fields[7] as int,
      jumlahLike: fields[8] as int,
      jumlahKomentar: fields[9] as int,
      createdAt: fields[10] as DateTime,
      updatedAt: fields[11] as DateTime,
      cachedAt: fields[12] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, KomunitasArtikelCache obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.userId)
      ..writeByte(2)
      ..write(obj.kategori)
      ..writeByte(3)
      ..write(obj.judul)
      ..writeByte(4)
      ..write(obj.excerpt)
      ..writeByte(5)
      ..write(obj.isi)
      ..writeByte(6)
      ..write(obj.gambar)
      ..writeByte(7)
      ..write(obj.isAnonymous)
      ..writeByte(8)
      ..write(obj.jumlahLike)
      ..writeByte(9)
      ..write(obj.jumlahKomentar)
      ..writeByte(10)
      ..write(obj.createdAt)
      ..writeByte(11)
      ..write(obj.updatedAt)
      ..writeByte(12)
      ..write(obj.cachedAt);
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
