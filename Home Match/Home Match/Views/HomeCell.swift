//
//  HomeCell.swift
//  Home Match
//
//  Created by Sterling Gamble on 4/6/21.
//

import UIKit

class HomeCell: UICollectionViewCell {
    static let identifier = "HomeCell"
    
    private var gradient: CAGradientLayer?
    
    let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    private let addressLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .systemFont(ofSize: 13, weight: .semibold)
        return label
    }()
    
    private let priceLabel: UILabel = {
        let label = UILabel()
        label.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.6)
        label.font = .systemFont(ofSize: 10, weight: .semibold)
        return label
    }()
    
    private let infoView: UIView = {
        let view = UIView()
        // can not load gradient in here, must be in layoutSubViews()
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.layer.cornerRadius = 8
        contentView.layer.masksToBounds = true
        
        contentView.addSubview(imageView)
        contentView.addSubview(infoView)
        contentView.addSubview(addressLabel)
        contentView.addSubview(priceLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        addressLabel.frame = CGRect(x: 6, y: contentView.bounds.height/2, width: contentView.bounds.width-12, height: contentView.bounds.height/2)
        priceLabel.frame = CGRect(x: 6, y: (contentView.bounds.height/2)+19, width: contentView.bounds.width-12, height: contentView.bounds.height/2)
        imageView.frame = contentView.bounds
        infoView.frame = CGRect(x: 0, y: contentView.bounds.height/2, width: contentView.bounds.width, height: contentView.bounds.height/2)
        
        // gradient will only display when defined in layoutSubviews()
        // must check if a gradient is already set so we dont duplicated when layoutSubviews() is called multiple times while scrolling
        if let gradient = gradient {
            gradient.frame = infoView.bounds
        } else {
            gradient = CAGradientLayer()
            gradient?.frame = infoView.bounds
            gradient?.colors = [UIColor.clear.cgColor, UIColor(red: 0.15, green: 0.07, blue: 0.06, alpha: 1.00).cgColor]
            infoView.layer.insertSublayer(gradient!, at: 0)
        }

    }
    
    func configure(with home: Home) {
        addressLabel.text = home.address
        priceLabel.text = home.price
        contentView.backgroundColor = .lightGray
    }
    
    
}
