//
//  EventViewController.swift
//  ReligiousApp
//
//  Created by Trenton Parrotte on 5/3/19.
//  Copyright © 2019 Trenton Parrotte. All rights reserved.
//

import Foundation
import AVFoundation
import UIKit

class EventViewcontroller:UITableViewController {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var EventTitle: UIButton!
    @IBOutlet weak var EventName: UILabel!
    @IBOutlet weak var Pronounciation: UILabel!
    
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var dateView: UIView!
    @IBOutlet weak var month: UILabel!
    @IBOutlet weak var day: UILabel!
    @IBOutlet weak var religionView: UIView!
    @IBOutlet weak var religionImage: UILabel!
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
    
    @IBOutlet weak var detailText: UITextView!
    
    
    
    
    override func viewDidLoad() {
        
        //Get image if they are in the assets
            //Code Here
        
        //Get default image if the event does not have an image
        if(imageView.image == nil) {
            imageView.image = getDefaultImage()
        }
        
        //Set the Table View to utilize the full screen
        self.tableView.contentInset = UIEdgeInsets(top: -(88 + view.safeAreaInsets.top), left: 0, bottom: 0, right: 0)
        
        //Event Cell
        
        //Set Button to unclickable
        EventTitle.isUserInteractionEnabled = false
        //Get Holiday Name
            //Code Here
        //Get Pronounciation
            //Code Here
        if(Pronounciation.text == "Pronounce"){
            Pronounciation.text = "No Pronounciation Found"
        }
        
        //Mood Cell
        
        //Set up the stack view
        funView.sizeThatFits(CGSize.init(width: 40, height: 92))
        //Get Moods - Order is Celbratory, Fun, Reflective, Serious, Mournful
        let moodArray = [true, true, false, false, false]
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
        
        let impactList = [true, true, true, false]
        if(!impactList[0]) { fastingCheck.image = UIImage.init(named: "XSymbol")} else { fastingCheck.image = UIImage.init(named: "CheckSymbol")}
        if(!impactList[1]) { travelCheck.image = UIImage.init(named: "XSymbol")} else { travelCheck.image = UIImage.init(named: "CheckSymbol")}
        if(!impactList[2]) { expectCheck.image = UIImage.init(named: "XSymbol")} else { expectCheck.image = UIImage.init(named: "CheckSymbol")}
        if(!impactList[3]) { busyCheck.image = UIImage.init(named: "XSymbol")} else { busyCheck.image = UIImage.init(named: "CheckSymbol")}
        
        //FoodListCell
        
        foodList.text = "Lorem ipsum dolor sit amet"
        
        //GreetingInfoCell
        
        greetingText.text = "Happy Greeting"
        
        //DetailsTextCell
        
        detailText.text = "Lorem ipsum dolor sit er elit lamet, consectetaur cillium adipisicing pecu, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum. Nam liber te conscient to factor tum poen legum odioque civiuda."
        
        
        

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //Change the opacity of the navigation controller
        self.navigationController?.setNavigationBarHidden(false, animated: true) //Sets the bar to visible
        let color = UIColor.init(red: 125/255, green: 125/255, blue: 125/255, alpha: 0.4)
        let colorImage = UIImage().imageFromColor(color: color, frame: CGRect(x: 0, y: 0, width: 340, height: 64))
        self.navigationController?.navigationBar.setBackgroundImage(colorImage, for: .default)
        //Set tint color to white
        self.navigationController?.navigationBar.tintColor = UIColor.white
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
        self.navigationController?.navigationBar.tintColor = self.view.tintColor
    }
    
    //Function that uses a random number generator to select a random animal from the list and return that animal as an image to be displayed
    func getDefaultImage() -> UIImage{
        //Create image Variable
        var image:UIImage
        
        //Get Randomized Animal Image
        let animals = ["meerkat","aardvark","addax","alligator","alpaca","anteater","antelope","ape","argali","armadillo","baboon","badger","beagle","basilisk","bat","bear","beaver","bighorn","bison","budgerigar","buffalo","bull","bunny","burro","camel","canary","capybara","cat","chameleon","chamois","cheetah","chimpanzee","chinchilla","chipmunk","civet","coati","colt","cougar","cow","coyote","crocodile","crow","deer","dingo","doe","dungbeetle","dog","donkey","dormouse","dromedary","platypus","dugong","eland","elephant","elk","ermine","ewe","fawn","ferret","finch","fish","fox","frog","gazelle","gemsbok","giraffe","gnu","goat","gopher","gorilla","grizzlybear","groundhog","guanaco","guineapig","hamster","hare","hartebeest","hedgehog","highlandcow","hippopotamus","hog","horse","hyena","ibex","iguana","impala","jackal","jaguar","jerboa","kangaroo","kitten","koala","lemur","leopard","lion","lizard","llama","lovebird","lynx","mandrill","mare","marmoset","marten","mink","mole","mongoose","monkey","moose","mountaingoat","mouse","mule","musk-ox","muskrat","mustang","mynahbird","newt","ocelot","okapi","opossum","orangutan","oryx","otter","ox","panda","panther","parakeet","parrot","peccary","pig","quokka","octopus","starfish","crab","snowyowl","chicken","rooster","bumblebee","polarbear","pony","porcupine","porpoise","prairiedog","pronghorn","puma","puppy","quagga","rabbit","raccoon","ram","rat","reindeer","rhinoceros","salamander","seal","sheep","shrew","silverfox","skunk","sloth","snake","springbok","squirrel","stallion","steer","tapir","tiger","toad","turtle","vicuna","walrus","warthog","waterbuck","weasel","whale","wildcat","baldeagle","wolf","wolverine","wombat","woodchuck","yak","zebra","zebu"]
        let size = animals.count
        let rng = Int.random(in: 0 ..< size)
        let animal = animals[rng]
        let url = URL(string: "https://loremflickr.com/414/246/animal,\(animal)/all")!
        image = downloadImage(url: url)
        
        return image
    }
    
    //Function that downloads an image from the Internet
    func downloadImage(url: URL) -> UIImage{
        var image:UIImage
        do{
            //The size of the UI Image View is 414x246
            print(url)
            let imageData = try Data(contentsOf: url)
            image = UIImage(data: imageData)!
        } catch {
            print("[Error] Failed to load image")
            image = UIImage(named: "DU Logo")!
        }
        return image
    }
    
    //Function that converts text to speech using Swift's built in AVFoundation Kit
    @IBAction func textToSpeech(_ sender: Any) {
        let utterance = AVSpeechUtterance(string: Pronounciation.text!)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        utterance.rate = 0.1
        
        let synthesizer = AVSpeechSynthesizer()
        synthesizer.speak(utterance)
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
