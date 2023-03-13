//
//  NetworkManager.swift
//  ACCESS_interview
//
//  Created by 賴永峰 on 2023/3/13.
//

import Foundation

class NetworkController: NSObject {
  static let shared = NetworkController()
  
  private let queue: OperationQueue = {
    let queue = OperationQueue()
    queue.name = "networkqueue"
    queue.maxConcurrentOperationCount = 4
    return queue
  }()
  
  func getUserList(since: Int) {
    let operation = GitHubUserListNetworkRequest(since)
    queue.addOperation(operation)
  }
  
  func getUserDetail(loginName: String) {
    let operation = GitHubUserDetailNetworkRequest(loginName)
    queue.addOperation(operation)
  }
}
