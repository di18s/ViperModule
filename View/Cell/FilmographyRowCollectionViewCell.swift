//
//  FilmographyRowCollectionViewCell.swift
//  Kinopoisk
//
//  Created by Дмитрий Х on 17.04.2020.
//  Copyright © 2020 Yandex. All rights reserved.
//

import UIKit

final class FilmographyFilmsCollectionViewAdapter: BaseCollectionViewAdapter<NeverHeader, NeverFooter, ShowcaseFilmItemViewModel> {
	
}

final class FilmographyRowCollectionViewCell: CollectionViewCellWithCollection {
    private lazy var adapter: FilmographyFilmsCollectionViewAdapter = {
        let adapter = FilmographyFilmsCollectionViewAdapter(cellClasses: [ShowcaseFilmCollectionViewCell.self])
        adapter.output = self
        return adapter
    }()
	
    private var titleLabel: UILabel!
    private var labelContainer: UIView!
	    
    override var contentOffset: CGPoint? {
        didSet {
            self.adapter.contentOffsetForUpdate = self.contentOffset
        }
    }
    
    override var indexPathToFocus: IndexPath? {
        didSet {
            self.adapter.indexPathToFocus = self.indexPathToFocus
			
        }
    }
	
    override func prepareUI() {
        super.prepareUI()
		
		self.titleLabel = UILabel(forAutoLayout: ())
        self.titleLabel.font = UIFont.kinopoiskFont(ofSize: 32, weight: .semibold)
        self.titleLabel.textColor = .white
        self.labelContainer = UIView(forAutoLayout: ())
        self.labelContainer.addSubview(self.titleLabel)
		self.titleLabel.autoPinEdge(toSuperviewEdge: .top, withInset: 24)
        self.titleLabel.autoPinEdge(toSuperviewEdge: .leading, withInset: 250)
        self.labelContainer.autoSetDimension(.height, toSize: 96)
        
        self.collectionView.autoSetDimension(.height, toSize: 212)
        
        let stackView = UIStackView(forAutoLayout: ())
        stackView.axis = .vertical
        stackView.addArrangedSubview(self.labelContainer)
        stackView.addArrangedSubview(self.collectionView)
        self.contentView.addSubview(stackView)
        stackView.autoPinEdgesToSuperviewEdges(with: .zero, excludingEdge: .bottom)
        
        self.accessibilityElements = [self.collectionView as Any]
        self.accessibilityHeaderElements = [self.titleLabel as Any]
        self.titleLabel.isAccessibilityElement = false
    }
    
    override func setupCollectionView() {
        self.collectionView.contentInset = UIEdgeInsets(top: 0, left: 250, bottom: 0, right: 90)
        (self.collectionView.collectionViewLayout as? UICollectionViewFlowLayout)?.minimumLineSpacing = 24
        self.adapter.collectionView = self.collectionView
    }
}

extension FilmographyRowCollectionViewCell: ReusableComponent {
    static let reusableIdentifier: String = makeDefaultReusableIdentifier()
}

extension FilmographyRowCollectionViewCell: CollectionViewItemsSizeProvider {
    static func size(for item: Any?, collectionViewSize: CGSize) -> CGSize {
        guard let model = item as? FilmographySelectionViewModel else { return .zero }
		let hideTitle = model.title.isEmpty
        
        if hideTitle {
            return CGSize(width: collectionViewSize.width, height: 228)
        } else {
            return CGSize(width: collectionViewSize.width, height: 324)
        }
    }
}

extension FilmographyRowCollectionViewCell: ConfigurableComponent {
    func configure(with object: Any) {
        guard let model = object as? FilmographySelectionViewModel else { return }
		
		self.titleLabel.text = model.title
        self.adapter.updateData(with: [SectionData(collectionElementIdentifier: "Default", objects: model.items)])
    }
}

extension FilmographyRowCollectionViewCell: CollectionViewItemPreferredOffsetProvider {
    class func preferredOffset(for collectionView: UICollectionView, attributes: UICollectionViewLayoutAttributes, object: Any) -> CGPoint? {
        let y = attributes.frame.minY - collectionView.contentInset.top
        
        return CGPoint(x: 0, y: y)
    }
}
