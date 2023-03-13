//
//  Defines.swift
//  ACCESS_interview
//
//  Created by 賴永峰 on 2023/3/13.
//

import Foundation

enum NotificationType: String {
  case Network                        = "NetworkResponse"
  
  var notificationName: Notification.Name {
    return Notification.Name(rawValue: self.rawValue)
  }
}
