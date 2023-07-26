class UnbordingContent {
  String image;
  String title;
  String discription;
  String discription1;
  String discription2;

  UnbordingContent({
    required this.image,
    required this.title,
    required this.discription,
    required this.discription1,
    required this.discription2,
  });
}

List<UnbordingContent> contents = [
  UnbordingContent(
      title: 'Hi!',
      image: 'assets/lottie/82709-ghost.json',
      discription: "Welcome to the Grapp Mapping App.",
      discription1: '',
      discription2: ''),
  UnbordingContent(
      title: 'Required',
      image: 'assets/lottie/115925-no-internet.json',
      discription:
          "Please make sure you have a strong internet or cellular connection to function the app properly.",
      discription1: '',
      discription2: ''),
  UnbordingContent(
    title: 'Fast to navigate',
    image: 'assets/lottie/4901-location-finding.json',
    discription: "To navigate to the grave, click the ",
    discription1:
        'location icon on the Google map and then the direction icon at the bottom.',
    discription2: '',
  ),
];
