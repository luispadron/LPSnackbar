//
//  ViewController.swift
//  LPSnackbarExample
//
//  Created by Luis Padron on 7/13/17.
//  Copyright © 2017 Luis Padron. All rights reserved.
//

import UIKit
import LPSnackbar

class ViewController: UITableViewController {

    var snacks: [String] = ["Chocolate bar", "Lolipop", "Nougat", "Marshmellow", "Apple", "Cookies", "Chips"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Create a super simple snack
        LPSnackbar.showSnack(title: "Delete a cell to earn a snack!")
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return snacks.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "testCell", for: indexPath)
        cell.textLabel?.text = snacks[indexPath.row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .destructive, title: "Delete") { (action, path) in
            // Remove the cell from the tableview
            self.tableView.beginUpdates()
            let removedSnack = self.snacks.remove(at: path.row)
            self.tableView.deleteRows(at: [path], with: .automatic)
            self.tableView.endUpdates()
            
            // Present a snack to allow the user to undo this action
            let snack = LPSnackbar(title: "Snack deleted!", buttonTitle: "UNDO")
            // Show the snack
            snack.show(animated: true) { undone in
                // The snack has finished showing, we get back a boolean value which tells us
                // whether user tapped the button or not
                guard undone else { return }
                
                // Action waas undone, lets readd the cell back
                self.tableView.beginUpdates()
                self.snacks.insert(removedSnack, at: path.row)
                self.tableView.insertRows(at: [path], with: .automatic)
                self.tableView.endUpdates()
            }
        }
        
        return [delete]
    }

}

