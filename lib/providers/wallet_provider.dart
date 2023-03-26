import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:polygonid_flutter_sdk/iden3comm/domain/entities/iden3_message_entity.dart';
import 'package:polygonid_flutter_sdk/iden3comm/domain/entities/request/offer/offer_iden3_message_entity.dart';
import 'package:polygonid_flutter_sdk/identity/domain/entities/identity_entity.dart';
import 'package:polygonid_flutter_sdk/sdk/polygon_id_sdk.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:sadaivid/config/blockchain_resources.dart';
import 'package:sadaivid/config/storage_keys.dart';

class WalletProvider extends ChangeNotifier {
  final storage = FlutterSecureStorage();
  final PolygonIdSdk sdk = PolygonIdSdk.I;

  String? privateKey;
  String? did;
  bool isReady = false;

  Future<void> checkIdStatus() async {
    final privateKey = await storage.read(key: StorageKeys.privateKey);
    final did = await storage.read(key: StorageKeys.did);
    if (privateKey == null || did == null) {
      await createIdentity();
    }
    this.privateKey = privateKey;
    this.did = did;
    isReady = true;
    notifyListeners();
  }

  Future<IdentityEntity> getIdentity() async {
    final did = await storage.read(key: StorageKeys.did);
    final response = await sdk.identity.getIdentity(genesisDid: did!);
    return response;
  }

  Future<void> createIdentity() async {
    try {
      final response = await sdk.identity.addIdentity();
      print('created new id');
      await storage.write(
          key: StorageKeys.privateKey, value: response.privateKey);
      await storage.write(key: StorageKeys.did, value: response.did);
      checkIdStatus();
    } catch (e) {
      print(e);
    }
  }

  Future<Iden3MessageEntity> getIden3Message(String qrCodeResponse) async {
    final message =
        await sdk.iden3comm.getIden3Message(message: qrCodeResponse);
    return message;
  }

  Future<void> authenticate(Iden3MessageEntity iden3Message) async {
    if (!isReady) return;

    String didIdentifier = await sdk.identity.getDidIdentifier(
        privateKey: privateKey!,
        blockchain: BlockchainResources.blockchain,
        network: BlockchainResources.network);

    // final response = await sdk.credential.fetchAndSaveClaims(
    //     message: iden3Message, did: did!, privateKey: privateKey!);
    await sdk.iden3comm.authenticate(
        did: didIdentifier, message: iden3Message, privateKey: privateKey!);
    // print(response);
  }
}
