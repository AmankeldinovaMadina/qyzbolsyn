import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class PodcastDetailScreen extends StatefulWidget {
  const PodcastDetailScreen({super.key});

  @override
  _PodcastDetailScreenState createState() => _PodcastDetailScreenState();
}

class _PodcastDetailScreenState extends State<PodcastDetailScreen> {
  late YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController(
      initialVideoId: YoutubePlayer.convertUrlToId('https://youtu.be/J2lilGITYWs?si=BmiYbkaoIcW3XM0D')!,
      flags: const YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: GestureDetector(
          onTap: () {
            Navigator.of(context).pop(); // Navigate back when tapped
          },
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Icon(
              Icons.chevron_left,
              color: Color(0xFFFA7BFD), // Your specified color
              size: 42, // Adjust the size as needed
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, // Make sure everything is aligned left
            children: [
              // YouTube player displayed directly, no image beforehand
              ClipRRect(
                borderRadius: BorderRadius.circular(16.0),
                child: YoutubePlayer(
                  controller: _controller,
                  showVideoProgressIndicator: true,
                ),
              ),
              SizedBox(height: 16),
              // Tags aligned to the left
              Wrap(
                alignment: WrapAlignment.start, // Align to the left
                spacing: 8, // Space between buttons horizontally
                runSpacing: 8, // Space between buttons vertically
                children: [
                  TagWidget(label: 'Здоровье'),
                  LikeableTagWidget(label: 'В избранное'),
                  TagWidget(label: '40 минут 12 секунд'),
                ],
              ),
              SizedBox(height: 16),
              // Title
              Column(
                crossAxisAlignment: CrossAxisAlignment.start, // Align left for the title as well
                children: [
                  Text(
                    'Первыми гостями на подкасте Qyzbolsyn стали практикующие психологи Салима и Гульшат из организации Jarqyn.',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.left, // Align text to the left
                    softWrap: true,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Jarqyn — peer-to-peer клуб о ментальном здоровье в унивеситетах Казахстана.', 
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                    textAlign: TextAlign.left, // Align text to the left
                    softWrap: true,
                  ),
                ],
              ),
              SizedBox(height: 16),
              // Description
              Text(
                'В этом выпуске мы обсудим причины возникновения тревожности, стресса от происходящего в стране и думскроллига. В общем, главные ситуации, с которыми сталкивается каждая из нас. Самое важное — гостьи поделились наиболее эффективными методами борьбы со стрессом и тревогой!\nЭтот важный подкаст определенно будет полезен для вас 🩷',
                style: TextStyle(fontSize: 16),
                softWrap: true,
              ),
              SizedBox(height: 16),
              // Timestamps
              Text(
                'Таймкоды:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              TimestampWidget(time: '00:00', label: 'Приветствие гостей'),
              TimestampWidget(time: '00:37', label: '"Тревога: Как переживать тревогу?"'),
              TimestampWidget(time: '02:58', label: '"Какая у нас тревога на примере Алматинских землетрясений? (Личная/Ситуативная)"'),
              TimestampWidget(time: '05:42', label: '"Тревога сама уходит или мне нужно обратиться к специалисту?"'),
              TimestampWidget(time: '08:57', label: '"ТРЕВОЖИТЬСЯ - АБСОЛЮТНО НОРМАЛЬНО"'),
              TimestampWidget(time: '11:03', label: '"Мы ежеминутно обновляем ленту, следим за каждой новостью. Насколько эта супер-вовлеченность - НОРМА?"'),
              TimestampWidget(time: '15:08', label: '"Мы то, что мы едим: Важно балансировать количество НУЖНОГО контента"'),
              TimestampWidget(time: '17:33', label: '"Еще 5, 10, 15 минут Инсты/Тиктока: Как выйти из этой дофаминовой ловушки?"'),
              TimestampWidget(time: '20:55', label: '"Уметь говорить себе СТОП и рефлексировать свое состояние"'),
              TimestampWidget(time: '25:01', label: '"Обратная реакция окружения на мою гражданскую активность: Как справляться с ним?"'),
              TimestampWidget(time: '27:33', label: '"Если не можем себя контролировать и техника с Думскроллингом не помогает, что делать?"'),
              TimestampWidget(time: '35:10', label: '"Можно отнять 15 минут от 4 часов думскроллинга :)"'),
              TimestampWidget(time: '38:55', label: '"Кислородную маску сначала одеваем на себя и только после на всех кого хватит сил"'),
              TimestampWidget(time: '39:12', label: 'Ending fairy 🧚🏻'),
            ],
          ),
        ),
      ),
    );
  }
}

class TagWidget extends StatelessWidget {
  final String label;

  const TagWidget({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(label),
    );
  }
}

class LikeableTagWidget extends StatefulWidget {
  final String label;

  const LikeableTagWidget({required this.label});

  @override
  _LikeableTagWidgetState createState() => _LikeableTagWidgetState();
}

class _LikeableTagWidgetState extends State<LikeableTagWidget> {
  bool _isLiked = false;

  void _toggleLike() {
    setState(() {
      _isLiked = !_isLiked;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggleLike,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 2),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _isLiked ? Icons.favorite : Icons.favorite_border,
              color: Color(0xFFC575C7), // Heart icon color
              size: 16, // Adjust size as needed
            ),
            SizedBox(width: 4), // Space between icon and label
            Text(widget.label),
          ],
        ),
      ),
    );
  }
}

class TimestampWidget extends StatelessWidget {
  final String time;
  final String label;

  const TimestampWidget({
    required this.time,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          time,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        SizedBox(width: 8), // Space between time and label
        Expanded(
          child: Text(
            label,
            style: TextStyle(fontSize: 16),
            maxLines: null, // Allows text to wrap to a new line if needed
            overflow: TextOverflow.visible,
          ),
        ),
      ],
    );
  }
}
