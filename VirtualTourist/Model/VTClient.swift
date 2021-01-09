//
//  VTClient.swift
//  VirtualTourist
//
//  Created by 邱浩庭 on 8/1/2021.
//

import Foundation
import OAuthSwift

class VTClient {

    
    struct Auth {
        static let apiKey = "48ac9b73677358d9f41770b725d1e38e"
        static let secret = "3df087102feacc87"
        
        // What is oauth call back ??
        // output The operation couldn’t be completed. (OAuthSwiftError error -10.)
        static func authorize() {
            var oatuh = OAuth1Swift(consumerKey: apiKey, consumerSecret: secret, requestTokenUrl: "https://www.flickr.com/services/oauth/request_token", authorizeUrl: "https://www.flickr.com/services/oauth/authorize", accessTokenUrl: "https://www.flickr.com/services/oauth/access_token")
            // authorize
            let handle = oatuh.authorize(
                withCallbackURL: "oauth-vt:authenticate") { result in
                switch result {
                case .success(let (credential, response, parameters)):
                    print(credential.oauthToken)
                    print(credential.oauthTokenSecret)
                  // Do your request
                case .failure(let error):
                  print(error.localizedDescription)
                }
            }
            
            print(handle.debugDescription)
        }
    }
    
    private static let baseURL = "https://www.flickr.com/services/rest/"
}
