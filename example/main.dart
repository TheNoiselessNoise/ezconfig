import 'package:ezconfig/ezconfig.dart';

class ServerConfig extends EzConfig {
  late final EzField<String> host;
  late final EzField<int> port;
  late final EzField<bool?> debug;

  ServerConfig([super.data]) {
    host = field('host', initial: () => 'localhost');
    port = field('port', initial: () => 8080);
    debug = fieldNull('debug');
  }
}

void main() => print(ServerConfig({
  'host': 'example.com',
  'port': 'oops'
}).getData());