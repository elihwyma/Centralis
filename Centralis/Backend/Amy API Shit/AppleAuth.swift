//
//  AppleAuth.swift
//  Shimmer
//
//  Created by Somica on 01/08/2022.
//

import UIKit
import AuthenticationServices

final class AppleAuth: AuthenticationService {
    
    private var completion: ((_ token: String?, _ identityToken: String?) -> Void)?
        
    override func authenticate(window: UIWindow?, completion: @escaping (_ token: String?, _ identityToken: String?) -> Void) {
        super.authenticate(window: window, completion: completion)
        self.completion = completion
        
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let appleIDRequest = appleIDProvider.createRequest()
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [appleIDRequest])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
    
}

extension AppleAuth: ASAuthorizationControllerDelegate {
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        guard let completion = completion else { return }
        switch authorization.credential {
        case let appleIDCredential as ASAuthorizationAppleIDCredential:
            let userID = appleIDCredential.user
            guard let identityToken = appleIDCredential.identityToken else {
                return completion(nil, nil)
            }
            print("Poopy bum")
            completion(userID, String(decoding: identityToken, as: UTF8.self))
        default:
            completion(nil, nil)
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        completion?(nil, nil)
    }
    
}
