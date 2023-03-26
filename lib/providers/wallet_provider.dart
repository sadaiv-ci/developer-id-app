
import 'package:flutter/material.dart';
import 'package:polygonid_flutter_sdk/credential/domain/entities/claim_entity.dart';
import 'package:polygonid_flutter_sdk/iden3comm/domain/entities/iden3_message_entity.dart';
import 'package:polygonid_flutter_sdk/iden3comm/domain/entities/request/auth/proof_scope_request.dart';
import 'package:polygonid_flutter_sdk/identity/domain/entities/identity_entity.dart';
import 'package:polygonid_flutter_sdk/proof/domain/entities/circuit_data_entity.dart';
import 'package:polygonid_flutter_sdk/proof/domain/entities/jwz/jwz_proof.dart';
import 'package:polygonid_flutter_sdk/sdk/polygon_id_sdk.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:sadaivid/config/blockchain_resources.dart';
import 'package:sadaivid/config/storage_keys.dart';
import 'package:sadaivid/models/mappers/proof_model_type_mapper.dart';

import '../models/claim_model.dart';
import '../models/mappers/claim_model_mapper.dart';
import '../models/mappers/claim_model_state_mapper.dart';

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

  Future<List<ClaimModel>> getAllClaims() async {
    if (!isReady) return [];

    String didIdentifier = await sdk.identity.getDidIdentifier(
        privateKey: privateKey!,
        blockchain: BlockchainResources.blockchain,
        network: BlockchainResources.network);

    final claims = await sdk.credential
        .getClaims(did: didIdentifier, privateKey: privateKey!);
    final mapper =
        ClaimModelMapper(ClaimModelStateMapper(), ProofModelTypeMapper());
    List<ClaimModel> claimModelList =
        claims.map((claimEntity) => mapper.mapFrom(claimEntity)).toList();
    return claimModelList;
  }

  Future<bool> fetchAndSaveClaims(Iden3MessageEntity iden3Message) async {
    if (!isReady) return false;

    String didIdentifier = await sdk.identity.getDidIdentifier(
        privateKey: privateKey!,
        blockchain: BlockchainResources.blockchain,
        network: BlockchainResources.network);
    try {
      final response = await sdk.iden3comm.fetchAndSaveClaims(
          message: iden3Message, did: didIdentifier, privateKey: privateKey!);
      print(response.first);
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<JWZBaseProof?> generateProof(
      ClaimEntity claimEntity,
      CircuitDataEntity circuitDataEntity,
      ProofScopeRequest proofScopeRequest) async {
    if (!isReady) return null;

    String didIdentifier = await sdk.identity.getDidIdentifier(
        privateKey: privateKey!,
        blockchain: BlockchainResources.blockchain,
        network: BlockchainResources.network);
    final proof = await sdk.proof.prove(
        did: didIdentifier,
        claim: claimEntity,
        circuitData: circuitDataEntity,
        request: proofScopeRequest);
    return proof.proof;
  }
}
