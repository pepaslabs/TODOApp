//
//  TasksTableViewDataSource22.swift
//  TODOApp
//
//  Created by Pepas Personal on 8/2/15.
//  Copyright (c) 2015 Pepas Personal. All rights reserved.
//

import UIKit

class TaskStoreRepository
{
    static var sharedInstance: TaskStoreRepository = TaskStoreRepository()
    
    private var stores = [String: TaskStoreProtocol]()
    
    func taskStore(name: String) -> TaskStoreProtocol
    {
        if let store = stores[name]
        {
            return store
        }
        else
        {
            let store = NSUserDefaultsTaskStore(name: name)
            stores[name] = store
            return store
        }
    }
}

class TasksTableViewDataSource2: NSObject
{
    let name: String
    
    init(name: String)
    {
        self.name = name
        taskStore = TaskStoreRepository.sharedInstance.taskStore(name)
        doneTaskStore = TaskStoreRepository.sharedInstance.taskStore("Done")
    }
    
    weak var taskStore: TaskStoreProtocol?
    weak var doneTaskStore: TaskStoreProtocol?
    
    weak var tableView: UITableView?
    
    func addTask(taskTitle: String)
    {
        taskStore?.addTask(taskTitle)
        tableView?.reloadData()
    }
    
    func deleteTaskAtIndex(index: Int)
    {
        taskStore?.deleteTaskAtIndex(index)
        _deleteRowAtIndex(index)
    }
    
    func markTaskDoneAtIndex(index: Int)
    {
        if name == "Done"
        {
            return
        }
        
        if let title = taskStore?.taskTitleAtIndex(index)
        {
            taskStore?.deleteTaskAtIndex(index)
            doneTaskStore?.addTask(title)
            _deleteRowAtIndex(index)
        }
    }
    
    func setTaskTitle(title: String, atIndex index: Int)
    {
        taskStore?.setTaskTitle(title, atIndex: index)
        _reloadRowAtIndex(index)
    }
}

extension TasksTableViewDataSource2: UITableViewDataSource
{
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if let store = taskStore
        {
            return store.tasksCount()
        }
        else
        {
            return 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCellWithIdentifier("UITableViewCell", forIndexPath: indexPath) as! UITableViewCell
        
        let title = taskStore?.taskTitleAtIndex(indexPath.row) ?? ""
        cell.configureWithTaskTitle(title)
        
        return cell
    }
    
    func tableView(tableView: UITableView, moveRowAtIndexPath sourceIndexPath: NSIndexPath, toIndexPath destinationIndexPath: NSIndexPath)
    {
        taskStore?.moveTaskAtIndex(sourceIndexPath.row, toIndex: destinationIndexPath.row)
    }
}

// MARK: private helpers
extension TasksTableViewDataSource2
{
    private func _deleteRowAtIndex(index: Int)
    {
        let indexPath = NSIndexPath(forRow: index, inSection: 0)
        tableView?.deleteRowsAtIndexPaths([indexPath], withRowAnimation:.Automatic)
    }
    
    private func _reloadRowAtIndex(index: Int)
    {
        let indexPath = NSIndexPath(forRow: index, inSection: 0)
        tableView?.reloadRowsAtIndexPaths([indexPath], withRowAnimation:.Automatic)
    }
}

extension UITableViewCell
{
    func configureWithTaskTitle(title: String)
    {
        textLabel?.text = title
    }
}
