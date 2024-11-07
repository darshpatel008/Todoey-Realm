

import UIKit
import RealmSwift
import ChameleonFramework



class TodoListViewController: swipeTableViewController{
    
    let realm = try! Realm()
    var todoItems: Results<Item>?
   
    
    var selectedCategory : Category? 
    {
        didSet
        {
            loadItems()
        }
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        tableView.rowHeight = 80
        tableView.separatorStyle = .none
     
    }
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    
    override func viewWillAppear(_ animated: Bool) {
        
        if let colourHex = selectedCategory?.color 
        {
            title = selectedCategory!.name
            guard let navBar = navigationController?.navigationBar else { fatalError("Navigation controller does not exist.")
            }
            if let navBarColour = UIColor(hexString: colourHex) 
            {
                navBar.backgroundColor = navBarColour
                navBar.tintColor = ContrastColorOf(navBarColour, returnFlat: true)
                searchBar.barTintColor = navBarColour
            }
        }
    }
    
    
    //MARK: - Tableview Datasource Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoItems?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
       let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
       if  let item = todoItems?[indexPath.row]
        {
           
           cell.textLabel?.text = item.title
           
           cell.accessoryType = item.done ? .checkmark : .none
           
           if  let color = UIColor(hexString: selectedCategory!.color)?.darken(byPercentage: CGFloat(indexPath.row) / CGFloat(todoItems!.count))
           {
               cell.backgroundColor = color
               cell.textLabel?.textColor = ContrastColorOf(color, returnFlat: true)
           }
            
         }
        else
        {
            cell.textLabel?.text = "No Item Added"
        }
      
        
        return cell
    }
    
    //MARK: - TableView Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let item = todoItems?[indexPath.row]
        {
           do 
           {
               try realm.write
               {
//                   realm.delete(item)
                   item.done = !item.done
               }
           }
           catch
           {
               
           }
        }
        tableView.reloadData()
        
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
    //MARK: - Add New Items
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) 
    {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New Todoey Item", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
           

            if let currentCategory = self.selectedCategory
            {
                do {
                    try self.realm.write
                    {
                        let newItem = Item()
                        newItem.title = textField.text!
                        newItem.date = Date()
                        
                        currentCategory.items.append(newItem)
                    }
                } 
                catch
                {
                    print("Error is \(error)")
                }
            
            }
             
                self.tableView.reloadData()
        }
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new item"
            textField = alertTextField
            
        }
        
        
        alert.addAction(action)
        
        present(alert, animated: true, completion: nil)
        
    }
    
   
    func loadItems()
    {
        todoItems = selectedCategory?.items.sorted(byKeyPath: "title", ascending: true)
        tableView.reloadData()
        
    }
    
    override func updateModel(at indexPath: IndexPath)
    {
     if let deleteItem = self.todoItems?[indexPath.row]
         {
            do {
                 try self.realm.write
                   {
                     self.realm.delete(deleteItem)
                    }
                }
                catch
                {
                    print("Error is, \(error)")
                }
                 
        }
    }
    
}

//MARK: - Search bar methods

extension TodoListViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar)
    {
        todoItems = todoItems?.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "date", ascending: true)
        
        tableView.reloadData()
        
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String){
        if searchBar.text?.count == 0
        {
            loadItems()
            
            DispatchQueue.main.async 
            {
                searchBar.resignFirstResponder()
            }
        }
    }
}

