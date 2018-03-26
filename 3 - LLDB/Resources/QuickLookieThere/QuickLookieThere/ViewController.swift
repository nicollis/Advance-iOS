import UIKit
import CoreLocation

class ViewController: UIViewController {
    var image: UIImage
    var color: UIColor
    var bezierPath: UIBezierPath!
    var location: CLLocation
    var string: String!
    var attributedString: NSAttributedString!
    var data: Data!
    var url: URL
    
    var reuseIdentifier = "Reuse Identifier"

    
    @IBOutlet var collectionView: UICollectionView!
    
    required init?(coder: NSCoder) {
        image = UIImage(named: "enterprise.jpg")!
        color = UIColor(red: 0.9019607843, green: 0.2941176471, 
                        blue: 0.8509803922, alpha: 1.0)
        location = CLLocation(latitude: 33.759140, longitude: -84.332100)
        url = URL(string: "http://bignerdranch.com/blog")!
        
        super.init(coder: coder)
        
        bezierPath = makeBezierPath()
        string = loadString()
        attributedString = loadAttributedString()
        data = loadData()
    }
    
    func debugQuickLookObject() -> UIImage {
        let width: CGFloat = 450.0
        let height: CGFloat = 300.0
        
        let move = CGAffineTransform(translationX: width / 2, 
                                     y: height / 2)
        let flipAndMove = move.scaledBy(x: 1.0, y: -1.0)
        let rotate = CGAffineTransform(rotationAngle: -CGFloat.pi / 6.0)
        
        
        UIGraphicsBeginImageContext(CGSize(width: width, height: height))
        let fullRect = CGRect(x: 0.0, y: 0.0, width: width, height: height)
        UIColor.lightGray.set()
        UIRectFill(fullRect)
        
        let imageRect = CGRect(x: 0.0, y: 50.0, width: width * 0.777, height: height * 0.777)
        
        image.draw(in: imageRect, blendMode: .normal, alpha: 0.3)
        
        let mrHat = bezierPath.copy() as! UIBezierPath
        mrHat.apply(flipAndMove)
        
        UIColor.orange.set()
        mrHat.fill()
        
        let font = UIFont.boldSystemFont(ofSize: 40.0)
        let attributes = [ NSAttributedStringKey.font : font,
                           NSAttributedStringKey.foregroundColor: color]
                         as [NSAttributedStringKey : Any]
        
        let context = UIGraphicsGetCurrentContext()
        context?.concatenate(rotate)
        
        ("This is Techno Rock!" as NSString).draw(at: CGPoint(x: -50.0, y: height), withAttributes: attributes)
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
    func loadString() -> String {
        // Things are from the bundle. If missing, it's ok if we die quickly
        let url = Bundle.main.url(forResource: "raven", withExtension: "txt")
        let string = try? String(contentsOf: url!)
        return string!
    }
    
    func loadAttributedString() -> NSAttributedString {
        let url = Bundle.main.url(forResource: "raven", withExtension: "rtfd")
        let options = [NSAttributedString.DocumentReadingOptionKey.documentType : NSAttributedString.DocumentType.rtfd]
        let string = try? NSAttributedString(url: url!,
                                             options: options, 
                                             documentAttributes: nil)
        return string!
    }
    
    func loadData() -> Data {
        let url = Bundle.main.url(forResource: "raven", withExtension: "txt")
        let data = try? Data(contentsOf: url!)
        return data!
    }
    
    @IBAction func stopInDebugger() {
        print("You should now be stopped in the debugger")
        print("Be sure to QuickLook all my properties!")
        raise(SIGINT)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
    }
    
    // A collection view with a bunch of squares, to show off quicklook displaying
    // an arbitrary view.
    
}


extension ViewController: UICollectionViewDataSource {
    func setupCollectionView() {
        let layoutManager = UICollectionViewFlowLayout()
        let insets = UIEdgeInsets(top: 20.0, left: 5.0, bottom: 60.0, right: 5.0)
        layoutManager.sectionInset = insets
        layoutManager.itemSize = CGSize(width: 100, height: 40)
        
        collectionView.collectionViewLayout = layoutManager
        
        collectionView.register(UICollectionViewCell.self,
                                forCellWithReuseIdentifier: reuseIdentifier)
    }
    
    func collectionView(_ collectionView: UICollectionView, 
                        numberOfItemsInSection section: Int) -> Int {
        return 200
    }
    
    func collectionView(_ collectionView: UICollectionView, 
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier,
                                                      for: indexPath)

        let nullishPtr = UnsafeMutableRawPointer(bitPattern: 1)  // bit pattern of 0 == nils propagating
        let pointer = Unmanaged.passUnretained(cell).toOpaque()
        if let distance = nullishPtr?.distance(to: pointer) {
            let red: CGFloat = CGFloat(distance & 0xFF) / 255.0
            let green: CGFloat = CGFloat((distance >> 8) & 0xFF) / 255.0
            let blue: CGFloat = CGFloat((distance >> 16) & 0xFF) / 255.0
            cell.backgroundColor = UIColor(red: red, green: green, blue: blue, alpha: 1.0)
        } else {
            cell.backgroundColor = UIColor.purple
        }
        
        let labelTag = 1000
        
        var titleLabel: UILabel? = cell.contentView.viewWithTag(labelTag) as? UILabel
        if titleLabel == nil {
            titleLabel = UILabel(frame: cell.bounds)
            titleLabel?.tag = labelTag
            titleLabel?.textAlignment = .center
        }
        
        titleLabel?.text = "\(indexPath.section) \(indexPath.row)"
        cell.contentView.addSubview(titleLabel!)
        
        return cell
    }
    
}

















