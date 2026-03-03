//
//  HomeVC.swift
//  We&Movie
//
//  Created by Maxim Bondarev on 16/1/26.
//

import UIKit

class HomeVC: BaseVC {

    private let viewModel: VM
    private weak var coordinator: HomeCoordinator?

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Кинотека"
        label.font = .systemFont(ofSize: 32, weight: .bold)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 8
        layout.minimumLineSpacing = 12
        layout.sectionInset = UIEdgeInsets(top: 8, left: 12, bottom: 24, right: 12)

        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        cv.showsVerticalScrollIndicator = true
        cv.alwaysBounceVertical = true
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.delegate = self
        cv.dataSource = self
        cv.register(FilmCardCell.self, forCellWithReuseIdentifier: FilmCardCell.reuseId)
        cv.register(LoadingCell.self, forCellWithReuseIdentifier: LoadingCell.reuseId)
        return cv
    }()

    private let activityIndicator: UIActivityIndicatorView = {
        let ai = UIActivityIndicatorView(style: .medium)
        ai.hidesWhenStopped = true
        ai.translatesAutoresizingMaskIntoConstraints = false
        return ai
    }()

    init(coordinator: HomeCoordinator) {
        self.viewModel = VM()
        self.coordinator = coordinator
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewModel()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        Task { await viewModel.loadFilms() }
    }

    private func setupViewModel() {
        viewModel.onFilmsUpdated = { [weak self] in
            self?.collectionView.reloadData()
            if self?.viewModel.isLoading == true {
                self?.activityIndicator.startAnimating()
            } else {
                self?.activityIndicator.stopAnimating()
            }
        }
        viewModel.onError = { [weak self] error in
            self?.showError(error)
        }
    }

    override func setupUI() {
        super.setupUI()
        view.addSubviews(views: titleLabel, collectionView, activityIndicator)
    }

    override func setupConstraints() {
        super.setupConstraints()
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            collectionView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
}

// MARK: - UICollectionViewDataSource, UICollectionViewDelegateFlowLayout

extension HomeVC: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if viewModel.isLoading && viewModel.films.isEmpty {
            return 1
        }
        return viewModel.films.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if viewModel.isLoading && viewModel.films.isEmpty {
            return collectionView.dequeueReusableCell(withReuseIdentifier: LoadingCell.reuseId, for: indexPath)
        }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FilmCardCell.reuseId, for: indexPath) as! FilmCardCell
        let film = viewModel.films[indexPath.item]
        cell.configure(with: film)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = max(collectionView.bounds.width, view.bounds.width)
        if viewModel.isLoading && viewModel.films.isEmpty {
            return CGSize(width: max(width - 32, 0), height: 200)
        }
        let layout = collectionViewLayout as! UICollectionViewFlowLayout
        let horizontalInset = layout.sectionInset.left + layout.sectionInset.right
        let availableWidth = max(width - horizontalInset, 0)
        let spacingCount: CGFloat = 2  // 2 промежутка между 3 ячейками
        let cellWidth = (availableWidth - layout.minimumInteritemSpacing * spacingCount) / 3
        let imageAspect: CGFloat = 4 / 3
        let imageHeight = cellWidth / imageAspect
        let titleHeight: CGFloat = 36
        return CGSize(width: cellWidth, height: imageHeight + titleHeight)
    }
}

// MARK: - FilmCardCell

private final class FilmCardCell: UICollectionViewCell {

    static let reuseId = "FilmCardCell"

    private let imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.backgroundColor = .systemGray5
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .semibold)
        label.textColor = .label
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubviews(views: imageView, titleLabel)
        contentView.backgroundColor = .secondarySystemBackground

        contentView.layer.cornerRadius = 12
        contentView.layer.shadowColor = UIColor.black.cgColor
        contentView.layer.shadowOffset = CGSize(width: 0, height: 2)
        contentView.layer.shadowRadius = 4
        contentView.layer.shadowOpacity = 0.12

        imageView.layer.cornerRadius = 12
        imageView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]

        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor, multiplier: 3/4),

            titleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 4),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -4),
            titleLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -4)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with film: FilmPreview) {
        titleLabel.text = film.name
        if let imageBytes = film.image, !imageBytes.isEmpty {
            imageView.image = imageBytes.asImage
        } else {
            imageView.image = nil
            imageView.backgroundColor = .systemGray5
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
        titleLabel.text = nil
    }
}

// MARK: - LoadingCell

private final class LoadingCell: UICollectionViewCell {

    static let reuseId = "LoadingCell"

    private let activityIndicator: UIActivityIndicatorView = {
        let ai = UIActivityIndicatorView(style: .medium)
        ai.translatesAutoresizingMaskIntoConstraints = false
        return ai
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(activityIndicator)
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
        activityIndicator.startAnimating()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
