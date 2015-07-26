//
//  UIAlertController+addAction.swift
//  TODOApp
//
//  Created by Pepas Personal on 7/26/15.
//  Copyright (c) 2015 Pepas Personal. All rights reserved.
//

import UIKit

extension UIAlertController
{
    func addDefaultAction(title: String, handler: ((UIAlertAction!) -> Void)!)
    {
        let action = UIAlertAction(title: title, style: .Default, handler: handler)
        addAction(action)
    }
    
    func addDestructiveAction(title: String, handler: ((UIAlertAction!) -> Void)!)
    {
        let action = UIAlertAction(title: title, style: .Destructive, handler: handler)
        addAction(action)
    }
    
    func addCancelAction(title: String, handler: ((UIAlertAction!) -> Void)!)
    {
        let action = UIAlertAction(title: title, style: .Cancel, handler: handler)
        addAction(action)
    }
}


