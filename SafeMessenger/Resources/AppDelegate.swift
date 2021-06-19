//
//  AppDelegate.swift
//  SafeMessenger
//
//  Created by Sandeep Kumar on 21/05/21.
//

import UIKit
import Firebase
import GoogleSignIn

@main
class AppDelegate: UIResponder, UIApplicationDelegate, GIDSignInDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseConfiguration.shared.setLoggerLevel(.min)
        FirebaseApp.configure()
        _ = Database.database().reference()
        
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
        
        return true
    }
    
    // MARK: UISceneSession Lifecycle
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    //FIXME: This whole functions order is to be questioned because of the multiple API calls that are being made
    // A single failure shall corrupt the DataBase.
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        guard error == nil else {
            print("AppDelegate: Failed to Sign in with Google with \(String(describing: error))")
            return
        }
        
        let email = user.profile.email.lowercased()
        guard let firstName = user.profile.givenName,
              let secondName = user.profile.familyName
        else {
            return
        }
        
        print("AppDelegate: \(firstName)'s info recieved from Google")
        
        ApiHandler.shared.userExists(with: email) { exists in
            if !exists {
                let userInfo = ChatAppUserModel(firstName: firstName,
                                                secondName: secondName,
                                                email: email)
                
                let profileUploadCompletion: ResultStringCompletion = { res in
                    switch res {
                    case .success(let profileUrlString) :
                        let copyUser = ChatAppUserModel.getObject(for: userInfo, imageUrlString: profileUrlString)
                        
                        ApiHandler.shared.insertUserToDatabase(user: copyUser, completion: {_ in})
                        ApiHandler.shared.insertUserToSearchArray(user: copyUser, completion: {_ in})
                        break
                    case .failure(_):
                        break
                    }
                }
                
                let fileName = userInfo.profileImageString
                if user.profile.hasImage, let url = user.profile.imageURL(withDimension: 200) {
                    URLSession.shared.dataTask(with: URLRequest(url: url)) {data, _, err in
                        guard err == nil, let data = data else {
                            print("AppDelegate: Fetch Google Profile Image Failed")
                            return
                        }
                        print("AppDelegate: Fetch Google Profile Image Success")
                        StorageManager.shared.uploadUserProfileImage(with: data, fileName: fileName, completion: profileUploadCompletion)
                    }.resume()
                }
                else {
                    print("AppDelegate: Google doens't have user profile Image")
                    let data = UIImage(named: Constants.ImageNamePersonPlaceholder)?.pngData()
                    StorageManager.shared.uploadUserProfileImage(with: data!, fileName: fileName, completion: profileUploadCompletion)
                    return
                }
            }
        }
        
        guard let authentication = user.authentication else {
            print("AppDelegate: Missing Auth Object from user")
            return
        }
        
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken,
                                                       accessToken: authentication.accessToken)
        
        //userDefauls are already set just sign the user in here.
        //This is dicy, but thats how we roll
        FirebaseAuth.Auth.auth().signIn(with: credential) { authResult, err in
            guard authResult != nil, err == nil else {
                print("AppDelegate: Auth Missing or there is and error in google SignIn")
                return
            }
            print("AppDelegat: Successful Sign In")
            ApiHandler.shared.fetchLoggedInUserInfoAndSetDefaults(for: email) { success in
                if success {
                    NotificationCenter.default.post(name: .didLogInNotification, object: nil)
                }
            }
        }
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        print("AppDelegate: Google User disconnected")
    }
    
    func application(_ application: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any]) -> Bool {
        return GIDSignIn.sharedInstance().handle(url)
    }
}
