//
//  NewFilmographyModuleInteractor.swift
//  Kinopoisk
//
//  Created by Дмитрий Х on 15.04.2020.
//  Copyright © 2020 Yandex. All rights reserved.
//

import Foundation
import Combine

final class FilmographyInteractor: FilmographyInteractorInput {
	let snippetData: CurrentValueSubject<SnippetDataModel?, Never> = CurrentValueSubject(nil)
	let filmography: CurrentValueSubject<FilmographyModel?, Never> = CurrentValueSubject(nil)
	
	var currentSnippetDataRequest: AnyCancellable?
	var currentFilmographyRequest: AnyCancellable?
	
	let currentError: CurrentValueSubject<(error: NetworkServiceError, retryAction: () -> Void)?, Never> = CurrentValueSubject(nil)
    var isAllowedSubprofile: Bool {
        return self.services.authorizationInfoProvider.isAllowedSubprofile
    }
	internal let services: ShowcaseSelectionModuleInteractorServicesContainer
	private let filmographyService: FilmographyServiceInput

	init(services: ShowcaseSelectionModuleInteractorServicesContainer, filmographyService: FilmographyServiceInput) {
        self.services = services
		self.filmographyService = filmographyService
    }
	
	func filmographyRequest(person id: Int) {
		self.currentFilmographyRequest?.cancel()
        let publisher = self.filmographyService.fimographyPublisher(with: id)
        self.currentFilmographyRequest = publisher
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] result in
                switch result {
                case .finished:
                    self?.currentError.value = nil
                case let .failure(error):
                    self?.currentFilmographyRequest = nil
                    self?.currentError.value = (error, { [weak self] in
                        self?.filmographyRequest(person: id)
                    })
                }
                }, receiveValue: { [weak self] filmography in
                    self?.filmography.send(filmography)
            })
    }
}

extension FilmographyInteractor: ShowcaseInteractorWithSnippetDataTrait {
}
