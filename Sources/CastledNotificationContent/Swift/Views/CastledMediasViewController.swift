//
//  CastledMediasViewController.swift
//  Castled
//
//  Created by antony on 17/05/2023.
//

import UIKit
@_spi(CastledInternal) import Castled

class CastledMediasViewController: UIViewController, CastledNotificationContentProtocol {
    var userDefaults: UserDefaults?
    private var mediaObjects: [CastledNotificationMediaObject]

    private let pageControl: UIPageControl = {
        let control = UIPageControl()
        control.translatesAutoresizingMaskIntoConstraints = false
        control.pageIndicatorTintColor = .lightGray
        control.hidesForSinglePage = true
        control.currentPageIndicatorTintColor = .black
        return control
    }()

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .clear
        collectionView.isPagingEnabled = true
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.isScrollEnabled = true
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 1)

        collectionView.register(CastledMediaCollectionViewCell.self, forCellWithReuseIdentifier: CastledMediaCollectionViewCell.reuseIdentifier)
        return collectionView
    }()

    init(mediaObjects: [CastledNotificationMediaObject]) {
        self.mediaObjects = mediaObjects
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(collectionView)
        view.addSubview(pageControl)
        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            pageControl.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -45)
        ])
        pageControl.numberOfPages = mediaObjects.count
    }

    func getContentSizeHeight() -> CGFloat {
        return view.frame.size.width
    }

    func populateDetailsFrom(notificaiton: UNNotification) {}
}

extension CastledMediasViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return mediaObjects.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CastledMediaCollectionViewCell.reuseIdentifier, for: indexPath) as! CastledMediaCollectionViewCell
        let mediaObject = mediaObjects[indexPath.row]
        cell.configure(with: mediaObject)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let mediaObject = mediaObjects[indexPath.row]
        if mediaObject.mediaType == .image {
            userDefaults?.setValue(indexPath.item, forKey: CastledPushMediaConstants.CastledClickedNotiContentIndx)
            userDefaults?.synchronize()
            extensionContext?.performNotificationDefaultAction()
        }
    }

    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let mediaObject = mediaObjects[indexPath.row]

        if let videoCell = cell as? CastledMediaCollectionViewCell, mediaObject.mediaType == .video || mediaObject.mediaType == .audio {
            videoCell.playVideo()
        }
    }

    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let videoCell = cell as? CastledMediaCollectionViewCell {
            videoCell.pauseVideo()
        }
    }
}

extension CastledMediasViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.bounds.size
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let pageWidth = scrollView.frame.size.width
        let currentPage = Int((scrollView.contentOffset.x + pageWidth / 2) / pageWidth)
        pageControl.currentPage = currentPage
    }
}
