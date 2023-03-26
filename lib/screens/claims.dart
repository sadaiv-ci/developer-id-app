import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sadaivid/providers/wallet_provider.dart';

class ClaimsPage extends StatefulWidget {
  const ClaimsPage({super.key});

  @override
  State<ClaimsPage> createState() => _ClaimsPageState();
}

class _ClaimsPageState extends State<ClaimsPage> {
  final auth =
      '{"id":"f2a59ba2-5b6e-44bf-b7a6-c7589c01ac63","typ":"application/iden3comm-plain-json","type":"https://iden3-communication.io/authorization/1.0/request","thid":"f2a59ba2-5b6e-44bf-b7a6-c7589c01ac63","body":{"callbackUrl":"https://self-hosted-demo-backend-platform.polygonid.me/api/callback?sessionId=951277","reason":"test flow","scope":[]},"from":"did:polygonid:polygon:mumbai:2qH7XAwYQzCp9VfhpNgeLtK2iCehDDrfMWUCEg5ig5"}';

  @override
  Widget build(BuildContext context) {
    final wallet = Provider.of<WalletProvider>(context);

    Future<void> authenticate() async {
      final msg = await wallet.getIden3Message(auth);
      print('msg processed');
      await wallet.authenticate(msg);
    }

    return SafeArea(
      child: Scaffold(
        backgroundColor: Color(0xffF9F6EE),
        floatingActionButton: FloatingActionButton(
          onPressed: () {},
          child: Icon(Icons.qr_code),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 10),
          child: Column(
            children: [
              Row(
                children: const [
                  Text(
                    'Claims',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 30),
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                decoration: BoxDecoration(
                  color: Theme.of(context).accentColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: const [
                            Icon(
                              Icons.key,
                              color: Colors.white,
                            ),
                            Spacer(),
                            Icon(
                              Icons.chevron_right_rounded,
                              color: Colors.white,
                            )
                          ],
                        ),
                        Text(
                          'ETH India',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Last recieved in December 2022',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          '3 Pending Requests',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    authenticate();
                  },
                  child: Text('Authenticate'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
