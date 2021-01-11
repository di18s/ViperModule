//
//  NewFilmographyModuleViewIO.swift
//  Kinopoisk
//
//  Created by Дмитрий Х on 15.04.2020.
//  Copyright © 2020 Yandex. All rights reserved.
//

import Foundation

protocol FilmographyViewInput: LoadableInput, ShowcaseViewWithSnippetDataInput {
    func setSnippetHidden(_ hidden: Bool, showcaseLoading: Bool)
    func updateViewModel(with selectionViewModel: [FilmographySelectionViewModel]?, preview: ShowcaseSelectionPreviewViewModel)
    func setIndexToFocus(selection: IndexPath, item: Int?)
    
    func setDownArrowVisible(_ visible: Bool, animated: Bool)
    func setUpArrowVisible(_ visible: Bool, animated: Bool)
    
    func focusToItem(at indexPath: IndexPath)
    
    func animateTransitionFromPreview()
    func animateSelectionInPreview(onHighlight: @escaping () -> Void, completion: @escaping () -> Void)
}

protocol FilmographyViewOutput: ViewLifecycleObserver {
    func didUpdateFocusItem(at indexPath: IndexPath)
    func didSelectItem(at indexPath: IndexPath)
	func didSelectItem(at selectionIndex: Int, itemIndex: Int)
	func didUpdateItemFocus(at selectionIndex: Int, itemIndex: Int)
}
