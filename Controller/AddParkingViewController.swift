//
//  AddParkingViewController.swift
//  ParkEasy
//
//  Created by Emre Tuğ on 6.11.2023.
//

import UIKit
import CoreData
import MapKit
class AddParkingViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, CLLocationManagerDelegate {
    var context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    let locationManager = CLLocationManager()
    var lct : CLLocation?
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let image = info[.originalImage] as? UIImage {
                 imageView.image = image
                 picker.dismiss(animated: true, completion: nil)
                    
                
            }
        }
   
 
  
    private lazy var scrollView: UIScrollView = {
           let scroll = UIScrollView()
           scroll.translatesAutoresizingMaskIntoConstraints = false
            
           return scroll
       }()
    private lazy var contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    private lazy var nameTextField: UITextField = {
        let textfield = UITextField()
        textfield.backgroundColor = .white
        textfield.textColor = UIColor.black
        textfield.layer.cornerRadius = 30
        textfield.borderStyle = .none
        textfield.layer.borderWidth = 0.25
        
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: 60))
        textfield.leftView = paddingView
        textfield.leftViewMode = .always
        textfield.rightView = paddingView
        textfield.rightViewMode = .always
        
        let placeholderText = LocalizedString.name
        let attributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.systemGray, //
            
        ]
        
        textfield.attributedPlaceholder = NSAttributedString(string: placeholderText, attributes: attributes)
        
        textfield.tintColor = .white // Adjust cursor and selection color
        
        textfield.layer.masksToBounds = true
        return textfield
    }()

    private lazy var warningLabel : UILabel = {
        var label = UILabel()
        label.font = .systemFont(ofSize: 15)
        label.textColor = .red
        return label
    }()
    private lazy var locationDetailsTitleLabel : UILabel = {
       var label = UILabel()
        label.text = LocalizedString.detailtitlelabel
       label.font = .boldSystemFont(ofSize: 20)
       label.textColor = .black
       return label
    }()
    
    private lazy var locationLabel : UILabel = {
        var label = UILabel()
        label.numberOfLines = .zero
        label.font = .systemFont(ofSize: 15)
        label.textColor = .black
        return label
    }()
    private lazy var locationLogo :UIImageView = {
        var image = UIImageView()
        image.image = UIImage(systemName: "mappin.and.ellipse")
        image.layer.cornerRadius = 10
        image.clipsToBounds = true
        return image
        
    }()
    private lazy var detailTextField : UITextField = {
        let textfield = UITextField()
        textfield.backgroundColor = .white
        textfield.textColor = UIColor.black
        textfield.layer.cornerRadius = 30
        textfield.borderStyle = .none
        textfield.layer.borderWidth = 0.25
        
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: 60))
        textfield.leftView = paddingView
        textfield.leftViewMode = .always
        textfield.rightView = paddingView
        textfield.rightViewMode = .always
        
        let placeholderText = LocalizedString.detail
        let attributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.systemGray, //
            
        ]
        
        textfield.attributedPlaceholder = NSAttributedString(string: placeholderText, attributes: attributes)
        
        textfield.tintColor = .white // Adjust cursor and selection color
        
        textfield.layer.masksToBounds = true
        return textfield
       
    }()
    private lazy var parkingSpotPhotoTitleLabel : UILabel = {
       var label = UILabel()
        label.text = LocalizedString.phototitlelabel
       label.font = .boldSystemFont(ofSize: 20)
       label.textColor = .black
       return label
    }()
    private lazy var imageView : UIImageView = {
        var imageView = UIImageView()
        imageView.image = UIImage(systemName: "camera")
        imageView.tintColor = .gray
        
        imageView.isUserInteractionEnabled = true
        imageView.contentMode = .scaleAspectFit
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imageTapped))
        imageView.addGestureRecognizer(tapGesture)
        return imageView
    }()
    @objc func imageTapped () {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .photoLibrary
        imagePicker.mediaTypes = ["public.image"]

        self.present(imagePicker, animated: true, completion: nil)
    }
    private lazy var saveButton : UIButton = {
        
       var button = UIButton()
        var configuration = UIButton.Configuration.plain()
        configuration.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10)
        button.addAction(saveButtonAction, for: .touchUpInside)
        button.configuration = configuration
        button.setTitle(LocalizedString.savebutton, for: .normal)
        button.setTitleColor(.white, for: .highlighted)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .main
        button.layer.cornerRadius = 20
        button.clipsToBounds = true
        return button
    }()
    private lazy var saveButtonAction : UIAction = UIAction{_ in
        if let name = self.nameTextField.text , !name.isEmpty, let location = self.lct
        {
            self.warningLabel.isHidden = true
            let parkingSpotDetail = self.detailTextField.text
          
            let newPark = Park(context: self.context)
            newPark.name = name
            newPark.detail = parkingSpotDetail
            newPark.date = Date.now
            if let image = self.imageView.image , image != UIImage(systemName: "camera"){
                if let imageData = image.pngData() {
                    newPark.image = imageData
                }
            }
                newPark.latitude = location.coordinate.latitude
                newPark.longitude = location.coordinate.longitude
            
            newPark.isActive = true
            self.savePark()
            self.navigationController?.popViewController(animated: true)
        }
        else {
            self.warningLabel.text = LocalizedString.warninglabel
            self.warningLabel.isHidden = false
                }
        }
        
   
    func savePark(){
        
        do{
            try context.save()
        }
        catch{
            print("Error saving context \(error)")
        }
       
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else {
                return
            }
        lct = location
     
            let address = CLGeocoder.init()
        address.reverseGeocodeLocation(CLLocation.init(latitude: location.coordinate.latitude, longitude:location.coordinate.longitude)) { (places, error) in
                    if error == nil{
                        if let place = places?.first{
                            let thoroughfare = place.thoroughfare ?? "" // Sokak adı
                                   let subLocality = place.subLocality ?? ""   // Mahalle
                                   let locality = place.locality ?? ""         // İlçe
                                   let administrativeArea = place.administrativeArea ?? "" // İl
                                   let postalCode = place.postalCode ?? ""     // Posta kodu
                            let fullAddress = "\(thoroughfare), \(subLocality), \(locality), \(administrativeArea) \(postalCode)"

                            self.locationLabel.text = fullAddress
                            //here you can get all the info by combining that you can make address
                        }
                    }
                }
        
        
    }
    @objc func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()

        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.startUpdatingLocation()
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))

          
           view.addGestureRecognizer(tap)
         
        
         
        view.backgroundColor = .white
        
        self.title = LocalizedString.title
        let textAttributes = [NSAttributedString.Key.foregroundColor:UIColor.black]
        navigationController?.navigationBar.titleTextAttributes = textAttributes
        view.addSubview(scrollView)
        
        scrollView.isScrollEnabled = true
        scrollView.addSubview(contentView)
        contentView.addSubview(nameTextField)
        contentView.addSubview(warningLabel)
        contentView.addSubview(locationDetailsTitleLabel)
        contentView.addSubview(locationLogo)
        contentView.addSubview(locationLabel)
        contentView.addSubview(detailTextField)
        contentView.addSubview(parkingSpotPhotoTitleLabel)
        contentView.addSubview(imageView)
        contentView.addSubview(saveButton)
        scrollView.snp.makeConstraints { make in
            make.edges.equalTo(self.view.safeAreaLayoutGuide)
           
        }
        
        contentView.snp.makeConstraints { make in
            make.edges.equalTo(scrollView)
            make.width.equalTo(view.safeAreaLayoutGuide)
           
           
        }
        nameTextField.snp.makeConstraints { make in
            make.width.equalTo(view.frame.width - 40)
            make.centerX.equalToSuperview()
            make.height.equalTo(60)
            make.top.equalTo(contentView.safeAreaLayoutGuide.snp.top).offset(40)
        }
        warningLabel.snp.makeConstraints { make in
//            make.leading.equalToSuperview().offset(20)
            make.centerX.equalToSuperview()
            make.top.equalTo(nameTextField.snp.bottom).offset(5)
        }
        locationDetailsTitleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.top.equalTo(warningLabel.snp.bottom).offset(40)
        }
        locationLogo.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.top.equalTo(locationDetailsTitleLabel.snp.bottom).offset(10)
            make.height.equalTo(30)
            make.width.equalTo(30)
        }
        locationLabel.snp.makeConstraints { make in
            make.leading.equalTo(locationLogo.snp.trailing).offset(10)
            make.top.equalTo(locationDetailsTitleLabel.snp.bottom).offset(10)
            make.width.equalTo(view.frame.width - 90)
        }
        detailTextField.snp.makeConstraints { make in
            make.width.equalTo(view.frame.width - 40)
            make.centerX.equalToSuperview()
            make.height.equalTo(60)
            make.top.equalTo(locationLogo.snp.bottom).offset(10)
        }
        parkingSpotPhotoTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(detailTextField.snp.bottom).offset(40)
            make.leading.equalToSuperview().offset(20)
        }
        imageView.snp.makeConstraints { make in
            make.top.equalTo(parkingSpotPhotoTitleLabel.snp.bottom).offset(40)
            make.centerX.equalToSuperview()
            make.width.equalTo(view.frame.width - 40)
            make.height.equalTo(250)
        }
        saveButton.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom).offset(20)
            make.width.equalTo(view.frame.width - 40)
            make.height.equalTo(50)
            make.centerX.equalToSuperview()
            make.bottom.equalTo(contentView).offset(-70)
        }
      
    }
    

    class LocalizedString{
        static let title = NSLocalizedString("addparkingviewcontroller.title", comment: "")
        static let name = NSLocalizedString("addparkingviewcontroller.name", comment: "")
        static let detail = NSLocalizedString("addparkingviewcontroller.detail", comment: "")
        static let detailtitlelabel = NSLocalizedString("addparkingviewcontroller.detailtitlelabel", comment: "")
        static let phototitlelabel = NSLocalizedString("addparkingviewcontroller.phototitlelabel", comment: "")
        static let savebutton = NSLocalizedString("addparkingviewcontroller.savebutton", comment: "")
        static let warninglabel = NSLocalizedString("addparkingviewcontroller.warninglabel", comment: "")

       

    }

}
#Preview{
    AddParkingViewController()
}
