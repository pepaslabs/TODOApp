//
//  EditStringViewController.swift
//  TODOApp
//
//  Created by Pepas Personal on 7/12/15.
//  Copyright (c) 2015 Pepas Personal. All rights reserved.
//

import UIKit

protocol ModalStringCapturingDelegateProtocol: class
{
    func stringCapturingModalDidFinishCreatingNewString(string: String)
    func stringCapturingModalDidFinishEditingExistingString(data: StringEditingData)
    func stringCapturingModalDidCancel()
    func kindOfThingBeingEdited() -> String
}

struct StringEditingData
{
    var string: String
    var context: Any?
    
    init(string: String, context: Any?)
    {
        self.string = string
        self.context = context
    }
}

class EditStringViewController: UIViewController
{
    @IBOutlet weak var stringTextField: UITextField!
    weak var stringCapturingDelegate: ModalStringCapturingDelegateProtocol?
    
    deinit
    {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    private var data: StringEditingData?
}

// MARK: Factory methods
extension EditStringViewController
{
    class func storyboard() -> UIStoryboard
    {
        let storyboard = UIStoryboard(name: "EditStringViewController", bundle: nil)
        return storyboard
    }
    
    class func instantiateFromStoryboard(#existingStringData: StringEditingData?) -> EditStringViewController
    {
        let storyboard = self.storyboard()
        let vc = storyboard.instantiateViewControllerWithIdentifier("EditStringViewController") as! EditStringViewController
        vc.data = existingStringData
        return vc
    }
}

// MARK: View Lifecycle
extension EditStringViewController
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
        stringTextField.becomeFirstResponder()
    }

    override func viewDidDisappear(animated: Bool)
    {
        super.viewDidDisappear(animated)
        _unsubscribeFromTextFieldNotifications()
    }
}

extension EditStringViewController: UITextFieldDelegate
{
    func textFieldShouldReturn(textField: UITextField) -> Bool
    {
        _textFieldDoneButtonWillGetTapped()
        return true
    }
}

// MARK: UITextField methods
extension EditStringViewController
{
    private func _subscribeToTextFieldNotifications()
    {
        let action: Selector = "textFieldDidChangeNotificationHandler:"
        NSNotificationCenter.defaultCenter().addObserver(self,
            selector: action,
            name: UITextFieldTextDidChangeNotification,
            object: stringTextField)
        
    }
    
    private func _unsubscribeFromTextFieldNotifications()
    {
        NSNotificationCenter.defaultCenter().removeObserver(self,
            name: UITextFieldTextDidChangeNotification,
            object: stringTextField)
    }
    
    func textFieldDidChangeNotificationHandler(notification: NSNotification)
    {
        _updateNavBarDoneButtonEnabledness()
    }

    private func _setupTextField()
    {
        stringTextField.returnKeyType = .Done
        stringTextField.delegate = self
        stringTextField.text = data?.string
    }
    
    private func _textFieldDoneButtonWillGetTapped()
    {
        doneButtonDidGetTapped()
    }
}

// MARK: buttons
extension EditStringViewController
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
        stringTextField.resignFirstResponder()
        _finishIfAppropriate()
    }
    
    private func _addCancelBarButtonItemToNavBar()
    {
        navigationItem.leftBarButtonItem = _createCancelBarButtonItem()
    }
    
    private func _createCancelBarButtonItem() -> UIBarButtonItem
    {
        let action: Selector = "cancelButtonDidGetTapped"
        let barButtonItem = UIBarButtonItem(barButtonSystemItem: .Cancel,
            target: self,
            action: action)
        return barButtonItem
    }
    
    func cancelButtonDidGetTapped()
    {
        stringTextField.resignFirstResponder()
        stringCapturingDelegate?.stringCapturingModalDidCancel()
    }
    
    private func _updateNavBarDoneButtonEnabledness()
    {
        let shouldEnable = count(stringTextField.text) > 0
        navigationItem.rightBarButtonItem?.enabled = shouldEnable
    }
}

// MARK: background view
extension EditStringViewController
{
    private func _setupBackgroundView()
    {
        let action: Selector = "tapDidGetRecognized:"
        let recognizer = UITapGestureRecognizer(target: self, action: action)
        view.addGestureRecognizer(recognizer)
    }
    
    func tapDidGetRecognized(recognizer: UITapGestureRecognizer)
    {
        stringTextField.resignFirstResponder()
    }
}

// MARK: private helpers
extension EditStringViewController
{
    private func _finishIfAppropriate()
    {
        if count(stringTextField.text) > 0
        {
            _finish()
        }
    }
    
    private func _finish()
    {
        if data != nil
        {
            _finishEditingExistingString()
        }
        else
        {
            _finishCreatingNewString()
        }
    }
    
    private func _finishCreatingNewString()
    {
        let string = stringTextField.text
        stringCapturingDelegate?.stringCapturingModalDidFinishCreatingNewString(string)
    }
    
    private func _finishEditingExistingString()
    {
        data!.string = stringTextField.text
        stringCapturingDelegate?.stringCapturingModalDidFinishEditingExistingString(data!)
    }
    
    private func _isEditingExistingString() -> Bool
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
        var kindOfThing: String? = stringCapturingDelegate?.kindOfThingBeingEdited()
        
        if _isEditingExistingString()
        {
            return "Edit \(kindOfThing)"
        }
        else
        {
            return "New \(kindOfThing)"
        }
    }
}

