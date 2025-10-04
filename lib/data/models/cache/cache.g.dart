// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cache.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CacheMetadataAdapter extends TypeAdapter<CacheMetadata> {
  @override
  final int typeId = 0;

  @override
  CacheMetadata read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CacheMetadata(
      lastFetch: fields[0] as DateTime,
      totalPages: fields[1] as int,
      currentPage: fields[2] as int,
      totalItems: fields[3] as int,
      cacheKey: fields[4] as String,
      customExpiry: fields[5] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, CacheMetadata obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.lastFetch)
      ..writeByte(1)
      ..write(obj.totalPages)
      ..writeByte(2)
      ..write(obj.currentPage)
      ..writeByte(3)
      ..write(obj.totalItems)
      ..writeByte(4)
      ..write(obj.cacheKey)
      ..writeByte(5)
      ..write(obj.customExpiry);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CacheMetadataAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class CacheEntryAdapter extends TypeAdapter<CacheEntry> {
  @override
  final int typeId = 1;

  @override
  CacheEntry read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CacheEntry(
      key: fields[0] as String,
      jsonData: fields[1] as String,
      cachedAt: fields[2] as DateTime,
      customExpiry: fields[3] as DateTime?,
      dataType: fields[4] as String,
    );
  }

  @override
  void write(BinaryWriter writer, CacheEntry obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.key)
      ..writeByte(1)
      ..write(obj.jsonData)
      ..writeByte(2)
      ..write(obj.cachedAt)
      ..writeByte(3)
      ..write(obj.customExpiry)
      ..writeByte(4)
      ..write(obj.dataType);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CacheEntryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
