//
//  FilmographyPreviewCollectionViewCell.swift
//  Kinopoisk
//
//  Created by Дмитрий Х on 20.04.2020.
//  Copyright © 2020 Yandex. All rights reserved.
//

import UIKit

final class FilmographyPreviewCollectionViewCell: BaseCollectionViewCell {
    private var imageView: UIImageView!
	private var actorNameLabel: UILabel!
    private var resizableView: UIView!
    private var backgroundContainerView: UIView!
    private var backgroundImageView: UIImageView!
    
    private var gradientLayers: [CALayer] = []
    
    override var viewForFocusResizing: UIView? {
        return self.resizableView
    }
    
    override var viewForResizingFocusWidthDiff: CGFloat {
        return 38
    }
    
    private static let placeholderImage = UIImage(named: "ActorsItemPlaceholderImage")?
        .resizedAspectFit(to: CGSize(width: 343, height: 511))
    
    override func prepareUI() {
        self.backgroundContainerView = UIView(forAutoLayout: ())
        self.contentView.addSubviewWithSimpleLayout(self.backgroundContainerView)
        self.backgroundImageView = UIImageView(forAutoLayout: ())
        self.backgroundContainerView.addSubviewWithSimpleLayout(self.backgroundImageView)
        let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .light))
        self.backgroundContainerView.addSubviewWithSimpleLayout(blurView)
        
        self.addLeftGradient()
        self.addBottomGradient()
        
        self.resizableView = UIView(forAutoLayout: ())
        self.resizableView.layer.zPosition = 100
        self.contentView.addSubview(self.resizableView)
        self.resizableView.autoSetDimensions(to: CGSize(width: 343, height: 511))
        self.resizableView.autoCenterInSuperview()
        
        let viewForGlowViewContainer = UIView(forAutoLayout: ())
        viewForGlowViewContainer.cornerRadius = 12
        viewForGlowViewContainer.backgroundColor = UIColor.KinopoiskColors.lightGray
        self.viewForGlowViewContainer = viewForGlowViewContainer
        self.resizableView.addSubviewWithSimpleLayout(viewForGlowViewContainer)
        
        self.imageView = UIImageView(forAutoLayout: ())
        self.imageView.cornerRadius = 12
        self.imageView.contentMode = .scaleAspectFill
        viewForGlowViewContainer.addSubviewWithSimpleLayout(self.imageView)
		
		self.actorNameLabel = UILabel(forAutoLayout: ())
		self.actorNameLabel.textAlignment = .center
		self.actorNameLabel.font = UIFont.kinopoiskFont(ofSize: 48, weight: .regular)
		self.resizableView.addSubview(self.actorNameLabel)
		
		self.actorNameLabel.autoSetDimensions(to: CGSize(width: 800, height: 56))
        self.actorNameLabel.autoPinEdge(.top, to: .bottom, of: viewForGlowViewContainer, withOffset: 24)
        self.actorNameLabel.autoAlignAxis(.vertical, toSameAxisOf: viewForGlowViewContainer)
    }
    
    override func didEndDisplay() {
        super.didEndDisplay()
        self.imageView.setImage(with: nil)
    }
    
    private func makeAndAddGradientLayerToBackgroundImageView() -> CAGradientLayer {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = self.backgroundContainerView.bounds
        self.backgroundContainerView.layer.addSublayer(gradientLayer)
        self.gradientLayers.append(gradientLayer)
        gradientLayer.opacity = 0.75
        return gradientLayer
    }
    
    private func addLeftGradient() {
        let layer = self.makeAndAddGradientLayerToBackgroundImageView()
        layer.startPoint = CGPoint(x: 0, y: 0)
        layer.endPoint = CGPoint(x: 1, y: 0)
        
        layer.locations = [0, 0.0922, 0.1876, 0.2848, 0.3819, 0.4775, 0.5699, 0.6575, 0.7387, 0.8118, 0.8752, 0.9274, 0.9666, 0.9914, 1]
        let color = UIColor.black
        let colorAlphas: [CGFloat] = [1, 0.984314, 0.945098, 0.882353, 0.8, 0.709804, 0.607843, 0.501961, 0.392157, 0.290196, 0.2, 0.117647, 0.054902, 0.0156863, 0.0001]
        layer.colors = colorAlphas.map({ color.withAlphaComponent($0).cgColor })
    }
    
    private func addBottomGradient() {
        let layer = self.makeAndAddGradientLayerToBackgroundImageView()
        layer.startPoint = CGPoint(x: 0, y: 0)
        layer.endPoint = CGPoint(x: 0, y: 1)
        
        layer.locations = [0, 0.6219, 0.6435, 0.6676, 0.6938, 0.7216, 0.7507, 0.7806, 0.8109, 0.8412, 0.8712, 0.9002, 0.9281, 0.9542, 0.9784, 1]
        let color = UIColor.black
        let colorAlphas: [CGFloat] = [0.0001, 0.0001, 0.0588235, 0.121569, 0.192157, 0.262745, 0.341176, 0.419608, 0.501961, 0.580392, 0.658824, 0.737255, 0.807843, 0.878431, 0.941176, 1]
        layer.colors = colorAlphas.map({ color.withAlphaComponent($0).cgColor })
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.gradientLayers.forEach({ $0.frame = self.backgroundContainerView.bounds })
    }
}

extension FilmographyPreviewCollectionViewCell: ReusableComponent {
    static let reusableIdentifier: String = makeDefaultReusableIdentifier()
}

extension FilmographyPreviewCollectionViewCell: ConfigurableComponent {
    func configure(with object: Any) {
        guard let model = object as? ShowcaseSelectionPreviewViewModel else { return }
        self.imageView.setImage(with: model.image, placeholder: FilmographyPreviewCollectionViewCell.placeholderImage.map({ .image($0) }))
        self.backgroundImageView.setImage(with: model.backgroundImage)
		self.actorNameLabel.text = model.title
    }
}

extension FilmographyPreviewCollectionViewCell: CollectionViewItemsSizeProvider {
    static func size(for item: Any?, collectionViewSize: CGSize) -> CGSize {
        return collectionViewSize
    }
}

extension FilmographyPreviewCollectionViewCell: CollectionViewItemPreferredOffsetProvider {
    static func preferredOffset(for collectionView: UICollectionView, attributes: UICollectionViewLayoutAttributes, object: Any) -> CGPoint? {
        let y = attributes.frame.minY - collectionView.contentInset.top
        
        return CGPoint(x: 0, y: y)
    }
}
