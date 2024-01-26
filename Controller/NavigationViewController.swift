//
//  NavigationViewController.swift
//  ParkEasy
//
//  Created by Emre Tuğ on 12.11.2023.
//

import UIKit
import MapKit
import CoreData
class NavigationViewController: UIViewController {
    var context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var id : NSManagedObjectID?
    var item : Park?
    
    private lazy var mapView: MKMapView = {
            var map = MKMapView()
            map.showsUserLocation = true
            map.mapType = .standard
            map.layer.cornerRadius = 10
            map.layer.masksToBounds = true
            return map
        }()
    private lazy var finishButton : UIButton = {
        var uibutton = UIButton()
        uibutton.setTitle(LocalizedString.button, for: .normal)
        uibutton.layer.cornerRadius = 10
        uibutton.addAction(navigationaction, for: .touchUpInside)
        uibutton.backgroundColor = .main
        return uibutton
    }()
    func savePark(){
        
        do{
            try context.save()
        }
        catch{
            print("Error saving context \(error)")
        }
       
    }
    lazy var navigationaction :UIAction = UIAction{_ in
        self.item?.isActive = false
        
        self.savePark()
        self.navigationController?.popToRootViewController(animated: true)
    }
    let locationManager = CLLocationManager()
    var currentCoordinate: CLLocationCoordinate2D!
    var steps = [MKRoute.Step]()
    var stepCounter = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.startUpdatingLocation()
     
           
               
            
       
        view.backgroundColor = .white
        view.addSubview(mapView)
        mapView.addSubview(finishButton)
                mapView.snp.makeConstraints { make in
                    make.centerX.equalToSuperview()
                    make.top.equalTo(view.snp.top)
                    make.height.equalTo(view.frame.size.height)
                    make.width.equalTo(view.frame.width)
        
                }
        finishButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
            make.height.equalTo(50)
            make.width.equalTo(view.frame.width - 40)
        }
    }
    

    class LocalizedString{
        static let button = NSLocalizedString("navigationviewcontroller.button", comment: "")

    }

}

extension NavigationViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKPolyline {
            let renderer = MKPolylineRenderer(overlay: overlay)
            renderer.strokeColor = .blue
            renderer.lineWidth = 10
            return renderer
        }
        if overlay is MKCircle {
            let renderer = MKCircleRenderer(overlay: overlay)
            renderer.strokeColor = .red
            renderer.fillColor = .red
            renderer.alpha = 0.5
            return renderer
        }
        return MKOverlayRenderer()
    }
}

private extension MKMapView {
  func centerToLocation(
    _ location: CLLocation,
    regionRadius: CLLocationDistance = 1000
  ) {
    let coordinateRegion = MKCoordinateRegion(
      center: location.coordinate,
      latitudinalMeters: regionRadius,
      longitudinalMeters: regionRadius)
    setRegion(coordinateRegion, animated: true)
  }
}
 extension NavigationViewController : CLLocationManagerDelegate{
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
           manager.stopUpdatingLocation()
           guard let currentLocation = locations.first else { return }
           currentCoordinate = currentLocation.coordinate
           mapView.userTrackingMode = .followWithHeading
        if let item = findItem(withParkID: id!){
            let cordinate =  CLLocationCoordinate2D(latitude: item.latitude, longitude: item.longitude)
            getDirections(to: MKMapItem(placemark: MKPlacemark(coordinate:cordinate)))
                let annotation = MKPointAnnotation()
                annotation.coordinate = cordinate
                mapView.addAnnotation(annotation)
            
            }

       }
     func findItem(withParkID parkID: NSManagedObjectID) -> Park? {
         do {
              item = try context.existingObject(with: parkID) as? Park
             return item
         } catch {
             print("Hata: Nesne bulunamadı - \(error)")
             return nil
         }
     }

func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        print("ENTERED")
        stepCounter += 1
        if stepCounter < steps.count {

        } 
    else {

            stepCounter = 0
            locationManager.monitoredRegions.forEach({ self.locationManager.stopMonitoring(for: $0) })
            
        }
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

     func getDirections(to destination: MKMapItem) {
         let sourcePlacemark = MKPlacemark(coordinate: currentCoordinate)
                let sourceMapItem = MKMapItem(placemark: sourcePlacemark)
 
         let directionsRequest = MKDirections.Request()
                directionsRequest.source = sourceMapItem
                directionsRequest.destination = destination
                directionsRequest.transportType = .walking
 
                let directions = MKDirections(request: directionsRequest)
                directions.calculate { (response, _) in
 
                    guard let response = response else { return }
                    guard let primaryRoute = response.routes.first else { return }
 
                    self.mapView.addOverlay(primaryRoute.polyline)
                    self.locationManager.monitoredRegions.forEach({ self.locationManager.stopMonitoring(for: $0) })
 
                               self.steps = primaryRoute.steps
                               for i in 0 ..< primaryRoute.steps.count {
                                   let step = primaryRoute.steps[i]
                                   print(step.instructions)
                                   print(step.distance)
                                   let region = CLCircularRegion(center: step.polyline.coordinate,
                                                                 radius: 20,
                                                                 identifier: "\(i)")
                                   self.locationManager.startMonitoring(for: region)
 
                               }
 
                               self.stepCounter += 1
                           }
                       }
   
}
#Preview{
    NavigationViewController()
}
