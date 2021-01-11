//
//  NewFilmographyModulePresenter.swift
//  Kinopoisk
//
//  Created by Дмитрий Х on 15.04.2020.
//  Copyright © 2020 Yandex. All rights reserved.
//

import UIKit
import Combine

final class FilmographyPresenter<Interactor: FilmographyInteractorInput>: FilmographyInput, ShowErrorPresenterTrait {
	
	enum Section: Equatable {
		case actor([FilmMiniModel])
        case director([FilmMiniModel])
    }
	
    private weak var view: FilmographyViewInput!
    private let router: FilmographyRouterInput
	internal let interactor: Interactor
    
	private var filmographyBuilder: NewFilmographyViewModelBuilderType
    private let selectionPreviewBuilder: FilmographyPreviewViewModelBuilderType
	internal let snippetViewModelBuilder: FilmSnippetViewModelBuilderType
    private let errorBuilder: ErrorViewModelBuilderType
    private let analyticsService: AnalyticsServiceInput
    
    private var shouldRequestDataOnAppear = true
    
    private var interactorSubscriptions: Set<AnyCancellable> = []
    
	var snippetUpdateTimer: ExtendableTimerInput = ExtendableTimer()
	
	var lastSnippetViewModel: SnippetViewModel?
	
	var previewSnippetModel: SnippetViewModel?
	
	var sections: [FilmographyPresenter<FilmographyInteractor>.Section] = []
	private var filmography: FilmographyModel? {
        return self.interactor.filmography.value
	}
	
	var focusedSelectionItemId: String?
	var previewImageURL: URL?
	
	var autoselectTimer: ExtendableTimer?
	var autoselectTimerWasStarted: Bool = false
    
    var canAutoselect: Bool {
        return self.filmography != nil && (self.filmography?.filmsWithActorRole.isEmpty == false || self.filmography?.filmsWithDirectorRole.isEmpty == false)
    }
	
	var personId: Int?
	var personName: String?
    var referer: FilmographyReferrer?
    
    init(view: FilmographyViewInput,
         router: FilmographyRouterInput,
         interactor: Interactor,
         selectionPreviewBuilder: FilmographyPreviewViewModelBuilderType,
         snippetViewModelBuilder: FilmSnippetViewModelBuilderType,
         errorBuilder: ErrorViewModelBuilderType,
         filmographyBuilder: NewFilmographyViewModelBuilderType,
         analyticsService: AnalyticsServiceInput) {
        self.view = view
        self.router = router
        self.interactor = interactor
        self.selectionPreviewBuilder = selectionPreviewBuilder
        self.snippetViewModelBuilder = snippetViewModelBuilder
        self.errorBuilder = errorBuilder
        self.filmographyBuilder = filmographyBuilder
        self.analyticsService = analyticsService
    }

    // MARK: FilmographyInput
    func configure(with personId: Int, personName: String?, previewImage: URL?, referer: FilmographyReferrer) {
		self.previewImageURL = previewImage
		self.personId = personId
        self.personName = personName
        self.referer = referer
	}
	
	func requestFilmography() {
		guard let id = self.personId else { return }
		self.router.hideError()
		if self.sections.isEmpty {
			self.view.setLoading(true)
		}
		self.interactor.filmographyRequest(person: id)
	}
	
	func updateViewModels() {
		guard let model = self.filmographyBuilder.build(with: self.sections, filmography: self.filmography) else { return }
		let preview = self.selectionPreviewBuilder.buildPreview(with: self.previewImageURL, and: model.title)
		self.view.updateViewModel(with: model.items, preview: preview)
	}
	
}

extension FilmographyPresenter: FilmographyViewOutput {
    // MARK: FilmographyViewOutput
    
    func viewDidLoad() {
        self.view.setSnippetHidden(true, showcaseLoading: false)
        self.subscribeToInteractorUpdates()
		self.view.setDownArrowVisible(false, animated: false)
        self.view.setUpArrowVisible(false, animated: false)
		let viewModel = self.selectionPreviewBuilder.buildPreview(with: self.previewImageURL, and: self.personName)
        self.view.updateViewModel(with: nil, preview: viewModel)
    }
    
    func viewWillAppear() {
        guard self.shouldRequestDataOnAppear else { return }
		self.requestFilmography()
        self.shouldRequestDataOnAppear = false
    }
    
    func viewDidAppear() {
        guard let referer = self.referer, let personId = self.personId else { return }
        self.analyticsService.filmographyDidShow(personId: personId, referrer: referer)
    }
	
