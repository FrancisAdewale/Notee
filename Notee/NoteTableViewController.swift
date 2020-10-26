//
//  NoteTableViewController.swift
//  Notee
//
//  Created by Francis Adewale on 23/10/2020.
//

import UIKit
import CoreData
import NRSpeechToText

class NoteTableViewController: SwipeCellViewController {
    
    @IBOutlet weak var stopRecording: UIBarButtonItem!
    
    //MARK: - Properties
    
    var itemArray = [Item]()
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var selectedCategory: Category? {
        didSet{
            loadItems()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        navigationItem.title = selectedCategory?.name
        
        stopRecording.style = .plain
    }
    
    
    // MARK: - Table view data source
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return itemArray.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        let item = itemArray[indexPath.row]
        cell.textLabel?.text = item.text
        cell.accessoryType = .detailButton
        
        
        
        return cell
    }
    
    //MARK: - Table View Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
    
    override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        
        let alert = UIAlertController(title: "Date Posted", message: "\(itemArray[indexPath.row].date!)", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Dismiss", style: .cancel) { (alertAction) in
            self.dismiss(animated: true, completion: nil)
        }
        
        alert.addAction(action)
        
        present(alert, animated: true, completion: nil)
        
    }
    
    
    //MARK: - IB Actions
    @IBAction func addNotePressed(_ sender: UIBarButtonItem) {
        
        
        var textfield = UITextField()
        
        let actionSheet = UIAlertController(title: "Select Option", message: "", preferredStyle: .actionSheet)
        
        let cancelButton = UIAlertAction(title: "Cancel", style: .cancel) { (cancelAction) in
            
        }
        
        let noteAction = UIAlertAction(title: "Write Note", style: .default) { (alertAction) in
            
            let alert = UIAlertController(title: "Write a note", message: "", preferredStyle: .alert)
            
            let action = UIAlertAction(title: "Add", style: .default) { (alertAction) in
                let newItem = Item(context: self.context)
                newItem.text = textfield.text!
                newItem.parentCategory = self.selectedCategory
                newItem.date = Date()
                
                self.itemArray.append(newItem)
                self.saveItem()
            }
            
            alert.addTextField { (alertTextField) in
                alertTextField.placeholder = "Create Category"
                textfield = alertTextField
            }

            alert.addAction(action)
            self.present(alert, animated: true, completion: nil)
        }
        
        let recordAction = UIAlertAction(title: "Record Note", style: .default) { (recordActionButton) in
            
            self.stopRecording.style = .done
            
            NRSpeechToText.shared.authorizePermission { (authorize) in
                if authorize {
                    if NRSpeechToText.shared.isRunning {
                        NRSpeechToText.shared.stop()
                    }
                    else {
                        self.startRecording()
                        DispatchQueue.main.async {
                            self.navigationItem.title = "Start Recording"

                        }
                    }
                }
            }
        }
        
        actionSheet.addAction(noteAction)
        actionSheet.addAction(cancelButton)
        actionSheet.addAction(recordAction)
        
        present(actionSheet, animated: true, completion: nil)
        
    }
    
    
    @IBAction func stopRecordingPressed(_ sender: UIBarButtonItem) {
        if NRSpeechToText.shared.isRunning {
            NRSpeechToText.shared.stop()
        }
        loadItems()
        
        navigationItem.title = selectedCategory?.name
        
    }
    
    func startRecording() {
        var textArray = [String]()
        let newItem = Item(context: self.context)

        NRSpeechToText.shared.startRecording {(result: String?, isFinal: Bool, error: Error?) in
            
            if error == nil {
                
                if let text = result {
                    textArray.append(text)
                    newItem.text = textArray[textArray.count - 1]
                    print(newItem.text!)
                    newItem.parentCategory = self.selectedCategory
                    newItem.date = Date()
                }
            }
            //self.itemArray.append(newItem)

            self.saveItem()
            self.tableView.reloadData()

        }
        

    
    }
    //MARK: - Data Manipulation
    
    override func updateModel(at indexPath: IndexPath) {
        
        context.delete(itemArray[indexPath.row])
        itemArray.remove(at: indexPath.row)
        self.saveItem()

    }
    
    
    func saveItem() {
        do {
            try context.save()
        } catch {
            print("Could not save \(error)")
        }
        DispatchQueue.main.async {
            self.tableView.reloadData()

        }
    }
    
    func loadItems() {
        let predicate = NSPredicate(format:"parentCategory.name MATCHES %@", selectedCategory!.name!)
        let fetchRequest: NSFetchRequest<Item> = Item.fetchRequest()
        fetchRequest.predicate = predicate
        
        do {
            itemArray = try context.fetch(fetchRequest)
        } catch {
            print("Can't fetch results \(error)")
        }
    }
    
    
    

}
