//
//  EditTaskViewController.swift
//  TODOApp
//
//  Created by Pepas Personal on 7/12/15.
//  Copyright (c) 2015 Pepas Personal. All rights reserved.
//

import UIKit

protocol ModalTaskCapturingDelegateProtocol: class
{
    func taskCapturingModalDidFinishCreatingNewTask(taskTitle: String)
    func taskCapturingModalDidFinishEditingExistingTask(data: TaskEditingData)
    func taskCapturingModalDidCancel()
}

struct TaskEditingData
{
    var title: String
    var index: Int
    
    init(title: String, index: Int)
    {
        self.title = title
        self.index = index
    }
}

class EditTaskViewController: UIViewController
{
    @IBOutlet weak var taskTitleTextField: UITextField!
    weak var taskCapturingDelegate: ModalTaskCapturingDelegateProtocol?
    
    deinit
    {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    private var data: TaskEditingData?
}

// MARK: Factory methods
extension EditTaskViewController
{
    class func storyboard() -> UIStoryboard
    {
        let storyboard = UIStoryboard(name: "EditTaskViewController", bundle: nil)
        return storyboard
    }
    
    class func instantiateFromStoryboard(#existingTaskData: TaskEditingData?) -> EditTaskViewController
    {
        let storyboard = self.storyboard()
        let vc = storyboard.instantiateViewControllerWithIdentifier("EditTaskViewController") as! EditTaskViewController
        vc.data = existingTaskData
        return vc
    }
}

// MARK: View Lifecycle
extension EditTaskViewController
{
    override func viewDidLoad()
    {
        super.viewDidLoad()
        _setupNavBar()
        _setupTextField()
        _setupBackgroundView()
    }
    
    override func viewWillAppear(animated: Bool)
    {
        super.viewWillAppear(animated)
        _subscribeToTextFieldNotifications()
        _updateNavBarDoneButtonEnabledness()
        taskTitleTextField.becomeFirstResponder()
    }

    override func viewDidDisappear(animated: Bool)
    {
        super.viewDidDisappear(animated)
        _unsubscribeFromTextFieldNotifications()
    }
}

extension EditTaskViewController: UITextFieldDelegate
{
    func textFieldShouldReturn(textField: UITextField) -> Bool
    {
        _textFieldDoneButtonWillGetTapped()
        return true
    }
}

// MARK: UITextField methods
extension EditTaskViewController
{
    private func _subscribeToTextFieldNotifications()
    {
        let action: Selector = "textFieldDidChangeNotificationHandler:"
        NSNotificationCenter.defaultCenter().addObserver(self,
            selector: action,
            name: UITextFieldTextDidChangeNotification,
            object: taskTitleTextField)
        
    }
    
    private func _unsubscribeFromTextFieldNotifications()
    {
        NSNotificationCenter.defaultCenter().removeObserver(self,
            name: UITextFieldTextDidChangeNotification,
            object: taskTitleTextField)
    }
    
    func textFieldDidChangeNotificationHandler(notification: NSNotification)
    {
        _updateNavBarDoneButtonEnabledness()
    }

    private func _setupTextField()
    {
        taskTitleTextField.returnKeyType = .Done
        taskTitleTextField.delegate = self
        taskTitleTextField.text = data?.title
    }
    
    private func _textFieldDoneButtonWillGetTapped()
    {
        doneButtonDidGetTapped()
    }
}

// MARK: buttons
extension EditTaskViewController
{
    private func _setupNavBarButtons()
    {
        _addCancelBarButtonItemToNavBar()
        _addDoneBarButtonItemToNavBar()
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
        taskTitleTextField.resignFirstResponder()
        _finishIfAppropriate()
    }
    
    private func _addCancelBarButtonItemToNavBar()
    {
        navigationItem.leftBarButtonItem = _createCancelBarButtonItem()
    }
    
    private func _createCancelBarButtonItem() -> UIBarButtonItem
    {
        let action: Selector = "cancelButtonDidGetTapped"
        let cancelBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Cancel,
            target: self,
            action: action)
        return cancelBarButtonItem
    }
    
    func cancelButtonDidGetTapped()
    {
        taskTitleTextField.resignFirstResponder()
        taskCapturingDelegate?.taskCapturingModalDidCancel()
    }
    
    private func _updateNavBarDoneButtonEnabledness()
    {
        let shouldEnable = count(taskTitleTextField.text) > 0
        navigationItem.rightBarButtonItem?.enabled = shouldEnable
    }
}

// MARK: background view
extension EditTaskViewController
{
    private func _setupBackgroundView()
    {
        let action: Selector = "tapDidGetRecognized:"
        let recognizer = UITapGestureRecognizer(target: self, action: action)
        view.addGestureRecognizer(recognizer)
    }
    
    func tapDidGetRecognized(recognizer: UITapGestureRecognizer)
    {
        taskTitleTextField.resignFirstResponder()
    }
}

// MARK: private helpers
extension EditTaskViewController
{
    private func _finishIfAppropriate()
    {
        if count(taskTitleTextField.text) > 0
        {
            _finish()
        }
    }
    
    private func _finish()
    {
        if data != nil
        {
            _finishEditingExistingTask()
        }
        else
        {
            _finishCreatingNewTask()
        }
    }
    
    private func _finishCreatingNewTask()
    {
        let title = taskTitleTextField.text
        taskCapturingDelegate?.taskCapturingModalDidFinishCreatingNewTask(title)
    }
    
    private func _finishEditingExistingTask()
    {
        data!.title = taskTitleTextField.text
        taskCapturingDelegate?.taskCapturingModalDidFinishEditingExistingTask(data!)
    }
    
    private func _isEditingExistingTask() -> Bool
    {
        if data == nil
        {
            return false
        }
        else
        {
            return true
        }
    }
    
    private func _setupNavBar()
    {
        _setupNavBarTitle()
        _setupNavBarButtons()
    }
    
    private func _setupNavBarTitle()
    {
        title = _navBarTitle()
    }
    
    private func _navBarTitle() -> String
    {
        if _isEditingExistingTask()
        {
            return "Edit Task"
        }
        else
        {
            return "New Task"
        }
    }
}

