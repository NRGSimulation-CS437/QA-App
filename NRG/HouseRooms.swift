//
//  HouseRooms.swift
//  NRG
//
//  Created by Kevin Argumedo on 1/29/16.
//  Copyright © 2016 Kevin Argumedo. All rights reserved.
//

import Foundation
import UIKit
import Alamofire

class HouseRooms : UITableViewController
{
    var rooms = [JSON]()
    var user : JSON!
    var house = [JSON]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(animated: Bool) {
        
        self.rooms.removeAll()

        let parameters  = ["owner" : String(self.user["username"]), "house": String(self.house[0]["name"])]
        
        Alamofire.request(.GET, "http://ignacio.kevinhuynh.net:1337/rooms/", parameters: parameters)
            .responseJSON { response in
                
                if let JSON1 = response.result.value
                {
                    for(_,jso) in JSON(JSON1)
                    {
                        self.rooms.append(jso)
                        
                    }
                    if(self.rooms.isEmpty)
                    {
                        self.rooms.removeAll()
                        
                        let randomObject : JSON =  ["name": "You have not added any rooms!", "extra": "gibberish no one will read"]
                        
                        self.rooms.append(randomObject)
                    }
                }
                dispatch_async(dispatch_get_main_queue()) {
                    self.tableView.reloadData()
                }
        }
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.rooms.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as UITableViewCell
    
        let myURL = "http://ignacio.kevinhuynh.net:1337/devices/"
        
        var counter : Double = 0
        
        let parameters = ["trigger" : "on", "room":String(self.rooms[indexPath.row]["name"]), "owner": String(self.user["username"]), "house": String(self.house[0]["name"])]
        
        Alamofire.request(.GET, myURL, parameters: parameters)
            .responseJSON { response in
                
                if let JSON1 = response.result.value
                {
                    for(_,dev) in JSON(JSON1)
                    {
                        if let tempCount = Double(String(dev["watts"]))
                        {
                            counter += tempCount
                        }
                    }
                    
                    if(String(self.rooms[indexPath.row]) == "You have not added any rooms!")
                    {
                        cell.textLabel?.text = String(self.rooms[indexPath.row]["name"])
                    }
                    else
                    {
                        cell.textLabel?.text = "Watts:  " + String(counter) + " " + String(self.rooms[indexPath.row]["name"])
                    }
                    

                }
        }
        
        return cell
    }
    
    func displayMessage(message: String)
    {
        let myAlert = UIAlertController(title:"Alert", message:message, preferredStyle: UIAlertControllerStyle.Alert)
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil)
        myAlert.addAction(okAction);
        self.presentViewController(myAlert, animated:true, completion: nil);
    }
    
    @IBAction func addRoom(sender: AnyObject)
    {
        
        var inputTextField: UITextField?
        
        let actionSheetController: UIAlertController = UIAlertController(title: "Add a Room", message: "", preferredStyle: .Alert)
        
        let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .Cancel) { action -> Void in
            //Do some cancelation stuff
        }
        actionSheetController.addAction(cancelAction)
        
        
        let nextAction: UIAlertAction = UIAlertAction(title: "Add", style: .Default)
        { action -> Void in
            
            let rName = inputTextField!.text
            
            if(rName!.isEmpty)
            {
                self.displayMessage("All Fields Required")
                return
            }
            
            for room in self.rooms
            {
                if(String(rName!) == String(room["name"]))
                {
                    self.displayMessage("You already have a house with that name")
                    return
                }
            }
            
            let myURL = "http://172.249.231.197:1337/rooms/create?"
            
            let owner = String(self.user["username"])
            let cHouse = String(self.house[0]["name"])
            
            let parameters = ["name": String(rName!), "owner": owner, "house": cHouse]

            Alamofire.request(.POST, myURL, parameters: parameters)
                .response { request, response, data, error in
                    
                    if(response!.statusCode != 400)
                    {
                        self.displayMessage("A new Room has been added!")
                        
                        dispatch_async(dispatch_get_main_queue()) {
                            
                            if(self.rooms.count == 1)
                            {
                                if(self.rooms[0]["name"] == "You have not added any rooms!")
                                {
                                    self.rooms.removeAll()
                                }
                            }
                            
                            let newRoom : JSON =  ["name": String(rName!), "owner": owner, "house":cHouse]

                            self.rooms.append(newRoom)
                            
                            self.tableView.reloadData()
                        }
                    }
            }
        }
        
        actionSheetController.addAction(nextAction)
            
        actionSheetController.addTextFieldWithConfigurationHandler { textField -> Void in
            inputTextField = textField
        }
        
        self.presentViewController(actionSheetController, animated: true, completion: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "toDevices")
        {
            let indexPath : NSIndexPath = self.tableView.indexPathForSelectedRow!

            let dest = segue.destinationViewController as! DevicesCollection
            
            dest.user = self.user
            dest.house = self.house[0]
            dest.room = self.rooms[indexPath.row]
        }
    }
        
}
