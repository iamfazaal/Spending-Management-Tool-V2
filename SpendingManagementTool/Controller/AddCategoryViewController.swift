//
//  AddCategoryViewController.swift
//  SpendingManagementTool
//
//  Created by Fazal on 11/05/2021.
//

import UIKit

class AddCategoryViewController: UIViewController {
    
    
    @IBOutlet weak var labelCategory: UILabel!
    @IBOutlet weak var textFieldCategoryName: UITextField!
    @IBOutlet weak var textFieldCategoryBudget: UITextField!
    @IBOutlet weak var textFieldCategoryNotes: UITextField!
    @IBOutlet weak var ColorPicker: UISegmentedControl!
    
    
    var categoryPlaceholder: Category?
    var isEditView:Bool?
    
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    
    
    func alert() {
        let namealert = UIAlertController (title: "Wrong Input!", message: "Please enter a category name, budget and color to add a category!", preferredStyle: .alert
        )
        namealert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        self.present(namealert,animated: true)
        
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.ColorPicker.selectedSegmentIndex = 0
        if (isEditView!) {
            if let category = categoryPlaceholder {
                labelCategory.text = "Edit " + category.name! + " Category"
                textFieldCategoryName.text = category.name
                textFieldCategoryBudget.text = "\(category.monthlybudget)"
                textFieldCategoryNotes.text = category.notes
                ColorPicker.selectedSegmentIndex =  Int(category.colour)
            }
            
            textFieldCategoryName.becomeFirstResponder()
        }
        
        // Do any additional setup after loading the view.
    }
    
    func closePopUp(){
        self.dismiss(animated: true, completion: nil)
    }
    
    func updateData(){
    }
    
    @IBAction func saveCategory(_ sender: UIButton) {
        
        if (self.textFieldCategoryName.text == "" || self.textFieldCategoryBudget.text == ""){
            alert()
        }else {
            var newCategory:Category
            if(self.isEditView ?? false){
                newCategory = self.categoryPlaceholder!
            }else{
                newCategory = Category(context: context)
            }
            
            newCategory.name = self.textFieldCategoryName.text
            newCategory.monthlybudget = Double(self.textFieldCategoryBudget.text!)!
            newCategory.colour = Int16(ColorPicker.selectedSegmentIndex)
            newCategory.notes = self.textFieldCategoryNotes.text
            (UIApplication.shared.delegate as! AppDelegate).saveContext()
            closePopUp()
            
        }
        
    }
    
    // MARK: - Navigation
    //
    //    // In a storyboard-based application, you will often want to do a little preparation before navigation
    //    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    //        // Get the new view controller using segue.destination.
    //        // Pass the selected object to the new view controller.
    //    }
    //
    
}
