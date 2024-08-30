import 'dart:io';

class ServerConfig {
  late final InternetAddress ip;
  late final int port;

  ServerConfig({
    InternetAddress? ip,
    int? port,
  }) {
    this.ip = ip ?? InternetAddress.anyIPv4;
    this.port = port ?? 8080;
  }
}
