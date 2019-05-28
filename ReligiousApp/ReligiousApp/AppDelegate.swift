//
//  AppDelegate.swift
//  ReligiousApp
//
//  Created by Trenton Parrotte on 4/23/19.
//  Copyright © 2019 Trenton Parrotte. All rights reserved.
//

import UIKit
import GoogleSignIn
import MXLCalendarManagerSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, GIDSignInDelegate {
    var window: UIWindow?
    public var EventArr = [Event]()


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // Initialize sign-in
        GIDSignIn.sharedInstance().clientID = "744700381381-flvfrkqv2tqvkma7jsdthd82ogsg7dhc.apps.googleusercontent.com"
        GIDSignIn.sharedInstance().delegate = self
        
        // Create an event array
        var event = Event.init()
        //Only Parse through the calendar files the first time the app is loaded
        if(!UserDefaults.standard.bool(forKey: "onBoard")){
            let eventList = parseEventFile()
            let size = eventList?.events.count ?? 0
            var index = 0
            
            let calendar = Calendar.current
            
            let today = Date.init()
            
            var components = calendar.dateComponents([Calendar.Component.day, Calendar.Component.month, Calendar.Component.year], from: today)
            
            
            components.day = 1
            components.month = 1
            components.hour = 7
            components.minute = 1
            
            let thisYear = calendar.date(from: components)

            while(index < size){
                var mkEvent = eventList?.events.remove(at: 0)
                var eventName: String = mkEvent!.eventSummary!
                //Different Religions: Sikh, Jewish, Islam, Hindu, Christian, Buddhist
                var religion: String = mkEvent!.eventLocation!
                var startDate: Date = mkEvent!.eventStartDate!
                var endDate: Date = mkEvent!.eventEndDate!
                
                //Only add events if they are within this year (or greater)
                if(endDate >= thisYear ?? today){
                    event = Event.init(title: eventName, start: startDate, end: endDate, tradition: religion)
                    EventArr.append(event)
                }
                index += 1
            }
            
            //Sort the Array by start date for easier retrival
            EventArr.sort(by: sorterForEvents)
            UserDefaults.standard.set(true, forKey: "onBoard")
            saveEvents()
            
        } else {
            //Load in the Events
            EventArr = loadEvents()!
        }
        
        //Loop through the events for testing
        for event in EventArr{
            if(event.name == "Hanukkah Starts" || event.name == "Hanukkah Ends"){
                print("Title: \(event.name)\n Start Date: \(event.startDate)\n End Date: \(event.endDate)\n Tradition: \(event.tradition)")
            }
        }
        

        return true
    }
    
    //Helper Function to sort Events
    private func sorterForEvents(this:Event, that:Event) -> Bool {
        return this.startDate < that.startDate
    }
    
    //Saves Events into the Document Directory
    private func saveEvents(){
        do{
            let isSuccessfulSave = try? NSKeyedArchiver.archivedData(withRootObject: EventArr, requiringSecureCoding: false)
            try isSuccessfulSave?.write(to: URL(fileURLWithPath: Event.ArchiveURL.path))
            print("Events were sucessfully saved")
        } catch {
            print("Failed to save events")
        }
    }
    
    //Loads Events from the Document Directory
    private func loadEvents() -> [Event]?{
        var savedEvents: [Event] = []
        do{
            let loadEvents = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(Data.init(contentsOf: URL(fileURLWithPath: Event.ArchiveURL.path))) as? [Event]
            savedEvents = loadEvents ?? []
        } catch {
            print("Couldn't read file.")
        }
        return savedEvents
    }
    
    // here
    // pasted function from documentation
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!,
              withError error: Error!) {
        if let error = error {
            print("\(error.localizedDescription)")
        } else {
            // Perform any operations on signed in user here.
            let userId = user.userID                  // For client-side use only!
            let idToken = user.authentication.idToken // Safe to send to the server
            let fullName = user.profile.name
            let givenName = user.profile.givenName
            let familyName = user.profile.familyName
            let email = user.profile.email
            
            var user = GIDSignIn.sharedInstance()!.currentUser
            let calendarScope = "https://www.googleapis.com/auth/calendar"
            var userScopes:[String] = user?.accessibleScopes as! [String]
            
            print(GIDSignIn.sharedInstance().scopes)
            
            // Check if the user has granted the Calendar scope
            if (!userScopes.contains(calendarScope)) {
                // request additional drive scope
                GIDSignIn.sharedInstance()?.scopes.append(calendarScope) // append scope to accessible scopes
                GIDSignIn.sharedInstance()!.loginHint = email // set login hint to skip account chooser
                GIDSignIn.sharedInstance()?.signIn() // sign in to refresh tokens
            }
        }
    }
    
    
    // and here
    // pasted function from documentation
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!,
              withError error: Error!) {
        // Perform any operations when the user disconnects from app here.
        // ...
    }
    
    // pasted function from documentation
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        return GIDSignIn.sharedInstance().handle(url as URL?,
                                                 sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String,
                                                 annotation: options[UIApplication.OpenURLOptionsKey.annotation])
    }
    
    // pasted function from documentation
    func application(application: UIApplication,
                     openURL url: NSURL, sourceApplication: String?, annotation: AnyObject?) -> Bool {
        var options: [String: AnyObject] = [UIApplication.OpenURLOptionsKey.sourceApplication.rawValue: sourceApplication as AnyObject,
                                            UIApplication.OpenURLOptionsKey.annotation.rawValue: annotation!]
        return GIDSignIn.sharedInstance().handle(url as URL,
                                                    sourceApplication: sourceApplication,
                                                    annotation: annotation)
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
    }
    

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    //Parse Events copied from ViewController.Swift
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


}

