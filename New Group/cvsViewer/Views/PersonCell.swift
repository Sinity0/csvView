//
//  PersonCell.swift
//  cvsViewer
//
//  Created by Evgeny Mikhalkov on 03/12/2024.
//

import UIKit
import SnapKit

final class PersonCell: UITableViewCell {
    static let identifier = "PersonCell"
    
    private let profileImageView = UIImageView()
    private let nameLabel = UILabel()
    private let issueCountLabel = UILabel()
    private let dobLabel = UILabel()
    private let labelsStackView = UIStackView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    func configure(with person: Person) {
        nameLabel.text = "\(person.firstName) \(person.surName)"
        issueCountLabel.text = "Issues: \(person.issueCount)"
        
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        dobLabel.text = formatter.string(from: person.dateOfBirth)
    }
}

//MARK: - Private API

private extension PersonCell {
    func setup() {
        profileImageView.image = UIImage(systemName: "person.crop.circle")
        profileImageView.contentMode = .scaleAspectFit
        profileImageView.tintColor = .gray
        profileImageView.clipsToBounds = true
        
        nameLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        issueCountLabel.font = UIFont.systemFont(ofSize: 14)
        dobLabel.font = UIFont.systemFont(ofSize: 10)
        dobLabel.textColor = .gray
        
        labelsStackView.axis = .vertical
        labelsStackView.alignment = .leading
        labelsStackView.spacing = 4
        labelsStackView.addArrangedSubview(nameLabel)
        labelsStackView.addArrangedSubview(issueCountLabel)
        labelsStackView.addArrangedSubview(dobLabel)

        contentView.addSubview(profileImageView)
        contentView.addSubview(labelsStackView)
        layout()
    }
    
    func layout() {
        profileImageView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(8)
            make.bottom.equalToSuperview().offset(-8)
            make.width.height.equalTo(64)
        }
        
        labelsStackView.snp.makeConstraints { make in
            make.left.equalTo(profileImageView.snp.right).offset(8)
            make.right.equalToSuperview().offset(-8)
            make.centerY.equalToSuperview()
        }
    }
}
