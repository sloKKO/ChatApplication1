<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Deafult.aspx.cs" Inherits="ChatApplication1.Deafult" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>My Chat application :)</title>
    <script src="Scripts/jquery-3.4.1.min.js"></script>
    <script src="Scripts/jquery.signalR-2.2.2.min.js"></script>
    <script src="signalr/hubs"></script>
</head>
<body>
   
    Enter name:<input id="txtName" type="text" />
    <input id="btnSetName" type="button" value="Set Name" /> <br /><br/>

    Enter Message:<input id="txtMessage" type="text" style="width:400px;" />
    <input id="btnGiveCommand" type="button" value="Give Voice Command" />
    <input id="btnSend" type="button" value="Send Message" /><br /><br />

    <div id="divName" style="display:block;margin:5px auto;font-size:20px;width:200px;text-align:center;"></div>
    <div id="divMessages" style="display:block;width:500px;margin:0 auto;border:1px solid green;height:1000px;"></div>


    <script>
        $(function () {
            let txtName = document.querySelector('#txtName');
            let btnSetName = document.querySelector("#btnSetName");
            let txtMessage = document.querySelector('#txtMessage');
            let btnSend = document.querySelector('#btnSend');
            let divName = document.querySelector('#divName');
            let divMessages = document.querySelector('#divMessages');

            let chat = $.connection.chatHub;

            btnSetName.onclick = function () {
                divName.innerText = `Name: ${txtName.value}`;
            }

            chat.client.sendMessage = function (name, message) {
                $(divMessages).append($(`<div style='border:2px solid orange;padding:5px;margin:5px; background:green; color:yellow;'>
                                <b>${name}: </b> ${message}</div>`))
            }

            $.connection.hub.start().done(function () {
                btnSend.onclick = function () {
                    chat.server.send(`${txtName.value}`, `${txtMessage.value}`);
                };
            });

            //Speech recognision , it is use web speech API and we need to create the object for this recognision ans speech grammar classes.
           
            var SpeechRecognition = SpeechRecognition || webkitSpeechRecognition;
            var SpeechGrammarList = SpeechGrammarList || webkitSpeechGrammarList;
            var SpeechRecognitionEvent = SpeechRecognitionEvent || webkitSpeechRecognitionEvent

            var grammar = '#JSGF V1.0;'

            var recognition = new SpeechRecognition();
            var speechRecognitionList = new SpeechGrammarList();
            speechRecognitionList.addFromString(grammar, 1);
            recognition.grammars = speechRecognitionList;
            recognition.log = 'en-US';
            recognition.interimResults = true;

            recognition.onresult = function (event) {
                let command = event.results[0][0].transcript;
                let isFinal = event.results[0].isFinal;
                txtMessage.value = command;
                if (isFinal) {
                    chat.server.send(txtName.value, command);
                }
            };
            document.querySelector('#btnGiveCommand').onclick = function () {
                recognition.start();
            };
            recognition.onspeechend = function () {
                recognition.stop();
            };
            recognition.onerror = function (event) {
                txtMessage.value = 'Error occured in recognition:' + event.error;
            }

            });






    </script>




</body>
</html>
