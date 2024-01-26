
//
//  HomeViewController.swift
//  ParkEasy
//
//  Created by Emre Tuğ on 31.10.2023.
//

import UIKit
import GoogleMobileAds
import SnapKit
import CoreData

class HomeViewController: UIViewController ,UIScrollViewDelegate{
    var context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    
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
    private lazy var homeTitleLabel:UILabel = {
       var label = UILabel()
        label.text = LocalizedString.title
        label.font = .boldSystemFont(ofSize: 27)
        label.textColor = .black
        return label
    }()
    private lazy var homeSubtitleLabel:UILabel = {
       var label = UILabel()
        label.text = LocalizedString.subtitle
        label.font = .systemFont(ofSize: 20)
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
    private lazy var maplogo:UIImageView = {
        var image = UIImageView()
        image.image =  UIImage(systemName: "map.fill")?.imageWithColor(tintColor: .white)
        return image
        
    }()
    private lazy var lineView: UIView = {
        var lineView = UIView()
        lineView.backgroundColor = .systemGray5
        return lineView
    }()
   
    
    private lazy var newParkingView: UIView = {
        var npView = UIView()
        npView.layer.cornerRadius = 20
        npView.backgroundColor = .main
//        npView.layer.masksToBounds = true
        npView.clipsToBounds = true
       return npView
    }()
    
    
    private lazy var newParkingStackView: UIView = {
       var stack = UIView()
        return stack
    }()
    
    private lazy var newParkingTitleLabel:UILabel = {
       var label = UILabel()
        label.text = LocalizedString.newparkingtitle
        label.numberOfLines = 2
        label.font = .boldSystemFont(ofSize: 20)
        label.textColor = .white
        return label
    }()
    private lazy var newParkingSubtitleLabel:UILabel = {
       var label = UILabel()
        label.text = LocalizedString.newparkingsubtitle
        label.font = .systemFont(ofSize: 15)
        label.textColor = .white
        return label
    }()

    private lazy var newParkingButton:UIButton = {
        var button = UIButton()
        button.addAction(action, for: .touchUpInside)
        var configuration = UIButton.Configuration.plain()
        configuration.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10)
        button.configuration = configuration
        button.setTitle(LocalizedString.newparkingbutton, for: .normal)
        button.setTitleColor(.black, for: .highlighted)
        button.setTitleColor(.black, for: .normal)
        button.backgroundColor = .white
        button.layer.cornerRadius = 20
        button.clipsToBounds = true
        return button
    
    }()
 
    lazy var action :UIAction = UIAction{_ in
        let addparkingvc = AddParkingViewController()
        self.navigationController?.pushViewController(addparkingvc, animated: true)
    }
    private lazy var lastParkedLabel:UILabel = {
       var label = UILabel()
        label.text = LocalizedString.lastparked
        label.font = .boldSystemFont(ofSize: 20)
        label.textColor = .black
        return label
    }()
    
