
//
//  HomeViewController.swift
//  ParkEasy
//
//  Created by Emre Tuğ on 31.10.2023.
//

import UIKit
import GoogleMobileAds
import MapKit
import SnapKit
import CoreData
import SwipeCellKit
class HistoryViewController: UIViewController , MKMapViewDelegate, UITableViewDataSource , UITableViewDelegate , SwipeTableViewCellDelegate{
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else { return nil }

        let deleteAction = SwipeAction(style: .destructive, title: "Delete") { action, indexPath in
            self.updatePark(indexPath: indexPath)
        }

        deleteAction.image = UIImage(named: "delete")

        return [deleteAction]
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return parkList.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
           let cell = SwipeTableViewCell(style: .default, reuseIdentifier: "cellIdentifier")
           cell.delegate = self
        cell.backgroundColor = .white
        cell.textLabel?.textColor = .black
           cell.textLabel?.text = parkList[indexPath.row].name
           cell.accessoryType = .detailButton

        
           return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        mapView.centerToLocation(CLLocation(latitude: parkList[indexPath.row].latitude, longitude: parkList[indexPath.row].longitude))
        if let cell = tableView.cellForRow(at: indexPath) {
            cell.setSelected(false, animated: true)
           }
    }
    func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        let parkDetailVC = ParkDetailViewController()
        parkDetailVC.id = parkList[indexPath.row].objectID
        self.navigationController?.pushViewController(parkDetailVC, animated: true)
    }
    
    var context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    private var parkList: [Park] = []
  
    private lazy var latestTitleLabel:UILabel = {
       var label = UILabel()
        label.text = LocalizedString.title
        label.font = .boldSystemFont(ofSize: 27)
        label.numberOfLines = 2
        label.textColor = .black
        return label
    }()
   
    // MARK: - değişecek
    private lazy var carlogo:UIImageView = {
        var image = UIImageView(image: .icons8Car64)
        image.layer.cornerRadius = 10
        image.clipsToBounds = true
        return image
        
    }()
    private lazy var lineView: UIView = {
        var lineView = UIView()
        lineView.backgroundColor = .systemGray5
        return lineView
    }()
   
    private lazy var mapView: MKMapView = {
        var map = MKMapView()
//        map.showsUserLocation = true
        map.mapType = .standard
        map.layer.cornerRadius = 10
        map.layer.masksToBounds = true
        return map
    }()
    
    private lazy var tableView: UITableView = {
        var tableView = UITableView()
        tableView.backgroundColor = .white
        tableView.estimatedRowHeight = 44 // Tahmini hücre yüksekliği
        tableView.rowHeight = UITableView.automaticDimension // Otomatik yükseklik
       return tableView
    }()
    private lazy var denemeView:UIView = {
        var vieww = UIView()
        vieww.backgroundColor = .red
        return vieww
    }()
    
    
    var bannerView: GADBannerView!
    override func viewWillAppear(_ animated: Bool) {
        loadPark()
        addLocation()
        if let lct = parkList.last{
            mapView.centerToLocation(CLLocation(latitude: lct.latitude, longitude: lct.longitude))
        }
       

    }
   
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        tableView.dataSource = self
        tableView.delegate = self
        mapView.delegate = self
        bannerView = GADBannerView(adSize: GADAdSizeBanner)
        bannerView.delegate = self
        addBannerViewToView(bannerView)
        bannerView.adUnitID = "ca-app-pub-6544171000174072/5315757502"
        bannerView.rootViewController = self
        bannerView.load(GADRequest())
        
        self.navigationItem.setHidesBackButton(true, animated: true)
        view.backgroundColor = .white
       
        
        view.addSubview(latestTitleLabel)
        view.addSubview(carlogo)
        view.addSubview(lineView)
        view.addSubview(mapView)
      
        view.addSubview(tableView)
        
        
      
        latestTitleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.leading.equalTo(view.snp.leading).offset(20)
        }
      
        carlogo.snp.makeConstraints { make in
            make.leading.equalTo(latestTitleLabel.snp.trailing)
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.trailing.equalTo(view.snp.trailing).offset(-30)
            make.height.equalTo(50)
            make.width.equalTo(50)
        }
        lineView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(latestTitleLabel.snp.bottom).offset(40)
            make.height.equalTo(1)
            make.width.equalTo(view.frame.size.width - 40)
            
        }
        mapView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(lineView.snp.bottom).offset(10)
            make.height.equalTo(200)
            make.width.equalTo(view.frame.width - 40)
            
        }
        
        tableView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
               make.top.equalTo(mapView.snp.bottom).offset(10)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-50)
               make.width.equalTo(view.frame.width - 40)
        }
       

      
        
    }
    class LocalizedString{
        static let title = NSLocalizedString("historyviewcontroller.title", comment: "")

    }
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKPointAnnotation {
            let annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "carPin")
            let carImage = UIImage(systemName: "car")
            annotationView.image = carImage
            annotationView.isEnabled = false
            return annotationView
        }
        return nil
    }
    func addLocation(){
        parkList.forEach { location in
            let annotation = MKPointAnnotation()
            annotation.coordinate = CLLocationCoordinate2D(latitude:location.latitude, longitude: location.longitude)
            annotation.title = String(location.name ?? "")
            mapView.addAnnotation(annotation)
            
        }
    }
