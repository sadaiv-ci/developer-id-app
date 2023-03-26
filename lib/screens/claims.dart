import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:flutter/material.dart';
import 'package:polygonid_flutter_sdk/iden3comm/domain/entities/iden3_message_entity.dart';
import 'package:provider/provider.dart';
import 'package:sadaivid/models/claim_model.dart';
import 'package:sadaivid/providers/wallet_provider.dart';

import '../components/claim_card.dart';

class ClaimsPage extends StatefulWidget {
  const ClaimsPage({super.key});

  @override
  State<ClaimsPage> createState() => _ClaimsPageState();
}

class _ClaimsPageState extends State<ClaimsPage> {
  final auth = '''
{"id":"7e6b901b-a915-45a3-bffd-65aec3537246","typ":"application/iden3comm-plain-json","type":"https://iden3-communication.io/credentials/1.0/offer","thid":"7e6b901b-a915-45a3-bffd-65aec3537246","body":{"url":"https://self-hosted-platform.polygonid.me/v1/agent","credentials":[{"id":"93d4563c-cb4f-11ed-8e4f-0242c0a88005","description":"KYCCountryOfResidenceCredential"}]},"from":"did:polygonid:polygon:mumbai:2qH7XAwYQzCp9VfhpNgeLtK2iCehDDrfMWUCEg5ig5","to":"did:polygonid:polygon:mumbai:2qDoRn4eRgncmVvkowjLu5rECDG8Y9TmAywdQKMvzD"}
''';

  List<ClaimModel> claims = [];

  Future<void> fetchAllClaims() async {
    final wallet = Provider.of<WalletProvider>(context, listen: false);
    final claimsList = await wallet.getAllClaims();
    setState(() {
      claims = claimsList;
    });
  }

  @override
  void initState() {
    super.initState();

    fetchAllClaims();
  }

  @override
  Widget build(BuildContext context) {
    final wallet = Provider.of<WalletProvider>(context);

    return SafeArea(
      child: Scaffold(
        backgroundColor: Color(0xffF9F6EE),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            var result = await BarcodeScanner.scan();
            if(result.rawContent == '') return;
            final iden3result = await wallet.getIden3Message(result.rawContent);
            if (iden3result.messageType == Iden3MessageType.offer) {
              final resp = await wallet.fetchAndSaveClaims(iden3result);
              if (resp) fetchAllClaims();
            } else {
              // await wallet.generateProof(iden3msg, circuitDataEntity, proofScopeRequest)
            }
          },
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
              RefreshIndicator(
                onRefresh: fetchAllClaims,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: claims.map((c) => ClaimCard(claim: c)).toList(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
