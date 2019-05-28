//
//  CellTableViewController.swift
//  ReligiousApp
//
//  Created by Trenton Parrotte on 5/13/19.
//  Copyright © 2019 Trenton Parrotte. All rights reserved.
//

import Foundation
import UIKit

class CellTableViewController: UITableViewController {
  
    private var eventArr = [Event]()
    private var cellArray = [[Event](), [Event](), [Event]()]
    private var observer: NSObjectProtocol!
    public var searchEvents = [Event]()
    private var isSearching = false

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Add observer for notification
        observer = NotificationCenter.default.addObserver(forName: .isWeekChanged, object: nil, queue: .main){
            [weak self] notification in
            self!.cellArray[0] = self!.createEventList()
            self!.tableView.reloadData()
        }
        
        //Load Cells
        cellArray[0] = createEventList()
    }
    
    //MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 3
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return cellArray[section].count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "default", for: indexPath) as! customCell
        
        if(indexPath.section == 0) {
            cell = tableView.dequeueReusableCell(withIdentifier: "default", for: indexPath) as! customCell
            
            
            let layer = cell.backView.layer
            layer.masksToBounds = false
            layer.cornerRadius = 15
            layer.shadowOffset = CGSize.init(width: -0.2, height: 0.2)
            layer.shadowRadius = 5
            layer.shadowOpacity = 0.5
            
            
            //let it = eventArr[indexPath.row]
            let it = cellArray[0][indexPath.row]
            
            cell.holidayLabel.text = it.tradition
            cell.titleLabel.text = it.name
            
            let dateFormatter = DateFormatter()
            let date = it.startDate
            
            // US English Locale (en_US)
            dateFormatter.locale = Locale(identifier: "en_US")
            
            dateFormatter.setLocalizedDateFormatFromTemplate("MMMMd")// set template after setting locale
            cell.timeLabel.text = dateFormatter.string(from: date) // December 31
            
            //Get Religion Image
            let tradition = it.tradition
            switch tradition{
            case "Sikh":
                cell.religionImage.image = UIImage.init(named: "Khanda1x")
            case "Jewish":
                cell.religionImage.image = UIImage.init(named: "judaism")
            case "Islam":
                cell.religionImage.image = UIImage.init(named: "islam")
            case "Hindu":
                cell.religionImage.image = UIImage.init(named: "hinduism")
            case "Christian":
                cell.religionImage.image = UIImage.init(named: "christianity")
            case "Buddhist":
                cell.religionImage.image = UIImage.init(named: "buddhism")
            default:
                cell.religionImage.image = UIImage.init(named: "XSymbol")
            }
        }
        
        return cell
    }
    
    func createEventList() -> [Event]{
        //Get Cell Data
        let del = UIApplication.shared.delegate as! AppDelegate
        eventArr = del.EventArr
        var loadArray: [Event] = []
        let today = Calendar.current.startOfDay(for: Date.init())
        var lastDate = today
        
        if(!isSearching){
            if(isWeek){
                lastDate = Date.init(timeInterval: (7*24*60*60), since: lastDate)
            } else {
                lastDate = Date.init(timeInterval: (24*60*60), since: lastDate)
            }
            
            for event in eventArr{
                if(event.startDate <= lastDate){
                    if(event.startDate >= today){
                        loadArray.append(event)
                    }
                } else {
                    break
                }
            }
        } else {
            //lastDate = eventArr[eventArr.count].endDate
            //Load the items in as events
            loadArray = searchEvents
        }
        
 
        return loadArray
        //return eventArr
    }
    
    /*
     // Override to support conditional editing of the table view.
     override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }
     */
    
    /*
     // Override to support editing the table view.
     override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
     if editingStyle == .delete {
     // Delete the row from the data source
     tableView.deleteRows(at: [indexPath], with: .fade)
     } else if editingStyle == .insert {
     // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
     }
     }
     */
    
    /*
     // Override to support rearranging the table view.
     override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
     
     }
     */
    
    /*
     // Override to support conditional rearranging of the table view.
     override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
     */
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if(segue.identifier == "EventSegue") {
            
            let controller = segue.destination as? EventViewcontroller
            if let indexPath = self.tableView.indexPathForSelectedRow{
                let event = cellArray[0][indexPath.row]
                controller?.theEvent = event
            }
        }
    }
    deinit {
        NotificationCenter.default.removeObserver(observer)
    }
    
}

extension CellTableViewController: UISearchBarDelegate{
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        //Add the events to a list that I can search through
        let del = UIApplication.shared.delegate as! AppDelegate
        
        //Special cases for searching
        if(searchText.lowercased() == "all"){
            //Display all the events for the year in the calendar
            searchEvents = del.EventArr
        } else if(searchText.lowercased() == "sikh" || searchText.lowercased() == "jewish" || searchText.lowercased() == "islam" || searchText.lowercased() == "hindu" || searchText.lowercased() == "christian" || searchText.lowercased() == "buddhist"){
            //Display all events matching the appropriate religion
            searchEvents = del.EventArr.filter({$0.tradition.lowercased() == searchText.lowercased()})
        } else {
            //Dynamically search the list based on what letters are typed.
            //I.E. "A" will result in all events beginning with the letter 'A' or 'a'
            searchEvents = del.EventArr.filter({$0.name.lowercased().prefix(searchText.count) == searchText.lowercased()})
        }
        isSearching = true
        cellArray[0] = createEventList()
        tableView.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        isSearching = false
        searchBar.text = ""
        cellArray[0] = createEventList()
        tableView.reloadData()
    }
    
}

class customCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var holidayLabel: UILabel!
    @IBOutlet weak var religionImage: UIImageView!
    
    @IBOutlet weak var backView: UIView!
}
