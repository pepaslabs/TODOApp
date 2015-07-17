//
//  ViewController.swift
//  TODOApp
//
//  Created by Pepas Personal on 7/12/15.
//  Copyright (c) 2015 Pepas Personal. All rights reserved.
//

import UIKit

protocol TaskStoreProtocol
{
    func addTask(taskTitle: String)
    func tasksCount() -> Int
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
}

class NSUserDefaultsTaskStore: TaskStoreProtocol
{
    init()
    {
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
    
    private var tasks: [String] = [String]()

    private let _tasksNSUserDefaultsKey: String = "_tasksNSUserDefaultsKey"
    
    private func _loadTasksFromDisk() -> [String]
    {
        if var tasks = NSUserDefaults.standardUserDefaults().arrayForKey(_tasksNSUserDefaultsKey) as? [String]
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
        NSUserDefaults.standardUserDefaults().setObject(tasks, forKey: _tasksNSUserDefaultsKey)
    }
}

class ViewController: UIViewController, ModalTaskCapturingDelegateProtocol
{
    @IBOutlet weak var taskCountLabel: UILabel!
    private var taskStore: TaskStoreProtocol = NSUserDefaultsTaskStore()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool)
    {
        super.viewWillAppear(animated)
        _updateTaskCountLabel()
    }
    
    private func _updateTaskCountLabel()
    {
        taskCountLabel.text = "\(taskStore.tasksCount())"
    }
}

// MARK: Target/Action
extension ViewController
{
    @IBAction func buttonDidGetTapped(sender: AnyObject)
    {
        let vc = NewTaskViewController.instantiateFromStoryboard()
        vc.taskCapturingDelegate = self
        
        let navC = UINavigationController(rootViewController: vc)
        presentViewController(navC, animated: true, completion: nil)
    }
}

extension ViewController: ModalTaskCapturingDelegateProtocol
{
    func taskCapturingModalDidFinish(taskTitle: String)
    {
        taskStore.addTask(taskTitle)
        _updateTaskCountLabel()
        presentedViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func taskCapturingModalDidCancel()
    {
        presentedViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
}

