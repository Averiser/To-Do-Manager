//
//  Task.swift
//  To-Do Manager
//
//  Created by MyMacBook on 14.07.2022.
//

import Foundation

// task type
enum TaskPriority {
  // current
  case normal
  // important
  case important
}

// task status
enum TaskStatus: Int {
  // planned
  case planned
  // finished
  case completed
}

//  requirements to type describing substance "Task"
protocol TaskProtocol {
  var title: String {get set}
  var type: TaskPriority {get set}
  var status: TaskStatus {get set}
}

// substance "Task"
struct Task: TaskProtocol {
  var title: String
  var type: TaskPriority
  var status: TaskStatus
}
