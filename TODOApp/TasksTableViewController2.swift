//
//  TasksTableViewController22.swift
//  TODOApp
//
//  Created by Pepas Personal on 8/2/15.
//  Copyright (c) 2015 Pepas Personal. All rights reserved.
//

import UIKit

class TasksTableViewController2Factory
{
    class func createDefaultController() -> TasksTableViewController2
    {
        let name = "To-Do"
        let vc = TasksTableViewController2.instantiateFromStoryboard(name: name)
        vc.dataSource = TasksTableViewDataSource2(name: name)
        vc.cellEditMenuDelegate = CellEditMenuDelegate()
        vc.modalTaskCapturingDelegate = ModalTaskCapturingDelegate()
        vc.addTaskDelegate = AddTaskDelegate()
        return vc
    }
    
    class func createDoneController() -> TasksTableViewController2
    {
        let name = "Done"
        let vc = TasksTableViewController2.instantiateFromStoryboard(name: name)
        vc.dataSource = TasksTableViewDataSource2(name: name)
        return vc
    }
}

class TasksTableViewController2: UITableViewController
{
    private var name: String!
    private var dataSource: TasksTableViewDataSource2?
    private var cellEditMenuDelegate: CellEditMenuDelegate?
    private var modalTaskCapturingDelegate: ModalTaskCapturingDelegate?
    private var addTaskDelegate: AddTaskDelegate?
}

// MARK: Factory methods
extension TasksTableViewController2
{
    class func storyboard() -> UIStoryboard
    {
        let storyboard = UIStoryboard(name: "TasksTableViewController2", bundle: nil)
        return storyboard
    }
    
    class func instantiateFromStoryboard(#name: String) -> TasksTableViewController2
    {
        let storyboard = self.storyboard()
        let vc = storyboard.instantiateViewControllerWithIdentifier("TasksTableViewController2") as! TasksTableViewController2
        vc.name = name
        return vc
    }
}

// MARK: View Lifecycle
extension TasksTableViewController2
{
    override func viewDidLoad()
    {
        super.viewDidLoad()
        title = name
        _setupDelegates()
        _setupTableView()
        _setupNavBarButtons()
    }
}

extension TasksTableViewController2: UITableViewDelegate
{
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        cellEditMenuDelegate?.showMenuForCellAtIndex(indexPath.row)
    }
    
    override func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle
    {
        return .None
    }
}

// MARK: private helpers
extension TasksTableViewController2
{
    private func _setupTableView()
    {
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier:"UITableViewCell")
        dataSource?.tableView = tableView
        tableView.dataSource = dataSource
    }

    private func _setupNavBarButtons()
    {
        addTaskDelegate?.addPlusBarButtonItemToNavBar()
    }
    
    private func _setupDelegates()
    {
        modalTaskCapturingDelegate?.viewController = self
        modalTaskCapturingDelegate?.dataSource = dataSource
        
        cellEditMenuDelegate?.dataSource = dataSource
        cellEditMenuDelegate?.tableView = tableView
        cellEditMenuDelegate?.viewController = self
        cellEditMenuDelegate?.modalTaskCapturingDelegate = modalTaskCapturingDelegate
        cellEditMenuDelegate?.navigationItem = navigationItem
        
        addTaskDelegate?.viewController = self
        addTaskDelegate?.navigationItem = navigationItem
        addTaskDelegate?.modalTaskCapturingDelegate = modalTaskCapturingDelegate
    }
}


class CellEditMenuDelegate
{
    weak var viewController: UIViewController?
    weak var tableView: UITableView?
    weak var dataSource: TasksTableViewDataSource2?
    weak var modalTaskCapturingDelegate: ModalTaskCapturingDelegate?
    weak var navigationItem: UINavigationItem?
    
    private var preservedBarButtonItem: UIBarButtonItem?
    
    func showMenuForCellAtIndex(index: Int)
    {
        let actionSheet = _createMenuForCellAtIndex(index)
        viewController?.presentViewController(actionSheet, animated: true, completion: nil)
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
        if let selectedIndexPath = tableView?.indexPathForSelectedRow()
        {
            tableView?.deselectRowAtIndexPath(selectedIndexPath, animated: true)
        }
    }
    
    private func _deleteActionDidGetSelected(index: Int)
    {
        dataSource?.deleteTaskAtIndex(index)
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
        dataSource?.markTaskDoneAtIndex(index)
    }
    
    private func _presentEditTaskViewController(index: Int)
    {
        if let title = dataSource?.taskStore?.taskTitleAtIndex(index)
        {
            let data = TaskEditingData(title: title, index: index)
            _presentEditTaskViewController(data)
        }
    }
    
    private func _presentEditTaskViewController(data: TaskEditingData)
    {
        let vc = EditTaskViewController.instantiateFromStoryboard(existingTaskData: data)
        vc.taskCapturingDelegate = modalTaskCapturingDelegate
        let navC = UINavigationController(rootViewController: vc)
        viewController?.presentViewController(navC, animated: true, completion: nil)
    }
    
    private func _enterTableViewEditingMode()
    {
        tableView?.setEditing(true, animated: true)
        _addDoneBarButtonItemToNavBar()
    }
    
    private func _leaveTableViewEditingMode()
    {
        tableView?.setEditing(false, animated: true)
        navigationItem?.rightBarButtonItem = preservedBarButtonItem
    }

    private func _addDoneBarButtonItemToNavBar()
    {
        preservedBarButtonItem = navigationItem?.rightBarButtonItem
        navigationItem?.rightBarButtonItem = _createDoneBarButtonItem()
    }
    
    private func _createDoneBarButtonItem() -> UIBarButtonItem
    {
        let action: Selector = "doneButtonDidGetTapped"
        let barButtonItem = UIBarButtonItem(barButtonSystemItem: .Done,
            target: self,
            action: action)
        return barButtonItem
    }
    
    @objc func doneButtonDidGetTapped()
    {
        _leaveTableViewEditingMode()
    }
}

class AddTaskDelegate
{
    weak var viewController: UIViewController?
    weak var navigationItem: UINavigationItem?
    weak var modalTaskCapturingDelegate: ModalTaskCapturingDelegate?

    func addPlusBarButtonItemToNavBar()
    {
        navigationItem?.rightBarButtonItem = _createPlusBarButtonItem()
    }
    
    private func _createPlusBarButtonItem() -> UIBarButtonItem
    {
        let action: Selector = "plusButtonDidGetTapped"
        let barButtonItem = UIBarButtonItem(barButtonSystemItem: .Add,
            target: self,
            action: action)
        return barButtonItem
    }
    
    @objc func plusButtonDidGetTapped()
    {
        _presentNewTaskViewController()
    }
    
    private func _presentNewTaskViewController()
    {
        let vc = EditTaskViewController.instantiateFromStoryboard(existingTaskData: nil)
        vc.taskCapturingDelegate = modalTaskCapturingDelegate
        let navC = UINavigationController(rootViewController: vc)
        viewController?.presentViewController(navC, animated: true, completion: nil)
    }
}

class ModalTaskCapturingDelegate: ModalTaskCapturingDelegateProtocol
{
    weak var viewController: UIViewController?
    weak var dataSource: TasksTableViewDataSource2?

    func taskCapturingModalDidFinishCreatingNewTask(taskTitle: String)
    {
        dataSource?.addTask(taskTitle)
        viewController?.presentedViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func taskCapturingModalDidFinishEditingExistingTask(data: TaskEditingData)
    {
        dataSource?.setTaskTitle(data.title, atIndex: data.index)
        viewController?.presentedViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func taskCapturingModalDidCancel()
    {
        viewController?.presentedViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
}

