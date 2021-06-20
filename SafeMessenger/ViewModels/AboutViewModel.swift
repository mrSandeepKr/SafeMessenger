//
//  AboutViewModel.swift
//  SafeMessenger
//
//  Created by Sandeep Kumar on 20/06/21.
//

import Foundation

class AboutViewModel {
    var aboutMessage: String?
    var loggedInUserEmail: String
    let defaultAboutMessage = "Would you like to add something about yourself"
    
    init() {
        aboutMessage = defaultAboutMessage
        loggedInUserEmail = Utils.shared.getLoggedInUserEmail() ?? ""
    }
    
    func getAboutString(completion:@escaping SuccessCompletion) {
        DispatchQueue.background(background: {[weak self] in
            guard let strongSelf = self else {
                return
            }
            ProfileCardService.shared.fetchAboutString(for: strongSelf.loggedInUserEmail) {[weak strongSelf] res in
                switch res {
                case .success(let aboutStringFetched):
                    strongSelf?.aboutMessage = aboutStringFetched
                    completion(true)
                case .failure(_):
                    print("AboutViewModel: Couldn't Fetch AboutString")
                    completion(false)
                }
            }
        })
    }
    
    func setAboutString(aboutString: String,completion:@escaping SuccessCompletion) {
        DispatchQueue.background(background: {[weak self] in
            guard let strongSelf = self
            else {
                return
            }
            ProfileCardService.shared.setAboutString(info: aboutString) {[weak strongSelf] success in
                if success {
                    strongSelf?.aboutMessage = aboutString
                }
                completion(success)
            }
        })
    }
}
