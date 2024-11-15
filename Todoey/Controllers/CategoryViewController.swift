

import UIKit
import RealmSwift
import ChameleonFramework


class CategoryViewController: swipeTableViewController {
    
  
    let realm = try! Realm()
    var categories: Results<Category>?
    
    
    override func viewDidLoad() 
    {
        super.viewDidLoad()
        
        loadCategories()
        tableView.rowHeight = 80
        tableView.separatorStyle = .none
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        guard let navbar = navigationController?.navigationBar else {fatalError("NavigationBar doesn't exist yet")}
        navbar.backgroundColor = UIColor(hexString: "1D9BF6")
    }
    
    //MARK: - TableView Datasource Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return categories?.count ?? 1
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell 
    {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
       
            cell.textLabel?.text = categories?[indexPath.row].name ?? "No Categories added yet"
            
            cell.backgroundColor = UIColor(hexString:  categories?[indexPath.row].color ?? "1D9BF6")
            
        return cell
    }

    
    //MARK: - TableView Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        performSegue(withIdentifier: "goToItems", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        let destinationVC = segue.destination as! TodoListViewController
        
        if let indexPath = tableView.indexPathForSelectedRow
        {
            destinationVC.selectedCategory = categories![indexPath.row]
        }
    }
    
    //MARK: - Data Manipulation Methods
    
    func save(category: Category) 
    {
            do {
                try realm.write 
                {
                    realm.add(category)
                }
            } 
           catch 
           {
                print("Error saving category \(error)")
            }
            tableView.reloadData()
        }
        
    
    func loadCategories() 
    {
         
         categories = realm.objects(Category.self)
         tableView.reloadData()
     }
     
    //MARK: - Delete Data From Swipe
    
    override func updateModel(at indexPath: IndexPath)
    {
     if let deleteCategory = self.categories?[indexPath.row]
         {
            do {
                 try self.realm.write
                   {
                     self.realm.delete(deleteCategory)
                    }
                }
                catch
                {
                    print("Error is, \(error)")
                }
                 
        }
    }

    
    //MARK: - Add New Categories

    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) 
    {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New Category", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add", style: .default) { (action) in
            
            
            let newCategory = Category()
            newCategory.name = textField.text!
            newCategory.color = UIColor.randomFlat().hexValue()
            
            self.save(category: newCategory)
            
        }
        
        alert.addAction(action)
        
        alert.addTextField { (field) in
            textField = field
            textField.placeholder = "Add a new category"
        }
        
        present(alert, animated: true, completion: nil)
        
    }

}
