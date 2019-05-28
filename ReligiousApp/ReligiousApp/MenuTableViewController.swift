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
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        setUsername()
        
    }
    
    /*!
    @brief sets the username of the user for a more personalized feel
    @discussion Opens an alert controller with a text field to edit. If the user decides to cancel then the name will be set "User"
    */
    private func setUsername(){
        if(UserDefaults.standard.string(forKey: "user") == nil){
            var inputName = "there"
            //Presets for the alert
            let alertController = UIAlertController(title: "", message: "", preferredStyle: .alert)
            alertController.addTextField { textField in
                textField.placeholder = "Your name"
                textField.isSecureTextEntry = false
            }
            //Code that runs if the user confirms their action
            let confirmAction = UIAlertAction(title: "OK", style: .default) { [weak alertController] _ in
                guard let alertController = alertController, let textField = alertController.textFields?.first else { return }
                inputName = textField.text!
                print("Current username \(String(describing: textField.text))")
                UserDefaults.standard.set(inputName, forKey: "user")
                self.editLabel()
            }
            //Code that runs if the user cancels their action
            alertController.addAction(confirmAction)
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            alertController.addAction(cancelAction)
            self.editLabel()
            //Present
            present(alertController, animated: true, completion: nil)
            
        }
    }
    
    
    @IBAction func changeUsername(_ sender: Any) {
        if(UserDefaults.standard.string(forKey: "user") != nil){
            UserDefaults.standard.removeObject(forKey: "user")
        }
        if(isWeek){
            helloLabel.text = "Hello User, here is your week:"
        } else {
            helloLabel.text = "Hello User, here is your day:"
        }
        setUsername()
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

