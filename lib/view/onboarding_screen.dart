import 'package:com.example.while_app/resources/components/text_button.dart';
import 'package:com.example.while_app/view/auth/login_screen.dart';
import 'package:com.example.while_app/view/intro_screens/intro_page_1.dart';
import 'package:com.example.while_app/view/intro_screens/intro_page_2.dart';
import 'package:com.example.while_app/view/intro_screens/intro_page_3.dart';
import 'package:com.example.while_app/view/intro_screens/intro_page_4.dart';
import 'package:com.example.while_app/view/intro_screens/intro_page_5.dart';
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class OnBoardingScreen extends StatefulWidget {
  const OnBoardingScreen({super.key});

  @override
  _OnBoardingScreenState createState() => _OnBoardingScreenState();
}

class _OnBoardingScreenState extends State<OnBoardingScreen> {
  final PageController _controller = PageController();
  int currentPage = 0;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      if (currentPage != _controller.page?.round()) {
        setState(() {
          currentPage = _controller.page!.round();
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView(
            controller: _controller,
            children: [
              IntroPage1(),
              IntroPage2(),
              IntroPage3(),
              IntroPage4(),
              IntroPage5(),
            ],
            onPageChanged: (int page) {
              setState(() {
                currentPage = page;
              });
            },
          ),
          // Dot indicators and navigation buttons
          Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: Container(
              alignment: Alignment.center,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Skip
                  GestureDetector(
                    onTap: () {
                      _controller.jumpToPage(4); // Jump to the last page
                    },
                    child: Text("Skip", style: TextStyle(fontSize: 20),)
                  ),
                  // Dot indicator
                  SmoothPageIndicator(
                    controller: _controller,
                    count: 5,
                  ),
                  // Next or Done
                  GestureDetector(
                    onTap: () {
                      if (currentPage == 4) {
                        Navigator.of(context).push(MaterialPageRoute(builder: (context) => LoginScreen(),),);
                      } else {
                        _controller.nextPage(
                          duration: Duration(milliseconds: 500),
                          curve: Curves.easeInOut,
                        );
                      }
                    },
                    child: Text(currentPage == 4 ? 'Done' : 'Next', style: TextStyle(fontSize: 20),),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
