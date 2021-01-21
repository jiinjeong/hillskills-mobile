/* ************************************************************************
 * FILE : chat.dart
 * DESC : Creates feed for single chat
 * ************************************************************************
 */

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:HillSkills/data/globalWidgets.dart';
import 'package:HillSkills/data/globals.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:HillSkills/utils/backend/accountManagement.dart';
import 'package:HillSkills/utils/backend/chatInteraction.dart';
import 'package:HillSkills/utils/backend/userInteraction.dart';
import 'package:HillSkills/utils/dateFormatting.dart';
import 'package:HillSkills/utils/navigation.dart';

class ChatPage extends StatefulWidget {

  final Chat chat;
  ChatPage(this.chat, {Key key}) : super(key: key);

  @override
  ChatPageState createState() => new ChatPageState();
}

// Dynamic data for widget
class ChatPageState extends State<ChatPage> {

  static final TextEditingController messageController = TextEditingController();
  Chat chat;
  ScrollController feedScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    chat = this.widget.chat;
  }

  Widget displayTimeStamp(time){
    return Center(
      child: Container(
        padding: EdgeInsets.only(top: 10, bottom: 2),
        child: Text(
          dateToDisplay(time),
        )
      )
    );
  }

  // Main feed for single chat
  Widget buildMessageFeed(){
    return StreamBuilder(
      stream: chat.chatStream,
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot){

        // If no data yet
        if (!snapshot.hasData && !snapshot.hasError) return Center(child: CircularProgressIndicator());
        else if (snapshot.hasError || snapshot.data == null || snapshot.data.docs.isEmpty) return Center();

        // Get data from snapshot
        List<QueryDocumentSnapshot> builderData = snapshot.data.docs;

        // Build a list of messages
        return ListView.builder(
          reverse: true,
          scrollDirection: Axis.vertical,
          controller: feedScrollController,
          itemCount: builderData.length,
          itemBuilder: ((BuildContext buildContext, int index) {

            // Creates message
            ChatMessage chatMessage = ChatMessage().fromJson(
              builderData[index].id,
              builderData[index].data()
            );

            bool sameAsPrevious = false;
            bool sameAsNext = false;
            bool firstOfDay = false;

            // Checks if newer message exists
            if (index - 1 >= 0) {
            
              // Checks if sent on same day as the next item
              if(sameDate(
                localize(builderData[index - 1].data()[DATETIME_STR]),
                chatMessage.dateTimeStr
              ))

                // If same author as next item
                if (builderData[index - 1].data()[AUTHOR] == chatMessage.author)

                  // Checks messages within 15 minutes of each other
                  if(withinMinutes(
                    15,
                    localize(builderData[index - 1].data()[DATETIME_STR]),
                    chatMessage.dateTimeStr
                  ))

                    // If all true, same as next
                    sameAsNext = true;
            }

            // Checks if older message exists
            if (index  + 1 < builderData.length) {

              // Checks if sent on same day as the previous item
              if (!sameDate(
                localize(builderData[index + 1].data()[DATETIME_STR]),
                chatMessage.dateTimeStr
              ))

                // If first sent on new day
                firstOfDay = true;

              // If same author as previous item
              else if (builderData[index + 1].data()[AUTHOR] == chatMessage.author)

                // Checks messages within 15 minutes of each other
                if(withinMinutes(
                  15,
                  localize(builderData[index + 1].data()[DATETIME_STR]),
                  chatMessage.dateTimeStr
                ))

                  // If all true, same as previous
                  sameAsPrevious = true;
            }

            // Checks if message first in feed
            else
              firstOfDay = true;

            return firstOfDay
              ? ListView(
                primary: false,
                shrinkWrap: true,
                children: [
                displayTimeStamp(chatMessage.dateTimeStr),
                ChatMessageBubble(
                  chatMessage,
                  otherUser: chat.otherUser,
                  sameAsNext: sameAsNext,
                  sameAsPrevious: sameAsPrevious,
                  key: UniqueKey()
                )
              ])
              : ChatMessageBubble(
                chatMessage,
                otherUser: chat.otherUser,
                sameAsNext: sameAsNext,
                sameAsPrevious: sameAsPrevious,
                key: UniqueKey()
              );
          })
        );
      },
    );
  }

  void sendMessage() {

    // Runs if message valid
    if (messageController.text.isNotEmpty || messageController.text.trim().isNotEmpty ) {

      // Creates object
      ChatMessage chatMessage = ChatMessage(
        text: messageController.text,
        author: AccountManagement().currentUserId()
      );

      // Clears textfield
      messageController.clear();

      // Submits to backend
      ChatInteraction().addMessage(chat.id, chatMessage);

      // Scrolls to bottom
      if(feedScrollController.hasClients)
        feedScrollController.animateTo(
          0.0, duration: Duration(milliseconds: 300), curve: Curves.easeOut);

    }
  }

  // Bar at top of widget with link to other user's profile
  Widget makeTopBar () {
    return AppBar(
      centerTitle: true,
      title: InkWell(
        borderRadius: BorderRadius.all(Radius.circular(10)),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 8, horizontal: 14),
          child: Wrap(
            direction: Axis.horizontal,
            children: <Widget>[
              chat.otherUser.userAvatar(
                radius: 32,
                padding: EdgeInsets.only(right: 14)
              ),
              Text(chat.otherUser.userName, overflow: TextOverflow.clip),
              SizedBox(width: 23),
            ]
          ),
        ),
        onTap: () => locator<NavigationService>().navigateWithParameters(
          '/profile',
          chat.otherUser
        )
      )
    );
  }

  // Widget used to type and send messages
  Container sendMessageBar() {
    return Container(
      margin: EdgeInsets.only(left: 14, right: 14, bottom: 24, top: 14),
      child: Row(
        children: <Widget>[

          // Field in which user types
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 14, horizontal: 18),
              decoration: BoxDecoration(
                borderRadius: VERY_ROUND,
                color: currentTheme.cardColor()
              ),
              child: scrollWithoutAnimation(
                child: TextField(
                  style: TextStyle(fontSize: 15.5),
                  strutStyle: StrutStyle(forceStrutHeight: true, fontSize: 15.5),
                  textCapitalization: TextCapitalization.sentences,
                  decoration:  InputDecoration.collapsed(hintText: "Start typing..."),
                  controller: messageController,
                  minLines: 1,
                  maxLines: 5
                )
              )
            )
          ),

          // Button used to send messages
          Container(
            margin: const EdgeInsets.only(left: 8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: PRIMARY_COLOR
            ),
            child: Material(
              borderRadius: BorderRadius.all(Radius.circular(100)),
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.all(Radius.circular(100)),
                child: Container(padding: EdgeInsets.all(14),
                  child: Icon(
                    Icons.send,
                    size: 21,
                    color: Colors.white,
                  ),
                ),
                onTap: ()=> sendMessage()
              ),
            )
          )
        ]
      )
    );
  }

  Widget build(BuildContext context) {
    return Scaffold(
      key: snackbarKeys[CHAT],
      appBar: makeTopBar(),
      body: Column(
        children: [
          Expanded(child: buildMessageFeed()),
          sendMessageBar()
        ]
      )
    );
  }
}

