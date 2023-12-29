import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:grapp/UI/const/const.dart';
import 'package:grapp/main.dart';

bool _isLoading = true;

class ShowImage extends StatefulWidget {
  const ShowImage({super.key});

  @override
  State<ShowImage> createState() => _ShowImageState();
}

class _ShowImageState extends State<ShowImage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$showfullname'),
        foregroundColor: Color.fromARGB(255, 5, 44, 77),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
          width: double.infinity,
          height: double.infinity,
          child: SingleChildScrollView(
            child: Column(children: [
              CachedNetworkImage(
                imageUrl: showimage.toString(),
                placeholder: (context, url) => const Center(
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: CircularProgressIndicator(),
                  ),
                ),
                errorWidget: (context, url, error) => Center(
                  child: Text('Error loading image'),
                ),
                imageBuilder: (context, imageProvider) {
                  // Image is loaded successfully, set isLoading to false
                  _isLoading = false;
                  return Container(
                    height: 400,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: imageProvider,
                        fit: BoxFit.cover,
                      ),
                    ),
                  );
                },
              ),
              Padding(
                padding: EdgeInsets.all(20),
                child: Container(
                  padding: const EdgeInsets.only(
                      top: 10,
                      left: 20,
                      right: 20,
                      bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  width: double.infinity,
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Image.asset(
                              'assets/cemetery.png',
                              scale: 6.5),
                          SizedBox(width: 5),
                          Text('Note', style: TextStyle(fontWeight: FontWeight.bold),)
                        ],
                      ),
                      SizedBox(height: 5),
                      const Text(
                        "       The image provided may not be an up-to-date representation of the current state of the grave. Due to the passage of time or changes in the grave's surroundings, such as weathering, landscaping, or other factors, the actual appearance of the grave might differ from what is shown in the image",
                        style: TextStyle(
                            color: Color.fromARGB(
                                255, 5, 44, 77)),
                      ),
                    ],
                  ),
                ),
              ),
            ],),
          )
      ),
    );
  }
}
