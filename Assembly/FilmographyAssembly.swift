//
//  NewFilmographyModuleAssembly.swift
//  Kinopoisk
//
//  Created by Дмитрий Х on 15.04.2020.
//  Copyright © 2020 Yandex. All rights reserved.
//

import Foundation

extension FilmographyViewController: StoryboardCreatable {
    func didCreateFromStoryboard() {
        FilmographyAssembly.injectProperties(in: self)
    }
}
struct FilmographyAssembly: ViewControllerBuildable, ViewControllerInjectable {

    static func makeStoryboard() -> UIStoryboard {
        return UIStoryboard(name: "NewFilmographyModule", bundle: nil)
    }

    static func injectProperties(in view: FilmographyViewController) {
        let router = FilmographyRouter(transitionHandler: view)
        
        let services = ShowcaseSelectionModuleInteractorServicesContainer(selectionsService: NetworkServicesAssembly.selectionsService(),
                                                                          licensedContentMetadataService: NetworkServicesAssembly.licensedMetadataService(),
                                                                          trailersService: NetworkServicesAssembly.trailersService(),
                                                                          authorizationInfoProvider: CommonServicesAssembly.authorizationInfoProvider())
        let interactor = FilmographyInteractor(services: services,
                                               filmographyService: NetworkServicesAssembly.filmographyService())
        
        let imageSourceBuilder = RemoteImageSourceBuilder()
        let builder = NewFilmographyViewModelBuilder(itemsViewModelBuilder: ShowcaseFilmItemViewModelBuilder(imageSourceBuilder: imageSourceBuilder, priceFormatter: NumberFormatters.currencyFormatter()))
        let presenter = FilmographyPresenter(view: view,
                                             router: router,
                                             interactor: interactor,
                                             selectionPreviewBuilder: FilmographyPreviewViewModelBuilder(imageSourceBuilder: imageSourceBuilder),
                                             snippetViewModelBuilder: FilmSnippetViewModelBuilder(imageSourceBuilder: imageSourceBuilder,
                                                                                                  filmMetaBuilder: FilmMetaDataViewModelBuilder(filmDurationDateComponentsFormatter: DateComponentsFormatters.shortHMin),
                                                                                                  rentViewModelBuilder: RentViewModelBuilder()),
                                             errorBuilder: ErrorViewModelBuilder(),
                                             filmographyBuilder: builder,
                                             analyticsService: CommonServicesAssembly.analyticsService())
        
        view.output = presenter
        view.moduleInput = presenter
        
        let adapter = FilmographyCollectionViewAdapter()
        adapter.output = view
		view.adapterContainer = FilmographyAdapterContainer(adapter: adapter)
    }
    
}
