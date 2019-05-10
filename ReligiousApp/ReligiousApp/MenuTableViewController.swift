//
//  MenuTableViewController.swift
//  ReligiousApp
//
//  Created by Trenton Parrotte on 5/5/19.
//  Copyright © 2019 Trenton Parrotte. All rights reserved.
//

import UIKit
import Foundation

class MenuTableViewController: UIViewController {
    //class MenuTableViewController: UITableViewController {
    @IBOutlet weak var helloLabel: UILabel!
    
    private var isWeek = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        editLabel()
        
        //        let main_string = "Hello World"
        //        let string_to_color = "World"
        //
        //        let range = (main_string as NSString).range(of: string_to_color)
        //
        //        let attribute = NSMutableAttributedString.init(string: main_string)
        //        attribute.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.red , range: range)
        
        
        //        txtfield1 = UITextField.init(frame:CGRect(x:10 , y:20 ,width:100 , height:100))
        //        txtfield1.attributedText = attribute
        
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        
        if(UserDefaults.standard.string(forKey: "user") == nil){
            var inputName = "there"
            //Have user input their
            let alertController = UIAlertController(title: "", message: "", preferredStyle: .alert)
            alertController.addTextField { textField in
                textField.placeholder = "Your name"
                textField.isSecureTextEntry = false
            }
            let confirmAction = UIAlertAction(title: "OK", style: .default) { [weak alertController] _ in
                guard let alertController = alertController, let textField = alertController.textFields?.first else { return }
                inputName = textField.text!
                print("Current username \(String(describing: textField.text))")
                UserDefaults.standard.set(inputName, forKey: "user")
                self.editLabel()
            }
            alertController.addAction(confirmAction)
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            alertController.addAction(cancelAction)
            present(alertController, animated: true, completion: nil)
            
        }
        
    }
    @IBAction func pressedDay(_ sender: Any) {
        isWeek = false
        editLabel()
    }
    @IBAction func pressedWeek(_ sender: Any) {
        isWeek = true
        editLabel()
    }
    
    func editLabel(){
        var main = helloLabel.text
        var coloredPart = "User"
        if(UserDefaults.standard.string(forKey: "user") != nil){
            main = main!.replacingOccurrences(of: "User", with: UserDefaults.standard.string(forKey: "user")!)
            coloredPart = UserDefaults.standard.string(forKey: "user")!
        }
        if(isWeek){
            main = main?.replacingOccurrences(of: "day", with: "week")
        } else {
            main = main?.replacingOccurrences(of: "week", with: "day")
        }

        let range = (main as! NSString).range(of: coloredPart)
        
        let attribute = NSMutableAttributedString.init(string: main!)
        let crimson = UIColor.init(red: 141/255, green: 25/255, blue: 41/255, alpha: 1)
        attribute.addAttribute(NSAttributedString.Key.foregroundColor, value: crimson, range: range)
        attribute.addAttribute(NSAttributedString.Key.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: (main as! NSString).range(of: main!))
        attribute.addAttribute(NSAttributedString.Key.underlineColor, value: UIColor(red: 125/255, green: 125/255, blue: 125/255, alpha: 1), range: (main as! NSString).range(of: main!))
        helloLabel.attributedText = attribute
    }
    
    // MARK: - Table view data source
    //
    //    override func numberOfSections(in tableView: UITableView) -> Int {
    //        // #warning Incomplete implementation, return the number of sections
    //        return 0
    //    }
    //
    //    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    //        // #warning Incomplete implementation, return the number of rows
    //        return 0
    //    }
    
    /*
     override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
     let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
     
     // Configure the cell...
     
     return cell
     }
     */
    
    /*
     // Override to support conditional editing of the table view.
     override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }
     */
    
    /*
     // Override to support editing the table view.
     override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
     if editingStyle == .delete {
     // Delete the row from the data source
     tableView.deleteRows(at: [indexPath], with: .fade)
     } else if editingStyle == .insert {
     // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
     }
     }
     */
    
    /*
     // Override to support rearranging the table view.
     override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
     
     }
     */
    
    /*
     // Override to support conditional rearranging of the table view.
     override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
     */
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}
