//
//  NewFilmographyModuleIO.swift
//  Kinopoisk
//
//  Created by Дмитрий Х on 15.04.2020.
//  Copyright © 2020 Yandex. All rights reserved.
//

import Foundation

protocol FilmographyInput: class {
    func configure(with personId: Int, personName: String?, previewImage: URL?, referer: FilmographyReferrer)
}
