//
//  AuthenticationService.swift
//  Shimmer
//
//  Created by Amy While on 17/07/2022.
//

import UIKit
import AuthenticationServices

class AuthenticationService: NSObject {
    
    weak var window: UIWindow?
    
    required override init() {
        super.init()
    }

    func authenticate(window: UIWindow?, completion: @escaping (_ token: String?, _ identityToken: String?) -> Void) {
        self.window = window
    }
    
}

extension AuthenticationService: ASWebAuthenticationPresentationContextProviding, ASAuthorizationControllerPresentationContextProviding {
    
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        window ?? ASPresentationAnchor()
    }
    
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        window ?? ASPresentationAnchor()
    }
    
}
