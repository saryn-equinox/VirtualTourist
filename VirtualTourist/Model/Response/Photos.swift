//
//  Photoes.swift
//  VirtualTourist
//
//  Created by 邱浩庭 on 9/1/2021.
//

import Foundation

struct Photos: Codable {
    let page: Int
    let pages: Int
    let perpage: Int
    let total: String
    var photo: [PhotoInfo]
}
