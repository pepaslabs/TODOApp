//
//  ViewController.swift
//  TODOApp
//
//  Created by Pepas Personal on 7/12/15.
//  Copyright (c) 2015 Pepas Personal. All rights reserved.
//

import UIKit

class ViewController: UIViewController, ModalTaskCapturingDelegateProtocol
{
    override func viewDidLoad()
    {
        super.viewDidLoad()
    }
}

// MARK: Target/Action
extension ViewController
{
    @IBAction func buttonDidGetTapped(sender: AnyObject)
    {
        debugPrintln("button!")
        
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
        debugPrintln("done!!! with task title: \(taskTitle)")
        presentedViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func taskCapturingModalDidCancel()
    {
        debugPrintln("cancel!!!")
        presentedViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
}

