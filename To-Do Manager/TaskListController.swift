//
//  TaskListController.swift
//  To-Do Manager
//
//  Created by MyMacBook on 14.07.2022.
//

import UIKit

class TaskListController: UITableViewController {
  
  // task storage
  var tasksStorage: TasksStorageProtocol = TasksStorage()
  // task collection
  var tasks: [TaskPriority: [TaskProtocol]] = [:]
  
  // порядок отображения секций по типам
  // индекс в массиве соответствует индексу секции в таблице
  
  var sectionsTypesPosition: [TaskPriority] = [.important, .normal]
  
  // rendering order of tasks acc. to status
  var tasksStatusPosition: [TaskStatus] = [.planned, .completed]
  

    override func viewDidLoad() {
        super.viewDidLoad()

        loadTasks()
    }
  
  private func loadTasks() {
    // подготовка коллекции с задачами
    // будем использовать только те задачи, для которых определена секция в таблице
    sectionsTypesPosition.forEach { taskType in
      tasks[taskType] = []
    }
    // загрузка и разбор задач из хранилища
    tasksStorage.loadTasks().forEach { task in
      tasks[task.type]?.append(task)
    }
    
    for (tasksGroupPriority, tasksGroup) in tasks {
      tasks[tasksGroupPriority] = tasksGroup.sorted { task1, task2 in
        let task1position = tasksStatusPosition.firstIndex(of: task1.status) ?? 0
        let task2position = tasksStatusPosition.firstIndex(of: task2.status) ?? 0
        return task1position < task2position
      }
    }
  }
  
  override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    var title: String?
    let tasksType = sectionsTypesPosition[section]
    if tasksType == .important {
      title = "Important"
    } else if tasksType == .normal  {
      title = "Current"
    }
    return title
  }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
      return tasks.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let taskType = sectionsTypesPosition[section]
        guard let currentTasksType = tasks[taskType] else {
        return 0
      }
      return currentTasksType.count
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

      return configuredTaskCell_constraints(for: indexPath)
    }
  
  // ячейка на основе ограничений
  private func configuredTaskCell_constraints(for indexPath: IndexPath) -> UITableViewCell {
    // load a cell prototype based on identifier
    let cell = tableView.dequeueReusableCell(withIdentifier: "taskCellConstraints", for: indexPath)
    // получаем данные о задаче, которую необходимо вывести в ячейке
    let taskType = sectionsTypesPosition[indexPath.section]
    guard let currentTask = tasks[taskType]?[indexPath.row] else {
      return cell
    }
  
  let symbolLabel = cell.viewWithTag(1) as? UILabel
  let textLabel = cell.viewWithTag(2) as? UILabel

  // изменяем символ в ячейке
  symbolLabel?.text = getSymbolForTask(with: currentTask.status)
  // change text in cell
  textLabel?.text = currentTask.title
  
  if currentTask.status == .planned {
    textLabel?.textColor = .black
    symbolLabel?.textColor = .black
  } else {
    textLabel?.textColor = .lightGray
    symbolLabel?.textColor = .lightGray
      }
    return cell
  }
  
  private func getSymbolForTask(with status: TaskStatus) -> String {
    var resultSymbol: String
    if status == . planned {
      resultSymbol = "\u{25CB}"
    } else if status == .completed {
      resultSymbol = "\u{25C9}"
    } else {
      resultSymbol = ""
    }
    return resultSymbol
  }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
