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
    var isEditView:Bool?
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
        if (isEditView!) {
            if let expense = expense {
                labelCategoryName.text = "Edit " + expense.notes! + " Expense"
//                category?.name = expense.category
                textFieldAmount.text = "\(expense.amount)"
                textFieldNotes.text = expense.notes
                DatePicker.date = expense.date!
                category = expense.expenseCategory
                OccurenceControl.selectedSegmentIndex =  Int(expense.occurrence)
                switchToggleCalendar.isOn = expense.reminderflag
                
            }
            
            textFieldAmount.becomeFirstResponder()
        }
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
            var newexpense:Expense
            if(self.isEditView ?? false){
                newexpense = self.expense!
            }else{
                newexpense = Expense(context: context)
            }
            
            
            newexpense.category = category?.name
            newexpense.amount = Double(textFieldAmount.text!)!
            newexpense.notes = textFieldNotes.text
            newexpense.date = DatePicker.date
            newexpense.expenseCategory = category
            newexpense.occurrence = Int16(OccurenceControl.selectedSegmentIndex)
            newexpense.reminderflag = switchToggleCalendar.isOn

            
            if (switchToggleCalendar.isOn == true){
                eventStore.requestAccess(to: EKEntityType.event, completion: {(granted, error) in
                                            DispatchQueue.main.async {
                                                if (granted) && (error == nil){
                                                    let event = EKEvent(eventStore: self.eventStore)
                                                    event.title = newexpense.notes
                                                    event.startDate = newexpense.date
                                                    event.endDate = newexpense.date
                                                    event.url = URL(string: "Created by Spending Mangement Tool. - Fazal")
                                                    event.calendar = self.eventStore.defaultCalendarForNewEvents
                                                    let selectedOccurenceValue = self.OccurenceControl.titleForSegment(at: self.OccurenceControl.selectedSegmentIndex)
                                                    var rule: EKRecurrenceFrequency? = nil
                                                    switch selectedOccurenceValue! {
                                                    case "One Off":
                                                        rule = nil
                                                    case "Daily":
                                                        rule = .daily
                                                    case "Weekly":
                                                        rule = .weekly
                                                    case "Monthly":
                                                        rule = .monthly
                                                    default:
                                                        rule = nil
                                                    }

                                                    if rule != nil {
                                                        let recurrenceRule = EKRecurrenceRule(recurrenceWith: rule!, interval: 1, end: nil)
                                                        event.addRecurrenceRule(recurrenceRule)
                                                    }

                                                    do {
                                                        try self.eventStore.save(event, span: .thisEvent)
                                                    } catch let error as NSError {
                                                        fatalError("Failed to save event with error : \(error)")
                                                    }
                                                    
                                                }else{
                                                    fatalError("Failed to save event with error : \(String(describing: error)) or access not granted")
                                                }
                                                
                                            }})
                
            }
            
            (UIApplication.shared.delegate as! AppDelegate).saveContext()
            closePopUp()
            
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
