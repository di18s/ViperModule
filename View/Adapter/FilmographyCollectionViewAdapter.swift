//
//  FilmographyCollectionViewAdapter.swift
//  Kinopoisk
//
//  Created by Дмитрий Х on 15.04.2020.
//  Copyright © 2020 Yandex. All rights reserved.
//

import Foundation

enum FilmographyViewModelType: CollectionIdentifiableElement {
    case preview(ShowcaseSelectionPreviewViewModel)
    case film(FilmographySelectionViewModel)
    
    var collectionElementIdentifier: String {
        switch self {
        case let .film(model):
            return model.collectionElementIdentifier
        case let .preview(model):
            return model.collectionElementIdentifier
        }
    }
}

protocol FilmographyCollectionViewAdapterInput: CollectionViewAdapterWithCellWithCollectionViewInput, ShowcaseCollectionVewAdapterPreviewAnimatableInput {
    
}

protocol FilmographyCollectionViewAdapterOutput: CollectionViewAdapterWithCellWithCollectionViewOutput {
    
}

final class FilmographyCollectionViewAdapter: CollectionViewAdapterWithCellWithCollectionView<NeverHeader, NeverFooter, FilmographyViewModelType>, FilmographyCollectionViewAdapterInput {	
    
	private var adapterOutput: FilmographyCollectionViewAdapterOutput? {
        return self.output as? FilmographyCollectionViewAdapterOutput
    }
	
    override init() {
        super.init()
		self.configureCellType = .dequeue
        self.cellClasses = [
            FilmographyRowCollectionViewCell.self,
            FilmographyPreviewCollectionViewCell.self
        ]
    }
    
    override func cellClass(for model: Any) -> ReusableAndRegistrableComponent.Type? {
        if model is ShowcaseSelectionPreviewViewModel {
            return FilmographyPreviewCollectionViewCell.self
        } else {
            return FilmographyRowCollectionViewCell.self
        }
    }

	override func object(at indexPath: IndexPath) -> Any {
        let object = super.object(at: indexPath)
        guard let model = object as? FilmographyViewModelType else { return object }
        switch model {
        case let .film(film):
			return film
        case let .preview(preview):
            return preview
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        super.collectionView(collectionView, willDisplay: cell, forItemAt: indexPath)
        
        self.prepareCellFade(for: cell, at: indexPath)
    }
    
    override func collectionView(_ collectionView: UICollectionView, didUpdateFocusIn context: UICollectionViewFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        super.collectionView(collectionView, didUpdateFocusIn: context, with: coordinator)
        
        self.updateVisibleCellsFading(for: collectionView, in: context, with: coordinator)
    }
    
    override func preferredCellOffset(for collectionView: UICollectionView, attributes: UICollectionViewLayoutAttributes, object: Any) -> CGPoint? {
        
        let y = attributes.frame.minY - collectionView.contentInset.top
        
        return CGPoint(x: 0, y: y)
    }
}

extension FilmographyCollectionViewAdapter: ShowcaseCollectionVewAdapterPreviewAnimatableTrait { }

extension FilmographyCollectionViewAdapter: ShowcaseCollectionViewAdapterFadingTrait {
    
    func shouldHidePreviousCells(for indexPath: IndexPath) -> Bool {
        return true
    }
}
