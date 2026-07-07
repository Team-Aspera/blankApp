import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _enterFullscreen();
  runApp(const MainApp());
}

Future<void> _enterFullscreen() async {
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  await SystemChrome.setPreferredOrientations(DeviceOrientation.values);
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: BlankScreenApp(),
    );
  }
}

class BlankScreenApp extends StatefulWidget {
  const BlankScreenApp({super.key});

  @override
  State<BlankScreenApp> createState() => _BlankScreenAppState();
}

class _BlankScreenAppState extends State<BlankScreenApp>
    with WidgetsBindingObserver {
  static const MethodChannel _deviceChannel = MethodChannel('blank_app/device');

  static const List<_ScreenPage> _pages = <_ScreenPage>[
    _ScreenPage.blank(),
    _ScreenPage.asset('assets/screens/3dmark_1.jpg', isThreeDMark: true),
    _ScreenPage.asset('assets/screens/3dmark_2.jpg', isThreeDMark: true),
    _ScreenPage.asset('assets/screens/3dmark_3.jpg', isThreeDMark: true),
    _ScreenPage.asset('assets/screens/geekbench.jpg'),
  ];

  int _pageIndex = 0;
  bool _proximityCovered = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _deviceChannel.setMethodCallHandler(_handleDeviceMethodCall);
    _configureDevice();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _deviceChannel.setMethodCallHandler(null);
    _deviceChannel.invokeMethod<void>('disableProximityScreenOff');
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _configureDevice();
    }
  }

  Future<void> _configureDevice() async {
    await _enterFullscreen();
    try {
      await _deviceChannel.invokeMethod<void>('enableProximityScreenOff');
    } on PlatformException {
      // Some targets do not expose a proximity sensor or screen-off API.
    } on MissingPluginException {
      // Desktop/test runs can use the same Dart UI without native support.
    }
  }

  void _nextPage() {
    setState(() {
      _pageIndex = (_pageIndex + 1) % _pages.length;
    });
  }

  Future<void> _handleDeviceMethodCall(MethodCall call) async {
    if (call.method == 'nextPage') {
      _nextPage();
      return;
    }

    if (call.method != 'proximityChanged') {
      return;
    }

    final isNear = call.arguments == true;
    if (isNear == _proximityCovered || !mounted) {
      return;
    }

    setState(() {
      _proximityCovered = isNear;
    });
  }

  @override
  Widget build(BuildContext context) {
    final page = _pages[_pageIndex];

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _nextPage,
      child: ColoredBox(
        color: _proximityCovered ? Colors.black : page.backgroundColor,
        child: SizedBox.expand(
          child: _proximityCovered || page.assetPath == null
              ? const SizedBox.shrink()
              : _ScreenshotPage(page: page),
        ),
      ),
    );
  }
}

class _ScreenshotPage extends StatelessWidget {
  const _ScreenshotPage({required this.page});

  final _ScreenPage page;

  @override
  Widget build(BuildContext context) {
    final path = page.assetPath!;

    if (!page.isThreeDMark) {
      return Image.asset(
        path,
        fit: BoxFit.fill,
        width: double.infinity,
        height: double.infinity,
      );
    }

    return Center(
      child: AspectRatio(
        aspectRatio: 9 / 16,
        child: Image.asset(
          path,
          fit: BoxFit.contain,
          width: double.infinity,
          height: double.infinity,
        ),
      ),
    );
  }
}

class _ScreenPage {
  const _ScreenPage.blank()
    : assetPath = null,
      isThreeDMark = false,
      backgroundColor = Colors.white;

  const _ScreenPage.asset(this.assetPath, {this.isThreeDMark = false})
    : backgroundColor = isThreeDMark ? Colors.black : Colors.white;

  final String? assetPath;
  final bool isThreeDMark;
  final Color backgroundColor;
}
