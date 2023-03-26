import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sadaivid/models/claim_model.dart';
import 'package:sadaivid/screens/claim_details.dart';

class ClaimCard extends StatefulWidget {
  final ClaimModel claim;

  const ClaimCard({super.key, required this.claim});

  @override
  State<ClaimCard> createState() => _ClaimCardState();
}

class _ClaimCardState extends State<ClaimCard> {
  @override
  Widget build(BuildContext context) {
    final expiry = DateTime.parse(widget.claim.expiration!);
    return InkWell(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ClaimDetails(claim: widget.claim))),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        decoration: BoxDecoration(
          color: Color.fromARGB(255, 239, 106, 194),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
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
              widget.claim.name,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 10),
            Text(
              widget.claim.issuer,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 10),
            Text(
              widget.claim.expiration != null
                  ? 'Expires in ${DateFormat('MMMM').format(expiry)} ${expiry.year}'
                  : 'No expiry',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
