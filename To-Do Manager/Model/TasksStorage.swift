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
  // Ссылка на хранилище
  private var storage = UserDefaults.standard
  // Ключ, по которому будет происходить сохранение и загрузка хранилища из User Defaults
  var storageKey: String = "tasks"
  
  // Перечисление с ключами для записи в User Defaults
  private enum TaskKey: String {
    case title
    case type
    case status
  }

  func loadTasks() -> [TaskProtocol] {
    // temporal realization which returns test task collection
    var resultTasks: [TaskProtocol] = []
    let tasksFromStorage = storage.array(forKey: storageKey) as? [[String:String]] ?? []
    for task in tasksFromStorage {
      guard let title = task[TaskKey.title.rawValue],
            let typeRaw = task[TaskKey.type.rawValue],
            let statusRaw = task[TaskKey.status.rawValue] else {
              continue
            }
//      let type: TaskPriority = typeRaw == "important" ? .important : .normal
      
      let type: TaskPriority = typeRaw == "important" ? .important : .normal
      let status: TaskStatus = statusRaw == "planned" ? .planned : .completed
      resultTasks.append(Task(title: title, type: type, status: status))
    }
    
//      Task(title: "Buy food", type: .normal, status: .planned),
//      Task(title: "Wash cat", type: .important, status: .planned),
//      Task(title: "pay off debt", type: .important, status: .completed),
//      Task(title: "Buy vacuum cleaner", type: .normal, status: .completed),
//      Task(title: "Give flowers", type: .important, status: .planned),
//      Task(title: "Make phone call", type: .important, status: .planned),
//      Task(title: "Invite to a party Dolf, Vika, Jeniffer, Christine, Ludwig, Thomas", type: .important, status: .planned)
    
    return resultTasks
  }
  
  func saveTasks(_ tasks: [TaskProtocol]) {
    var arrayForStorage: [[String: String]] = []
    tasks.forEach { task in
      var newElementForStorage: Dictionary<String, String> = [:]
      newElementForStorage[TaskKey.title.rawValue] = task.title
      newElementForStorage[TaskKey.type.rawValue] = (task.type == .important) ? "important" : "normal"
      newElementForStorage[TaskKey.status.rawValue] = (task.status == .planned) ? "planned" : "completed"
      arrayForStorage.append(newElementForStorage)
    }
    storage.set(arrayForStorage, forKey: storageKey)
  }
  
  
}
