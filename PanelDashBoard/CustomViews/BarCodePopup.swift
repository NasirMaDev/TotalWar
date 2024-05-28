//
//  BarCodePopup.swift
//  PanelDashBoard
//
//  Created by Nasir Bin Tahir on 28/05/2024.
//  Copyright © 2024 Asjd. All rights reserved.
//

import Foundation
import UIKit

class BarCodePopup: UIView {

    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.minimumScaleFactor = 0.5
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let messageLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let buttonStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 10
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    private let mainStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.distribution = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    init(image: UIImage?, title: String, message: String, buttons: [UIButton]) {
        super.init(frame: .zero)
        setupView(image: image, title: title, message: message, buttons: buttons)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView(image: UIImage?, title: String, message: String, buttons: [UIButton]) {
        self.backgroundColor = .white
        self.layer.cornerRadius = 15
        self.layer.masksToBounds = true

        if let image = image {
            imageView.image = image
            mainStackView.addArrangedSubview(imageView)
        }

        titleLabel.text = title
        messageLabel.text = message

        mainStackView.addArrangedSubview(titleLabel)
        mainStackView.addArrangedSubview(messageLabel)
        mainStackView.addArrangedSubview(buttonStackView)

        for button in buttons {
            buttonStackView.addArrangedSubview(button)
        }

        addSubview(mainStackView)
        setupConstraints()
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            mainStackView.topAnchor.constraint(equalTo: self.topAnchor, constant: 20),
            mainStackView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20),
            mainStackView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20),
            mainStackView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -20),

            imageView.widthAnchor.constraint(equalToConstant: 100),
            imageView.heightAnchor.constraint(equalToConstant: 100)
        ])
    }
}
