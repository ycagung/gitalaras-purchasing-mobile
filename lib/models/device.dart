import 'package:equatable/equatable.dart';
import 'dart:io';

class Device extends Equatable {
  final String id;
  final String type;
  final String name;
  final String os;

  const Device({
    required this.id,
    required this.type,
    required this.name,
    required this.os,
  });

  factory Device.fromJson(Map<String, dynamic> json) {
    return Device(
      id: json['id'] as String,
      type: json['type'] as String,
      name: json['name'] as String,
      os: json['os'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'name': name,
      'os': os,
    };
  }

  @override
  List<Object?> get props => [id, type, name, os];
}

