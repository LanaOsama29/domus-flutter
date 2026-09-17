import 'package:flutter/material.dart';

class RatingDialogContent extends StatefulWidget {
  final Function(int rating, String? comment) onSubmit;

  const RatingDialogContent({Key? key, required this.onSubmit})
    : super(key: key);

  @override
  _RatingDialogContentState createState() => _RatingDialogContentState();
}

class _RatingDialogContentState extends State<RatingDialogContent> {
  int _rating = 0;
  final TextEditingController _commentController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'How was your experience with the apartment?',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              fontFamily: 'Nunito',
            ),
          ),

          SizedBox(height: 20),

          // Stars
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _rating = index + 1;
                  });
                },
                child: Icon(
                  Icons.star,
                  size: 40,
                  color: index < _rating ? Colors.amber : Colors.grey[300],
                ),
              );
            }),
          ),

          SizedBox(height: 10),

          Text(
            '$_rating / 5',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
              fontFamily: 'Nunito',
            ),
          ),

          SizedBox(height: 20),

          // Comment field
          TextField(
            controller: _commentController,
            decoration: InputDecoration(
              labelText: 'Comment (optional)',
              hintText: 'Share your experience...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 15,
                vertical: 12,
              ),
            ),
            maxLines: 3,
            textInputAction: TextInputAction.done,
          ),

          SizedBox(height: 20),

          // Submit button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed:
                  _rating > 0
                      ? () {
                        widget.onSubmit(
                          _rating,
                          _commentController.text.trim(),
                        );
                      }
                      : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: EdgeInsets.symmetric(vertical: 14),
              ),
              child: Text(
                'Submit Rating',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Nunito',
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }
}
