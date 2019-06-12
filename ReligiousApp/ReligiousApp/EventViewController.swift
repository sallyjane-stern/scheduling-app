//
//  EventViewController.swift
//  ReligiousApp
//
//  Created by Trenton Parrotte on 5/3/19.
//  Copyright © 2019 Trenton Parrotte. All rights reserved.
//

import Foundation
import SafariServices
import AVFoundation
import UIKit
import SDWebImage
import GoogleAPIClientForREST
import Alamofire
import SwiftSoup

//Class representing the Event Information Screen
class EventViewcontroller:UITableViewController{
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var EventTitle: UIButton!
    @IBOutlet weak var EventName: UILabel!
    @IBOutlet weak var pronunciation: UILabel!
    @IBOutlet var theTable: UITableView!
    
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var dateView: UIView!
    @IBOutlet weak var month: UILabel!
    @IBOutlet weak var day: UILabel!
    @IBOutlet weak var religionView: UIView!
    @IBOutlet weak var religionImage: UIImageView!
    @IBOutlet weak var religionText: UILabel!
    
    @IBOutlet weak var celebratoryView: UIView!
    @IBOutlet weak var funView: UIView!
    @IBOutlet weak var reflectiveView: UIView!
    @IBOutlet weak var seriousView: UIView!
    @IBOutlet weak var mournfulView: UIView!
    @IBOutlet weak var sepLine: UIImageView!
    
    @IBOutlet weak var fastingCheck: UIImageView!
    @IBOutlet weak var travelCheck: UIImageView!
    @IBOutlet weak var expectCheck: UIImageView!
    @IBOutlet weak var busyCheck: UIImageView!
    
    @IBOutlet weak var foodList: UILabel!
    @IBOutlet weak var greetingText: UILabel!
    @IBOutlet weak var detailText: UILabel!
    
    //The Cells
    @IBOutlet weak var impactsCell: UITableViewCell!
    @IBOutlet weak var detailsTextCell: UITableViewCell!
    @IBOutlet weak var detailsCell: UITableViewCell!
    @IBOutlet weak var greetingInfoCell: UITableViewCell!
    @IBOutlet weak var greetingCell: UITableViewCell!
    @IBOutlet weak var foodListCell: UITableViewCell!
    @IBOutlet weak var foodCell: UITableViewCell!
    @IBOutlet weak var getInvolvedCell: UITableViewCell!
    @IBOutlet weak var impactsListCell: UITableViewCell!
    public var theEvent: Event!
    private var infoStruct: SheetData?
    private let kTableHeaderHeight: CGFloat = 246.0
    var headerView: UIView!
    private var isInGoogleSheets: Bool?
    
    //google sheets information for event
    private var sheetsURL: String = ""
    private var sheetsPronunciation: String = ""
    private var sheetsImpact: [String] = []
    private var sheetsMood: [String] = []
    private var sheetsFood: String = ""
    private var sheetsGreeting: String = ""
    private var sheetsDescription: String = ""
    private var sheetsRestrictions: String = ""
    
    
    private var del = UIApplication.shared.delegate as! AppDelegate

    
    
