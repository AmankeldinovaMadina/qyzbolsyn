import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:last/home/forum/talking_page.dart';
import 'package:last/services/talk_service.dart';
import 'package:last/services/model/talk.dart';

class TalkWidget extends StatefulWidget {
  const TalkWidget({Key? key}) : super(key: key);

  @override
  _TalkWidgetState createState() => _TalkWidgetState();
}

class _TalkWidgetState extends State<TalkWidget> {
  late Future<Talk> futureTalk; // Future to hold the fetched last talk

  @override
  void initState() {
    super.initState();
    futureTalk = TalkService().fetchLastTalk(); // Fetch the last talk when the widget initializes
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width; // Get the screen width

    return FutureBuilder<Talk>(
      future: futureTalk,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 200,
            child: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasError) {
          return SizedBox(
            height: 200,
            child: Center(
              child: Text(
                'Ошибка загрузки данных: ${snapshot.error}',
                style: const TextStyle(color: Colors.red),
              ),
            ),
          );
        } else if (snapshot.hasData) {
          final talk = snapshot.data!;
          return ClipRRect(
            borderRadius: BorderRadius.circular(16), // Apply the corner radius to clip the widget
            child: Container(
              width: screenWidth, // Set the width to full screen
              height: 200, // Set the height
              child: Stack(
                children: [
                  // Background SVG
                  Positioned.fill(
                    child: SvgPicture.asset(
                      'assets/podcasts/one.svg', // Path to your SVG background image
                      fit: BoxFit.cover, // Cover the entire container
                    ),
                  ),
                  // Foreground content (Text and Button)
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Title Text
                        const Text(
                          'Давайте пообщаемся?',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Subtitle Text (Use the question from the talk)
                        Text(
                          talk.question,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white70,
                          ),
                        ),
                        const Spacer(), // This will push the button to the bottom
                        // Share Button
                        Align(
                          alignment: Alignment.bottomLeft,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => TalkingPage(talkId: talk.id)),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.purple,
                              backgroundColor: Colors.white, // Button background color
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20), // Rounded corners for the button
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            ),
                            child: const Text(
                              'Поделиться',
                              style: TextStyle(
                                color: Color(0xFFE66EE9),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        } else {
          return const SizedBox(
            height: 200,
            child: Center(child: Text('Нет данных для отображения.')),
          );
        }
      },
    );
  }
}
