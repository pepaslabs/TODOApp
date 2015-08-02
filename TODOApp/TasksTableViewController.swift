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
    
    override func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle
    {
        return .None
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
        
        actionSheet.addDefaultAction("Mark Done", handler: { [weak self] (action) -> Void in
            self?._markDoneActionDidGetSelected(index)
        })

        actionSheet.addDefaultAction("Edit", handler: { [weak self] (action) -> Void in
            self?._editActionDidGetSelected(index)
        })

        actionSheet.addDefaultAction("Reorder", handler: { [weak self] (action) -> Void in
            self?._reorderActionDidGetSelected()
        })
        
        actionSheet.addDestructiveAction("Delete", handler: { [weak self] (action) -> Void in
            self?._deleteActionDidGetSelected(index)
        })
        
        actionSheet.addCancelAction("Cancel", handler: { [weak self] (action) -> Void in
            self?._cancelActionDidGetSelected()
        })
        
        return actionSheet
    }
    
    private func _cancelActionDidGetSelected()
    {
        if let selectedIndexPath = tableView.indexPathForSelectedRow()
        {
            tableView.deselectRowAtIndexPath(selectedIndexPath, animated: true)
        }
    }
    
    private func _deleteActionDidGetSelected(index: Int)
    {
        dataSource.deleteTaskAtIndex(index)
    }
    
    private func _editActionDidGetSelected(index: Int)
    {
        _presentEditTaskViewController(index)
    }

    private func _reorderActionDidGetSelected()
    {
        _enterTableViewEditingMode()
    }
    
    private func _markDoneActionDidGetSelected(index: Int)
    {
        dataSource.markTaskDoneAtIndex(index)
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
        _presentNewTaskViewController()
    }

    private func _addDoneBarButtonItemToNavBar()
    {
        navigationItem.rightBarButtonItem = _createDoneBarButtonItem()
    }
    
    private func _createDoneBarButtonItem() -> UIBarButtonItem
    {
        let action: Selector = "doneButtonDidGetTapped"
        let barButtonItem = UIBarButtonItem(barButtonSystemItem: .Done,
            target: self,
            action: action)
        return barButtonItem
    }
    
    func doneButtonDidGetTapped()
    {
        _leaveTableViewEditingMode()
    }
}

extension TasksTableViewController: ModalTaskCapturingDelegateProtocol
{
    func taskCapturingModalDidFinishCreatingNewTask(taskTitle: String)
    {
        dataSource.addTask(taskTitle)
        presentedViewController?.dismissViewControllerAnimated(true, completion: nil)
    }

    func taskCapturingModalDidFinishEditingExistingTask(data: TaskEditingData)
    {
        dataSource.setTaskTitle(data.title, atIndex: data.index)
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
        dataSource.taskStore = NSUserDefaultsTaskStore(name: "To-Do")
        dataSource.doneTaskStore = NSUserDefaultsTaskStore(name: "Done")
        dataSource.tableView = tableView
        tableView.dataSource = dataSource
    }
    
    private func _enterTableViewEditingMode()
    {
        tableView.setEditing(true, animated: true)
        _addDoneBarButtonItemToNavBar()
    }
    
    private func _leaveTableViewEditingMode()
    {
        tableView.setEditing(false, animated: true)
        _addPlusBarButtonItemToNavBar()
    }
    
    private func _presentEditTaskViewController(index: Int)
    {
        if let title = dataSource.taskStore?.taskTitleAtIndex(index)
        {
            let data = TaskEditingData(title: title, index: index)
            _presentEditTaskViewController(data)
        }
    }
    
    private func _presentEditTaskViewController(data: TaskEditingData)
    {
        let vc = EditTaskViewController.instantiateFromStoryboard(existingTaskData: data)
        vc.taskCapturingDelegate = self
        _presentTaskCapturingViewController(vc)
    }
    
    private func _presentNewTaskViewController()
    {
        let vc = EditTaskViewController.instantiateFromStoryboard(existingTaskData: nil)
        vc.taskCapturingDelegate = self
        _presentTaskCapturingViewController(vc)
    }
    
    private func _presentTaskCapturingViewController(vc: EditTaskViewController)
    {
        let navC = UINavigationController(rootViewController: vc)
        presentViewController(navC, animated: true, completion: nil)
    }
}
