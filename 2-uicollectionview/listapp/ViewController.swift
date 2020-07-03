//
//  ViewController.swift
//  listapp
//
//  Created by Daniel on 7/3/20.
//  Copyright © 2020 dk. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    var collectionView: UICollectionView?
    var dataSource: [Show] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "UICollectionView - iOS 6"

        // Setup collection view
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .white
        cv.register(ShowCell.self, forCellWithReuseIdentifier: ShowCell.reuseIdentifier)
        cv.dataSource = self
        cv.delegate = self

        // Display collection view
        cv.frame = view.bounds
        view.addSubview(cv)

        collectionView = cv

        // Load data
        let urlString = "https://api.tvmaze.com/shows"
        guard let url = URL(string: urlString) else { return }
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard
                let data = data,
                let shows = try? JSONDecoder().decode([Show].self, from: data) else { return }

            self.dataSource = shows

            DispatchQueue.main.async {
                self.collectionView?.reloadData()
            }
        }.resume()
    }
}

extension ViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ShowCell.reuseIdentifier, for: indexPath) as? ShowCell else { fatalError("Cannot create new cell") }

        let show = dataSource[indexPath.row]
        cell.titleLabel.text = show.name
        cell.subtitleLabel.text = show.subtitle

        return cell
    }
}

extension ViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var size = view.bounds.size
        size.height = 210/2
        return size
    }
}

class ShowCell: UICollectionViewCell {
    static let reuseIdentifier = "ShowCell"

    let titleLabel = UILabel ()
    let subtitleLabel = UILabel ()

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        setup()
    }

    func setup() {
        titleLabel.numberOfLines = 0

        subtitleLabel.font = .preferredFont(forTextStyle: .caption1)
        subtitleLabel.numberOfLines = 4
        subtitleLabel.textColor = .secondaryLabel

        [titleLabel, subtitleLabel].forEach {
            contentView.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        let inset: CGFloat = 20
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 0),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: inset),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -inset),

            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor),
            subtitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            subtitleLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            subtitleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5),
        ])
    }
}

struct Show: Codable {
    let name, status, premiered, summary: String
}

extension Show {
    var subtitle: String {
        return premiered + "\n" + status + summary
            .replacingOccurrences(of: "<p>", with: "\n")
            .replacingOccurrences(of: "</p>", with: "\n")
            .replacingOccurrences(of: "<b>", with: "")
            .replacingOccurrences(of: "</b>", with: "")
    }
}