	func didSelectItem(at selectionIndex: Int, itemIndex: Int) {
		let indexPath = IndexPath(item: itemIndex, section: selectionIndex)
		var filmId: String?
		switch self.sections[indexPath.section] {
		case .director:
			filmId = self.filmography?.filmsWithDirectorRole?[indexPath.item].filmId
		case .actor:
			filmId = self.filmography?.filmsWithActorRole?[indexPath.item].filmId
		}
        
		guard let id = filmId else { return }
        self.router.showFilm(with: id, referer: .other, animated: true)
        
        guard let personId = self.personId else { return }
        self.analyticsService.filmographyFilmDidClick(personId: personId, filmId: id)
		
	}
	
	func didUpdateItemFocus(at selectionIndex: Int, itemIndex: Int) {
		let indexPath = IndexPath(item: itemIndex, section: selectionIndex)
        let prevItemId = self.focusedSelectionItemId
        
        view.setIndexToFocus(selection: IndexPath(item: selectionIndex, section: 1), item: itemIndex)
        
		self.view.setDownArrowVisible(false, animated: true)
        self.view.setUpArrowVisible(selectionIndex == 0, animated: true)
		
        let film = self.filmModel(for: indexPath)
		self.focusedSelectionItemId = film.filmId
		self.reloadSnippetAfterItemChanged(to: film, isOtherItem: prevItemId != self.focusedSelectionItemId, coverURL: film.coverUrl)
        guard let personId = self.personId else { return }
        self.analyticsService.filmographyFilmDidShow(personId: personId, filmId: film.filmId)
	}
	
    func didUpdateFocusItem(at indexPath: IndexPath) {
		if indexPath.section == 0 {
            self.view.setSnippetHidden(true, showcaseLoading: false)
            if canAutoselect {
                self.view.setDownArrowVisible(true, animated: true)
                self.startAutoselectTimerIfNeeded()
            }
            self.view.setUpArrowVisible(false, animated: true)
		}
    }
    
    func didSelectItem(at indexPath: IndexPath) {
        if indexPath.section == 0 {
            guard canAutoselect else { return }
            self.autoselectTimer?.stop()
            self.view.animateTransitionFromPreview()
            self.view.focusToItem(at: IndexPath(item: 0, section: 1))
		}
    }
    
    func startAutoselectTimerIfNeeded() {
        guard self.autoselectTimerWasStarted == false else { return }
        self.autoselectTimerWasStarted = true
        self.autoselectTimer = ExtendableTimer()
        self.autoselectTimer?.updateTimer(with: 0.5, actionBlock: { [weak self] _ in
            self?.autoselectTimer = nil
            self?.view.animateSelectionInPreview(onHighlight: {
                self?.didSelectItem(at: IndexPath(item: 0, section: 0))
            }, completion: { })
        })
    }
	
	private func filmModel(for indexPath: IndexPath) -> FilmMiniModel {
        let section = self.sections[indexPath.section]
        switch section {
        case let .director(films):
            return films[indexPath.item]
        case let .actor(films):
            return films[indexPath.item]
        }
    }
}

private extension FilmographyPresenter {
    func subscribeToInteractorUpdates() {
		self.interactor.currentError
            .sink { [weak self] errorInfo in
                guard let strongSelf = self, let errorInfo = errorInfo else { return }
                strongSelf.handleNetworkError(errorInfo.error,
                                              builder: strongSelf.errorBuilder,
                                              router: strongSelf.router) {
                                                self?.router.hideError()
                                                errorInfo.retryAction()
                }
        }
        .store(in: &self.interactorSubscriptions)
		
		self.interactor.filmography
			.sink { [weak self] filmography in
				guard let strongSelf = self else { return }
				strongSelf.view.setLoading(false)
				strongSelf.sections = strongSelf.filmographyBuilder.buildSections(with: filmography)
				strongSelf.updateViewModels()
                if filmography != nil {
                    strongSelf.startAutoselectTimerIfNeeded()
                }
		}
        .store(in: &self.interactorSubscriptions)
		
        self.subscribeToSnippetUpdates()
            .store(in: &self.interactorSubscriptions)
    }
}

extension FilmographyPresenter: ShowcasePresenterWithSnippetDataTrait {
    var viewWithSnippet: ShowcaseViewWithSnippetDataInput {
        return self.view
    }
}

extension FilmographyPresenter: FilmTransitionModuleInput {
    var transitionFilmId: String? {
        return self.focusedSelectionItemId
    }
}
