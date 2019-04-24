//
//  ViewController.swift
//  ReligiousApp
//
//  Created by Trenton Parrotte on 4/23/19.
//  Copyright © 2019 Trenton Parrotte. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var addButton: UIButton!
    
    @IBOutlet weak var containerView: UIView!
    
    private var calBoxes: ViewDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func addToCal(_ sender: Any) {
        let relgious = (calBoxes?.checkedBoxed[0])!
        let canvas = (calBoxes?.checkedBoxed[1])!
        let duEvents = (calBoxes?.checkedBoxed[2])!
        
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

