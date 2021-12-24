//
//  StringUtils.swift
//  NetworkToolbox
//
//  Created by 周涵嵩 on 2021/12/23.
//

import Foundation


func makeURL(onBase baseURL: String, withPara parameters: [[String]]) -> String {
    var url = baseURL
    var isFirstPara = true
    for parameter in parameters {
        if parameter[0] != "" || parameter[1] != "" {
            if isFirstPara {
                url += ("?" + parameter[0] + "=" + parameter[1])
                isFirstPara = false
            } else {
                url += ("&" + parameter[0] + "=" + parameter[1])
            }
        }
    }
    return url
}

func convertToDict(_ parameters: [[String]]) -> [String: String] {
    var dict = [String: String]()
    for parameter in parameters {
        if parameter.isEmpty {
            return dict
        }
        if parameter[0] != "" || parameter[1] != "" {
            dict[parameter[0]] = parameter[1]
        }
    }
    return dict
}
