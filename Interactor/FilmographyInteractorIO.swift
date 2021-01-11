//
//  NewFilmographyModuleInteractorIO.swift
//  Kinopoisk
//
//  Created by Дмитрий Х on 15.04.2020.
//  Copyright © 2020 Yandex. All rights reserved.
//

import Foundation
import Combine

protocol FilmographyInteractorInput: ShowcaseInteractorWithSnippetDataInput {
	var currentError: CurrentValueSubject<(error: NetworkServiceError, retryAction: () -> Void)?, Never> { get }
	var filmography: CurrentValueSubject<FilmographyModel?, Never> { get }
	
    func filmographyRequest(person id: Int)
}
