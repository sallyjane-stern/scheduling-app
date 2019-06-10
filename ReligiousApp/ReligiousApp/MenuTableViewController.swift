//
//  MenuTableViewController.swift
//  ReligiousApp
//
//  Created by Trenton Parrotte on 5/5/19.
//  Copyright © 2019 Trenton Parrotte. All rights reserved.
//

import UIKit
import Foundation

var isWeek = true{
    didSet{
        NotificationCenter.default.post(name: .isWeekChanged, object: nil)
    }
}

//Class Representing the Home Screen minus the table
class MenuTableViewController: UIViewController {
    @IBOutlet weak var helloLabel: UILabel!

    

    override func viewDidLoad() {
        super.viewDidLoad()
        editLabel()
        
        
        
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        self.navigationController?.setNavigationBarHidden(true, animated: true)
        self.navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
    }
    
    
    @IBAction func pressedDay(_ sender: Any) {
        isWeek = false
        editLabel()
        
    }
    @IBAction func pressedWeek(_ sender: Any) {
        isWeek = true
        editLabel()
    }
    
    @IBAction func contactButton(_ sender: Any) {
        let alert = UIAlertController(title: "Contact Us", message: "Have questions or recommendations?\nEmail us at: JurassicProgrammingTeam@gmail.com", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
            NSLog("The \"OK\" alert occured.")
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    
    func editLabel(){
//        var main = helloLabel.text
        if(isWeek){
//            main = main?.replacingOccurrences(of: "day", with: "week")
            self.navigationItem.title = "Your Week"
        } else {
            self.navigationItem.title = "Your Day"
//            main = main?.replacingOccurrences(of: "week", with: "day")
        }
    }
    
    
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}

extension NSNotification.Name {
    static let isWeekChanged = NSNotification.Name(Bundle.main.bundleIdentifier! + ".isWeek")
}

