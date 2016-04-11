//
//  DHTableView.swift
//  DHTableView
//
//  Created by Derrick  Ho on 4/10/16.
//  Copyright © 2016 Derrick  Ho. All rights reserved.
//

import UIKit

extension DHTableView {
	func setExampleDataSource(b: AnyObject?) {
		self.tableViewSections = [
			DHTableViewSectionViewModel(
				identifier: "cheese",
				sectionTitle: "hi1234899pp",
				cells:
				DHTableViewCellViewModel(nibName: String(DHCell)),
				DHTableViewCellViewModel(nibName: String(DHCell), configureCell: { (cell) -> () in
					let c = cell as! DHCell
					c.wordLabel.text = "world7998_"
					}, willDisplayCell: { (cell) -> () in
						let c = cell as! DHCell
						c.contentView.backgroundColor = UIColor.redColor()
					}, didSelect: { (cell: UITableViewCell, sender: DHTableView) -> () in
						sender.setVisibility(false, forSectionIdentifier: "cheese")
				})
			),
			// Apparently, the order of the arguments do not matter!
			DHTableViewSectionViewModel(
				sectionFooter: "bye",
				cells: DHTableViewCellViewModel(
					configureCell: { (cell) -> () in
						cell.textLabel!.text = "sayonara!"
					},
					didSelect: { (cell: UITableViewCell, sender: DHTableView) -> () in
						sender.setVisibility(true, forSectionIdentifier: "cheese")
					}
				),
				sectionTitle: "b"),
			DHTableViewSectionViewModel(sectionFooter: "Travis0900",
				cells: DHTableViewCellViewModel())
		]
		self.tableView.reloadData()
	}
}

@IBDesignable
public class DHTableView: UIView, UITableViewDataSource, UITableViewDelegate {
	
