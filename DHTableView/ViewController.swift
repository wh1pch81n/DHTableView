//
//  ViewController.swift
//  DHTableView
//
//  Created by Derrick  Ho on 4/9/16.
//  Copyright © 2016 Derrick  Ho. All rights reserved.
//

import UIKit
import DesignableViews

class ViewController: UIViewController {
	@IBOutlet var tableView: DHTableView!
	override func viewDidLoad() {
		super.viewDidLoad()
//		(self.view as! DHTableView).tableViewSections = exampleDataSource
//		(self.view as! DHTableView).tableView.reloadData()
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
}
