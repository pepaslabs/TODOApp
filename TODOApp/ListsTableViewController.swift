//
//  ListsTableViewController.swift
//  TODOApp
//
//  Created by Pepas Personal on 8/2/15.
//  Copyright (c) 2015 Pepas Personal. All rights reserved.
//

import UIKit

class ListsTableViewController: UITableViewController
{
    private var dataSource: ListsTableViewDataSource = ListsTableViewDataSource()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        title = "Lists"
        _setupTableView()
    }
}

// MARK: Factory methods
extension ListsTableViewController
{
    class func storyboard() -> UIStoryboard
    {
        let storyboard = UIStoryboard(name: "ListsTableViewController", bundle: nil)
        return storyboard
    }
    
    class func instantiateFromStoryboard() -> ListsTableViewController
    {
        let storyboard = self.storyboard()
        let vc = storyboard.instantiateViewControllerWithIdentifier("ListsTableViewController") as! ListsTableViewController
        return vc
    }
}

extension ListsTableViewController: UITableViewDelegate
{
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        if let title = dataSource.titleAtIndex(indexPath.row)
        {
            switch title {
                
            case "Tasks":
                _presentTasksTableViewController()
                
            case "Done":
                _presentDoneTableViewController()

            default:
                return
            }
        }
    }
}

// MARK: private helpers
extension ListsTableViewController
{
    private func _setupTableView()
    {
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "UITableViewCell")
        tableView.dataSource = dataSource
    }
    
    private func _presentTasksTableViewController()
    {
//        let vc = TasksTableViewController.instantiateFromStoryboard()
        let vc = TasksTableViewController2Factory.createDefaultController()
        navigationController?.showViewController(vc, sender: self)
    }
    
    private func _presentDoneTableViewController()
    {
//        let vc = DoneTableViewController.instantiateFromStoryboard()
        let vc = TasksTableViewController2Factory.createDoneController()
        navigationController?.showViewController(vc, sender: self)
    }
}

class ListsTableViewDataSource: NSObject
{
    func titleAtIndex(index: Int) -> String?
    {
        switch index {
        case 0:
            return "Tasks"
            
        case 1:
            return "Done"
            
        default:
            return nil
        }
    }
}

extension ListsTableViewDataSource: UITableViewDataSource
{
    @objc func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return 2
    }
    
    @objc func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCellWithIdentifier("UITableViewCell", forIndexPath: indexPath) as! UITableViewCell
        _configureCell(cell, atIndex: indexPath.row)
        return cell
    }
}

// MARK: private helpers
extension ListsTableViewDataSource
{
    private func _configureCell(cell: UITableViewCell, atIndex index: Int)
    {
        cell.textLabel?.text = titleAtIndex(index)
    }
}
