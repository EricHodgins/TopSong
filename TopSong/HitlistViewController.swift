//
//  HitlistViewController.swift
//  TopSong
//
//  Created by Eric Hodgins on 2016-07-30.
//  Copyright © 2016 Eric Hodgins. All rights reserved.
//

import UIKit
import CoreData
import Firebase

class HitlistViewController: UIViewController, NSFetchedResultsControllerDelegate, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    var user: FIRUser?
    var loggedInUser: User?
    let youtubeImageCache = YoutubeImageCache()
    
    //MARK: Context
    lazy var sharedContext: NSManagedObjectContext = {
        return CoreDataStackManager.sharedInstance.managedObjectContext
    }()
    
    lazy var fetchedResultsController: NSFetchedResultsController = {
        let fetchRequest = NSFetchRequest(entityName: "HitListSong")
        let sortDescriptors = NSSortDescriptor(key: "artist", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptors]
        fetchRequest.predicate = NSPredicate(format: "user = %@", self.loggedInUser!)
        
        return NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.sharedContext, sectionNameKeyPath: nil, cacheName: nil)
        
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Hitlist"
        self.navigationController?.navigationBar.titleTextAttributes = [NSFontAttributeName : UIFont.chalkboardFont(withSize: 20.0), NSForegroundColorAttributeName: UIColor.whiteColor()]
        
        findUser()
        tableView.dataSource = self
        tableView.delegate = self
        fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController.performFetch()
        } catch {}
    }
    
    func findUser() {
        let fetchRequest = NSFetchRequest(entityName:"User")
        let predicate = NSPredicate(format: "userId = %@", user!.uid)
        fetchRequest.predicate = predicate
        do {
            let fetchResults = try sharedContext.executeFetchRequest(fetchRequest)
            if fetchResults.count != 0 {
                loggedInUser = fetchResults[0] as? User
            }
        } catch let error as NSError {
            print("Error occurred querying for logged in user: \(error.localizedDescription)")
        }
    }
}

//MARK: Table Data Source
extension HitlistViewController {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultsController.sections![section].numberOfObjects
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("hitlistCell", forIndexPath: indexPath) as! HitlistTableViewCell
        let hitlistSong = fetchedResultsController.objectAtIndexPath(indexPath) as! HitListSong
        
        cell.artistLabel.attributedText = UIDesign.lightStyleAttributedString(hitlistSong.artist, fontSize: 15.0)
        cell.songTitleLabel.attributedText = UIDesign.darkStyleAttributedString(hitlistSong.title, fontSize: 20.0)
        
        return cell
    }
}

//MARK: Table Delegate
extension HitlistViewController {
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            
            let song = fetchedResultsController.objectAtIndexPath(indexPath) as! HitListSong
            self.sharedContext.performBlock({ 
                self.sharedContext.deleteObject(song)
                CoreDataStackManager.sharedInstance.saveContext()
            })
        }
    }
    
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        tableView.beginUpdates()
    }
    
    func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        switch type {
        case .Insert:
            tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
            
        case .Delete:
            tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
            
        case .Update:
            tableView.reloadRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
        
        case .Move:
            tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
            tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
        }
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        tableView.endUpdates()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "youtubeSegue" {
            let hitlistCell = sender as! HitlistTableViewCell
            let indexPath = tableView.indexPathForCell(hitlistCell)
            let song = fetchedResultsController.objectAtIndexPath(indexPath!) as! HitListSong
            let youtubeController = segue.destinationViewController as! YoutubeViewController
            youtubeController.hitlistSong = song
            youtubeController.youtubeImageCache = youtubeImageCache
        }
    }
}











