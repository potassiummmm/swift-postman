//
//  RequestModel.swift
//  NetworkToolbox
//
//  Created by 周涵嵩 on 2021/12/22.
//

import Foundation

enum MethodType: String, CaseIterable, Identifiable {
    case GET
    case POST
    var id: String { self.rawValue }
}
