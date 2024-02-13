//
//  ConversationCell.swift
//  DualBit
//
//  Created by Georgi Popov on 8.02.24.

import UIKit
import Firebase


class ConversationCell: UITableViewCell {
    let profilePicturePlaceholder: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 20 // Half of the width and height
        view.clipsToBounds = true
        view.backgroundColor = .lightGray // Set a placeholder color
        return view
    }()
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let initialLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        addSubview(profilePicturePlaceholder)
        profilePicturePlaceholder.addSubview(initialLabel)
        
        // Constraints for profilePicturePlaceholder
        NSLayoutConstraint.activate([
            profilePicturePlaceholder.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            profilePicturePlaceholder.centerYAnchor.constraint(equalTo: centerYAnchor),
            profilePicturePlaceholder.widthAnchor.constraint(equalToConstant: 40),
            profilePicturePlaceholder.heightAnchor.constraint(equalToConstant: 40),
            
            // Constraints for initialLabel
            initialLabel.centerXAnchor.constraint(equalTo: profilePicturePlaceholder.centerXAnchor),
            initialLabel.centerYAnchor.constraint(equalTo: profilePicturePlaceholder.centerYAnchor)
        ])
    }
    
    func configure(with conversation: Conversation) {
        initialLabel.text = String(conversation.userName.first ?? "U")
        nameLabel.text = conversation.userName
        // Additional configuration for nameLabel and the cell
    }
}

