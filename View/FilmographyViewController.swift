//
//  NewFilmographyModuleViewController.swift
//  Kinopoisk
//
//  Created by Дмитрий Х on 15.04.2020.
//  Copyright © 2020 Yandex. All rights reserved.
//

import UIKit

final class FilmographyViewController: LoadableViewController, FilmographyViewInput, ShowcaseModuleFilmTransitionInput {

    var output: FilmographyViewOutput!
    private let swipeBarrier = SwipeBarrier()
    
    // swiftlint:disable private_outlet
    @IBOutlet weak var collectionViewContainerView: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet private weak var downArrowImageView: UIImageView!
    @IBOutlet private weak var upArrowImageView: UIImageView!
    @IBOutlet weak var downArrowBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var upArrowTopConstraint: NSLayoutConstraint!
    // swiftlint:enable private_outlet
    
    var adapterContainer: FilmographyAdapterContainerInput!
    
    weak var snippetView: SnippetViewInput!
    
    private let snippetEmbedSegueIdentifier = "SnippetEmbedSegue"
    
    private var offsets: [IndexPath: CGPoint] = [:]
    
    private(set) var viewIsFocused: Bool = false
    
    // MARK: Lifecycle

    override func setupView() {
        super.setupView()
        
        self.restoresFocusAfterTransition = false
        
        self.collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 148, right: 0)
        
        self.preferredFocusEnvironmentsContainer.setEnvironments([self.collectionView])
        self.adapterContainer.setCollectionView(self.collectionView)
        self.snippetView.update(inset: SnippetInsets.filmTitleTopInset)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        if segue.identifier == self.snippetEmbedSegueIdentifier {
            self.snippetView = segue.destination as? SnippetViewInput
        }
    }
    
    override func shouldUpdateFocus(in context: UIFocusUpdateContext) -> Bool {
        return self.swipeBarrier.shouldUpdateFocus(in: context, checkType: FilmographyPreviewCollectionViewCell.self) ?? super.shouldUpdateFocus(in: context)
    }
    
    override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        super.didUpdateFocus(in: context, with: coordinator)

        if let nextItem = context.nextFocusedItem, self.contains(nextItem) {
            self.viewIsFocused = true
        } else {
            self.viewIsFocused = false
            self.snippetView.clearPlayback()
        }
        
        self.swipeBarrier.didUpdateFocus(with: coordinator)
    }

    // MARK: FilmographyViewOutput
    
    func updateViewModel(with selectionViewModel: [FilmographySelectionViewModel]?, preview: ShowcaseSelectionPreviewViewModel) {
        self.adapterContainer.updateCollection(with: selectionViewModel, preview: preview)
    }
    
    func setIndexToFocus(selection: IndexPath, item: Int?) {
        self.adapterContainer.indexPathToFocus = selection
        self.adapterContainer.itemIndexToFocus = item
    }
    
    func focusToItem(at indexPath: IndexPath) {
		self.adapterContainer.focusToItem(at: indexPath, item: 0)
    }
    
    func animateTransitionFromPreview() {
        self.adapterContainer.animateTransitionFromPreviewCell(in: self.collectionViewContainerView)
    }
    
    func animateSelectionInPreview(onHighlight: @escaping () -> Void, completion: @escaping () -> Void) {
        self.adapterContainer.animateSelectionInPreview(in: self.collectionViewContainerView, onHighlight: onHighlight, completion: completion)
    }

    // MARK: Actions
}

extension FilmographyViewController: SnippetViewUpdaterTrait { }

extension FilmographyViewController: ShowcaseViewArrowsAnimationsTrait { }

extension FilmographyViewController: NavigationControllerTransitionProviderInput {
    func navigationTransition(for operation: UINavigationController.Operation,
                              to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        guard operation == .push,
            (toVC is FilmModuleViewInput) else { return nil }
        return FilmFromSnippetTransition.makeNavigationTransition(for: operation, to: toVC, from: self)
    }
}

extension FilmographyViewController: FilmographyCollectionViewAdapterOutput {
    func didUpdateContentOffset(offset: CGPoint, at rowIndexPath: IndexPath) {
        self.offsets[rowIndexPath] = offset
    }
    
    func contentOffset(for rowIndexPath: IndexPath) -> CGPoint? {
        return self.offsets[rowIndexPath]
    }
    
    func didUpdateFocus(at selection: IndexPath, itemIndexPath item: IndexPath) {
		self.output.didUpdateItemFocus(at: selection.item, itemIndex: item.item)
	}
	
    func didSelectItem(at selection: IndexPath, itemIndexPath item: IndexPath) {
		self.output.didSelectItem(at: selection.item, itemIndex: item.item)
	}
	
    func didUpdateFocusedCollectionCell(from oldIndexPath: IndexPath?, to newIndexPath: IndexPath?, with coordinator: UIFocusAnimationCoordinator) {
        guard let indexPath = newIndexPath else { return }
        self.output.didUpdateFocusItem(at: indexPath)
    }
    
    func didSelectCollectionCell(at indexPath: IndexPath) {
        self.output.didSelectItem(at: indexPath)
    }
    
    func didLongPressItem(at rowIndexPath: IndexPath, itemIndexPath: IndexPath) {
        
    }
}
