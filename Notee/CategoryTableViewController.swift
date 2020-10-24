//
//  CategoryTableViewController.swift
//  Notee
//
//  Created by Francis Adewale on 22/10/2020.
//

import UIKit
import CoreData


class CategoryTableViewController: SwipeCellViewController {
    
    
    
    //MARK: - Properties
    //C IN CRUD
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
   var categoryArray = [Category]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = 80.0
        
        loadCategories()
    
        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
        
        
        }

    // MARK: - Table view data source


    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoryArray.count
        
        //decides number of rows displayed
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        let category = categoryArray[indexPath.row]
        cell.textLabel?.text = category.name
        cell.backgroundColor = .darkGray
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToNote", sender: self)
        
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! NoteTableViewController
        
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.selectedCategory = categoryArray[indexPath.row]
        }
    }
    
    
    func saveCategory(){
        
        do {
            try context.save()
        } catch {
            print("Could not save \(error)")
        }
        
        self.tableView.reloadData()
        
    }
    
    func loadCategories() {
        let fetchRequest: NSFetchRequest<Category> = Category.fetchRequest()

        do {
            categoryArray = try context.fetch(fetchRequest)
            
        } catch {
            print("Can't fetch results \(error)")
        }
        
    }
    
    override func updateModel(at indexPath: IndexPath) {
            self.context.delete(self.categoryArray[indexPath.row])
            self.categoryArray.remove(at: indexPath.row)
    }
    
    
    @IBAction func addCategory(_ sender: UIBarButtonItem) {
        
        var textfield = UITextField()
        
        let alert = UIAlertController(title: "Add A Category", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add", style: .default) { (alertAction) in
            
            let newCategory = Category(context: self.context)
            newCategory.name = textfield.text!
            self.categoryArray.append(newCategory)
            self.saveCategory()

        }
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create Category"
            textfield = alertTextField
        }
        
        
        alert.addAction(action)
        
        present(alert, animated: true, completion: nil)
    }
    
    
}
