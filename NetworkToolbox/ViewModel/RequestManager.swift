//
//  RequestManager.swift
//  NetworkToolbox
//
//  Created by 周涵嵩 on 2021/12/22.
//

import Foundation
import Combine
import SwiftUI
import Alamofire


class RequestManager: ObservableObject {
    @Published var response: AFDataResponse<Data?>!
    
    @Published var isSuccess: Bool = false
    
    @Published var showDetail: Bool = false
    
    private lazy var userDefaults = UserDefaults.standard
    
    func setStatus(success: Bool) {
        self.isSuccess = success
    }
    
    func sendRequest(name: String, url: String, method: MethodType, parameters: [[String]], headers: [[String]], body: [[String]]) {
        AF.request(url, parameters: convertToDict(parameters)).response { _response in
            switch _response.result {
            case .success:
                self.response = _response
                self.isSuccess = true
                self.showDetail = true
                
            case let .failure(error):
                self.isSuccess = false
                self.showDetail = false
                print(error)
            }
        }
    }
}
