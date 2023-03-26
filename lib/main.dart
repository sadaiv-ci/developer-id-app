import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'package:polygonid_flutter_sdk/common/domain/entities/env_entity.dart';
import 'package:provider/provider.dart';
import 'package:sadaivid/providers/wallet_provider.dart';
import 'package:sadaivid/screens/claims.dart';
import 'package:sadaivid/screens/home.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:polygonid_flutter_sdk/sdk/polygon_id_sdk.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await PolygonIdSdk.init(
      env: EnvEntity(
    blockchain: 'polygon',
    network: 'mumbai',
    web3Url:
        'https://polygon-mumbai.g.alchemy.com/v2/dwquSdMnSF6C8wTuFcBkT6fMbNotN-sL',
    web3RdpUrl:
        'wss://polygon-mumbai.g.alchemy.com/v2/dwquSdMnSF6C8wTuFcBkT6fMbNotN-sL',
    web3ApiKey: 'dwquSdMnSF6C8wTuFcBkT6fMbNotN-sL',
    idStateContract: '0x453A1BC32122E39A8398ec6288783389730807a5',
    pushUrl: 'https://push.service.io/api/v1',
  ));
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: WalletProvider()..checkIdStatus(),
      builder: (context, _) => MaterialApp(
        title: 'Developer ID',
        theme: ThemeData(
          primaryColor: Color(0xffB64286),
          primarySwatch: Colors.purple,
        ),
        home: const MyHomePage(title: 'Sadaiv ID'),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    super.initState();

    FirebaseMessaging.instance.getToken().then((value) => print(value));

    // Checking if app opened from notification.
    FirebaseMessaging.onMessageOpenedApp.listen((event) async {
      final data = event.data;
      switch (data['type'].toString()) {
        case 'URL':
          if (await canLaunchUrlString(data['value'].toString())) {
            await launchUrlString(data['value'].toString());
          }
          break;
      }
    });
    startCircuitsDownload();
  }

  Future<void> startCircuitsDownload() async {
    final sdk = PolygonIdSdk.I;
    final stream = await sdk.proof.initCircuitsDownloadAndGetInfoStream;
    stream.listen((event) {
      print(event);
    });
  }

  final auth =
      '{"id":"a6542f00-39cd-408f-8ca5-404cfbf0fe32","typ":"application/iden3comm-plain-json","type":"https://iden3-communication.io/authorization/1.0/request","thid":"a6542f00-39cd-408f-8ca5-404cfbf0fe32","body":{"callbackUrl":"https://self-hosted-demo-backend-platform.polygonid.me/api/callback?sessionId=214475","reason":"test flow","scope":[]},"from":"did:polygonid:polygon:mumbai:2qH7XAwYQzCp9VfhpNgeLtK2iCehDDrfMWUCEg5ig5"}';

  @override
  Widget build(BuildContext context) {
    final wallet = Provider.of<WalletProvider>(context);
    final isReady = wallet.isReady;
    PersistentTabController controller =
        PersistentTabController(initialIndex: 0);

    List<Widget> _buildScreens() {
      return [
        HomePage(),
        ClaimsPage(),
        Container(),
        Container(),
      ];
    }

    List<PersistentBottomNavBarItem> _navBarsItems() {
      return [
        PersistentBottomNavBarItem(
          icon: Icon(CupertinoIcons.home),
          title: ("Home"),
          activeColorPrimary: Color(0xffB64286),
          inactiveColorPrimary: CupertinoColors.systemGrey,
        ),
        PersistentBottomNavBarItem(
          icon: Icon(CupertinoIcons.staroflife),
          title: ("Claims"),
          activeColorPrimary: Color(0xffB64286),
          inactiveColorPrimary: CupertinoColors.systemGrey,
        ),
        PersistentBottomNavBarItem(
          icon: Icon(CupertinoIcons.bell),
          title: ("Notifications"),
          activeColorPrimary: Color(0xffB64286),
          inactiveColorPrimary: CupertinoColors.systemGrey,
        ),
        PersistentBottomNavBarItem(
          icon: Icon(CupertinoIcons.person),
          title: ("Profile"),
          activeColorPrimary: Color(0xffB64286),
          inactiveColorPrimary: CupertinoColors.systemGrey,
        ),
      ];
    }

    return PersistentTabView(
      context,
      controller: controller,
      screens: _buildScreens(),
      items: _navBarsItems(),
      confineInSafeArea: true,
      backgroundColor: Colors.white, // Default is Colors.white.
      handleAndroidBackButtonPress: true, // Default is true.
      resizeToAvoidBottomInset:
          true, // This needs to be true if you want to move up the screen when keyboard appears. Default is true.
      stateManagement: true, // Default is true.
      hideNavigationBarWhenKeyboardShows:
          true, // Recommended to set 'resizeToAvoidBottomInset' as true while using this argument. Default is true.
      decoration: NavBarDecoration(
        borderRadius: BorderRadius.circular(10.0),
        colorBehindNavBar: Colors.white,
      ),
      popAllScreensOnTapOfSelectedTab: true,
      popActionScreens: PopActionScreensType.all,
      itemAnimationProperties: ItemAnimationProperties(
        // Navigation Bar's items animation properties.
        duration: Duration(milliseconds: 200),
        curve: Curves.ease,
      ),
      screenTransitionAnimation: ScreenTransitionAnimation(
        // Screen transition animation on change of selected tab.
        animateTabTransition: true,
        curve: Curves.ease,
        duration: Duration(milliseconds: 200),
      ),
      navBarStyle:
          NavBarStyle.style1, // Choose the nav bar style with this property.
    );
  }
}
