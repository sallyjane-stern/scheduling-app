//
//  ViewController.swift
//  ReligiousApp
//
//  Created by Trenton Parrotte on 4/23/19.
//  Copyright © 2019 Trenton Parrotte. All rights reserved.
//

import UIKit
import EventKit
import MXLCalendarManagerSwift

class ViewController: UIViewController{
    
    @IBOutlet weak var outlookCal: UIButton!
    
    @IBOutlet weak var googleCal: UIButton!
    @IBOutlet weak var appleCal: UIButton!
    @IBOutlet weak var addButton: UIButton!
    
    @IBOutlet weak var containerView: UIView!
    
    @IBOutlet var SwipeRecognizer: UISwipeGestureRecognizer!
    private var calBoxes: ViewDelegate?
    
    private var pickerArray = [false, false, false]
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    func checkOrAddCalendar(store:EKEventStore){
        let parsedEventList = parseEventFile()
        let firstCheck = checkForCalendar(store:store)
        if firstCheck.0 {
            print("[INFO] Calendar already exists")
            insertEvents(store: store, calendar: firstCheck.1!, eventList: parsedEventList!)
        } else {
            print("[INFO] Calendar does not exist, creating...")
            addOurCalendar(store: store)
            let secondCheck = checkForCalendar(store: store)
            if secondCheck.0{
                insertEvents(store: store, calendar: secondCheck.1!, eventList: parsedEventList!)
            } else {
                print("NO CALENDAR RETURNED FROM CREATE")
            }
        }
    }
    
    func checkForCalendar(store:EKEventStore)->(Bool, EKCalendar?){
        let userCals = store.calendars(for: .event)
        for calendar in userCals{
            //determine if we have already created a seperate calendar for
            //app use
            if calendar.title == "DU Schedule"{
                return (true, calendar)
            }
        }
        return (false, nil)
    }
    
    func addOurCalendar(store:EKEventStore){
        let newCalendar = EKCalendar(for:.event, eventStore: store)
        newCalendar.title="DU Schedule"
        newCalendar.source = store.defaultCalendarForNewEvents?.source
        do{
            try store.saveCalendar(newCalendar, commit: true)
            UserDefaults.standard.set(newCalendar.calendarIdentifier, forKey: "EventTrackerPrimaryCalendar")
        }catch {
            let alert = UIAlertController(title: "Calendar could not save", message: (error as NSError).localizedDescription, preferredStyle: .alert)
            let OKAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(OKAction)
            
            self.present(alert, animated: true, completion: nil)
        }
        print("[INFO] Calendar created")
    }
    
    func parseEventFile()->MXLCalendar?{
        print("Parsing ICS File...")
        guard let filePath = Bundle.main.path(forResource: "religious_holidays", ofType: "ics") else {
            print("ERROR: Did not find .ics file path")
            return nil
        }
        let calendarManager = MXLCalendarManager()
        var eventList:MXLCalendar = MXLCalendar()
        calendarManager.scanICSFileatLocalPath(filePath: filePath) { (calendar, error) in
            guard let calendar = calendar else {
                return
            }
            eventList = calendar
        }
        print("Done Parsing file")
        return eventList
    }
    
    func insertEvents(store: EKEventStore, calendar : EKCalendar, eventList : MXLCalendar){
        print("[INFO] Saving parsed events...")
        for eventFromList in eventList.events{
            let event = eventFromList.convertToEKEventOn(date: eventFromList.eventStartDate!, store: store)
            event?.calendar = calendar
            event?.isAllDay = true
            do{
                try store.save(event!, span:.thisEvent)
            } catch {
                print("[ERROR] Event not saved")
            }
        }
        print("[INFO] Finished saving parsed events")
    }

    //Function called when "Add To Calendar" button is pressed
    @IBAction func addToCal(_ sender: Any) {
        //Booleans representing if the checkbox is checked or not
        let religious = (calBoxes?.checkedBoxed[0])!
        let canvas = (calBoxes?.checkedBoxed[1])!
        let duEvents = (calBoxes?.checkedBoxed[2])!
        
        // apple calendar code
        //if(pickerArray[0]){
            let store = EKEventStore()
            
            switch EKEventStore.authorizationStatus(for: .event){
            case .authorized:
                //allowed access to calendar, process .ics
                print("[INFO] Allowed access to EventStore")
                checkOrAddCalendar(store: store)
            case .denied:
                print("[ERROR]Access to Calendar Denied")
            case .notDetermined:
                // not sure what this is
                store.requestAccess(to: .event, completion:
                    {[weak self] (granted: Bool, error: Error?) -> Void in
                        if granted {
                            self!.checkOrAddCalendar(store: store)
                        } else {
                            print("[ERROR] Access denied")
                        }
                })
            default:
                print("Case default")
            }
        //}
        
        // google calendar code
        if (pickerArray[1]) {
            
        }
        
        // outlook calendar code
        if (pickerArray[2]) {
            
        }
        
        //Test output to ensure program knows what boxes are checked and unchecked
        print("Added to Calendar:\(getTitle(index: 0, bool: religious))\(getTitle(index: 1, bool: canvas))\(getTitle(index: 2, bool: duEvents))")
        
    }
    
    //Testing Function to check which menu boxes are checked
    private func getTitle(index: Int, bool: Bool) -> String{
        
        if(index == 0 && bool){
            return " Religous Holidays,"
        } else if(index == 1 && bool){
            return " Canvas,"
        } else if(index == 2 && bool){
            return " Du Events"
        } else {
            return " Nothing"
        }
    }
    
    // handles calendar choice
    
    @IBAction func appleButton(_ sender: Any) {
        if (pickerArray[0]) {
            appleCal.setImage(UIImage.init(named: "XSymbol"), for: .normal)
        }
        
        else {
            appleCal.setImage(UIImage.init(named: "CheckSymbol"), for: .normal)
        }
        
        pickerArray[0] = !pickerArray[0]
    }
    
    @IBAction func googleButton(_ sender: Any) {
        if (pickerArray[1]) {
            googleCal.setImage(UIImage.init(named: "XSymbol"), for: .normal)
        }
            
        else {
            googleCal.setImage(UIImage.init(named: "CheckSymbol"), for: .normal)
        }
        
        pickerArray[1] = !pickerArray[1]
    }
    
    @IBAction func outlookButton(_ sender: Any) {
        if (pickerArray[2]) {
            outlookCal.setImage(UIImage.init(named: "XSymbol"), for: .normal)
        }
            
        else {
            outlookCal.setImage(UIImage.init(named: "CheckSymbol"), for: .normal)
        }
        
        pickerArray[2] = !pickerArray[2]
    }
    
    
    //Adds the TableViewController to the Screen
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "imbed"){
            calBoxes = ViewDelegate()
            let vc = segue.destination as! TableViewController
            vc.calBoxes = self.calBoxes
        }
    }
    
    
}


//Sets the defaults for the TableViewController
class ViewDelegate {
    var checkedBoxed = [true,true,true]
}

