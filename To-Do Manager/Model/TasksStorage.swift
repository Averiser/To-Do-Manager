//
//  TasksStorage.swift
//  To-Do Manager
//
//  Created by MyMacBook on 14.07.2022.
//

import Foundation

protocol TasksStorageProtocol {
  func loadTasks() -> [TaskProtocol]
  func saveTasks(_ tasks: [TaskProtocol])
}

class TasksStorage: TasksStorageProtocol {
  func loadTasks() -> [TaskProtocol] {
    // temporal realization which returns test task collection
    let testTasks: [TaskProtocol] = [
      Task(title: "Buy food", type: .normal, status: .planned),
      Task(title: "Wash cat", type: .important, status: .planned),
      Task(title: "pay off debt", type: .important, status: .completed),
      Task(title: "Buy vacuum cleaner", type: .normal, status: .completed),
      Task(title: "Give flowers", type: .important, status: .planned),
      Task(title: "Make phone call", type: .important, status: .planned),
      Task(title: "Invite to a party Dolf, Vika, Jeniffer, Christine, Ludwig, Thomas", type: .important, status: .planned)
    ]
    
    return testTasks
  }
  
  func saveTasks(_ tasks: [TaskProtocol]) {
    
  }
  
  
}
