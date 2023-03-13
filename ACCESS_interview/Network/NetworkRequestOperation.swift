//
//  NetworkRequestOperation.swift
//  ACCESS_interview
//
//  Created by 賴永峰 on 2023/3/13.
//

import Foundation

class NetworkRequestOperation: Operation {
  var data: Data!
  var error: Error?
  fileprivate var timeoutIntervalForRequest: Double = 10
  fileprivate var task: URLSessionTask!
  
  func success(_ data: Data) {
    self.data = data
  }
  
  func failure(_ error: Error?, _ data: Data?) {
    self.error = error
    self.data = data
    var response: String?
    
    do {
      let data = try JSONSerialization.data(withJSONObject: self, options: .fragmentsAllowed)
      response = String(data: data, encoding: .utf8)
    } catch {
      let fetchError = error as NSError
      print("\(fetchError), \(fetchError.userInfo)")
      return
    }
    
    if let url = task.originalRequest?.url {
      print("⁉️ \(url) task failure\nError: \(error.debugDescription)\nresponse:\(response ?? "nil")")
    } else {
      assertionFailure()
    }
    
    let errorMessage = String(describing: error)
    print(errorMessage)
  }
  
  func sendGetRequest(urlString: String) {
    guard let url = URL(string: urlString) else {
      print("⁉️ urlString error: \(urlString)")
      assertionFailure()
      return
    }
    
    var request = URLRequest(url: url,
                             cachePolicy: .useProtocolCachePolicy,
                             timeoutInterval: timeoutIntervalForRequest)
    request.httpMethod = "GET"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    
    task = URLSession.shared.dataTask(with: request) { data, response, error in
      if error != nil {
        self.failure(error, data)
        return
      }
      
      guard let nonNilData = data else {
        self.failure(error, data)
        return
      }
      
      self.success(nonNilData)
    }
    
    task.resume()
  }
}
