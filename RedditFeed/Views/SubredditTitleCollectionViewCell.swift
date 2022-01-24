//
//  SubredditTitleCollectionViewCell.swift
//  RedditFeed
//
//  Created by Farid Kopzhassarov on 24/01/2022.
//

import UIKit
import AVFoundation

class SubredditTitleCollectionViewCell: UICollectionViewCell {
    let label: UILabel = {
        let label: UILabel = .init()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = .secondarySystemBackground
        label.textColor = .label

        return label
    }()

    override class var requiresConstraintBasedLayout: Bool {
        return true
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupView()
        setupLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        label.text = nil
    }
}

extension SubredditTitleCollectionViewCell {
    func setupTitle(_ title: String) {
        label.text = title
    }

    private func setupView() {
        backgroundColor = .secondarySystemBackground
        layer.cornerRadius = 8
        clipsToBounds = true
        contentView.backgroundColor = .secondarySystemBackground

        contentView.addSubview(label)
    }

    private func setupLayout() {
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            label.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            label.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8)
        ])
    }
}

