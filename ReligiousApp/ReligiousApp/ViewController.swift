//
//  ViewController.swift
//  ReligiousApp
//
//  Created by Trenton Parrotte on 4/23/19.
//  Copyright © 2019 Trenton Parrotte. All rights reserved.
//

import UIKit
import EventKit

class ViewController: UIViewController {

    @IBOutlet weak var addButton: UIButton!
    
    @IBOutlet weak var containerView: UIView!
    
    private var calBoxes: ViewDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        
    }
    
    func checkOrAddCalendar(store:EKEventStore){
        let firstCheck = checkForCalendar(store:store)
        if firstCheck.0 {
            print("[INFO] Calendar already exists")
            insertEvents(store: store, calendar: firstCheck.1!)
        } else {
            addOurCalendar(store: store)
            let secondCheck = checkForCalendar(store: store)
            if secondCheck.0{
                insertEvents(store: store, calendar: secondCheck.1!)
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
        let sourcesInEventStore = store.sources
        newCalendar.source = sourcesInEventStore.filter{
            (source:EKSource) ->Bool in
            source.sourceType.rawValue == EKSourceType.local.rawValue
            }.first!
        
        do{
            try store.saveCalendar(newCalendar, commit: true)
            UserDefaults.standard.set(newCalendar.calendarIdentifier, forKey: "EventTrackerPrimaryCalendar")
        }catch {
            let alert = UIAlertController(title: "Calendar could not save", message: (error as NSError).localizedDescription, preferredStyle: .alert)
            let OKAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(OKAction)
            
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func insertEvents(store: EKEventStore, calendar : EKCalendar){
        print("[INFO] Creating event...")
        //right now, only inserting one event
        let event = EKEvent(eventStore: store)
        event.calendar = calendar
        event.title = "NEW EVENT"
        event.startDate = Date()
        event.endDate = Date().addingTimeInterval(2 * 60 * 60)
        print("[INFO] Event Created")
        print("[INFO] Saving event...")
        do{
            try store.save(event, span:.thisEvent)
        } catch {
            print("[ERROR] Event not saved")
        }
    }

    @IBAction func addToCal(_ sender: Any) {
        //Booleans representing if the checkbox is checked or not
        let relgious = (calBoxes?.checkedBoxed[0])!
        let canvas = (calBoxes?.checkedBoxed[1])!
        let duEvents = (calBoxes?.checkedBoxed[2])!
        
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
        
        
        print("Added to Calendar:\(getTitle(index: 0, bool: relgious))\(getTitle(index: 1, bool: canvas))\(getTitle(index: 2, bool: duEvents))")
        
    }
    
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "imbed"){
            calBoxes = ViewDelegate()
            let vc = segue.destination as! TableViewController
            vc.calBoxes = self.calBoxes
        }
    }
    
}

class ViewDelegate {
    var checkedBoxed = [true,true,true]
}

