//
//  MediaCollectionViewCell.swift
//  CastledNotificationContent
//
//  Created by antony on 18/05/2023.
//
import UIKit
import AVFoundation
import SDWebImage

internal class CastledMediaCollectionViewCell: UICollectionViewCell {
    
    static let reuseIdentifier = "MediaCell"
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private let videoPlayerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        label.shadowColor = .black
        label.shadowOffset = CGSize(width: 1, height: 1)
        label.textAlignment = .left
        label.numberOfLines = 2
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.shadowColor = .black
        label.shadowOffset = CGSize(width: 1, height: 1)
        label.textAlignment = .left
        label.numberOfLines = 2
        return label
    }()
    
    private var player: AVPlayer?
    private var playerLayer: AVPlayerLayer?
    private let playPauseButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let playImage = UIImage(named: "playbtn", in: Bundle.resourceBundle(for: CastledMediaCollectionViewCell.self), compatibleWith: nil)!
    let pauseImage = UIImage(named: "pausebtn", in: Bundle.resourceBundle(for: CastledMediaCollectionViewCell.self),compatibleWith: nil)!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(imageView)
        contentView.addSubview(videoPlayerView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(subtitleLabel)
        contentView.addSubview(playPauseButton)
        playPauseButton.setImage(pauseImage, for: .normal)
        playPauseButton.addTarget(self, action: #selector(playPauseButtonTapped(_:)), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            videoPlayerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            videoPlayerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            videoPlayerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            videoPlayerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            titleLabel.bottomAnchor.constraint(equalTo: subtitleLabel.topAnchor, constant: -5),
            
            subtitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            subtitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            subtitleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
            
            playPauseButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            playPauseButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            playPauseButton.topAnchor.constraint(equalTo: contentView.topAnchor),
            playPauseButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
        ])
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        player?.pause()
        removePlayerItems()
        
    }
    
    internal func configure(with mediaViewModel: CastledNotificationMediaObject) {
        titleLabel.text = mediaViewModel.title
        subtitleLabel.text = mediaViewModel.subTitle
        
        //  imageView.image = nil
        
        let urlImageString = mediaViewModel.thumbUrl
        if let url = URL(string: urlImageString) {
            
            imageView.sd_setImage(with: url, completed: nil)
            /**URLSession.downloadImage(atURL: url) { [weak self] (data, error) in
             if let data = data{
             DispatchQueue.main.async { [weak self] in
             self?.imageView.image = UIImage(data: data)
             }
             }
             
             }*/
        }
        else
        {
            imageView.image = nil
        }
        
        switch mediaViewModel.mediaType {
        case .image:
            // Configure image view
            imageView.isHidden = false
            videoPlayerView.isHidden = true
            playPauseButton.isHidden = true
            
            // imageView.sd_setImage(with: imageURL, completed: nil)
            
        case .video,.audio:
            // Configure video player
            imageView.isHidden = false
            playPauseButton.isHidden = false
            videoPlayerView.isHidden = false
            
            // Create AVPlayerItem with video URL
            guard let videoUrl = URL(string: mediaViewModel.mediaUrl) else {
                imageView.isHidden = false
                return }
            let playerItem = AVPlayerItem(url: videoUrl)
            // Create AVPlayer with player item
            player = AVPlayer(playerItem: playerItem)
            
            // Create AVPlayerLayer and add to videoPlayerView's layer
            playerLayer = AVPlayerLayer(player: player)
            playerLayer?.videoGravity = .resizeAspectFill
            videoPlayerView.layer.addSublayer(playerLayer!)
            
            if mediaViewModel.mediaType == .video{
                playerItem.addObserver(self, forKeyPath: #keyPath(AVPlayerItem.status), options: .new, context: nil)
                imageView.isHidden = true
                
            }
            else{
                imageView.isHidden = false
                
            }
            
            NotificationCenter.default.addObserver(self, selector: #selector(playerDidFinishPlaying), name: .AVPlayerItemDidPlayToEndTime, object: playerItem)
            
            
        case .none:
            break
        }
    }
    
    @objc private func playerDidFinishPlaying(notification: Notification) {
        guard let playerItem = notification.object as? AVPlayerItem else { return }
        playerItem.seek(to: .zero, completionHandler: nil)
        player?.play()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Update playerLayer's frame when the cell's layout changes
        DispatchQueue.main.async { [self] in
            playerLayer?.frame = videoPlayerView.bounds
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?,
                               of object: Any?,
                               change: [NSKeyValueChangeKey: Any]?,
                               context: UnsafeMutableRawPointer?) {
        if keyPath == #keyPath(AVPlayerItem.status),
           let statusNumber = change?[.newKey] as? NSNumber,
           let status = AVPlayerItem.Status(rawValue: statusNumber.intValue) {
            switch status {
            case .readyToPlay:
                // Player item is ready to play
                imageView.isHidden = true
                
                //  player?.play()
            case .failed:
                // Player item failed to load or play
                // Handle error if needed
                imageView.isHidden = false
                
                break
            case .unknown:
                // Player item is in an unknown state
                break
            @unknown default:
                break
            }
        }
    }
    
    @objc func playPauseButtonTapped(_ sender:UIButton) {
        if player?.rate == 0{
            playVideo()
        } else {
            pauseVideo()
        }
    }
    
    internal func playVideo() {
        player?.play()
        playPauseButton.setImage(pauseImage, for: .normal)
    }
    
    internal func pauseVideo() {
        player?.pause()
        playPauseButton.setImage(playImage, for: .normal)
    }
    
    internal func removePlayerItems(){
        if player == nil{
            return
        }
        player?.pause()
        
        playerLayer?.removeFromSuperlayer()
        if let playerItem = player?.currentItem {
            if playerItem.observationInfo != nil {
                playerItem.removeObserver(self, forKeyPath: #keyPath(AVPlayerItem.status))
            }
        }
        
        NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: player?.currentItem)
        
        player = nil
        playerLayer = nil
    }
    
    deinit {
        removePlayerItems()
    }
}

extension Bundle {

    static func resourceBundle(for bundleClass: AnyClass) -> Bundle {

        let mainBundle = Bundle.main
        let sourceBundle = Bundle(for: bundleClass)
        guard let moduleName = String(reflecting: bundleClass).components(separatedBy: ".").first else {
            fatalError("Couldn't determine module name from class \(bundleClass)")
        }
        // SPM
        var bundle: Bundle?
        if let bundlePath = mainBundle.path(forResource: "\(bundleClass)_Castled", ofType: "bundle") {
            bundle = Bundle(path: bundlePath)
        }
        if bundle == nil,let bundlePath = mainBundle.path(forResource: "\(moduleName)_Castled", ofType: "bundle") {
            bundle = Bundle(path: bundlePath)
        }
        if bundle == nil,let bundlePath = mainBundle.path(forResource: "\(bundleClass)-Castled", ofType: "bundle") {
            bundle = Bundle(path: bundlePath)
        }
        if bundle == nil,let bundlePath = sourceBundle.path(forResource: "\(bundleClass)-Castled", ofType: "bundle") {
            bundle = Bundle(path: bundlePath)
        }
        if bundle == nil,let bundlePath = sourceBundle.path(forResource: "Castled", ofType: "bundle") {
            bundle = Bundle(path: bundlePath)
        }
        if bundle == nil,let bundlePath = mainBundle.path(forResource: "Castled", ofType: "bundle") {
            bundle = Bundle(path: bundlePath)
        }
        // CocoaPods (static)
        if bundle == nil, let staticBundlePath = mainBundle.path(forResource: moduleName, ofType: "bundle") {
            bundle = Bundle(path: staticBundlePath)
        }

        // CocoaPods (framework)
        if bundle == nil, let frameworkBundlePath = sourceBundle.path(forResource: moduleName, ofType: "bundle") {
            bundle = Bundle(path: frameworkBundlePath)
        }
        return bundle ?? sourceBundle
    }
}
