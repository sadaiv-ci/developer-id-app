import './claim_detail_model.dart';
import './claim_model_state.dart';

class ClaimModel {
  final String? expiration;
  final String id;
  final String value;
  final String name;
  final String issuer;
  final ClaimModelState state;
  final String type;
  final List<ClaimDetailModel> details;

  ClaimModel(
      {required this.id,
      required this.value,
      required this.expiration,
      required this.issuer,
      required this.type,
      required this.state,
      required this.name,
      required this.details});
}
