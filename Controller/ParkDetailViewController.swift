//
//  HistoryDetailViewController.swift
//  ParkEasy
//
//  Created by Emre Tuğ on 7.11.2023.
//

import UIKit



import UIKit
import GoogleMobileAds
import MapKit
import CoreLocation
import SnapKit
import CoreData
class ParkDetailViewController: UIViewController  {
   

    var context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var id : NSManagedObjectID?
    var item:Park?
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
   
//    private lazy var mapView: MKMapView = {
//        var map = MKMapView()
//        map.showsUserLocation = true
//        map.mapType = .standard
//        map.layer.cornerRadius = 10
//        map.layer.masksToBounds = true
//        return map
//    }()
    

    private lazy var detailLabel : UILabel = {
       var label = UILabel()
       label.font = .systemFont(ofSize: 20)
       label.textColor = .gray
       return label
    }()
    private lazy var imageView : UIImageView = {
        var imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 15
        return imageView
    }()
    private lazy var navigationButton : UIButton = {
        var uibutton = UIButton()
        uibutton.setTitle(LocalizedString.button, for: .normal)
        uibutton.layer.cornerRadius = 10
        uibutton.addAction(navigationaction, for: .touchUpInside)
        uibutton.backgroundColor = .main
        return uibutton
    }()
    lazy var navigationaction :UIAction = UIAction{_ in
       let navigationvc = NavigationViewController()
        navigationvc.id = self.id
        self.navigationController?.pushViewController(navigationvc, animated: true)
    }
    var bannerView: GADBannerView!
  
        override func viewDidLoad() {
            
        super.viewDidLoad()
            
            view.backgroundColor = .white
            let textAttributes = [NSAttributedString.Key.foregroundColor:UIColor.black]
            navigationController?.navigationBar.titleTextAttributes = textAttributes
           
        if let parkId = id {
            item = findItem(withParkID: parkId)
            self.title = item?.name
            detailLabel.text = item?.detail
            if let imagedata = item?.image , let image = UIImage(data: imagedata){
                imageView.image = image
            }
            else{
                imageView.isHidden = true
            }
           
               
            
       }
            
           
        
   
//        mapView.delegate = self
        bannerView = GADBannerView(adSize: GADAdSizeBanner)
        bannerView.delegate = self
        addBannerViewToView(bannerView)
        bannerView.adUnitID = "ca-app-pub-6544171000174072/5315757502"
        bannerView.rootViewController = self
        bannerView.load(GADRequest())
        
       
            
            view.addSubview(detailLabel)
            view.addSubview(imageView)
            view.addSubview(navigationButton)


            detailLabel.snp.makeConstraints { make in
                make.top.equalTo(imageView.snp.bottom).offset(20)
                make.leading.equalToSuperview().offset(20)
            }
            imageView.snp.makeConstraints { make in
                make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
                
                make.centerX.equalToSuperview()
                make.width.equalTo(view.frame.width - 40)
                if let width = imageView.image?.size.width , let height = imageView.image?.size.height{
                    let oran = width / height
                    make.height.equalTo((view.frame.width - 40)/oran)
                }
                
               
            }
            navigationButton.snp.makeConstraints { make in
                make.centerX.equalToSuperview()
                make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-70)
                make.leading.equalToSuperview().offset(20)
                make.trailing.equalToSuperview().offset(-20)
                make.height.equalTo(50)
                
            }
          
//            button.snp.makeConstraints { make in
//                make.centerX.equalToSuperview()
//                make.top.equalTo(mapView.snp.bottom)
//            }

      
        
    }
      
    class LocalizedString{
        static let button = NSLocalizedString("parkdetailviewcontroller.button", comment: "")

    }
  

//    func addLocation(){
//        parkList.forEach { location in
//            let annotation = MKPointAnnotation()
//            annotation.coordinate = CLLocationCoordinate2D(latitude:location.latitude, longitude: location.longitude)
//            annotation.title = String(location.latitude)
//            mapView.addAnnotation(annotation)
//            
//        }
//    }
//
    func findItem(withParkID parkID: NSManagedObjectID) -> Park? {
        do {
            let item = try context.existingObject(with: parkID) as? Park
            return item
        } catch {
            print("Hata: Nesne bulunamadı - \(error)")
            return nil
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


extension ParkDetailViewController: GADBannerViewDelegate{
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

#Preview{
    ParkDetailViewController()
}

