//
//  CategoryDetailViewController.swift
//  SpendingManagementTool
//
//  Created by Fazal on 11/05/2021.
//

import UIKit
import CoreData

class CategoryDetailViewController: UIViewController, NSFetchedResultsControllerDelegate{

    @IBOutlet weak var labelCategoryName: UILabel!
    @IBOutlet weak var labelCategoryMonthlyBudget: UILabel!
    @IBOutlet weak var labelCategorySpent: UILabel!
    @IBOutlet weak var labelCategoryRemaining: UILabel!
    
    var categoryName = ""
    var categoryMonthlyBudget = ""
    var categorySelected = ""
    var category:Category?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createPieChart()
    }
    
//    func viewWillAppear() {
//        createPieChart()
//
//    }
    
    
    func createPieChart(){
       
        var expenses = [Expense]()
        
        let managedObjectContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        var _fetchedResultsController: NSFetchedResultsController<Expense>? = nil
        
        var fetchedResultsController: NSFetchedResultsController<Expense> {
            if _fetchedResultsController != nil {
                return _fetchedResultsController!
            }
            
            //build the fetch request
            let fetchRequest: NSFetchRequest<Expense> = Expense.fetchRequest()
            
            let sortDescriptor = NSSortDescriptor(key: "amount", ascending: false, selector: #selector(NSNumber.compare(_:)))
            //add the sort to the request
            fetchRequest.sortDescriptors = [sortDescriptor]
            
            let predicate = NSPredicate(format: "category = %@", categoryName)
            fetchRequest.predicate = predicate

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
        
        func getRandomColor() -> UIColor {
            
            
            
             //Generate between 0 to 1
             let red:CGFloat = CGFloat(drand48())
             let green:CGFloat = CGFloat(drand48())
             let blue:CGFloat = CGFloat(drand48())

             return UIColor(red:red, green: green, blue: blue, alpha: 0.6)
        }
        
        let pieChartView = PieChartView()
        
        var sumOfExpenses = 0.0
        
        expenses = fetchedResultsController.fetchedObjects!
                
        for (index, expense) in expenses.enumerated() {
            sumOfExpenses = sumOfExpenses+expense.amount
        }
     
        let padding: CGFloat = 10
        let height = (view.frame.height - padding * 2) / 3

        
        labelCategoryName.text = categoryName
        labelCategoryMonthlyBudget.text = categoryMonthlyBudget
        labelCategorySpent.text = String(sumOfExpenses)
        
        let budget = Double(categoryMonthlyBudget) ?? 0.0
        let remaining = budget - sumOfExpenses
        
        if (sumOfExpenses > Double(categoryMonthlyBudget) ?? 0.0){
            
            labelCategoryRemaining.text = String(remaining)
            labelCategoryRemaining.textColor = UIColor(red: 255/255, green: 121/255, blue: 121.0/255, alpha: 1.0)
        
        }
        else if (sumOfExpenses < Double(categoryMonthlyBudget) ?? 0.0){

            labelCategoryRemaining.text = String(remaining)
            labelCategoryRemaining.textColor = UIColor(red: 186/255, green: 220/255, blue: 88/255, alpha: 1.0)
        }
        
        
        pieChartView.frame = CGRect(
             x: 3, y: 3,
             width: view.frame.size.width, height: height
           )

        var remainingExpenses = 0.0
        
        for (index, expense) in expenses.enumerated() {
            
            if (index <= 3){
            pieChartView.segments.append(LabelledSegment(color: getRandomColor(), name:expense.notes!  ,value: CGFloat(expense.amount)))

            }
            else {
               remainingExpenses += expense.amount
            }
        
        }
        if (remainingExpenses != 0.0) {
        pieChartView.segments.append(LabelledSegment(color: UIColor(red: 0.9, green: 1.0, blue: 1.0, alpha: 1.0), name: "others", value: CGFloat(remainingExpenses)))
        }
        
           view.addSubview(pieChartView)
    }
    
    
    // 1. Fetch total budget from category
    // 2. Fetch all expenses
    // 3. Add expenses
    // 4. remaining: create segment
    // 4a. spent: create segments per expense
    // 4b. segment per expense
    

    

}
