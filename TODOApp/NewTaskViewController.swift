//
//  NewTaskViewController.swift
//  TODOApp
//
//  Created by Pepas Personal on 7/12/15.
//  Copyright (c) 2015 Pepas Personal. All rights reserved.
//

import UIKit

protocol ModalTaskCapturingDelegateProtocol: class
{
    func taskCapturingModalDidFinish(taskTitle: String)
    func taskCapturingModalDidCancel()
}

class NewTaskViewController: UIViewController
{
    @IBOutlet weak var taskTitleTextField: UITextField!
    weak var taskCapturingDelegate: ModalTaskCapturingDelegateProtocol?
    
    deinit
    {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}

// MARK: Factory methods
extension NewTaskViewController
{
    class func storyboard() -> UIStoryboard
    {
        let storyboard = UIStoryboard(name: "NewTaskViewController", bundle: nil)
        return storyboard
    }
    
    class func instantiateFromStoryboard() -> NewTaskViewController
    {
        let storyboard = self.storyboard()
        let vc = storyboard.instantiateViewControllerWithIdentifier("NewTaskViewController") as! NewTaskViewController
        return vc
    }
}

// MARK: View Lifecycle
extension NewTaskViewController
{
    override func viewDidLoad()
    {
        super.viewDidLoad()
        title = "New Task"
        _setupNavBarButtons()
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

extension NewTaskViewController: UITextFieldDelegate
{
    func textFieldShouldReturn(textField: UITextField) -> Bool
    {
        _textFieldDoneButtonWillGetTapped()
        return true
    }
}

// MARK: UITextField methods
extension NewTaskViewController
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
    }
    
    private func _textFieldDoneButtonWillGetTapped()
    {
        doneButtonDidGetTapped()
    }
}

// MARK: buttons
extension NewTaskViewController
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
extension NewTaskViewController
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
extension NewTaskViewController
{
    private func _finishIfAppropriate()
    {
        if count(taskTitleTextField.text) > 0
        {
            let title = taskTitleTextField.text
            taskCapturingDelegate?.taskCapturingModalDidFinish(title)
        }
    }
}

