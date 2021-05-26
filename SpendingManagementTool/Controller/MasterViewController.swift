//
//  MasterViewController.swift
//  SpendingManagementTool
//
//  Created by Fazal on 10/05/2021.
//

import UIKit
import CoreData

class MasterViewController: UITableViewController, NSFetchedResultsControllerDelegate {
    
    var detailViewController: DetailViewController? = nil
    var managedObjectContext: NSManagedObjectContext? = nil
    var category: Category?
    var addCategoryViewController: AddCategoryViewController? = nil
    
    var isEditView:Bool? = false
    
    
    let cellSelColour:UIColor = UIColor (red: 0.0, green: 0.0, blue: 1.0, alpha: 0.2)
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        if let split = splitViewController {
            let controllers = split.viewControllers
            detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
            
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
        super.viewWillAppear(animated)
    }
    
    @objc
    func insertNewObject(_ sender: Any) {
        let context = self.fetchedResultsController.managedObjectContext
        // Save the context.
        do {
            try context.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
    }
    
    // MARK: - Segues
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let object = fetchedResultsController.object(at: indexPath)
                let controller = (segue.destination as! UINavigationController).topViewController as! DetailViewController
                controller.category = object
                controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
                controller.navigationItem.leftItemsSupplementBackButton = true
                detailViewController = controller
            }
        }
        
        if segue.identifier == "popToAddCategory" {
            let controller = segue.destination as! AddCategoryViewController
            controller.categoryPlaceholder = category
            controller.isEditView = self.isEditView
            addCategoryViewController = controller
        }
        
    }
    
    // MARK: - Table View
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController.sections?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = fetchedResultsController.sections![section]
        return sectionInfo.numberOfObjects
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "categoryCell", for: indexPath) as! CategoryTableViewCell
        configureCell(cell, indexPath: indexPath)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let edit = editAction(at: indexPath)
        let delete = deleteAction(at: indexPath)
        return UISwipeActionsConfiguration(actions: [edit,delete])
    }
    
    func editAction (at indexPath: IndexPath) -> UIContextualAction {
        let action = UIContextualAction(style: .normal, title: "Edit") { (action, view, completion) in
            self.isEditView = true
            self.category = self.fetchedResultsController.object(at: indexPath)
            self.performSegue(withIdentifier: "popToAddCategory", sender: self)
            self.isEditView = false
            completion(true)
        }
        action.image = UIImage(named: "edit")
        action.image = action.image?.withTintColor(.white)
        action.backgroundColor = .systemBlue
        return action
    }
    
    func deleteAction (at indexPath: IndexPath) -> UIContextualAction {
        let action = UIContextualAction(style: .normal, title: "Delete") { (action, view, completion) in
            let context = self.fetchedResultsController.managedObjectContext
            context.delete(self.fetchedResultsController.object(at: indexPath))
            
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
            completion(true)
        }
        action.image = UIImage(named: "delete")
        action.image = action.image?.withTintColor(.white)
        action.backgroundColor = .systemRed
        return action
    }
    
    
    func configureCell(_ cell: CategoryTableViewCell, indexPath: IndexPath) {
        
        let name = self.fetchedResultsController.fetchedObjects?[indexPath.row].name
        let notes = self.fetchedResultsController.fetchedObjects?[indexPath.row].notes
        let budget = self.fetchedResultsController.fetchedObjects?[indexPath.row].monthlybudget
        let colour = self.fetchedResultsController.fetchedObjects?[indexPath.row].colour
        
        
        if (colour == 0){
            //RED
            cell.backgroundColor = UIColor(red: 255/255, green: 121/255, blue: 121.0/255, alpha: 0.8)
        }
        else if (colour == 1){
            //BLUE
            cell.backgroundColor = UIColor(red: 34/255, green: 166/255, blue: 179/255, alpha: 0.9)
        }
        else if (colour == 2){
            //GREEN
            cell.backgroundColor = UIColor(red: 186/255, green: 220/255, blue: 88/255, alpha: 1.0)
        }
        else if (colour == 3){
            //PURPLE
            cell.backgroundColor = UIColor(red: 224/255, green: 86/255, blue: 253/255, alpha: 0.7)
        }
        else if (colour == 4){
            //YELLOW
            cell.backgroundColor = UIColor(red: 246/255, green: 229/255, blue: 141/255, alpha: 1.0)
        }
        else if (colour == 5){
            //ORANGE
            cell.backgroundColor = UIColor(red: 255/255, green: 190/255, blue: 118/255, alpha: 1.0)
        }
        
        cell.labelCategoryName.text = name
        cell.labelCategoryNotes.text = notes
        cell.labelCategoryBudget.text = String(budget!)
    }
    @IBAction func sortByBudget(_ sender: Any) {
        
        do {
            let fetchRequest: NSFetchRequest<Category> = Category.fetchRequest()
            
            fetchRequest.fetchBatchSize = 20
            
            let sortDescriptor = NSSortDescriptor(key: "monthlybudget", ascending: false, selector: #selector(NSNumber.compare(_:)))
            
            fetchRequest.sortDescriptors = [sortDescriptor]
            
            let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext!, sectionNameKeyPath: nil, cacheName: nil)
            aFetchedResultsController.delegate = self
            _fetchedResultsController = aFetchedResultsController
            
            try _fetchedResultsController!.performFetch()
            self.tableView.reloadData()
        }
        
        catch{
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
    }
    
    
    
    @IBAction func sortAlphabetically(_ sender: Any) {
        
        do {
            let fetchRequest: NSFetchRequest<Category> = Category.fetchRequest()
            
            fetchRequest.fetchBatchSize = 20
            
            let sortDescriptor = NSSortDescriptor(key: "name", ascending: true, selector: #selector(NSString.localizedStandardCompare(_:)))
            
            
            fetchRequest.sortDescriptors = [sortDescriptor]
            
            let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext!, sectionNameKeyPath: nil, cacheName: nil)
            aFetchedResultsController.delegate = self
            _fetchedResultsController = aFetchedResultsController
            
            try _fetchedResultsController!.performFetch()
            self.tableView.reloadData()
        }
        
        catch{
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
        
        
    }
    // MARK: - Fetched results controller
    
    var fetchedResultsController: NSFetchedResultsController<Category> {
        if _fetchedResultsController != nil {
            return _fetchedResultsController!
        }
        
        let fetchRequest: NSFetchRequest<Category> =
            Category.fetchRequest()
        
        // Set the batch size to a suitable number.
        fetchRequest.fetchBatchSize = 20
        
        // if button is pressed -> ascending true, else ascending false
        // Edit the sort key as appropriate.
        let sortDescriptor = NSSortDescriptor(key: "selected", ascending: false, selector: #selector(NSNumber.compare(_:)))
        
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        // nil for section name key path means "no sections".
        let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext!, sectionNameKeyPath: nil, cacheName: nil)
        aFetchedResultsController.delegate = self
        _fetchedResultsController = aFetchedResultsController
        
        
        do {
            try _fetchedResultsController!.performFetch()
            print("fetchedddddddd")
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
        
        return _fetchedResultsController!
    }
    
    var _fetchedResultsController: NSFetchedResultsController<Category>? = nil
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            tableView.insertSections(IndexSet(integer: sectionIndex), with: .fade)
        case .delete:
            tableView.deleteSections(IndexSet(integer: sectionIndex), with: .fade)
        default:
            return
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            tableView.insertRows(at: [newIndexPath!], with: .fade)
        case .delete:
            tableView.deleteRows(at: [indexPath!], with: .fade)
        case .update:
            self.configureCell(tableView.cellForRow(at: indexPath!)! as! CategoryTableViewCell, indexPath: newIndexPath!)
        case .move:
            tableView.moveRow(at: indexPath!, to: newIndexPath!)
        default:
            return
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    
    /*
     // Implementing the above methods to update the table view in response to individual changes may have performance implications if a large number of changes are made simultaneously. If this proves to be an issue, you can instead just implement controllerDidChangeContent: which notifies the delegate that all section and object changes have been processed.
     
     func controllerDidChangeContent(controller: NSFetchedResultsController) {
     // In the simplest, most efficient, case, reload the table view.
     tableView.reloadData()
     }
     */
    
}

