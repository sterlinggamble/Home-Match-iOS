//
//  ImagePickerViewController.swift
//  Home Match
//
//  Created by Sterling Gamble on 4/7/21.
//

import UIKit
import AlamofireImage

protocol ImageSelectionDelegate {
    func pickedImage(url: String)
}

class ImagePickerViewController: UIViewController {
    private let textFieldLine: CALayer = {
        let line = CALayer()
        line.backgroundColor = #colorLiteral(red: 0.7764705882, green: 0.7764705882, blue: 0.7843137255, alpha: 1)
        return line
    }()
    
    private let textField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Enter image URL"
        textField.borderStyle = .none
        return textField
    }()
    
    private let addButton: UIButton = {
        let button = UIButton()
        button.tintColor = .systemBlue
//        let image = UIImage(systemName: "plus.circle")
//        image?.size = CGSize(width: 24, height: 26)
        button.setImage(UIImage(systemName: "plus.circle"), for: .normal)
        
        return button
    }()
    
    let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 8
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    let defaultImageView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 8
        view.backgroundColor = .lightGray
        return view
    }()
    
    var selectionDelegate: ImageSelectionDelegate!
    
    var url: String?

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        navigationController?.navigationBar.backgroundColor = .white
        navigationController?.navigationBar.shadowImage = nil
        
        addButton.addTarget(self, action: #selector(addImage), for: .touchUpInside)
        
        textFieldLine.frame = CGRect(x: 0, y: 37, width: view.bounds.width, height: 1)
        textField.frame = CGRect(x: 16, y: 25, width: view.bounds.width-53, height: 36)
        addButton.frame = CGRect(x: textField.bounds.width+21, y: 25, width: 30, height: 32)
        defaultImageView.frame = CGRect(x: 15, y: 85, width: view.bounds.width-30, height: 230)
        imageView.frame = defaultImageView.bounds
        
        textField.layer.addSublayer(textFieldLine)
        view.addSubview(textField)
        view.addSubview(addButton)
        defaultImageView.addSubview(imageView)
        view.addSubview(defaultImageView)
        
    }
    
    @objc func addImage() {
        guard let urlString = textField.text else {
            return
        }
        
        imageView.af.setImage(withURL: URL(string: urlString)!)
        selectionDelegate.pickedImage(url: urlString)
        
    }
    
    

   

}
