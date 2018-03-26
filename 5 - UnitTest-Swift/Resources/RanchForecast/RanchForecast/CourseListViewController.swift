
import UIKit

class CourseListViewController: UITableViewController {

    let fetcher = ScheduleFetcher()
    var courses:[Course] = []
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(refreshControlPulled(_:)), for: .valueChanged)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        refreshCourses()
    }
        
    // MARK: - Actions
    
    @objc func refreshControlPulled(_ sender: UIRefreshControl) {
        refreshCourses()
    }
    
    // MARK: - Data Fetching
    
    func refreshCourses() {
        refreshControl?.beginRefreshing()
        
        fetcher.fetchCourses { [weak self](result) in
            if let strongSelf = self {
                switch result {
                case .success(let courses):
                    print("Got courses: \(courses)")
                    strongSelf.courses = courses
                case .failure(let error):
                    
                    print("Got error: \(error)")
                    strongSelf.courses = []
                }
                
                strongSelf.refreshControl?.endRefreshing()
                strongSelf.tableView.reloadData()
            }
        }
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return courses.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "CourseCell", for: indexPath) 
        let course = courses[(indexPath as NSIndexPath).row]
        cell.textLabel?.text = course.nextStartDateString
        cell.detailTextLabel?.text = course.title
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let course = courses[(indexPath as NSIndexPath).row]
        UIApplication.shared.open(course.url, options: [:], completionHandler: nil)
    }
}
