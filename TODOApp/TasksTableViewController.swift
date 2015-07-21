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

extension TasksTableViewController: UITableViewDelegate
{
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        _showMenuForCellAtIndex(indexPath.row)
    }
}

// MARK: Cell editing methods
extension TasksTableViewController
{
    private func _showMenuForCellAtIndex(index: Int)
    {
        let actionSheet = _createMenuForCellAtIndex(index)
        presentViewController(actionSheet, animated: true, completion: nil)
    }
    
    private func _createMenuForCellAtIndex(index: Int) -> UIAlertController
    {
        let actionSheet = UIAlertController(title:nil, message:nil, preferredStyle:.ActionSheet)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { [weak self] (action) -> Void in
            if let selectedIndexPath = self?.tableView.indexPathForSelectedRow()
            {
                self?.tableView.deselectRowAtIndexPath(selectedIndexPath, animated: true)
            }
        }
        actionSheet.addAction(cancelAction)
        
        let deleteAction = UIAlertAction(title: "Delete", style: .Destructive) { [weak self] (action) -> Void in
            self?.dataSource.deleteTaskAtIndex(index)
        }
        actionSheet.addAction(deleteAction)

        return actionSheet
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
