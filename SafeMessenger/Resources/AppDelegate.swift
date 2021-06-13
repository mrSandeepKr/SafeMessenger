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
        FirebaseApp.configure()
        
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
        
        guard let email = user.profile.email,
              let firstName = user.profile.givenName,
              let secondName = user.profile.familyName
        else {
            return
        }
        
        print("AppDelegate: \(firstName)'s info recieved from Google")
        
        ApiHandler.shared.userExists(with: email) { exists in
            if !exists {
                let userInfo = ChatAppUserModel(firstName: firstName,
                                                secondName: secondName ,
                                                email: email)
                ApiHandler.shared.insertUserToDatabase(user: userInfo) {[weak self] success in
                    if success {
                        let fileName = userInfo.profileImageString
                        guard user.profile.hasImage, let url = user.profile.imageURL(withDimension: 200)
                        else {
                            print("AppDelegate: Google doens't have user profile Image")
                            let data = UIImage(named: "personPlaceholder")?.pngData()
                            self?.uploadImage(with: data!, fileName: fileName)
                            return
                        }
                        
                        URLSession.shared.dataTask(with: URLRequest(url: url)) {[weak self] data, _, err in
                            guard err == nil, let data = data else {
                                return
                            }
                            print("AppDelegate: Fetched Google Profile Image")
                            self?.uploadImage(with: data, fileName: fileName)
                        }.resume()
                    }
                }
            }
        }
        
        guard let authentication = user.authentication else {
            print("AppDelegate: Missing Auth Object from user")
            return
        }
        
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken,
                                                       accessToken: authentication.accessToken)
        
        FirebaseAuth.Auth.auth().signIn(with: credential) { authResult, err in
            guard authResult != nil, err == nil else {
                print("AppDelegate: Auth Missing or there is and error in google SignIn")
                return
            }
            print("AppDelegat: Successful Sign In")
            UserDefaults.standard.setValue(email, forKey: UserDefaultConstant.userEmail)
            NotificationCenter.default.post(name: .didLogInNotification, object: nil)
        }
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        print("AppDelegate: Google User disconnected")
    }
    
    func application(_ application: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any]) -> Bool {
        return GIDSignIn.sharedInstance().handle(url)
    }
}

extension AppDelegate {
    private func uploadImage(with data: Data,fileName: String) {
        StorageManager.shared.uploadProfileImage(with: data, fileName: fileName) { res in
            switch res {
            case .success(let downloadURL) :
                UserDefaults.standard.setValue(downloadURL, forKey: UserDefaultConstant.profileImageUrl)
                break
            case .failure(_) :
                break
            }
        }
    }
}
