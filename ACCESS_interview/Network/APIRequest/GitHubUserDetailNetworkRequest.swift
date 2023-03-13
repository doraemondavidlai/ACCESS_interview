//
//  GitHubUserDetailNetworkRequest.swift
//  ACCESS_interview
//
//  Created by 賴永峰 on 2023/3/13.
//

import Foundation

class GitHubUserDetailNetworkRequest: NetworkRequestOperation {
  init(_ loginName: String) {
    super.init()
    sendGetRequest(urlString: String(format: "https://api.github.com/users/%@", loginName))
  }
  
  override func success(_ data: Data) {
    super.success(data)
    
    guard let dictionary = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? NSMutableDictionary else {
      print(data as Any)
      return
    }
    
    print(dictionary)
    
#warning("implement: save to coredata")
    
  }
  
  override func failure(_ error: Error?, _ data: Data?) {
    super.failure(error, data)
  }
}