    private lazy var lastParkingView: UIView = {
        var lpView = UIView()
        lpView.layer.cornerRadius = 20
        lpView.backgroundColor = .main
        lpView.clipsToBounds = true
       return lpView
    }()
    private lazy var locationlogo:UIImageView = {
        var image = UIImageView()
        image.image =  UIImage(systemName: "map.fill")?.imageWithColor(tintColor: .white)
        return image
        
    }()
    private lazy var lastParkingViewLocationNameLabel:UILabel = {
       var label = UILabel()
        label.text = LocalizedString.lastparkedlocation
        label.font = .boldSystemFont(ofSize: 20)
        label.textColor = .white
        return label
    }()
    private lazy var lastParkingViewLocationDetailLabel:UILabel = {
       var label = UILabel()
        label.text = LocalizedString.lastparkedlocationdetail
        label.font = .systemFont(ofSize: 15)
        label.textColor = .white
        label.numberOfLines = 1
        return label
    }()
    private lazy var viewDetailsButton:UIButton = {
        var button = UIButton()
        var configuration = UIButton.Configuration.plain()
        configuration.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10)
        button.configuration = configuration
        button.addAction(viewDetailAction, for: .touchUpInside)
        button.setTitle(LocalizedString.viewdetails, for: .normal)
        button.setTitleColor(.black, for: .highlighted)
        button.setTitleColor(.black, for: .normal)
        button.backgroundColor = .white
        button.layer.cornerRadius = 20
        button.clipsToBounds = true
        return button
    }()
    private lazy var viewDetailAction = UIAction{_ in
        if let id = self.parkList.last?.objectID {
            let detailVC = ParkDetailViewController()
            detailVC.id = id
            self.navigationController?.pushViewController(detailVC, animated: true)
     
        }
    }
    private lazy var parkDurationLabel:UILabel = {
       var label = UILabel()
        label.text = LocalizedString.parkduration
        label.font = .boldSystemFont(ofSize: 20)
        label.textColor = .black
        return label
    }()
    private lazy var parkDurationView: UIView = {
        var pdView = UIView()
        pdView.layer.cornerRadius = 20
        pdView.backgroundColor = .main
        pdView.clipsToBounds = true
       return pdView
    }()
    private lazy var parkDurationTimerLabel : UILabel = {
       var label = UILabel()
        label.font = .boldSystemFont(ofSize: 40)
        label.textColor = .white
        return label
    }()
   
    
    var bannerView: GADBannerView!
    var timer:Timer?
    private var parkList: [Park] = []
    override func viewWillAppear(_ animated: Bool) {
        timer?.invalidate()
        loadPark()
        
        if let park = parkList.last, park.isActive == true{
            lastParkedLabel.isHidden = false
            lastParkingView.isHidden = false
            parkDurationView.isHidden = false
            parkDurationLabel.isHidden = false
            lastParkingViewLocationNameLabel.text = park.name
            lastParkingViewLocationDetailLabel.text = park.detail
            timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] timer in
                let currentDate = Date() // Şu anki tarih ve saat
                if let targetDate = park.date { // Karşılaştırılacak tarih
                    let calendar = Calendar.current
                    let components = calendar.dateComponents([.day, .hour, .minute, .second], from: targetDate, to: currentDate)
                    
                    if let days = components.day, let hours = components.hour, let minutes = components.minute {
                        // UILabel'ı güncelle
                        let localizedFormat = LocalizedString.durationFormat
                        let formattedString = String(format: localizedFormat, days, hours, minutes)

                        self?.parkDurationTimerLabel.text = formattedString
                    }
                }
            }

        }
        else{
            lastParkedLabel.isHidden = true
            lastParkingView.isHidden = true
            parkDurationView.isHidden = true
            parkDurationLabel.isHidden = true
            lastParkingViewLocationNameLabel.text = ""
            lastParkingViewLocationDetailLabel.text = ""
            parkDurationTimerLabel.text = ""
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
   
        
        
        bannerView = GADBannerView(adSize: GADAdSizeBanner)
        bannerView.delegate = self
        addBannerViewToView(bannerView)
        
        bannerView.adUnitID = "ca-app-pub-6544171000174072/5315757502"
        bannerView.rootViewController = self
        bannerView.load(GADRequest())
       
        
        self.navigationItem.setHidesBackButton(true, animated: true)
        view.backgroundColor = .white
        view.addSubview(scrollView)
        
        scrollView.isScrollEnabled = true
        scrollView.addSubview(contentView)
        contentView.addSubview(homeTitleLabel)
        contentView.addSubview(homeSubtitleLabel)
        contentView.addSubview(carlogo)
        contentView.addSubview(lineView)
        contentView.addSubview(newParkingView)
        contentView.addSubview(lastParkedLabel)
        contentView.addSubview(lastParkingView)
        contentView.addSubview(parkDurationView)
        contentView.addSubview(parkDurationLabel)
        
        
        newParkingView.addSubview(newParkingStackView)
        newParkingView.addSubview(maplogo)
        newParkingView.addSubview(newParkingButton)
        newParkingStackView.addSubview(newParkingTitleLabel)
        newParkingStackView.addSubview(newParkingSubtitleLabel)
        
        lastParkingView.addSubview(locationlogo)
        lastParkingView.addSubview(lastParkingViewLocationNameLabel)
        lastParkingView.addSubview(lastParkingViewLocationDetailLabel)
        lastParkingView.addSubview(viewDetailsButton)
        
        parkDurationView.addSubview(parkDurationTimerLabel)
        
        
        
        scrollView.snp.makeConstraints { make in
            make.edges.equalTo(self.view.safeAreaLayoutGuide)
           
        }
        
        contentView.snp.makeConstraints { make in
            make.edges.equalTo(scrollView)
            make.width.equalTo(view.safeAreaLayoutGuide)
           
           
        }

        homeTitleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(contentView.safeAreaLayoutGuide.snp.top)
            make.leading.equalTo(contentView.snp.leading).offset(20)
        }
        homeSubtitleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(homeTitleLabel.snp.bottom).offset(5)
            make.leading.equalTo(contentView.snp.leading).offset(20)
        }
        carlogo.snp.makeConstraints { make in
            make.leading.equalTo(homeSubtitleLabel.snp.trailing)
            make.top.equalTo(contentView.safeAreaLayoutGuide.snp.top)
            make.trailing.equalTo(contentView.snp.trailing).offset(-30)
            make.height.equalTo(50)
            make.width.equalTo(50)
        }
        lineView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(homeSubtitleLabel.snp.bottom).offset(20)
            make.height.equalTo(1)
            make.width.equalTo(view.frame.size.width - 40)
            
        }
        newParkingView.snp.makeConstraints { make in
            make.centerX.equalTo(contentView)
            make.top.equalTo(lineView).offset(20)
            make.height.equalTo(190)
            make.width.equalTo(view.frame.size.width - 40)
        }
        maplogo.snp.makeConstraints { make in
            make.leading.equalTo(newParkingView.snp.leading).offset(10)
            make.top.equalTo(newParkingView.snp.top).offset(20)
            make.height.equalTo(30)
            make.width.equalTo(30)

        }
        newParkingStackView.snp.makeConstraints { make in
            make.leading.equalTo(maplogo.snp.trailing).offset(20)
            make.centerX.equalTo(newParkingView.snp.centerX)
        }
        newParkingTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(newParkingView.snp.top).offset(20)
            make.width.equalTo(view.frame.width - 80)
        }
        newParkingSubtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(newParkingTitleLabel.snp.bottom).offset(10)
        }
        newParkingButton.snp.makeConstraints { make in
            make.centerX.equalTo(newParkingView.snp.centerX)
            make.height.equalTo(50)
            make.bottom.equalTo(newParkingView.snp.bottom).offset(-30)
            make.leading.equalTo(newParkingStackView.snp.leading)
            make.trailing.equalTo(newParkingStackView.snp.trailing)
        }
        lastParkedLabel.snp.makeConstraints { make in
            make.leading.equalTo(contentView.snp.leading).offset(20)
            make.top.equalTo(newParkingView.snp.bottom).offset(20)
        }
        lastParkingView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(lastParkedLabel.snp.bottom).offset(20)
            make.width.equalTo(view.frame.size.width - 40)
            make.height.equalTo(100)
        }
        locationlogo.snp.makeConstraints { make in
            make.leading.equalTo(lastParkingView.snp.leading).offset(10)
            make.top.equalTo(lastParkingView.snp.top).offset(20)
            make.height.equalTo(30)
            make.width.equalTo(30)

        }
        lastParkingViewLocationNameLabel.snp.makeConstraints { make in
            make.leading.equalTo(locationlogo.snp.trailing).offset(10)
            make.top.equalTo(lastParkingView.snp.top).offset(20)

        }
        lastParkingViewLocationDetailLabel.snp.makeConstraints { make in
            make.leading.equalTo(locationlogo.snp.trailing).offset(10)
            make.top.equalTo(lastParkingViewLocationNameLabel.snp.bottom).offset(5)
            make.trailing.equalTo(viewDetailsButton.snp.leading)
         
        }
        viewDetailsButton.snp.makeConstraints { make in
            make.centerY.equalTo(lastParkingView.snp.centerY)
            make.trailing.equalTo(lastParkingView.snp.trailing).offset(-20)
            make.height.equalTo(50)
            make.width.equalTo(130)
            
        }
        
       
        
        parkDurationLabel.snp.makeConstraints { make in
            make.leading.equalTo(contentView.snp.leading).offset(20)
            make.top.equalTo(lastParkingView.snp.bottom).offset(20)
        }
        parkDurationView.snp.makeConstraints { make in
            make.height.equalTo(100)
            make.width.equalTo(view.frame.size.width - 40)
            make.centerX.equalToSuperview()
            make.top.equalTo(parkDurationLabel.snp.bottom).offset(20)
            make.bottom.equalTo(contentView).offset(-70)

        }
        
        parkDurationTimerLabel.snp.makeConstraints { make in
            make.center.equalTo(parkDurationView.snp.center)
        }
        

        
    }
    
    class LocalizedString{
        static let title = NSLocalizedString("homeviewcontroller.title", comment: "welcome string")
        static let subtitle = NSLocalizedString("homeviewcontroller.subtitle", comment: "duration format")
        static let newparkingtitle = NSLocalizedString("homeviewcontroller.newparkingtitle", comment: "")
        static let newparkingsubtitle = NSLocalizedString("homeviewcontroller.newparkingsubtitle", comment: "")
        static let newparkingbutton = NSLocalizedString("homeviewcontroller.newparkingbutton",comment: "")
        static let lastparked = NSLocalizedString("homeviewcontroller.lastparked", comment: "")
        static let lastparkedlocation = NSLocalizedString("homeviewcontroller.lastparkedlocation", comment: "")
        static let lastparkedlocationdetail = NSLocalizedString("homeviewcontroller.lastparkedlocationdetail", comment: "")
        static let viewdetails = NSLocalizedString("homeviewcontroller.viewdetails",comment: "")
        static let parkduration = NSLocalizedString("homeviewcontroller.parkduration",comment: "")
        static let durationFormat = NSLocalizedString("homeviewcontroller.durationformat", comment: "duration format")


    }
    func loadPark(with request :NSFetchRequest<Park> = Park.fetchRequest()){



            do{
               parkList = try context.fetch(request)

            }
            catch{
                print("Error fetching data \(error)")
            }

        }
    func addBannerViewToView(_ bannerView: GADBannerView) {
       bannerView.translatesAutoresizingMaskIntoConstraints = false
       view.addSubview(bannerView)
        bannerView.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
            make.centerX.equalToSuperview()
        }
      }

}

extension HomeViewController: GADBannerViewDelegate{
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
    HomeViewController()
}
