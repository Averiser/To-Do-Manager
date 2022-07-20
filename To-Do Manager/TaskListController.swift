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
  
  var tasks: [TaskPriority:[TaskProtocol]] = [:] {
    didSet {
      for (tasksGroupPriority, tasksGroup) in tasks {
        tasks[tasksGroupPriority] = tasksGroup.sorted{ task1, task2 in
          let task1position = tasksStatusPosition.firstIndex(of:
                                                              task1.status) ?? 0
          let task2position = tasksStatusPosition.firstIndex(of:
                                                              task2.status) ?? 0
          return task1position < task2position
        }
      }
      // сохранение задач
      var savingArray: [TaskProtocol] = []
      tasks.forEach { _, value in
        savingArray += value
      }
      tasksStorage.saveTasks(savingArray)
    }
  }
  
  // порядок отображения секций по типам
  // индекс в массиве соответствует индексу секции в таблице
  
  var sectionsTypesPosition: [TaskPriority] = [.important, .normal]
  
  // rendering order of tasks acc. to status
  var tasksStatusPosition: [TaskStatus] = [.planned, .completed]
  

    override func viewDidLoad() {
        super.viewDidLoad()
//      Не хватает указания на удаление строки (сейчас закомментирована) из viewDidLoad, иначе приложение продолжает затирать данные 
//        loadTasks()
      // кнопка активации режима редактирования
      navigationItem.leftBarButtonItem = editButtonItem
    }
  
   private func loadTasks() {
    
    // подготовка коллекции с задачами
    // будем использовать только те задачи, для которых определена секция в таблице
    sectionsTypesPosition.forEach { taskType in
      tasks[taskType] = []
    }
//    // загрузка и разбор задач из хранилища
    tasksStorage.loadTasks().forEach { task in
      tasks[task.type]?.append(task)
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
      // cell based on constraints
//      return configuredTaskCell_constraints(for: indexPath)
      // cell based on stack
      return getConfiguredTaskCell_stack(for: indexPath)
    }
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    // 1. Check whether task does exist
    let taskType = sectionsTypesPosition[indexPath.section]
    guard let _ = tasks[taskType]?[indexPath.row] else {
      return
    }
      // 2. Make sure task is not completed
      guard tasks[taskType]![indexPath.row].status == .planned else {
        // withdraw highlighting off the line
        tableView.deselectRow(at: indexPath, animated: true)
        return
      }
      // 3. Mark task as completed
      tasks[taskType]![indexPath.row].status = .completed
      // 4. Reload section
      tableView.reloadSections(IndexSet(arrayLiteral: indexPath.section), with: .automatic)
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


  private func getConfiguredTaskCell_stack(for indexPath: IndexPath) -> UITableViewCell {
    // загружаем прототип ячейки по идентификатору
    let cell = tableView.dequeueReusableCell(withIdentifier: "taskCellStack", for: indexPath) as! TaskCell
    // получаем данные о задаче, которые необходимо вывести в ячейке
    let taskType = sectionsTypesPosition[indexPath.section]
    guard let currentTask = tasks[taskType]?[indexPath.row] else {
      return cell
    }
    
    // change text, symbol in a cell
    cell.title.text = currentTask.title
    cell.symbol.text = getSymbolForTask(with: currentTask.status)
    
    // change cell colour
    if currentTask.status == .planned {
      cell.title.textColor = .black
      cell.symbol.textColor = .black
    } else {
      cell.title.textColor = .lightGray
      cell.symbol.textColor = .lightGray
    }
    return cell
  }
  
  override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
    // получаем данные о задаче, которую необходимо перевести в статус "запланирована"
    let taskType = sectionsTypesPosition[indexPath.section]
    guard let _ = tasks[taskType]?[indexPath.row] else {
      return nil
    }
      
//    // проверяем, что задача имеет статус "выполнено"
//    guard tasks[taskType]![indexPath.row].status == .completed else {
//      return nil
//    }
    // создаем действие для изменения статуса
    let actionSwipeInstance = UIContextualAction(style: .normal, title: "Not completed") { _, _, _ in
      self.tasks[taskType]![indexPath.row].status = .planned
      self.tableView.reloadSections(IndexSet(arrayLiteral: indexPath.section), with: .automatic)
    }
    
    // действие для перехода к экрану редактирования
    let actionEditInstance = UIContextualAction(style: .normal, title: "Edit") { _, _, _ in
      // загрузка сцены со storyboard
      let editScreen = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TaskEditController") as! TaskEditController
      // передача значений редактируемой задачи
      editScreen.taskText = self.tasks[taskType]![indexPath.row].title
      editScreen.taskType = self.tasks[taskType]![indexPath.row].type
      editScreen.taskStatus = self.tasks[taskType]![indexPath.row].status
      // передача обработчика для сохранения задачи
      editScreen.doAfterEdit = {[self] title, type, status in
        let editedTask = Task(title: title, type: type, status: status)
        tasks[taskType]![indexPath.row] = editedTask
        tableView.reloadData()
      }
      // переход к экрану редактирования
      self.navigationController?.pushViewController(editScreen, animated: true)
    }
    // изменяем цвет фона кнопки с действием
    actionEditInstance.backgroundColor = .darkGray
    
    // создаем объект, описывающий доступные действия
    // в зависимости от статуса задачи будет отображено 1 или 2 действия
    let actionsConfiguration: UISwipeActionsConfiguration
    if tasks[taskType]![indexPath.row].status == .completed {
      actionsConfiguration = UISwipeActionsConfiguration(actions: [actionSwipeInstance, actionEditInstance])
    } else {
      actionsConfiguration = UISwipeActionsConfiguration(actions: [actionEditInstance])
    }
    // возвращаем настроенный объект
    return actionsConfiguration
  }

  override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
    
    let taskType = sectionsTypesPosition[indexPath.section]
    // remove a task
    tasks[taskType]?.remove(at: indexPath.row)
    // remove a line corresponding to the task
    // удаляем строку, соответствующую задаче
    tableView.deleteRows(at: [indexPath], with: .automatic)
  }
  
  override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
    return true
  }
  
  override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
    let taskTypeFrom = sectionsTypesPosition[sourceIndexPath.section]
    let taskTypeTo = sectionsTypesPosition[destinationIndexPath.section]
    
    // безопасно извлекаем задачу, тем самым копируем ее
    guard let movedTask = tasks[taskTypeFrom]?[sourceIndexPath.row] else { return
    }
    // удаляем задачу с места, откуда она перенесена
    tasks[taskTypeFrom]!.remove(at: sourceIndexPath.row)
    // вставляем задачу на новую позицию
    tasks[taskTypeFrom]!.insert(movedTask, at: destinationIndexPath.row)
    // если секция изменилась, изменяем тип задачи в соответствии с новой позицией
    if taskTypeFrom != taskTypeTo {
      tasks[taskTypeTo]![destinationIndexPath.row].type == taskTypeTo
    }
    // update data
    tableView.reloadData()
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "toCreateScreen" {
      let destination = segue.destination as! TaskEditController
      destination.doAfterEdit = {[unowned self] title, type, status in
        let newTask = Task(title: title, type: type, status: status)
        tasks[type]?.append(newTask)
        tableView.reloadData()
      }
    }
  }
  
  // получение списка задач, их разбор и установка в свойство tasks
  func setTasks(_ tasksCollection: [TaskProtocol]) {
    // подготовка коллекции с задачами
    // будем использовать только те задачи, для которых определена секция
    sectionsTypesPosition.forEach { taskType in
      tasks[taskType] = []
    }
    // загрузка и разбор задач из хранилища
    tasksCollection.forEach { task in
      tasks[task.type]?.append(task)
    }
  }
  
}

