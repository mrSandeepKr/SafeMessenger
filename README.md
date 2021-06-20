#  <img src="/SafeMessenger/Resources/Assets.xcassets/AppIcon.appiconset/100.png" width="33" height="33" /> Safe Messenger

Project is a an attempt to set up a Real Time Chat Application. The service is Firebase supported. 
Person can look-up existing Users by their email and name, see their Presence updating and Chat with them in Real Time.
It was build keeping MVVM architecture on mind. The Controller, Views Just interact with the ViewModel and Model to get the Data to render.
The Netork Managing is still something that needs improvement on as it using Singletons, the preferred mode would be Dependecy Injections but it seemed like an overkill.
<br>
The user can: 
1. Create an account with his email or Log In with Google.
2. See Messages in Real Time.
3. See if User is online or not.
4. Supported Message Types 
    * Text
    * Location
    * Image
    * Video
5. Update profile Info
    * Status Message
    * Phone Number
    * Address
6. Delete Conversation
7. Have an experience on his present Theme
    
### Set Up
1. `git clone https://github.com/mrSandeepKr/safeMessenger`
2. Run `pod install` to get the project dependencies
3. Open `SafeMessenger.xcworkspace` and Run the project

### Preview
