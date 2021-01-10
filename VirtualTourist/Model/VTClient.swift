//
//  VTClient.swift
//  VirtualTourist
//
//  Created by 邱浩庭 on 8/1/2021.
//

import Foundation
import OAuthSwift
import Alamofire
import UIKit

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
    private static let imageBaseURL = "https://live.staticflickr.com/"
    
    /**
     Search photos assoicate with specific locaton
     */
    public static func searchForPhotoes(lat: Double, lon: Double) {
        let paramters: [String: Any] = ["method": "flickr.photos.search",
                         "api_key": Auth.apiKey,
                         "lat": lat,
                         "lon": lon,
                         "format": "json",
                         "nojsoncallback": 1]
    
        AF.request(VTClient.baseURL, method: .get, parameters: paramters).validate().responseDecodable(of: PhotoSearch.self) { (response) in
            switch response.result {
            case .success:
                AppData.photos = response.value
                downloadImages(photos: AppData.photos!.photos)
                NotificationCenter.default.post(name: .didReceivePhotoInfoUpdate, object: nil)
            case .failure:
                print(response.debugDescription)
            }
        }
    }
    
    /**
     Download images to display
     */
    public static func downloadImages(photos: Photos) {
        AppData.images = []
        for photo in photos.photo {
            DispatchQueue.global(qos: .userInteractive).sync {
                let url = imageBaseURL + "\(photo.server)/\(photo.id)_\(photo.secret)_m.jpg"
                AF.request(url, method: .get).validate().responseData { (response) in
                    switch response.result {
                    case .success:
                        AppData.images.append(UIImage(data: response.value!)!)
                        NotificationCenter.default.post(name: .didReceivePhotoInfoUpdate, object: nil)
                    case .failure:
                        print(response.debugDescription)
                    }
                }
            }
        }
    }
}
