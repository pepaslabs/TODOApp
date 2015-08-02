//
//  TaskStore.swift
//  TODOApp
//
//  Created by Pepas Personal on 7/19/15.
//  Copyright (c) 2015 Pepas Personal. All rights reserved.
//

import Foundation

protocol TaskStoreProtocol
{
    func addTask(taskTitle: String)
    func tasksCount() -> Int
    func taskTitleAtIndex(index: Int) -> String?
    func deleteTaskAtIndex(index: Int)
    func moveTaskAtIndex(sourceIndex: Int, toIndex destinationIndex: Int)
    func setTaskTitle(title: String, atIndex index: Int)
}

class InMemoryTaskStore: TaskStoreProtocol
{
    private var tasks: [String] = [String]()
    
    func addTask(taskTitle: String)
    {
        tasks.append(taskTitle)
    }
    
    func tasksCount() -> Int
    {
        return count(tasks)
    }
    
    func taskTitleAtIndex(index: Int) -> String?
    {
        return tasks.get(index)
    }
    
    func deleteTaskAtIndex(index: Int)
    {
        tasks.removeAtIndex(index)
    }
    
    func moveTaskAtIndex(sourceIndex: Int, toIndex destinationIndex: Int)
    {
        let task = tasks.removeAtIndex(sourceIndex)
        tasks.insert(task, atIndex: destinationIndex)
    }
    
    func setTaskTitle(title: String, atIndex index: Int)
    {
        if index < tasks.count
        {
            tasks[index] = title
        }
    }
}

class NSUserDefaultsTaskStore: TaskStoreProtocol
{
    init(name: String)
    {
        self.name = name
        tasksNSUserDefaultsKey = "_tasks_\(name)_NSUserDefaultsKey"
        tasks = _loadTasksFromDisk()
    }
    
    func addTask(taskTitle: String)
    {
        tasks.append(taskTitle)
        _writeTasksToDisk()
    }
    
    func tasksCount() -> Int
    {
        return count(tasks)
    }
    
    func taskTitleAtIndex(index: Int) -> String?
    {
        return tasks.get(index)
    }

    func deleteTaskAtIndex(index: Int)
    {
        tasks.removeAtIndex(index)
        _writeTasksToDisk()
    }
    
    func moveTaskAtIndex(sourceIndex: Int, toIndex destinationIndex: Int)
    {
        let task = tasks.removeAtIndex(sourceIndex)
        tasks.insert(task, atIndex: destinationIndex)
        _writeTasksToDisk()
    }

    func setTaskTitle(title: String, atIndex index: Int)
    {
        if index < tasks.count
        {
            tasks[index] = title
            _writeTasksToDisk()
        }
    }

    private var tasks: [String] = [String]()
    private var name: String
    private let tasksNSUserDefaultsKey: String
    
    private func _loadTasksFromDisk() -> [String]
    {
        if var tasks = NSUserDefaults.standardUserDefaults().arrayForKey(tasksNSUserDefaultsKey) as? [String]
        {
            return tasks
        }
        else
        {
            return [String]()
        }
    }
    
    private func _writeTasksToDisk()
    {
        NSUserDefaults.standardUserDefaults().setObject(tasks, forKey: tasksNSUserDefaultsKey)
    }
}

