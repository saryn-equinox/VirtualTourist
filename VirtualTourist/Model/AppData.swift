//
//  AppData.swift
//  VirtualTourist
//
//  Created by 邱浩庭 on 9/1/2021.
//

import Foundation
import UIKit

struct AppData {
    public static var photos: PhotoSearch?
    public static var images: [UIImage] = []
    public static let dataController: DataController = DataController(modelName: "VirtualTourist")
    
    init() {
        AppData.dataController.load()
    }
}
