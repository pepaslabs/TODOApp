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
        _addCancelBarButtonItemToNavBar()
        _addDoneBarButtonItemToNavBar()
    }
}

// MARK: buttons
extension NewTaskViewController
{
    private func _addDoneBarButtonItemToNavBar()
    {
        navigationItem.rightBarButtonItem = _createDoneBarButtonItem()
    }
    
    private func _createDoneBarButtonItem() -> UIBarButtonItem
    {
        let action: Selector = "doneButtonDidGetTapped"
        let doneBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Done,
            target: self,
            action: action)
        return doneBarButtonItem
    }
    
    func doneButtonDidGetTapped()
    {
        let title = taskTitleTextField.text
        taskCapturingDelegate?.taskCapturingModalDidFinish(title)
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
        taskCapturingDelegate?.taskCapturingModalDidCancel()
    }
}
