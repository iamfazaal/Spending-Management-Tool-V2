//
//  DetailViewController.swift
//  SpendingManagementTool
//
//  Created by Fazal on 10/05/2021.
//

import UIKit
import CoreData

class DetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    let cellSelColour:UIColor = UIColor (red: 200/255, green: 214/255, blue:229/255, alpha: 0.8)

    
    let managedObjectContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (self.category != nil)
        {
            let sectionInfo = self.fetchedResultsController.sections![section] as NSFetchedResultsSectionInfo
            return sectionInfo.numberOfObjects
        }
        else {
            return 1
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if (self.category != nil)
        {
            return self.fetchedResultsController.sections?.count ?? 1
        }
        else{
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "expenseCell", for: indexPath) as! ExpenseTableViewCell
        
        

        configureCell(cell, indexPath:indexPath)
        return cell
    }
    
    func addcounter(){
        self.category?.setValue(self.category!.selected + 1, forKey: "selected")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        addcounter()
        print("Selected counter: ", self.category?.selected as Any)
        
        // Do any additional setup after loading the view.
    }

    var category: Category?
    var expense: Expense?
    
    // MARK: Fetched results controller
    
    var _fetchedResultsController: NSFetchedResultsController<Expense>? = nil
    
    var fetchedResultsController: NSFetchedResultsController<Expense> {
        if _fetchedResultsController != nil {
            return _fetchedResultsController!
        }
        
        //build the fetch request
        let fetchRequest: NSFetchRequest<Expense> = Expense.fetchRequest()
        //add a sort descriptor
        let sortDescriptor = NSSortDescriptor(key: "amount", ascending: false, selector: #selector(NSNumber.compare(_:)))
        //add the sort to the request
        fetchRequest.sortDescriptors = [sortDescriptor]
        //add the predicate
        let predicate = NSPredicate(format: "expenseCategory = %@", self.category!)
        fetchRequest.predicate = predicate
        //intantiae resultscontroller
        let aFetchedResultsController = NSFetchedResultsController<Expense>(
            fetchRequest: fetchRequest,
            managedObjectContext: managedObjectContext, sectionNameKeyPath: #keyPath(Expense.category),cacheName: nil)
        //set the delegate
        aFetchedResultsController.delegate = self
        
        _fetchedResultsController = aFetchedResultsController
        
        //preform the fetch
        do {
            try _fetchedResultsController!.performFetch()
        } catch{
          let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
    
        return _fetchedResultsController!
    }
    
    // MARK: Configure Cell
    
    func configureCell(_ cell: ExpenseTableViewCell, indexPath: IndexPath){
        if (self.category != nil)//user must select a category first
        {
            let notes = self.fetchedResultsController.fetchedObjects?[indexPath.row].notes
            let amount = self.fetchedResultsController.fetchedObjects?[indexPath.row].amount
            let date = self.fetchedResultsController.fetchedObjects?[indexPath.row].date
            let occurence = self.fetchedResultsController.fetchedObjects?[indexPath.row].occurrence
            let reminderflag = self.fetchedResultsController.fetchedObjects?[indexPath.row].reminderflag
            let budget = category?.monthlybudget
            
            let progress = amount! / budget!
            
            
            let formatter1 = DateFormatter()
            formatter1.dateStyle = .short

            cell.labelDueDate.text = (formatter1.string(from: date!))
            cell.labelName.text = notes
            cell.labelAmount.text = String(amount ?? 0)
            
            let calculation = Float(progress) 
            cell.progressView.progress = calculation
            
          
            if (occurence == 0){
                cell.labelOccurence.text = "One off"
            }
            else if (occurence == 1){
                cell.labelOccurence.text = "Daily"
            }
            else if (occurence == 2){
                cell.labelOccurence.text = "Weekly"
            }
            else if (occurence == 3){
                cell.labelOccurence.text = "Monthly"
            }
            
            if (reminderflag == true){
                cell.labelReminder.text = "Reminder Set"
            }
            else if (reminderflag == false) {
                cell.labelReminder.text = "No Reminder"
            }
            
            cell.backgroundColor = self.cellSelColour
            

            if let amount = self.fetchedResultsController.fetchedObjects?[indexPath.row].amount
            {
                cell.detailTextLabel?.text = String(amount)
            }
            else {
                cell.detailTextLabel!.text = ""
            }
        }
    }
    
    // MARK: Table Editing
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let context = fetchedResultsController.managedObjectContext
            context.delete(fetchedResultsController.object(at: indexPath))
                
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tableView.beginUpdates()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tableView.endUpdates()
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
                self.configureCell(tableView.cellForRow(at: indexPath!)! as! ExpenseTableViewCell, indexPath: newIndexPath!)
            case .move:
                tableView.moveRow(at: indexPath!, to: newIndexPath!)
            default:
                return
        }
    }
    
    // MARK: NAVIGATION
    
    override func prepare (for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            switch identifier
            {
            case "categoryDetail":
            let destVC = segue.destination as! CategoryDetailViewController
                if let name = self.category?.name{
                    
                    destVC.categoryName = name
                }
                if let monthlybudget = self.category?.monthlybudget{
                    
                    destVC.categoryMonthlyBudget = String(monthlybudget)
                
                    
                }
                
                            if let expense = self.expense{
                                let destVC = segue.destination as! AddExpenseViewController
                                destVC.expense = expense
                            }
                
            case "addExpense":
                if let category = self.category{
                    let destVC = segue.destination as! AddExpenseViewController
                    destVC.category = category
                }
    
                if let expense = self.expense{
                    let destVC = segue.destination as! AddExpenseViewController
                    destVC.expense = expense
                }
                
            default:
                break
            }
            
        }
    }
    



}


