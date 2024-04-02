//
//  Book.swift
//  AudioBloom
//
//  Created by Angelina on 28.03.2024.
//

import Foundation

struct Book: Codable, Equatable, Identifiable {
    let id: Int
    let name: String
    let coverPageImage: String
    let chapters: [Chapter]
    var mode: Mode? = .audio

    enum Mode: Codable, Equatable {
        case reader
        case audio
    }
}

struct Chapter: Codable, Equatable, Identifiable {
    let id: Int
    let text: String
    let audio: String
    let keyPoint: String
}

extension Book {

    static var sample: Book {
        .init(
            id: 1,
            name: "Glinda of Oz",
            coverPageImage: "https://media.publit.io/file/glinda-of-oz-1002.png",
            chapters:
                [
                    .init(
                        id: 1,
                        text: "Glinda, the good Sorceress of Oz, sat in the grand court of her palace, surrounded by her maids of hundred of the most beautiful girls of the Fairyland of Oz. The palace court was built of rare marbles, exquisitely polished. Fountains tinkled musically here and there; the vast colonnade, open to the south, allowed the maidens, as they raised their heads from their embroideries, to gaze upon a vista of rose-hued fields and groves of trees bearing fruits or laden with sweet-scented flowers. At times one of the girls would start a song, the others joining in the chorus, or one would rise and dance, gracefully swaying to the music of a harp played by a companion. And then Glinda smiled, glad to see her maids mixing play with work.",
                        audio: "https://ia600708.us.archive.org/0/items/glinda_oz_0908_librivox/glindaofoz_02_baum_64kb.mp3",
                        keyPoint: "Residing in Ozma's palace at this time was a live Scarecrow."
                    )
                ], 
            mode: .audio
        )
    }

    static var idle: Book {
        .init(
            id: 0,
            name: "",
            coverPageImage: "",
            chapters: [
                Chapter(
                    id: 0,
                    text: "",
                    audio: "",
                    keyPoint: "")
            ], 
            mode: .audio
        )
    }
}
