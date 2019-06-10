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

//Class that represents the screen that is presented when "Add to Calendar" is pressed, minus the table
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
    
    fileprivate let calendarTitle = "Interfaith Calendar"
    private var localTimeZoneName: String { return TimeZone.current.identifier }
    
    // google stuff
    private let googleClientID = "744700381381-flvfrkqv2tqvkma7jsdthd82ogsg7dhc.apps.googleusercontent.com"
    private let googleScope = "https://www.googleapis.com/auth/calendar"
    private let googleURI = "com.googleusercontent.apps.744700381381-flvfrkqv2tqvkma7jsdthd82ogsg7dhc"
    private let googleResponse = "code"
    private let googleRequest = URL(string: "https://accounts.google.com/o/oauth2/v2/auth?client_id=744700381381-flvfrkqv2tqvkma7jsdthd82ogsg7dhc.apps.googleusercontent.com&redirect_uri=com.googleusercontent.apps.744700381381-flvfrkqv2tqvkma7jsdthd82ogsg7dhc&response_type=code&scope=calendar")
    
    private var pickerArray = [false, false, false]
    private var queryArry:[GTLRQuery] = []
    
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
        
        addButton.isEnabled = false
        addButton.isUserInteractionEnabled = false
        
        
        
        // Uncomment to automatically sign in the user.
        GIDSignIn.sharedInstance().signInSilently()
        
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
            //insertEvents(store: store, calendar: firstCheck.1!, eventList: parsedEventList!)
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
        if(completion(true) == true){
            dismissControllerHelper()
        }
    }
    
    func checkForCalendar(store:EKEventStore)->(Bool, EKCalendar?){
        let userCals = store.calendars(for: .event)
        for calendar in userCals{
            //determine if we have already created a seperate calendar for
            //app use
            if calendar.title == calendarTitle{
                return (true, calendar)
            }
        }
        return (false, nil)
    }
    
    func addOurCalendar(store:EKEventStore){
        let newCalendar = EKCalendar(for:.event, eventStore: store)
        newCalendar.title = calendarTitle
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
            // Check if the user has signed into Google
            if(GIDSignIn.sharedInstance().hasAuthInKeychain()){
                print("======Adding to Google Calendar!======")
                let service = GTLRCalendarService.init()
                let inst = GIDSignIn.sharedInstance()
                service.authorizer = GIDSignIn.sharedInstance().currentUser.authentication.fetcherAuthorizer()
                
                let calListQuery = GTLRCalendarQuery_CalendarListList.query()
                var hasCalendar = false
                var hasEvents = false
                var ourCal:GTLRCalendar_Calendar = GTLRCalendar_Calendar.init()
                var calID: String = ""
                
                //Check to see if the Calendar already exists
                service.executeQuery(calListQuery, completionHandler: { (ticket: GTLRServiceTicket, object: Any?, error: Error?) -> Void in
                    var calList = object as! GTLRCalendar_CalendarList
                    
                    for calendar in calList.items!{
                        var calTitle = calendar.summary!
                        if(calTitle == self.calendarTitle){
                            //if(calTitle == "DU AGO"){
                            hasCalendar = true
                            //Initialize ourCal to the calendar in the List
                            ourCal.eTag = calendar.eTag
                            ourCal.descriptionProperty = calendar.descriptionProperty
                            ourCal.identifier = calendar.identifier
                            ourCal.kind = calendar.kind
                            ourCal.location = calendar.location
                            ourCal.summary = calendar.summary
                            ourCal.timeZone = calendar.timeZone
                            break;
                        }
                    }
                    
                    if error != nil {print("\(object) error: \(error)")}
                    //If Calendar exists, check to see if our events have been added
                    if(hasCalendar){
                        print("GOOGLE CALENDAR ALREADY CREATED")
                        //Set Calendar ID
                        calID = ourCal.identifier!
                        //Check and see if the events are already created
                        let eventListQuery = GTLRCalendarQuery_EventsList.query(withCalendarId: calID)
                        service.executeQuery(eventListQuery, completionHandler: {(ticket: GTLRServiceTicket, object: Any?, error: Error?) -> Void in
                            let eventList = object as! GTLRCalendar_Events
                            if(!self.checkGoogleEventsList(eventList: eventList, calendarID: calID)){
                                //The events need to be added
                                print("CALENDAR HAS NO EVENTS")
                                self.addGoogleEvents(service: service, calendarID: calID)
                                
                            } else {
                                //The events have already been added
                                print("EVENTS HAVE ALREADY BEEN ADDED")
                            }
                        })
                        
                        
                    } else {
                        //Create the Calendar
                        print("CREATING GOOGLE CALENDAR")
                        ourCal.summary = self.calendarTitle
                        ourCal.timeZone = self.localTimeZoneName
                        //Add the calendar to the list
                        
                        let insertCalendarQuery = GTLRCalendarQuery_CalendarsInsert.query(withObject: ourCal)
                        
                        service.executeQuery(insertCalendarQuery, completionHandler: {(ticket: GTLRServiceTicket, object: Any?, error: Error?) -> Void in
                            let theCal:GTLRCalendar_Calendar = object as! GTLRCalendar_Calendar
                            calID = theCal.identifier!
                            self.addGoogleEvents(service: service, calendarID: calID)
                            if(error != nil){print("\(theCal) Error: \(error)")}
                        })
                        
                    }
                    self.dismissControllerHelper()
                })
            } else {
                let alert = UIAlertController(title: "Calendar Error", message: "Please sign into your Google Account", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
                    NSLog("The \"OK\" alert occured.")
                }))
                self.present(alert, animated: true, completion: nil)
            }
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
    
    //Check if the events are in the array
    func checkGoogleEventsList(eventList: GTLRCalendar_Events, calendarID: String) -> Bool{
        let del = UIApplication.shared.delegate as! AppDelegate
        var eventArray = del.EventArr
        var calEvent:GTLRCalendar_Event = GTLRCalendar_Event.init()

        
        for event in eventArray{
            calEvent.summary = event.name
            
            //Set date
            var startDateTime:GTLRDateTime = GTLRDateTime.init(date: event.startDate)
            var start:GTLRCalendar_EventDateTime = GTLRCalendar_EventDateTime.init()
            var GTLREvent = eventList.items![0]
            start.dateTime = startDateTime
            start.timeZone = localTimeZoneName
            calEvent.start = start
            var cond1 = GTLREvent.summary == calEvent.summary
//            var cond2 = GTLREvent.start == calEvent.start
            if(cond1){
                //Event is found
                return true
            }
        }
        return false
        
    }
    
    //Using the service that has the Oath2 Token and the Calendar ID, Add Events to the Calendar
    //Calendar ID has to be a paramater as calID may be nil when creating a new calendar due to
    //  the asynchronized function
    func addGoogleEvents(service: GTLRCalendarService, calendarID: String) {
        var index = 0;
        var calEventArray:[GTLRCalendar_Event] = self.createGoogleEvents()
        //Add Events to Calendar
        for calEvent in calEventArray{
            var addEventQuery = GTLRCalendarQuery_EventsInsert.query(withObject: calEvent, calendarId: calendarID)
            self.queryArry.append(addEventQuery)
        }
        //Send the Batch to the server to prcoess
        let batchQuery = GTLRBatchQuery.init(queries: self.queryArry)
        service.executeQuery(batchQuery, completionHandler: {(ticket: GTLRServiceTicket, object: Any?, error: Error?) -> Void in
            let qObject = object
            print("=======FINISHED ADDING TO GOOGLE CALENDAR=======")
            self.dismissControllerHelper()
            if(error != nil){print("\(qObject) Error: \(error)")}
        })
    }
    
    //Goes the the App Delegate's Event Array and converts those to GTLRCalendar_Events
    func createGoogleEvents() -> [GTLRCalendar_Event]{
        var calEventArray:[GTLRCalendar_Event] = []
        let del = UIApplication.shared.delegate as! AppDelegate
        var eventArray = del.EventArr
        var calEvent: GTLRCalendar_Event = GTLRCalendar_Event.init()
        
        for event in eventArray{
            //Set the event
            var name = event.name.replacingOccurrences(of: " ", with: "_")
            calEvent.descriptionProperty = "https://en.wikipedia.org/wiki/\(name) to know more about \(event.name)"
            
            //Obnoxious Date Setting
            var startDateTime:GTLRDateTime = GTLRDateTime.init(date: event.startDate)
            var start:GTLRCalendar_EventDateTime = GTLRCalendar_EventDateTime.init()
            start.dateTime = startDateTime
            start.timeZone = localTimeZoneName
            
            var endDateTime:GTLRDateTime = GTLRDateTime.init(date: event.endDate)
            var end:GTLRCalendar_EventDateTime = GTLRCalendar_EventDateTime.init()
            end.dateTime = endDateTime
            end.timeZone = localTimeZoneName
 
            calEvent.start = start
            calEvent.end = end
            
            calEvent.summary = event.name
            
            calEventArray.append(calEvent.copy() as! GTLRCalendar_Event)
        }
        return calEventArray
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
        changeAddButtonStatus()
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
        changeAddButtonStatus()
        
    }
    
    func changeButtonStatus(status: Bool){
        GoogleSignInButton.isHidden = status
    }
    
    
    @IBAction func outlookButton(_ sender: Any) {
        if (pickerArray[2]) {
            outlookCal.setImage(UIImage.init(named: "XSymbol"), for: .normal)
        }
            
        else {
            outlookCal.setImage(UIImage.init(named: "CheckSymbol"), for: .normal)
        }
        
        pickerArray[2] = !pickerArray[2]
        changeAddButtonStatus()
    }
    
    func changeAddButtonStatus(){
        if(pickerArray[0] || pickerArray[1] || pickerArray[2]){
            if(pickerArray[1]){
                if(GIDSignIn.sharedInstance().hasAuthInKeychain()){
                    addButton.isEnabled = true
                    addButton.isUserInteractionEnabled = true
                } else {
                    addButton.isEnabled = false
                    addButton.isUserInteractionEnabled = false
                }
            } else {
                addButton.isEnabled = true
                addButton.isUserInteractionEnabled = true
            }
        } else {
            addButton.isEnabled = false
            addButton.isUserInteractionEnabled = false
        }
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