	public lazy var tableView: UITableView = {
		let v = UITableView()
		v.translatesAutoresizingMaskIntoConstraints = false
		self.addSubview(v)
		let viewDict = ["v" : v]
		self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[v]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: viewDict))
		self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[v]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: viewDict))
		return v
	}()
	
	// MARK: - UITableViewDataSource
	public var tableViewSections: [DHTableViewSectionViewModel] = [] {
		didSet {
			registerTableViewCells()
//			let visibleSections = tableViewSections.filter({ $0.visible })
//			for section in visibleSections {
//				section.tableViewCells = section.tableViewCells.filter({ $0.visible })
//			}
//			_tableViewSections = visibleSections
		}
	}
	
	private var _tableViewSections: [DHTableViewSectionViewModel] {
		let visibleSections = tableViewSections.filter({ $0.visible })
		for section in visibleSections {
			section.tableViewCells = section.tableViewCells.filter({ $0.visible })
		}
		return visibleSections
	}
	
	public override init(frame: CGRect) {
		super.init(frame: frame)
		setUp()
	}
	
	public required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		setUp()
	}
	
	func setUp() {
		tableView.delegate = self
		tableView.dataSource = self
//		setExampleDataSource(nil)
	}
	
	public func viewModelSectionFromIdentifier(identifier: String) throws -> (viewModel:DHTableViewSectionViewModel, sectionIndex: Int) {
		for (index, section) in tableViewSections.enumerate() {
			if section.identifier == identifier {
				return (section, index)
			}
		}
		throw NSError(domain: "DHTableView Error", code: 0, userInfo: ["error_description" : "Section Identifier does not exist"])
	}
	
	public func viewModelCellFromIdentifier(identifier: String) throws -> DHTableViewCellViewModel {
		for section in tableViewSections {
			for cell in section.tableViewCells {
				if cell.identifier == identifier {
					return cell
				}
			}
		}
		throw NSError(domain: "DHTableView Error", code: 0, userInfo: ["error_description" : "Cell Identifier does not exist"])
	}
	
	public func setVisibility(visible: Bool, forSectionIdentifier: String, animation: UITableViewRowAnimation = .Automatic) {
		// TODO build convenience method fo hiding and showing based on identifier
		let (vm, section) = try! viewModelSectionFromIdentifier("cheese")
		guard vm.visible != visible else {
			return
		}
		let visible = vm.visible
		vm.visible = !vm.visible
		if visible {
			tableView.deleteSections(NSIndexSet(index: section), withRowAnimation: animation)
		} else {
			tableView.insertSections(NSIndexSet(index: section), withRowAnimation: animation)
		}
	}
	
	func registerTableViewCells() {
		for i in tableViewSections {
			for j in i.tableViewCells {
				if j.nibName.isEmpty {
					j.cellReuseIdentifier = j.cellReuseIdentifier ?? String(UITableViewCell)
					self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: j.cellReuseIdentifier!)
				} else {
					
					let nib = UINib(nibName: j.nibName, bundle: NSBundle(forClass: self.dynamicType))
					j.cellReuseIdentifier = j.cellReuseIdentifier ?? j.nibName
					self.tableView.registerNib(nib, forCellReuseIdentifier: j.cellReuseIdentifier!)
				}
			}
		}
	}
	
	public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cellModel = _tableViewSections[indexPath.section].tableViewCells[indexPath.row]
		let cellIdentifier = cellModel.cellReuseIdentifier!
		let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath)
		cellModel.configure(cell: cell)
		return cell
	}
	
	public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return _tableViewSections[section].tableViewCells.count
	}
	
	public func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return _tableViewSections.count
	}
	
	public func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		return _tableViewSections[section].sectionTitle
	}
	
	public func tableView(tableView: UITableView, titleForFooterInSection section: Int) -> String? {
		return _tableViewSections[section].sectionFooter
	}
	
	//
	//	// Editing
	//
	//	// Individual rows can opt out of having the -editing property set for them. If not implemented, all rows are assumed to be editable.
	//	@available(iOS 2.0, *)
	//	optional public func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool
	//
	//	// Moving/reordering
	//
	//	// Allows the reorder accessory view to optionally be shown for a particular row. By default, the reorder control will be shown only if the datasource implements -tableView:moveRowAtIndexPath:toIndexPath:
	//	@available(iOS 2.0, *)
	//	optional public func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool
	//
	//	// Index
	//
	//	@available(iOS 2.0, *)
	//	optional public func sectionIndexTitlesForTableView(tableView: UITableView) -> [String]? // return list of section titles to display in section index view (e.g. "ABCD...Z#")
	//	@available(iOS 2.0, *)
	//	optional public func tableView(tableView: UITableView, sectionForSectionIndexTitle title: String, atIndex index: Int) -> Int // tell table which section corresponds to section title/index (e.g. "B",1))
	//
	//	// Data manipulation - insert and delete support
	//
	//	// After a row has the minus or plus button invoked (based on the UITableViewCellEditingStyle for the cell), the dataSource must commit the change
	//	// Not called for edit actions using UITableViewRowAction - the action's handler will be invoked instead
	//	@available(iOS 2.0, *)
	//	optional public func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath)
	//
	//	// Data manipulation - reorder / moving support
	//
	//	@available(iOS 2.0, *)
	//	optional public func tableView(tableView: UITableView, moveRowAtIndexPath sourceIndexPath: NSIndexPath, toIndexPath destinationIndexPath: NSIndexPath)
	//
	//	@available(iOS 2.0, *)
	//	optional public func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath)
	//	@available(iOS 6.0, *)
	//	optional public func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int)
	//	@available(iOS 6.0, *)
	//	optional public func tableView(tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int)
	//	@available(iOS 6.0, *)
	//	optional public func tableView(tableView: UITableView, didEndDisplayingCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath)
	//	@available(iOS 6.0, *)
	//	optional public func tableView(tableView: UITableView, didEndDisplayingHeaderView view: UIView, forSection section: Int)
	//	@available(iOS 6.0, *)
	//	optional public func tableView(tableView: UITableView, didEndDisplayingFooterView view: UIView, forSection section: Int)
	//
	//	// Variable height support
	//
	//	@available(iOS 2.0, *)
	//	optional public func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat
	//	@available(iOS 2.0, *)
	//	optional public func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat
	//	@available(iOS 2.0, *)
	//	optional public func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat
	//
	//	// Use the estimatedHeight methods to quickly calcuate guessed values which will allow for fast load times of the table.
	//	// If these methods are implemented, the above -tableView:heightForXXX calls will be deferred until views are ready to be displayed, so more expensive logic can be placed there.
	//	@available(iOS 7.0, *)
	//	optional public func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat
	//	@available(iOS 7.0, *)
	//	optional public func tableView(tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat
	//	@available(iOS 7.0, *)
	//	optional public func tableView(tableView: UITableView, estimatedHeightForFooterInSection section: Int) -> CGFloat
	//
	//	// Section header & footer information. Views are preferred over title should you decide to provide both
	//
	//	@available(iOS 2.0, *)
	//	optional public func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? // custom view for header. will be adjusted to default or specified header height
	//	@available(iOS 2.0, *)
	//	optional public func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? // custom view for footer. will be adjusted to default or specified footer height
	//
	//	@available(iOS 2.0, *)
	//	optional public func tableView(tableView: UITableView, accessoryButtonTappedForRowWithIndexPath indexPath: NSIndexPath)
	//
	//	// Selection
	//
	//	// -tableView:shouldHighlightRowAtIndexPath: is called when a touch comes down on a row.
	//	// Returning NO to that message halts the selection process and does not cause the currently selected row to lose its selected look while the touch is down.
	//	@available(iOS 6.0, *)
	//	optional public func tableView(tableView: UITableView, shouldHighlightRowAtIndexPath indexPath: NSIndexPath) -> Bool
	//	@available(iOS 6.0, *)
	//	optional public func tableView(tableView: UITableView, didHighlightRowAtIndexPath indexPath: NSIndexPath)
	//	@available(iOS 6.0, *)
	//	optional public func tableView(tableView: UITableView, didUnhighlightRowAtIndexPath indexPath: NSIndexPath)
	//
	//	// Called before the user changes the selection. Return a new indexPath, or nil, to change the proposed selection.
	//	@available(iOS 2.0, *)
	//	optional public func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath?
	//	@available(iOS 3.0, *)
	//	optional public func tableView(tableView: UITableView, willDeselectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath?
	//	// Called after the user changes the selection.
	//	@available(iOS 2.0, *)
	public func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		let cellModel = _tableViewSections[indexPath.section].tableViewCells[indexPath.row]
		cellModel.didSelect(cell: tableView.cellForRowAtIndexPath(indexPath)!, sender: self)
	}
	//	@available(iOS 3.0, *)
	//	optional public func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath)
	//
	//	// Editing
	//
	//	// Allows customization of the editingStyle for a particular cell located at 'indexPath'. If not implemented, all editable cells will have UITableViewCellEditingStyleDelete set for them when the table has editing property set to YES.
	//	@available(iOS 2.0, *)
	//	optional public func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle
	//	@available(iOS 3.0, *)
	//	optional public func tableView(tableView: UITableView, titleForDeleteConfirmationButtonForRowAtIndexPath indexPath: NSIndexPath) -> String?
	//	@available(iOS 8.0, *)
	//	optional public func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? // supercedes -tableView:titleForDeleteConfirmationButtonForRowAtIndexPath: if return value is non-nil
	//
	//	// Controls whether the background is indented while editing.  If not implemented, the default is YES.  This is unrelated to the indentation level below.  This method only applies to grouped style table views.
	//	@available(iOS 2.0, *)
	//	optional public func tableView(tableView: UITableView, shouldIndentWhileEditingRowAtIndexPath indexPath: NSIndexPath) -> Bool
	//
	//	// The willBegin/didEnd methods are called whenever the 'editing' property is automatically changed by the table (allowing insert/delete/move). This is done by a swipe activating a single row
	//	@available(iOS 2.0, *)
	//	optional public func tableView(tableView: UITableView, willBeginEditingRowAtIndexPath indexPath: NSIndexPath)
	//	@available(iOS 2.0, *)
	//	optional public func tableView(tableView: UITableView, didEndEditingRowAtIndexPath indexPath: NSIndexPath)
	//
	//	// Moving/reordering
	//
	//	// Allows customization of the target row for a particular row as it is being moved/reordered
	//	@available(iOS 2.0, *)
	//	optional public func tableView(tableView: UITableView, targetIndexPathForMoveFromRowAtIndexPath sourceIndexPath: NSIndexPath, toProposedIndexPath proposedDestinationIndexPath: NSIndexPath) -> NSIndexPath
	//
	//	// Indentation
	//
	//	@available(iOS 2.0, *)
	//	optional public func tableView(tableView: UITableView, indentationLevelForRowAtIndexPath indexPath: NSIndexPath) -> Int // return 'depth' of row for hierarchies
	//
	//	// Copy/Paste.  All three methods must be implemented by the delegate.
	//
	//	@available(iOS 5.0, *)
	//	optional public func tableView(tableView: UITableView, shouldShowMenuForRowAtIndexPath indexPath: NSIndexPath) -> Bool
	//	@available(iOS 5.0, *)
	//	optional public func tableView(tableView: UITableView, canPerformAction action: Selector, forRowAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) -> Bool
	//	@available(iOS 5.0, *)
	//	optional public func tableView(tableView: UITableView, performAction action: Selector, forRowAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?)
	//
	//	// Focus
	//
	//	@available(iOS 9.0, *)
	//	optional public func tableView(tableView: UITableView, canFocusRowAtIndexPath indexPath: NSIndexPath) -> Bool
	//	@available(iOS 9.0, *)
	//	optional public func tableView(tableView: UITableView, shouldUpdateFocusInContext context: UITableViewFocusUpdateContext) -> Bool
	//	@available(iOS 9.0, *)
	//	optional public func tableView(tableView: UITableView, didUpdateFocusInContext context: UITableViewFocusUpdateContext, withAnimationCoordinator coordinator: UIFocusAnimationCoordinator)
	//	@available(iOS 9.0, *)
	//	optional public func indexPathForPreferredFocusedViewInTableView(tableView: UITableView) -> NSIndexPath?
}

