//
//  ViewController.swift
//  ParkEasy
//
//  Created by Emre Tuğ on 30.10.2023.
//

import UIKit
import SnapKit
class WelcomeViewController: UIViewController {
    
    private lazy var welcomeImageView :UIImageView = {
        var imageView = UIImageView(image: .icons8Car64)
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleToFill
        imageView.layer.cornerRadius = (imageView.frame.size.height)/2
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private lazy var welcomeTitleLabel:UILabel = {
        var label = UILabel()
        label.text = "ParkEasy!"
        label.font = .systemFont(ofSize: 50)
        label.textColor = .black
        return label
    }()
    private lazy var welcomeSubtitleLabel:UILabel = {
        var label = UILabel()
        label.text = LocalizedString.welcomesubtitle
        label.textColor = .black
        label.font = .systemFont(ofSize: 20)
        return label
    }()
 
   
    private lazy var welcomeButton : UIButton = {
        var uibutton = UIButton()
        uibutton.setTitle(LocalizedString.welcomebutton, for: .normal)
        uibutton.layer.cornerRadius = 10
        uibutton.addAction(action, for: .touchUpInside)
        uibutton.backgroundColor = .main
        return uibutton
    }()
    lazy var action :UIAction = UIAction{_ in
        UserDefaults.standard.set(false, forKey: "isFirstOpen")
        let tabvc = MyTabBarController()
        self.navigationController?.pushViewController(tabvc, animated: true)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        view.addSubview(welcomeImageView)
        view.addSubview(welcomeTitleLabel)
        view.addSubview(welcomeSubtitleLabel)
        view.addSubview(welcomeButton)
       
      

        welcomeImageView.snp.makeConstraints { make in
            let offsetFromTop = view.frame.height * 0.2
            make.height.equalTo(150)
            make.width.equalTo(150)
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(offsetFromTop)
        }
        welcomeTitleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(welcomeImageView.snp.bottom ).offset(80)
        }
        welcomeSubtitleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(welcomeTitleLabel.snp.bottom ).offset(10)
        }
        welcomeButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-20)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
            make.height.equalTo(50)
            
        }
        // Do any additional setup after loading the view.
    }
    
    class LocalizedString{
        static let welcomebutton = NSLocalizedString("welcomeviewcontroller.welcomebutton", comment: "")
        static let welcomesubtitle = NSLocalizedString("welcomeviewcontroller.subtitle", comment: "")

    }
}


extension UIImage {
       func imageWithColor(tintColor: UIColor) -> UIImage {
           UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)

           let context = UIGraphicsGetCurrentContext()!
           context.translateBy(x: 0, y: self.size.height)
           context.scaleBy(x: 1.0, y: -1.0);
           context.setBlendMode(.normal)

           let rect = CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height) as CGRect
           context.clip(to: rect, mask: self.cgImage!)
           tintColor.setFill()
           context.fill(rect)

           let newImage = UIGraphicsGetImageFromCurrentImageContext()!
           UIGraphicsEndImageContext()

           return newImage
       }
   }
extension UIImage {
  func withBackground(color: UIColor, opaque: Bool = true) -> UIImage {
    UIGraphicsBeginImageContextWithOptions(size, opaque, scale)
        
    guard let ctx = UIGraphicsGetCurrentContext(), let image = cgImage else { return self }
    defer { UIGraphicsEndImageContext() }
        
    let rect = CGRect(origin: .zero, size: size)
    ctx.setFillColor(color.cgColor)
    ctx.fill(rect)
    ctx.concatenate(CGAffineTransform(a: 1, b: 0, c: 0, d: -1, tx: 0, ty: size.height))
    ctx.draw(image, in: rect)
        
    return UIGraphicsGetImageFromCurrentImageContext() ?? self
  }
}
#Preview{
    WelcomeViewController()
}
