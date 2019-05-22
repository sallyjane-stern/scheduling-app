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
import GoogleAPIClientForREST
//import GTMOAuth2
import GoogleSignIn

class ViewController: UIViewController, GIDSignInUIDelegate {
    
    @IBOutlet weak var outlookCal: UIButton!
    
    @IBOutlet weak var googleCal: UIButton!
    @IBOutlet weak var appleCal: UIButton!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var GoogleSignInButton: GIDSignInButton!
    @IBOutlet weak var containerView: UIView!
    
    @IBOutlet var SwipeRecognizer: UISwipeGestureRecognizer!
    private var calBoxes: ViewDelegate?
    private var isDone = false
    
    // google stuff
    private let googleClientID = "744700381381-flvfrkqv2tqvkma7jsdthd82ogsg7dhc.apps.googleusercontent.com"
    private let googleScope = "https://www.googleapis.com/auth/calendar"
    private let googleURI = "com.googleusercontent.apps.744700381381-flvfrkqv2tqvkma7jsdthd82ogsg7dhc"
    private let googleResponse = "code"
    private let googleRequest = URL(string: "https://accounts.google.com/o/oauth2/v2/auth?client_id=744700381381-flvfrkqv2tqvkma7jsdthd82ogsg7dhc.apps.googleusercontent.com&redirect_uri=com.googleusercontent.apps.744700381381-flvfrkqv2tqvkma7jsdthd82ogsg7dhc&response_type=code&scope=calendar")
    
    private var pickerArray = [false, false, false]
    
    //Completion handler so the view does not close when it is not supposed to
    let handlerBlock: (Bool) -> Bool = {
        if $0 {
            print("Add To Calendar is complete")
            //Closes the view controller
            return true
        } else {
            return false
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        GoogleSignInButton.isHidden = true
        GIDSignIn.sharedInstance().uiDelegate = self
        
        // Uncomment to automatically sign in the user.
        //GIDSignIn.sharedInstance().signInSilently()
        
        // TODO(developer) Configure the sign-in button look/feel
        // ...
    }
    
    @IBAction func didTapSignOut(_ sender: AnyObject) {
        GIDSignIn.sharedInstance().signOut()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        //Google Sign in button configuration
        if(GIDSignIn.sharedInstance().hasAuthInKeychain()){
            changeButtonStatus(status: true)
        }
    }
    

    
    
    func checkOrAddCalendar(store:EKEventStore, completion: (Bool) -> Bool){
        let parsedEventList = parseEventFile()
        let firstCheck = checkForCalendar(store:store)
        if firstCheck.0 {
            print("[INFO] Calendar already exists")
            insertEvents(store: store, calendar: firstCheck.1!, eventList: parsedEventList!)
        } else {
            addOurCalendar(store: store)
            let secondCheck = checkForCalendar(store: store)
            if secondCheck.0{
                insertEvents(store: store, calendar: secondCheck.1!, eventList: parsedEventList!)
            } else {
                print("NO CALENDAR RETURNED FROM CREATE")
            }
        }
        if(completion(true) == true){
            dismissControllerHelper()
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
        
        return eventList
    }
    
    func insertEvents(store: EKEventStore, calendar : EKCalendar, eventList : MXLCalendar){
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
        
    }

    
    //Function called when "Add To Calendar" button is pressed
    @IBAction func addToCal(_ sender: Any) {
        //Booleans representing if the checkbox is checked or not
        let religious = (calBoxes?.checkedBoxed[0])!
        let canvas = (calBoxes?.checkedBoxed[1])!
        let duEvents = (calBoxes?.checkedBoxed[2])!
        
        // apple calendar code
        if(pickerArray[0]){
            let store = EKEventStore()
            
            switch EKEventStore.authorizationStatus(for: .event){
            case .authorized:
                //allowed access to calendar, process .ics
                print("[INFO] Allowed access to EventStore")
                checkOrAddCalendar(store: store, completion: handlerBlock)
            case .denied:
                print("[ERROR]Access to Calendar Denied")
            case .notDetermined:
                // not sure what this is
                store.requestAccess(to: .event, completion:
                    {[weak self] (granted: Bool, error: Error?) -> Void in
                        if granted {
                            self!.checkOrAddCalendar(store: store, completion: self!.handlerBlock)
                        } else {
                            print("[ERROR] Access denied")
                        }
                })
            default:
                print("Case default")
            }
        }
        
        // google calendar code
        if (pickerArray[1]) {
            // get permission to access calendars
                // send request to google
            if(GIDSignIn.sharedInstance().hasAuthInKeychain()){
                print("======Adding to Google Calendar!======")
            } else {
                let alert = UIAlertController(title: "Calendar Error", message: "Please sign into your Google Account", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
                    NSLog("The \"OK\" alert occured.")
                }))
                self.present(alert, animated: true, completion: nil)
            }
            // check if calendar already exists
            // if doesn't exist add calendar
        }
        
        
        // outlook calendar code
        if (pickerArray[2]) {
            
        }
        
        //Test output to ensure program knows what boxes are checked and unchecked
        print("Added to Calendar:\(getTitle(index: 0, bool: religious))\(getTitle(index: 1, bool: canvas))\(getTitle(index: 2, bool: duEvents))")
        
        if(!pickerArray[0] && !pickerArray[2] && !pickerArray[1]){
            dismissControllerHelper()
        }
        
        
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
        if(pickerArray[1] && !GIDSignIn.sharedInstance().hasAuthInKeychain()){
            changeButtonStatus(status: false)
        } else {
            changeButtonStatus(status: true)
        }
        
        
    }
    
    func changeButtonStatus(status: Bool){
        GoogleSignInButton.isHidden = status
        addButton.isEnabled = status
        addButton.isUserInteractionEnabled = status
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
    
    //Dismisses the view Controller
    @IBAction func closeController(_ sender: Any) {
        dismissControllerHelper()
    }
    
    
    func dismissControllerHelper(){
        dismiss(animated: true, completion: nil)
    }
    
    
    
}


//Sets the defaults for the TableViewController
class ViewDelegate {
    var checkedBoxed = [true,true,true]
}