// Contains one individual chat bubble
class ChatMessageBubble extends StatefulWidget {

  final ChatMessage chatMessage;
  final UserAccount otherUser;
  final bool sameAsNext;
  final bool sameAsPrevious;

  ChatMessageBubble(this.chatMessage,
    {this.otherUser, this.sameAsNext, this.sameAsPrevious, Key key}) : super(key: key);

  @override
  ChatMessageBubbleState createState() => new ChatMessageBubbleState();
}

class ChatMessageBubbleState extends State<ChatMessageBubble> {

  bool sent = false;
  bool showDate = false;

  // Generates text for message
  Text messagingText(String textStr) {
    return Text(
      textStr,
      strutStyle: StrutStyle(forceStrutHeight: true, fontSize: 15.5),
      style: TextStyle(
        fontSize: 15.5,
        color: sent
          ? Colors.white
          : currentTheme.isDarkModeEnabled
            ? Colors.white
            : Colors.black
      ),
    );
  }

  Widget bubbleTime(String timeStr) {

    return new AnimatedContainer(duration: const Duration(milliseconds: 120),

      // Time hidden by default
      height: showDate ? 20 : 0,
      
      child: Padding(
        // Padding before time
        padding: sent
          ? EdgeInsets.only(right: 14, top: 2)
          : this.widget.sameAsNext
            ? EdgeInsets.only(left: 14, top: 2)
            : EdgeInsets.only(left: (39.0 + 14.0), top: 2),

        // Text of time
        child: Text(
          formattedTime(timeStr),
          style: TextStyle(
            color:
            Colors.grey.withOpacity(0.7),
            fontSize: 12
          )
        )
      )
    );
  }