public class DHTableViewCellViewModel: NSObject {
	var identifier: String?
	var visible: Bool
	var nibName: String
	var cellReuseIdentifier: String?
	//	var tableViewCell: UITableViewCell = UITableViewCell(style: .Default, reuseIdentifier: String(UITableViewCell))
	var configure: (cell: UITableViewCell) -> ()// = { (cell: T) -> () in }
	var willDisplay: (cell: UITableViewCell) -> ()// = { (cell: T) -> () in }
	var didSelect: (cell: UITableViewCell, sender: DHTableView) -> ()
	init(nibName: String = "",
	     visible: Bool = true,
	     identifier: String? = nil,
	     configureCell: (cell: UITableViewCell) -> () = {_ in },
	     willDisplayCell: (cell: UITableViewCell) -> () = {_ in },
	     didSelect: (cell: UITableViewCell, sender: DHTableView) -> () = {_ in }
		)
	{
		self.identifier = identifier
		self.nibName = nibName
		self.visible = visible
		self.configure = configureCell
		self.willDisplay = willDisplayCell
		self.didSelect = didSelect
	}
}

public class DHTableViewSectionViewModel: NSObject {
	var identifier: String?
	var visible: Bool
	var sectionTitle: String?
	var sectionFooter: String?
	var tableViewCells: [DHTableViewCellViewModel] = []
	public required init(visible: Bool = true,
	                     identifier: String? = nil,
	                     sectionTitle: String? = nil, sectionFooter: String? = nil,
	              cells: DHTableViewCellViewModel...)
	{
		self.identifier = identifier
		self.visible = visible
		self.sectionTitle = sectionTitle; self.sectionFooter = sectionFooter
		tableViewCells = cells
	}
}