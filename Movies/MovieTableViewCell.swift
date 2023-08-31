//
//  MovieTableViewCell.swift
//  Movies
//
//  Created by Shreeram Bhat on 11/08/23.
//

import UIKit
//import SDWebImage

class MovieTableViewCell: UITableViewCell {
    
    var firstImageView = AsyncImageView()
    var secondImageView = AsyncImageView()

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.addUI()
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.addUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        self.addUI()
    }
    
    private func addUI() {
//        let nameLabel = UILabel()
//        nameLabel.text = "Movie"
//        nameLabel.textColor = .black
//        self.contentView.addSubview(nameLabel)
        
//        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 16
        stackView.distribution = .fillEqually
        
        let firstImageView = AsyncImageView()
        let secondImageView = AsyncImageView()
        self.firstImageView = firstImageView
        self.secondImageView = secondImageView
        
        stackView.addArrangedSubview(firstImageView)
        stackView.addArrangedSubview(secondImageView)
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        self.contentView.addSubview(stackView)
        
        NSLayoutConstraint.activate([
//            nameLabel.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 16),
//            nameLabel.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor),
//            nameLabel.topAnchor.constraint(equalTo: self.contentView.topAnchor),
            
            stackView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -16),
            stackView.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant:  16),
            stackView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -16)
        ])
    }
    
    func configureCell(firstPath: String, secondPath: String) {
        let prefixPath = "https://image.tmdb.org/t/p/w500"
//        self.firstImageView.sd_setImage(with: URL(string: prefixPath + firstPath))
//        self.secondImageView.sd_setImage(with: URL(string: prefixPath + secondPath))
        if let firstUrl =  URL(string: prefixPath + firstPath) {
            self.firstImageView.downLoadFrom(url: firstUrl)
        }
        if let secondUrl = URL(string: prefixPath + secondPath) {
            self.secondImageView.downLoadFrom(url: secondUrl)
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