  BorderRadius bubbleRadius() {
    return sent
    ? BorderRadius.only(
      topLeft: Radius.circular(24),
      bottomLeft: Radius.circular(24),
      topRight: this.widget.sameAsPrevious
        ? Radius.circular(4)
        : Radius.circular(24),
      bottomRight: this.widget.sameAsNext
        ? Radius.circular(4)
        : Radius.circular(24),
    )

    : BorderRadius.only(
      topRight: Radius.circular(24),
      bottomRight: Radius.circular(24),
      topLeft: this.widget.sameAsPrevious
        ? Radius.circular(4)
        : Radius.circular(24),
      bottomLeft: this.widget.sameAsNext
        ? Radius.circular(4)
        : Radius.circular(24),
    );
  }

  Color bubbleColor() {
    return sent
      ? PRIMARY_COLOR
      : currentTheme.isDarkModeEnabled
        ? Color(0xfff2E2E2E)
        : Color(0xfffEEEEEE);
  }

  EdgeInsetsGeometry bubblePadding() {
    return EdgeInsets.only(
      left: sent
        ? 0
        : this.widget.sameAsNext
          ? (39.0 + 12.0)
          : 12,
      right: sent ? 12 : 0,
      bottom: this.widget.sameAsNext ? 2 : 9,
      top: this.widget.sameAsPrevious ? 2 : 9
    );
  }

  // Actual bubble with text
  Widget messageBubble(String message) {
    return Container(

      // Max width of bubble
      constraints: BoxConstraints(
        maxWidth: !sent && !this.widget.sameAsNext
          ? MediaQuery.of(context).size.width * .75 - (39.0)
          : MediaQuery.of(context).size.width * .75
      ),

      // Clickable text widget
      child: Material(

        // Can vary
        color: bubbleColor(),
        borderRadius: bubbleRadius(),
        
        child: InkWell(

          // Can vary
          borderRadius: bubbleRadius(),

          // Whether to show date
          onTap: () => setState((){showDate = !showDate;}),
          onLongPress: () {
            Clipboard.setData(ClipboardData(text: message));
            showSnackBar(CHAT, 'Text copied to clipboard.');
          },

          // Message text
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 9, horizontal: 15),
            child: messagingText(message)
          )
        )
      )
    );
  }

  Widget makeMessage(String message, String timeStr){
    return Container(
      padding: bubblePadding(),

      child: Flex(
        crossAxisAlignment: sent
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
        direction: Axis.vertical,
        children: [

          // Message bubble
          !sent && !this.widget.sameAsNext

            // With Avatar
            ? Flex(
              direction: Axis.horizontal,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                this.widget.otherUser.userAvatar(
                  radius: 31,
                  padding: EdgeInsets.only(right: 8)
                ),
                messageBubble(message)
              ]
            )

            // Without avatar
            : messageBubble(message),

          // Sent time
          bubbleTime(timeStr)
        ]
      )
    );
  }

  @override
  Widget build(BuildContext context) {

    // Determines if sent by current user
    if (this.widget.chatMessage.author != this.widget.otherUser.id)
      sent = true;

    // Message Widget
    return makeMessage(this.widget.chatMessage.text, this.widget.chatMessage.dateTimeStr);
  }
}