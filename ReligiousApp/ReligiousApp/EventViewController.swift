//
//  EventViewController.swift
//  ReligiousApp
//
//  Created by Trenton Parrotte on 5/3/19.
//  Copyright © 2019 Trenton Parrotte. All rights reserved.
//

import Foundation
import UIKit

class EventViewcontroller:UIViewController {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var EventTitle: UIButton!
    
    override func viewDidLoad() {
        //Get default image if the event does not have an image
        if(imageView.image == nil) {
            imageView.image = getDefaultImage()
        }
        
    }
    
    func getDefaultImage() -> UIImage{
        //Create image Variable
        var image:UIImage
        
        do{
        //Get Randomized Animal Image
            let animals = ["meerkat","aardvark","addax","alligator","alpaca","anteater","antelope","aoudad","ape","argali","armadillo","baboon","badger","basilisk","bat","bear","beaver","bighorn","bison","boar","budgerigar","buffalo","bull","bunny","burro","camel","canary","capybara","cat","chameleon","chamois","cheetah","chimpanzee","chinchilla","chipmunk","civet","coati","colt","cougar","cow","coyote","crocodile","crow","deer","dingo","doe","dung beetle","dog","donkey","dormouse","dromedary","platypus","dugong","eland","elephant","elk","ermine","ewe","fawn","ferret","finch","fish","fox","frog","gazelle","gemsbok","giraffe","gnu","goat","gopher","gorilla","grizzly bear","ground hog","guanaco","guinea pig","hamster","hare","hartebeest","hedgehog","highland cow","hippopotamus","hog","horse","hyena","ibex","iguana","impala","jackal","jaguar","jerboa","kangaroo","kitten","koala","lemur","leopard","lion","lizard","llama","lovebird","lynx","mandrill","mare","marmoset","marten","mink","mole","mongoose","monkey","moose","mountain goat","mouse","mule","musk-ox","muskrat","mustang","mynah bird","newt","ocelot","okapi","opossum","orangutan","oryx","otter","ox","panda","panther","parakeet","parrot","peccary","pig","quokka","octopus","starfish","crab","snowyowl","chicken","rooster","bumble bee","polar bear","pony","porcupine","porpoise","prairiedog","pronghorn","puma","puppy","quagga","rabbit","raccoon","ram","rat","reindeer","rhinoceros","salamander","seal","sheep","shrew","silverfox","skunk","sloth","snake","springbok","squirrel","stallion","steer","tapir","tiger","toad","turtle","vicuna","walrus","warthog","waterbuck","weasel","whale","wildcat","baldeagle","wolf","wolverine","wombat","woodchuck","yak","zebra","zebu"]
            let size = animals.count
            let rng = Int.random(in: 0 ..< size)
            let animal = animals[rng]
            
            //The size of the UI Image View is 414x246
            let url = URL(string: "https://loremflickr.com/414/246/animal,\(animal)")!
            print(url)
            let imageData = try Data(contentsOf: url)
            image = UIImage(data: imageData)!
        } catch {
            print("[Error] Failed to load image")
            image = UIImage(named: "DU Logo.png")!
        }
        
        return image
    }
    
}
