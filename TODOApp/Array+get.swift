//
//  Array+get.swift
//  TODOApp
//
//  Created by Pepas Personal on 7/26/15.
//  Copyright (c) 2015 Pepas Personal. All rights reserved.
//

import Foundation

extension Array
{
    func get(index: Int) -> Element?
    {
        if index < 0 || index >= self.count
        {
            return nil
        }
        else
        {
            return self[index]
        }
    }
}

