//
//  GitHubUserListNetworkRequest.swift
//  ACCESS_interview
//
//  Created by 賴永峰 on 2023/3/13.
//

import Foundation

class GitHubUserListNetworkRequest: NetworkRequestOperation {
  init(_ since: Int64) {
    super.init()
    sendGetRequest(urlString: String(format: "https://api.github.com/users?per_page=%d&since=%d", 20, since))
  }
  
  override func success(_ data: Data) {
    super.success(data)
    
    guard let userArray = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [NSMutableDictionary] else {
      print(data as Any)
      print(String(data: data, encoding: .utf8) as Any)
      return
    }
    
//    print(userArray)
    
    DispatchQueue.global(qos: .default).async {
      GitUserHandler.updateUsers(userArray)
    }
  }
  
  override func failure(_ error: Error?, _ data: Data?) {
    super.failure(error, data)
  }
}