//
     func updatePark(indexPath: IndexPath) {
        context.delete(parkList[indexPath.row])
        self.parkList.remove(at: indexPath.row)
        tableView.reloadData()
    }
    
        func loadPark(with request :NSFetchRequest<Park> = Park.fetchRequest()){
    
    
    
                do{
                   parkList = try context.fetch(request)
                   tableView.reloadData()
    
                }
                catch{
                    print("Error fetching data \(error)")
                }
    
            }
    func addBannerViewToView(_ bannerView: GADBannerView) {
       bannerView.translatesAutoresizingMaskIntoConstraints = false
       view.addSubview(bannerView)
       view.addConstraints(
         [NSLayoutConstraint(item: bannerView,
                             attribute: .bottom,
                             relatedBy: .equal,
                             toItem: view.safeAreaLayoutGuide,
                             attribute: .bottom,
                             multiplier: 1,
                             constant: 0),
          NSLayoutConstraint(item: bannerView,
                             attribute: .centerX,
                             relatedBy: .equal,
                             toItem: view,
                             attribute: .centerX,
                             multiplier: 1,
                             constant: 0)
         ])
      }

}
struct Location {
    var name: String
    var latitude: Double
    var longitude: Double
}
//
extension HistoryViewController: GADBannerViewDelegate{
    func bannerViewDidReceiveAd(_ bannerView: GADBannerView) {
      // Add banner to view and add constraints as above.
      addBannerViewToView(bannerView)
    }

    func bannerView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: Error) {
      print("bannerView:didFailToReceiveAdWithError: \(error.localizedDescription)")
    }

    func bannerViewDidRecordImpression(_ bannerView: GADBannerView) {
      print("bannerViewDidRecordImpression")
    }

    func bannerViewWillPresentScreen(_ bannerView: GADBannerView) {
      print("bannerViewWillPresentScreen")
    }

    func bannerViewWillDismissScreen(_ bannerView: GADBannerView) {
      print("bannerViewWillDIsmissScreen")
    }

    func bannerViewDidDismissScreen(_ bannerView: GADBannerView) {
      print("bannerViewDidDismissScreen")
    }
}
private extension MKMapView {
  func centerToLocation(
    _ location: CLLocation,
    regionRadius: CLLocationDistance = 100
  ) {
    let coordinateRegion = MKCoordinateRegion(
      center: location.coordinate,
      latitudinalMeters: regionRadius,
      longitudinalMeters: regionRadius)
      UIView.animate(withDuration: 0.5) {
          self.setRegion(coordinateRegion, animated: true)
      }
  }
}
#Preview{
    HistoryViewController()
}
