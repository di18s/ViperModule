//
//  FilmographyAdapterContainer.swift
//  Kinopoisk
//
//  Created by Дмитрий Х on 15.04.2020.
//  Copyright © 2020 Yandex. All rights reserved.
//

import UIKit

protocol FilmographyAdapterContainerInput: class {
    func setCollectionView(_ collectionView: UICollectionView)
    func updateCollection(with selectionViewModel: [FilmographySelectionViewModel]?, preview: ShowcaseSelectionPreviewViewModel)
    
    var indexPathToFocus: IndexPath? { get set }
    var itemIndexToFocus: Int? { get set }
    
    func focusToItem(at selectionIndexPath: IndexPath, item: Int?)
    func animateTransitionFromPreviewCell(in view: UIView)
    func animateSelectionInPreview(in view: UIView, onHighlight: @escaping () -> Void, completion: @escaping () -> Void)
}

final class FilmographyAdapterContainer<AdapterType: FilmographyCollectionViewAdapterInput>: FilmographyAdapterContainerInput where AdapterType.SectionHeader == NeverHeader, AdapterType.SectionFooter == NeverFooter, AdapterType.SectionItem == FilmographyViewModelType {
    
    private let adapter: AdapterType
    
    init(adapter: AdapterType) {
        self.adapter = adapter
    }
    
	var indexPathToFocus: IndexPath? {
        didSet {
            self.adapter.indexPathToFocus = self.indexPathToFocus
        }
    }
    
    var itemIndexToFocus: Int? {
        didSet {
            self.adapter.itemIndexPathToFocus = self.itemIndexToFocus.map({ IndexPath(item: $0, section: 0) })
        }
    }
	
    func setCollectionView(_ collectionView: UICollectionView) {
        self.adapter.collectionView = collectionView
    }
    
    func updateCollection(with selectionViewModel: [FilmographySelectionViewModel]?, preview: ShowcaseSelectionPreviewViewModel) {
		
		var sections: [SectionData<NeverHeader, NeverFooter, FilmographyViewModelType>] = []
		sections.append(SectionData(collectionElementIdentifier: "PreviewSection", objects: [.preview(preview)]))
		if let filmData = selectionViewModel {
			sections.append(SectionData(collectionElementIdentifier: "FilmsSection", objects: filmData.map({ .film($0) })))
		}
		
        self.adapter.updateData(with: sections, completion: { [weak self] in
            self?.adapter.collectionView?.setNeedsFocusUpdate()
            self?.adapter.collectionView?.updateFocusIfNeeded()
        })
    }
    
    func animateTransitionFromPreviewCell(in view: UIView) {
        self.adapter.animateTransitionFromPreview(in: view)
    }
    
    func animateSelectionInPreview(in view: UIView, onHighlight: @escaping () -> Void, completion: @escaping () -> Void) {
        self.adapter.animateSelectionInPreview(in: view, onHighlight: onHighlight, completion: completion)
    }
    
    func focusToItem(at selectionIndexPath: IndexPath, item: Int?) {
        self.itemIndexToFocus = item
        self.adapter.focusToItem(at: selectionIndexPath)
    }
}
