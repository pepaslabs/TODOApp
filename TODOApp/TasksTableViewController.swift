//
//  TableViewController.swift
//  TODOApp
//
//  Created by Pepas Personal on 7/19/15.
//  Copyright (c) 2015 Pepas Personal. All rights reserved.
//

import UIKit

class TasksTableViewController: UITableViewController
{
    private var dataSource = TasksTableViewDataSource()
}

// MARK: Factory methods
extension TasksTableViewController
{
    class func storyboard() -> UIStoryboard
    {
        let storyboard = UIStoryboard(name: "TasksTableViewController", bundle: nil)
        return storyboard
    }
    
    class func instantiateFromStoryboard() -> TasksTableViewController
    {
        let storyboard = self.storyboard()
        let vc = storyboard.instantiateViewControllerWithIdentifier("TasksTableViewController") as! TasksTableViewController
        return vc
    }
}

// MARK: View Lifecycle
extension TasksTableViewController
{
    override func viewDidLoad()
    {
        super.viewDidLoad()
        title = "Tasks"
        _setupTableView()
        _setupNavBarButtons()
    }
}

// MARK: buttons
extension TasksTableViewController
{
    private func _setupNavBarButtons()
    {
        _addPlusBarButtonItemToNavBar()
    }
    
    private func _addPlusBarButtonItemToNavBar()
    {
        navigationItem.rightBarButtonItem = _createPlusBarButtonItem()
    }
    
    private func _createPlusBarButtonItem() -> UIBarButtonItem
    {
        let action: Selector = "plusButtonDidGetTapped"
        let barButtonItem = UIBarButtonItem(barButtonSystemItem: .Add,
            target: self,
            action: action)
        return barButtonItem
    }
    
    func plusButtonDidGetTapped()
    {
        let vc = NewTaskViewController.instantiateFromStoryboard()
        vc.taskCapturingDelegate = self
        
        let navC = UINavigationController(rootViewController: vc)
        presentViewController(navC, animated: true, completion: nil)
    }
}

extension TasksTableViewController: ModalTaskCapturingDelegateProtocol
{
    func taskCapturingModalDidFinish(taskTitle: String)
    {
        dataSource.addTask(taskTitle)
        presentedViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func taskCapturingModalDidCancel()
    {
        presentedViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
}

// MARK: private helpers
extension TasksTableViewController
{
    private func _setupTableView()
    {
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier:"UITableViewCell")
        dataSource.taskStore = NSUserDefaultsTaskStore()
        dataSource.tableView = tableView
        tableView.dataSource = dataSource
    }
}

class TasksTableViewDataSource: NSObject, UITableViewDataSource
{
    var taskStore: TaskStoreProtocol?
    weak var tableView: UITableView?

    func addTask(taskTitle: String)
    {
        taskStore?.addTask(taskTitle)
        tableView?.reloadData()
    }
    
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
        
        if let title = taskStore?.taskTitleAtIndex(indexPath.row)
        {
            cell.configureWithTaskTitle(title)
        }
        else
        {
            cell.textLabel?.text = ""
        }
        
        return cell
    }
}

extension UITableViewCell
{
    func configureWithTaskTitle(title: String)
    {
        textLabel?.text = title
    }
}

