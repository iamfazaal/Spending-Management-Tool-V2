//
//  AddExpenseViewController.swift
//  SpendingManagementTool
//
//  Created by Fazal on 12/05/2021.
//
import EventKit
import EventKitUI
import UIKit

class AddExpenseViewController: UIViewController, EKEventEditViewDelegate {
    
    @IBOutlet weak var textFieldAmount: UITextField!
    @IBOutlet weak var textFieldNotes: UITextField!
    @IBOutlet weak var OccurenceControl: UISegmentedControl!
    @IBOutlet weak var DatePicker: UIDatePicker!
    @IBOutlet weak var switchToggleCalendar: UISwitch!
    @IBOutlet weak var labelCategoryName: UILabel!
  
    
    var category: Category?
    var expense: Expense?
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    
    func eventEditViewController(_ controller: EKEventEditViewController, didCompleteWith action: EKEventEditViewAction) {
        controller.dismiss(animated: true, completion: nil)
        closePopUp()

    }
    
    let eventStore = EKEventStore()
    var time = Date()
    
    func showAlert1(){
        let namealert = UIAlertController (title: "Wrong Input!", message: "Please enter an amount and notes to add an expense!", preferredStyle: .alert)
        namealert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        self.present(namealert,animated: true)
        
    }
    
    func showAlert2(){
        let noCategoryAlert = UIAlertController (title: "Warning", message: "Please create a Category before adding an expense.", preferredStyle: .alert)
        noCategoryAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        self.present(noCategoryAlert, animated: true)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func closePopUp(){
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func saveExpense(_ sender: UIButton) {
        
        if (self.category == nil){
            showAlert2()
        }
       
        else if (self.textFieldAmount.text == "" || self.textFieldNotes.text == ""){
            showAlert1()
        }
        else {
            let newexpense = Expense(context: context)

            newexpense.category = category?.name
            newexpense.amount = Double(textFieldAmount.text!)!
            newexpense.notes = self.textFieldNotes.text
            newexpense.date = self.DatePicker.date
            newexpense.expenseCategory = category
            newexpense.occurrence = Int16(OccurenceControl.selectedSegmentIndex)
            
            if (switchToggleCalendar.isOn == true){
                eventStore.requestAccess(to: EKEntityType.event, completion: {(granted, error) in
                                            DispatchQueue.main.async {
                                                if (granted) && (error == nil){
                                                    let event = EKEvent(eventStore: self.eventStore)
                                                    event.title = newexpense.notes
                                                    event.startDate = newexpense.date
                                                    event.endDate = newexpense.date
                                                    event.url = URL(string: "Created by Spending Mangement Tool. -Fazal")
                                                    let eventController = EKEventEditViewController()
                                                    eventController.event = event
                                                    eventController.eventStore = self.eventStore
                                                    eventController.editViewDelegate = self
                                                    newexpense.reminderflag = true
                                                    self.present(eventController, animated: true, completion: nil)
                                                    
                                                }
                                                
                                            }})
                
            }
        
            (UIApplication.shared.delegate as! AppDelegate).saveContext()
            //update PIE CHART!
                
        }
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
