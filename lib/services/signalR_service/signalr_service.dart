import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:logging/logging.dart';
import 'package:signalr_netcore/signalr_client.dart';
import 'package:rburger/services/login_service/auth_controller.dart';

class SignalRService {
  static final SignalRService instance = SignalRService._internal();
  SignalRService._internal();

  HubConnection? _hubConnection;
  final Set<Function(List<Object?>?)> _listeners = {}; // CHANGED: Set, not List

  bool get isConnected => _hubConnection?.state == HubConnectionState.Connected;
  static bool _loggingReady = false; // NEW

  // NEW
  void addListener(Function(List<Object?>?) listener) =>
      _listeners.add(listener);
  void removeListener(Function(List<Object?>?) listener) =>
      _listeners.remove(listener);
  static void _setupLogging() {
    if (_loggingReady) return;
    _loggingReady = true;
    Logger.root.level = Level.ALL; // dev only
    Logger.root.onRecord.listen((r) {
      if (r.loggerName.startsWith('SignalR')) {
        debugPrint('[${r.loggerName}] ${r.level.name}: ${r.message}');
      }
    });
  }

  // CHANGED: no callback parameter
  Future<void> connect() async {
    _setupLogging(); // NEW

    final state = _hubConnection?.state;
    if (state != null && state != HubConnectionState.Disconnected) return;

    final token = AuthController.instance.token;
    if (token == null || token.isEmpty) {
      debugPrint('SignalR connect aborted: no auth token available yet.');
      return;
    }

    final baseUrl = dotenv.get('API_URL');
    final serverUrl = Uri.parse(baseUrl).resolve('/hubs/orders').toString();
    final hub = HubConnectionBuilder()
        .withUrl(
          serverUrl,
          options: HttpConnectionOptions(
            logger: Logger('SignalR - transport'), // NEW
            accessTokenFactory: () async => AuthController.instance.token ?? '',
          ),
        )
        .configureLogging(Logger('SignalR - hub')) // NEW
        .withAutomaticReconnect()
        .build();

    hub.on('OrderStatusChanged', (arguments) {
      debugPrint('SignalR OrderStatusChanged: $arguments'); // NEW
      for (final listener in List.of(_listeners)) {
        listener(arguments);
      }
    });

    _hubConnection = hub; // CHANGED: assigned before the await (no race)
    try {
      await hub.start();
      debugPrint('SignalR Connected Successfully.');
      debugPrint('SignalR Connected. id=${hub.connectionId}'); // CHANGED
    } catch (e) {
      debugPrint('SignalR Connection Error: $e');
      _hubConnection = null; // NEW: allow a retry on the next connect()
    }
  }

  Future<void> disconnect() async {
    if (_hubConnection != null) {
      await _hubConnection!.stop();
      debugPrint('SignalR Disconnected.');
    }
  }
}
