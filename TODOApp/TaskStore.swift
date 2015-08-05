//
//  TaskStore.swift
//  TODOApp
//
//  Created by Pepas Personal on 7/19/15.
//  Copyright (c) 2015 Pepas Personal. All rights reserved.
//

import Foundation

protocol StringStoreProtocol: class
{
    func addString(text: String)
    func count() -> Int
    func stringTextAtIndex(index: Int) -> String?
    func deleteStringAtIndex(index: Int)
    func moveStringAtIndex(sourceIndex: Int, toIndex destinationIndex: Int)
    func setStringText(text: String, atIndex index: Int)
}

class InMemoryStringStore: StringStoreProtocol
{
    private var strings: [String] = [String]()
    
    func addString(text: String)
    {
        strings.append(text)
    }
    
    func count() -> Int
    {
        return strings.count
    }
    
    func stringTextAtIndex(index: Int) -> String?
    {
        return strings.get(index)
    }
    
    func deleteStringAtIndex(index: Int)
    {
        strings.removeAtIndex(index)
    }
    
    func moveStringAtIndex(sourceIndex: Int, toIndex destinationIndex: Int)
    {
        let text = strings.removeAtIndex(sourceIndex)
        strings.insert(text, atIndex: destinationIndex)
    }
    
    func setStringText(text: String, atIndex index: Int)
    {
        if index < strings.count
        {
            strings[index] = text
        }
    }
}

class NSUserDefaultsStringStore: StringStoreProtocol
{
    private var strings: [String] = [String]()
    private var name: String
    private let stringsNSUserDefaultsKey: String
    
    init(name: String)
    {
        self.name = name
        stringsNSUserDefaultsKey = "_strings_\(name)_NSUserDefaultsKey"
        strings = _loadTasksFromDisk()
    }
    
    func addString(text: String)
    {
        strings.append(text)
        _writeTasksToDisk()
    }
    
    func count() -> Int
    {
        return strings.count
    }
    
    func stringTextAtIndex(index: Int) -> String?
    {
        return strings.get(index)
    }
    
    func deleteStringAtIndex(index: Int)
    {
        strings.removeAtIndex(index)
        _writeTasksToDisk()
    }
    
    func moveStringAtIndex(sourceIndex: Int, toIndex destinationIndex: Int)
    {
        let text = strings.removeAtIndex(sourceIndex)
        strings.insert(text, atIndex: destinationIndex)
        _writeTasksToDisk()
    }
    
    func setStringText(text: String, atIndex index: Int)
    {
        if index < strings.count
        {
            strings[index] = text
            _writeTasksToDisk()
        }
    }
    
    private func _loadTasksFromDisk() -> [String]
    {
        if var strings = NSUserDefaults.standardUserDefaults().arrayForKey(stringsNSUserDefaultsKey) as? [String]
        {
            return strings
        }
        else
        {
            return [String]()
        }
    }
    
    private func _writeTasksToDisk()
    {
        NSUserDefaults.standardUserDefaults().setObject(strings, forKey: stringsNSUserDefaultsKey)
    }
}

protocol TaskStoreProtocol: class
{
    func addTask(title: String)
    func count() -> Int
    func taskTitleAtIndex(index: Int) -> String?
    func deleteTaskAtIndex(index: Int)
    func moveTaskAtIndex(sourceIndex: Int, toIndex destinationIndex: Int)
    func setTaskTitle(title: String, atIndex index: Int)
}

class BaseTaskStore: TaskStoreProtocol
{
    private var stringStore: StringStoreProtocol
    
    init(stringStore: StringStoreProtocol)
    {
        self.stringStore = stringStore
    }
    
    func addTask(title: String)
    {
        stringStore.addString(title)
    }
    
    func count() -> Int
    {
        return stringStore.count()
    }
    
    func taskTitleAtIndex(index: Int) -> String?
    {
        return stringStore.stringTextAtIndex(index)
    }
    
    func deleteTaskAtIndex(index: Int)
    {
        stringStore.deleteStringAtIndex(index)
    }
    
    func moveTaskAtIndex(sourceIndex: Int, toIndex destinationIndex: Int)
    {
        stringStore.moveStringAtIndex(sourceIndex, toIndex: destinationIndex)
    }
    
    func setTaskTitle(title: String, atIndex index: Int)
    {
        stringStore.setStringText(title, atIndex: index)
    }
}

class InMemoryTaskStore: BaseTaskStore {}
class NSUserDefaultsTaskStore: BaseTaskStore {}

class TaskStoreRepository
{
    static var sharedInstance: TaskStoreRepository = TaskStoreRepository()
    
    private var stores = [String: TaskStoreProtocol]()
    
    func taskStore(name: String) -> TaskStoreProtocol
    {
        if let store = stores[name]
        {
            return store
        }
        else
        {
            let stringStore = NSUserDefaultsStringStore(name: name)
            let store = NSUserDefaultsTaskStore(stringStore: stringStore)
            stores[name] = store
            return store
        }
    }
}

protocol ListStoreProtocol: class
{
    func addList(title: String)
    func count() -> Int
    func listTitleAtIndex(index: Int) -> String?
    func deleteListAtIndex(index: Int)
    func moveListAtIndex(sourceIndex: Int, toIndex destinationIndex: Int)
    func setListTitle(title: String, atIndex index: Int)
}

class BaseListStore: ListStoreProtocol
{
    private var stringStore: StringStoreProtocol
    
    init(stringStore: StringStoreProtocol)
    {
        self.stringStore = stringStore
    }
    
    func addList(title: String)
    {
        stringStore.addString(title)
    }
    
    func count() -> Int
    {
        return stringStore.count()
    }
    
    func listTitleAtIndex(index: Int) -> String?
    {
        return stringStore.stringTextAtIndex(index)
    }
    
    func deleteListAtIndex(index: Int)
    {
        stringStore.deleteStringAtIndex(index)
    }
    
    func moveListAtIndex(sourceIndex: Int, toIndex destinationIndex: Int)
    {
        stringStore.moveStringAtIndex(sourceIndex, toIndex: destinationIndex)
    }
    
    func setListTitle(title: String, atIndex index: Int)
    {
        stringStore.setStringText(title, atIndex: index)
    }
}

class InMemoryListStore: BaseListStore {}
class NSUserDefaultsListStore: BaseListStore {}

class ListStoreRepository
{
    static var sharedInstance: ListStoreRepository = ListStoreRepository()
    
    private var stores = [String: ListStoreProtocol]()
    
    func listStore(name: String) -> ListStoreProtocol
    {
        if let store = stores[name]
        {
            return store
        }
        else
        {
            let stringStore = NSUserDefaultsStringStore(name: name)
            let store = NSUserDefaultsListStore(stringStore: stringStore)
            stores[name] = store
            return store
        }
    }
}
