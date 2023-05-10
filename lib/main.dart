import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:text_to_speech/text_to_speech.dart';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:chat_gpt_sdk/chat_gpt_sdk.dart';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;
final GoogleSignIn googleSignIn = GoogleSignIn();

Future<String> signInWithGoogle() async {
  // Trigger the Google Authentication flow
  final GoogleSignInAccount? googleSignInAccount = await googleSignIn.signIn();

  // Obtain the Google Authentication credentials
  final GoogleSignInAuthentication googleAuth = await googleSignInAccount!.authentication;

  // Create a new Firebase credential with the Google Authentication credentials
  final OAuthCredential credential = GoogleAuthProvider.credential(
    accessToken: googleAuth.accessToken,
    idToken: googleAuth.idToken,
  );

  // Sign in to Firebase with the Google credentials
  final UserCredential userCredential = await _auth.signInWithCredential(credential);
  final User? user = userCredential.user;

  if (user != null) {
    // Return the user ID token
    return await user.getIdToken();
  } else {
    throw Exception('Failed to sign in with Google');
  }
}


  void main() async {
    // Initialize Firebase
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'GPT-3 by Tamim',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurpleAccent),
        useMaterial3: false,
      ),
      home: const MyHomePage(title: 'GPT-3 AI by Tamim'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var results = "results"; //texts written in the input on the send button
  // we declare open AI
  late ChatGPT openAI;
  //text Controller
  TextEditingController textEditingController = TextEditingController();
  //List messages
  List<ChatMessage> messages = [];
  ChatUser user = ChatUser(id: "1", firstName: "Tamim", lastName: "Golam");
  ChatUser openGPT = ChatUser(id: "2", firstName: "AI", lastName: "GPT3");
  //this is texttospeech library honestly this part of the implementation is hard for me to understand :/
  late TextToSpeech tts;

  void initializeTTS() async {
    await tts.setLanguage("en-US");
  }

  //this bool if user press button on tap
  bool isTTS = false;
  //initialize speech to text library
  SpeechToText _speechToText = SpeechToText();
  //bool for the mic
  bool _speechEnabled = false;
//This code reach for the API GPT
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    openAI = ChatGPT.instance.builder(
        baseOption: HttpSetup(receiveTimeout: 16000));
    tts = TextToSpeech();
    initializeTTS();
    _initSpeech();
  }

  //initiazing mic functionality
  void _initSpeech() async {
    _speechEnabled = await _speechToText.initialize();
    setState(() {});
  }

  //Each time to start a speech recognition session
  void _startListening() async {
    await _speechToText.listen(onResult: _onSpeechResult);
    setState(() {});
  }


  //Manually stop the active speech recognition session
  //Note that there are also timeouts that each platform enforces
  // and the SpeechToText plugin supports setting timeouts on the
  // listen method.
  void _stopListening() async {
    await _speechToText.stop();
    setState(() {});
  }

  /// This is the callback that the SpeechToText plugin calls when
  /// the platform returns recognized words.
  void _onSpeechResult(SpeechRecognitionResult result) {
    if (result.finalResult) {
      setState(() {
        //The text widget will catch the result of the messages
        textEditingController.text = result.recognizedWords;
        //this will send our result to chat gpt
        chatAction();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor:Colors.purple,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title. also we added padding and widget so that icons dont go far right
        title: Text("Tamim GPT-3"),
        centerTitle: true,
        actions: [
          InkWell(
            onTap: () {
              setState(() {
                if (isTTS) {
                  isTTS = false;
                  //this will stop the voice
                  tts.stop();
                } else {
                  isTTS = true;
                }
              });
            },
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(isTTS
                  ? Icons.spatial_audio_off_outlined
                  : Icons.voice_over_off_sharp),
            ),
          )
        ],leading: InkWell(
        onTap: () {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text("""Informations/Notice(j'espere que vous en voudrez pas que se soit en anglais) """),
              content: Text("""Hello i am Tamim(Student in App development and crazy about mobile development) ,i made this app with the help of an udemy course to learn more about flutter and integrating an Open AI API in an app.\nIf you want to generate an image type'generate image of',the mic sadly doesn't work well on the web version.\nPlease take a look at  my portfolio: https://portfoliogolamtamim.web.app/#/ or if you want to contact me: golam.tamim94@gmail.com for the code source (i'm not making my API key public xD) or anything else """),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Okay'),
                ),
              ],
            ),
          );
        },
        child: Icon(Icons.info),
      ),
      ),
      body: Container(
        decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage('images/BLABLA.jpg'), fit: BoxFit.cover,)),
        child: Center(
          // Center is a layout widget. It takes a single child and positions it
          // in the middle of the parent.
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              //  chatgpt replys inside this widget text
              Expanded(
                child: DashChat(
                  currentUser: user,
                  onSend: (ChatMessage m) {
                    setState(() {
                      messages.insert(0, m);
                    });
                  },
                  messages: messages,
                  // this will hide the 2nd bar chat
                  readOnly: true,
                ),
              ), //The row for the text  input and the button
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                        child:
                            //Card widget to shape the text field
                            Card(
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25)),
                      child:
                          // We are padding this child because its to close from the bottom screen from the phone atleast
                          Padding(
                        padding: const EdgeInsets.only(left: 14.0),
                        child: TextField(
                          controller: textEditingController,
                          //this will remove the line from the text field
                          decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText:
                                  "type/écrit something to test  Tamim app made with gpt-3/flutter!"),
                        ),
                      ),
                    )),
                    //speech button bassically a copy paste of the send button
                    ElevatedButton(
                        onPressed: () {

                            if (_speechEnabled == false) {
                              // If it is false, call the _startListening() method to start speech recognition
                              _startListening();
                              _speechEnabled = true;
                            } else {
                              // If it is true, call the _stopListening() method to stop speech recognition
                              _stopListening();
                              _speechEnabled = false;
                            }
                          },
                        child: Icon(Icons.mic),
                        //This will shape the button format
                        style: ElevatedButton.styleFrom(
                            shape: CircleBorder(),
                            padding: EdgeInsets.all(12),
                            backgroundColor: Colors.purple)),
                    //Button will communicate with gpt
                    ElevatedButton(
                        onPressed: () {
                          //we call chat action that was here fully here before
                          chatAction();
                        },
                        child: Icon(Icons.send),
                        //This will shape the button format
                        style: ElevatedButton.styleFrom(
                            shape: CircleBorder(),
                            padding: EdgeInsets.all(12),
                            backgroundColor: Colors.purple))
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  chatAction() {
    {
      //ChatMessages objet to make the messages appear on the app
      ChatMessage messge = ChatMessage(
          user: user,
          createdAt: DateTime.now(),
          text: textEditingController.text);
      setState(() {
        messages.insert(0, messge);
      });
      //Button property for text button  here :) took me 1h to find out i put it inside '' by mistake

      //If methode which one dalle or gpt user will call
      if (textEditingController.text.toLowerCase().startsWith("get an image of")) {
        final request =
            GenerateImage(textEditingController.text, 1, size: '512x512');
        openAI
            .generateImageStream(request)
            .asBroadcastStream()
            .first
            .then((it) {
          print(it.data?.last?.url);
          for (var imgData in it.data!) {
            ChatMessage messge = ChatMessage(
                user: openGPT,
                createdAt: DateTime.now(),
                text: "Image",
                medias: [
                  ChatMedia(
                      url: imgData!.url!,
                      fileName: "image",
                      type: MediaType.image)
                ]);
            setState(() {
              messages.insert(0, messge);
            });
          }
          //This below will put the drawing inside chatbox

          //this will put image inside the widget results
          results = it.data!.last!.url!;
          setState(() {
            results;
          });
        });
      } else {
        final request = CompleteReq(
            prompt: textEditingController.text,
            model: kTranslateModelV3,
            max_tokens: 200);
        // this underneat is the code to make text translate to thai which i used to test as an exemple
        /*final request = CompleteText(prompt: translateEngToThai(word:textEditingController.text),
                              model: kTranslateModelV3, maxTokens: 200);

                              openAI.onCompletionStream(request:request).listen((response) => print(response))
                                .onError((err) {
                                             print("$err");
                                  });*/
        //This is calling Dall e for generating image for now its a test
        /* final request = GenerateImage(textEditingController.text,1,size:'512x512' );
                          openAI.generateImageStream(request)
                              .asBroadcastStream()
                              .listen((it) {
                            print(it.data?.last?.url);
                            //this will put image inside thewidget results
                            results= it.data!.last!.url!;
                            setState(() {
                              results;
                            });
                          });*/

        openAI
            .onCompleteStream(request: request)
            // the message from gpt wont appear twice
            .first
            .then((response) {
              print(response!.model);
          //this will add chatgpt result inside the reponse box
          ChatMessage messge = ChatMessage(
              user: openGPT,
              createdAt: DateTime.now(),
              text: response!.choices!.first!.text!.trim());
          setState(() {
            messages.insert(0, messge);
          });
          /*response choice is added to results chatgpt will get the first result
                            results = response!.choices.first.text;
                            setState(() {
                              results;
                            });*/
          //look if tts is enable
          if (isTTS) {
            //this call the text to speech library
            tts.speak(response!.choices!.first!.text!.trim());
          }
        });
      }
      //this will clear the text after pushing the button
      textEditingController.clear();
      modelDataList();
    };
  }
  //method to use all the gpt model
  void modelDataList() async{
    final model = await ChatGPT.instance
    .builder("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")
    .listModel();
    for (var model in model.data){
      print(model.id+""+model.owned_by);

    }
  }
}