    override func viewDidLoad() {
        print("Got to view did load")
        //Set the Table View to utilize the full screen
        headerView = tableView.tableHeaderView
        tableView.tableHeaderView = nil
        tableView.addSubview(headerView)
        
        //Have the View Strech
        tableView.contentInset = UIEdgeInsets(top: kTableHeaderHeight, left: 0, bottom: 0, right: 0)
        tableView.contentOffset = CGPoint(x: 0, y: -kTableHeaderHeight)
        updateHeaderView()
        
        //Set Bar Style to White
//        navigationController?.navigationBar.barStyle = .black
        
        //Get the Appropriate Image
        isInGoogleSheets = checkGoogleSheets()
        var googleURL = ""
        if(isInGoogleSheets!){
            //Get URL from Google Sheets
            googleURL = sheetsURL
            if(!googleURL.contains(".jpg")){
                googleURL.append(".jpg")
                //print(googleURL)
            }
        } else {
            googleURL = getDefaultImageURL().absoluteString
        
        }
        let url = URL(string: googleURL)
        //Use SDWebView Library to get the appropriate image asyncronisly
        let defaultImage = UIImage().imageFromColor(color: UIColor.init(red: 141/255, green: 25/255, blue: 41/255, alpha: 1), frame: CGRect(x: 0, y: 0, width: 414, height: 246))
        
        
        imageView.sd_setImage(with: url, placeholderImage: defaultImage) { (image, error, cache, url) in
            //If Image fails to load then set the default image to a random animal
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let row = indexPath.row
        let section = indexPath.section
        //print("SHEETS VALUE: \(isInGoogleSheets!)")
        var willSetZero = !isInGoogleSheets!
        if(willSetZero && section == 0){
            if(row >= 2 && row <= 8){
                return 0
            } else {
                return UITableView.automaticDimension
            }
        } else {
            return UITableView.automaticDimension
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //Change the opacity of the navigation controller
//        self.navigationController?.setNavigationBarHidden(false, animated: true) //Sets the bar to visible
        let color = UIColor.init(red: 125/255, green: 125/255, blue: 125/255, alpha: 0.01)
        let colorImage = UIImage().imageFromColor(color: color, frame: CGRect(x: 0, y: 0, width: 340, height: 64))
//        self.navigationController?.navigationBar.setBackgroundImage(colorImage, for: .default)
        self.navigationController?.navigationBar.barTintColor = UIColor(patternImage: colorImage)
        self.navigationController?.navigationBar.isTranslucent = true
//        //Set tint color to white
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationController?.navigationBar.prefersLargeTitles = false
        
        
        //Event Cell
        isInGoogleSheets = checkGoogleSheets()
        
        //Set Button to unclickable
        EventTitle.isUserInteractionEnabled = false
        //Get Holiday Name
        EventName.text = theEvent.name
        //Get Pronounciation
        if(!isInGoogleSheets!){
            //pronunciation.text = "No Pronunciation Found"
            pronunciation.text = "Hoh-lee"
        } else {
            //Get the Pronunciation from Google Sheets
            pronunciation.text = sheetsPronunciation
        }
        
        //Date
        //Get date Components
        let date = theEvent.startDate
        let calendar = Calendar.current
        let components = calendar.dateComponents([Calendar.Component.day, Calendar.Component.month, Calendar.Component.year], from: date)
        
        let monthNum = components.month
        switch monthNum {
        case 1:
            month.text = "Jan"
        case 2:
            month.text = "Feb"
        case 3:
            month.text = "Mar"
        case 4:
            month.text = "Apr"
        case 5:
            month.text = "May"
        case 6:
            month.text = "June"
        case 7:
            month.text = "July"
        case 8:
            month.text = "Aug"
        case 9:
            month.text = "Sep"
        case 10:
            month.text = "Oct"
        case 11:
            month.text = "Nov"
        default:
            month.text = "Dec"
        }
        
        day.text = String(components.day!)
        
        //Religion Image
        let tradition = theEvent.tradition
        switch tradition{
        case "Sikh":
            religionImage.image = UIImage.init(named: "Khanda1x")
        case "Jewish":
            religionImage.image = UIImage.init(named: "judaism")
        case "Islam":
            religionImage.image = UIImage.init(named: "islam")
        case "Hindu":
            religionImage.image = UIImage.init(named: "hinduism")
        case "Christian":
            religionImage.image = UIImage.init(named: "christianity")
        case "Buddhist":
            religionImage.image = UIImage.init(named: "buddhism")
        default:
            religionImage.image = UIImage.init(named: "XSymbol")
        }
        
        religionText.text = tradition
        
        //Mood Cell
        
        //Set up the stack view
        funView.sizeThatFits(CGSize.init(width: 40, height: 92))
        //Get Moods - Order is Celbratory, Fun, Reflective, Serious, Mournful
        var moodArray = [false, false, false, false, false]
        if(!isInGoogleSheets!){
            moodArray = [false, false, false, false, false]
        } else {
            for mood in sheetsMood {
                if(mood == "Celebratory") {
                    moodArray[0] = true
                } else if(mood == "Fun") {
                    moodArray[1] = true
                } else if(mood == "Reflective") {
                    moodArray[2] = true
                } else if(mood == "Serious") {
                    moodArray[3] = true
                } else if(mood == "Mornful") {
                    moodArray[4] = true
                }
            }
            
        }
        celebratoryView.isHidden = !moodArray[0]
        funView.isHidden = !moodArray[1]
        reflectiveView.isHidden = !moodArray[2]
        seriousView.isHidden = !moodArray[3]
        mournfulView.isHidden = !moodArray[4]
        
        //If there are no moods set the seperator line to hidden
        if(moodArray == [false,false,false,false,false]){
            sepLine.isHidden = true
        }
        
        //ImpactsListCell
        
        var impactList = [true, true, true, true]
        if(!isInGoogleSheets!){
            impactList = [false, false, false, false]
        } else {
            for impact in sheetsImpact {
                if(impact == "Fasting") {
                    impactList[0] = true
                } else if(impact == "Traveling") {
                    impactList[1] = true
                } else if(impact == "Managing Family Expectations/Obligations") {
                    impactList[2] = true
                } else if(impact == "Busy with Holiday Preparation") {
                    impactList[3] = true
                }
                
            }
            
            
            
            //Set Impact
            if(!impactList[0]) { fastingCheck.image = UIImage.init(named: "XSymbol")} else { fastingCheck.image = UIImage.init(named: "CheckSymbol")}
            if(!impactList[1]) { travelCheck.image = UIImage.init(named: "XSymbol")} else { travelCheck.image = UIImage.init(named: "CheckSymbol")}
            if(!impactList[2]) { expectCheck.image = UIImage.init(named: "XSymbol")} else { expectCheck.image = UIImage.init(named: "CheckSymbol")}
            if(!impactList[3]) { busyCheck.image = UIImage.init(named: "XSymbol")} else { busyCheck.image = UIImage.init(named: "CheckSymbol")}
        }
        
        
        //FoodListCell
        if(isInGoogleSheets!) {
            foodList.text = sheetsFood
        }
        foodList.text = "Lorem ipsum dolor sit amet"
        
        //GreetingInfoCell
        
        greetingText.text = "Happy Greeting"
        
        //DetailsTextCell
        if(!isInGoogleSheets!){
            //            detailText.text = "Click the wikipedia button to learn more!"
            let text:String = EventName.text!.replacingOccurrences(of: " ", with: "_")
            let url = "https://en.wikipedia.org/wiki/\(text)"
            
            Alamofire.request(url).responseString { response in
                //                print("Request: \(String(describing: response.request))")   // original url request
                //                print("Response: \(String(describing: response.response))") // http url response
                //                print("Result: \(response.result)")                         // response serialization result
                
                //SwiftSoup.parse(response.result.description)
                var body = ""
                do {
                    let html = response.result.value
                    let doc: Document = try SwiftSoup.parse(html!)
                    var t = try doc.text()
                    var details = "From Wikipedia:\n"
                    var wordCount = 0
                    //String parsing
                    var distance:Int = 0
                    
                    if let startIndex = t.firstIndex(of: "["){
                        distance = t.distance(from: t.startIndex, to: startIndex)}
                    
                    if(distance != 0){
                        for index in 0...distance{
                            t.removeFirst()
                        }
                        
                        
                        for index in distance...t.count {
                            var char:Character = t.removeFirst()
                            if(wordCount < 200){
                                if(char == " "){
                                    wordCount += 1
                                }
                                details.append(char)
                            } else {
                                break
                            }
                        }
                        
                    } else {
                        details.append("Click Wikipedia Button for more details")
                    }
                    
                    details.append("...")
                    //print("=======DETAILS====")
                    //print(details)
                    self.detailText.text = details
                    self.view.setNeedsLayout()
                    self.tableView.reloadData()
                    
                    //self.detailText.text = try doc.text()
                } catch Exception.Error(let type, let message) {
                    print("Error1")
                } catch {
                    print("Error2")
                }
                
            }
            
            
            
        }
        
        
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableView.automaticDimension
        tableView.reloadData()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        //Resets the navigation controller to its default look
//        self.navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
        self.navigationController?.navigationBar.barTintColor = UIColor.init(red: 141/255, green: 25/255, blue: 42/255, alpha: 1.0)
        self.navigationController?.navigationBar.tintColor = self.view.tintColor
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationController?.navigationBar.isTranslucent = false
    }
    
    //    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    //        return UITableView.automaticDimension
    //    }
    
    func updateHeaderView() {
        var headerRect = CGRect(x: 0, y: -kTableHeaderHeight, width: tableView.bounds.width, height: kTableHeaderHeight)
        if tableView.contentOffset.y < -kTableHeaderHeight {
            headerRect.origin.y = tableView.contentOffset.y
            headerRect.size.height = -tableView.contentOffset.y
        }
        
        headerView.frame = headerRect
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        updateHeaderView()
    }
    
    func checkGoogleSheets() -> Bool {
        print("checkingSheets")
        //Check if the event is in Google Sheets
        var isInSheets:Bool = false
        for sheet in del.SheetArr {
            if theEvent.name == sheet.name {
                isInSheets = true
                
                sheetsURL = sheet.imageURL
                sheetsFood = sheet.food
                sheetsMood = sheet.mood
                sheetsImpact = sheet.impacts
                sheetsGreeting = sheet.greeting
                sheetsPronunciation = sheet.pronounce
                sheetsDescription = sheet.desc
                sheetsRestrictions = sheet.restrictions
            }
        }
        
        return isInSheets
    }
    
    func googleSheetsParser() {
        let service = GTLRService()
        let spreadSheetID = "1issBSCYE-qq00dk2_CD8AH95HPi_Mik1TGBd_0DLNGE"
        let range = "A1:K"
        let query = GTLRSheetsQuery_SpreadsheetsValuesGet.query(withSpreadsheetId: spreadSheetID, range: range)
        service.executeQuery(query, completionHandler: nil)
        
    }
    func addToSheetData(ticket: GTLRServiceTicket, finishedWithObject result : GTLRSheets_ValueRange, error : NSError?) {
        
        if let error = error {
            print("ERROR")
            return
        }
        let data = result.values!
        //        for row in data {
        //            infoSheet = SheetData.init(name: <#T##String#>, pronounce: <#T##String#>, tradition: <#T##String#>, mood: <#T##String#>, impacts: <#T##String#>, food: <#T##String#>, greeting: <#T##String#>, desc: <#T##String#>, imageURL: <#T##String#>, restrictions: <#T##String#>)
        //        }
    }
    //Function that uses a random number generator to select a random animal from the list and return that animal as an image to be displayed
    func getDefaultImageURL() -> URL{
        
        //Get Randomized Animal Image
        let animals = ["meerkat","aardvark","addax","alligator","alpaca","anteater","antelope","ape","argali","armadillo","baboon","badger","beagle","basilisk","bat","bear","beaver","bighorn","bison","budgerigar","buffalo","bull","bunny","burro","camel","canary","capybara","cat","chameleon","chamois","cheetah","chimpanzee","chinchilla","chipmunk","civet","coati","colt","cougar","cow","coyote","crocodile","crow","deer","dingo","doe","dungbeetle","dog","donkey","dormouse","dromedary","platypus","dugong","eland","elephant","elk","ermine","ewe","fawn","ferret","finch","fish","fox","frog","gazelle","gemsbok","giraffe","gnu","goat","gopher","gorilla","grizzlybear","groundhog","guanaco","guineapig","hamster","hare","hartebeest","hedgehog","highlandcow","hippopotamus","hog","horse","hyena","ibex","iguana","impala","jackal","jaguar","jerboa","kangaroo","kitten","koala","lemur","leopard","lion","lizard","llama","lovebird","lynx","mandrill","mare","marmoset","marten","mink","mole","mongoose","monkey","moose","mountaingoat","mouse","mule","musk-ox","muskrat","mustang","mynahbird","newt","ocelot","okapi","opossum","orangutan","oryx","otter","ox","panda","panther","parakeet","parrot","peccary","pig","quokka","octopus","starfish","crab","snowyowl","chicken","rooster","bumblebee","polarbear","pony","porcupine","porpoise","prairiedog","pronghorn","puma","puppy","quagga","rabbit","raccoon","ram","rat","reindeer","rhinoceros","salamander","seal","sheep","shrew","silverfox","skunk","sloth","snake","springbok","squirrel","stallion","steer","tapir","tiger","toad","turtle","vicuna","walrus","warthog","waterbuck","weasel","whale","wildcat","baldeagle","wolf","wolverine","wombat","woodchuck","yak","zebra","zebu"]
        let size = animals.count
        let rng = Int.random(in: 0 ..< size)
        let animal = animals[rng]
        //The size of the UI Image View is 414x246
        let url = URL(string: "https://loremflickr.com/414/246/animal,\(animal)/all")!
        
        return url
    }
    
    //Function that converts text to speech using Swift's built in AVFoundation Kit
    @IBAction func textToSpeech(_ sender: Any) {
        let utterance = AVSpeechUtterance(string: pronunciation.text!)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        utterance.rate = 0.5
        
        let synthesizer = AVSpeechSynthesizer()
        synthesizer.speak(utterance)
    }
    
    //Function that opens Safari Web Controller and links them to the appropriate wikipedia
    @IBAction func sendToWiki(_ sender: Any) {
        let text:String = EventName.text!.replacingOccurrences(of: " ", with: "_")
        let url = URL(string: "https://en.wikipedia.org/wiki/\(text)")!
        print(url)
        let safari = SFSafariViewController.init(url: url)
        present(safari, animated: true, completion: nil)
    }
    
    
    //Functions dealing with information buttons
    @IBAction func impactI(_ sender: Any) {
        let alert = UIAlertController(title: "Student Accommodations", message: "Student accommodations might include:\n• Assignment modifications\n• Student modified schedule\n• Excused absences\n• Other Accommodations (ask your classes!)", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
            NSLog("The \"OK\" alert occured.")
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func foodI(_ sender: Any) {
        let alert = UIAlertController(title: "Food Disclaimer", message: "Dishes will differ based on denomination and region.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
            NSLog("The \"OK\" alert occured.")
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func greetingI(_ sender: Any) {
        let alert = UIAlertController(title: "Greeting Disclaimer", message: "This is only an example greeting and greetings will differ based on denomination and region.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
            NSLog("The \"OK\" alert occured.")
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func disclaimerI(_ sender: Any) {
        let alert = UIAlertController(title: "General Disclaimer", message: "We realize that holidays are multilayered and complex; we are simply checking off a few moods to give people a tiny sense of the overall tone of the day\n\nThis fact sheet is part of DU’s new Religious Inclusivity Initiative. It is designed in consultation with scholars and practitioners and is meant as a practical go-to ‘beta’ resource, not a comprehensive or definitive presentation of any religion or holiday. Want to recommend a change? Want to suggest another holiday to feature? Contact Profs. Sarah Pessin & Andrea Stanton at cjs@du.edu\n\nWith support from the Paul and Caz Eldridge Endowed Fund for Judaic Studies and Cultural Diversity @ the University of Denver (DU), and presented as part of a new DU partnership with Interfaith Youth Core (IFYC) and the Association of American Colleges and Universities (AAC&U)", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
            NSLog("The \"OK\" alert occured.")
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}

//Extension for UIImage that will help set the color of the Navigation Controller
extension UIImage {
    func imageFromColor(color: UIColor, frame: CGRect) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(frame.size, false, 0)
        color.setFill()
        UIRectFill(frame)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
}

