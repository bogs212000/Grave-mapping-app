class UsersGuideUnbordingContent {
  String image;
  String title;
  String discription;
  String discription1;
  String discription2;
  String discription4;
  String discription5;

  UsersGuideUnbordingContent(
      {required this.image,
      required this.title,
      required this.discription,
      required this.discription1,
      required this.discription2,
      required this.discription4,
      required this.discription5});
}

List<UsersGuideUnbordingContent> contents = [
  UsersGuideUnbordingContent(
      title: 'Users guide',
      image: 'assets/one.png',
      discription:
          "Thank you for using the app. Here is the user guide on how to use the app.",
      discription1: '',
      discription2: '',
      discription4: '',
      discription5: ''),
  UsersGuideUnbordingContent(
      title: 'How to use',
      image: 'assets/three.png',
      discription:
          "Please make sure you have a strong internet or cellular connection to function the app properly.",
      discription1: '',
      discription2: '',
      discription4: '',
      discription5: ''),
  UsersGuideUnbordingContent(
      title: 'Navigating',
      image: 'assets/two.png',
      discription:
          "To navigate to the grave, click the location icon on the Google map and then the direction icon at the bottom.",
      discription1: '',
      discription2: '',
      discription4: '',
      discription5: ''),
];
