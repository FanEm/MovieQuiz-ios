//
//  QuestionFactory.swift
//  MovieQuiz
//

import Foundation

// MARK: - QuestionFactoryProtocol
protocol QuestionFactoryProtocol {
    func requestNextQuestion()
    func loadData()
}

// MARK: - QuestionFactory
final class QuestionFactory: QuestionFactoryProtocol {
    private let moviesLoader: MoviesLoading
    private weak var delegate: QuestionFactoryDelegate?

    init(moviesLoader: MoviesLoading, delegate: QuestionFactoryDelegate) {
        self.moviesLoader = moviesLoader
        self.delegate = delegate
    }

    private var movies: [MostPopularMovie] = []

    func loadData() {
        moviesLoader.loadMovies { [weak self] result in
            DispatchQueue.main.async {
                guard let self else { return }
                switch result {
                case .success(let mostPoopularMovies):
                    self.movies = mostPoopularMovies.items
                    self.delegate?.didLoadDataFromServer()
                case .failure(let error):
                    self.delegate?.didFailToLoadData(with: error)
                }
            }
        }
    }

    func requestNextQuestion() {
        DispatchQueue.global().async { [weak self] in
            guard let self else { return }

            let index = (0..<self.movies.count).randomElement() ?? 0
            guard let movie = self.movies[safe: index] else { return }

            var imageData = Data()
            do {
                imageData = try Data(contentsOf: movie.resizedImageURL)
            } catch {
                DispatchQueue.main.async { [weak self] in
                    guard let self else { return }
                    self.delegate?.didFailToLoadImage(with: error)
                }
                return
            }

            let (text, correctAnswer) = self.generateQuestionAndCorrectAnswer(movie.rating)

            let question = QuizQuestion(
                image: imageData,
                text: text,
                correctAnswer: correctAnswer
            )

            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                self.delegate?.didReceiveNextQuestion(question: question)
            }
        }
    }

    private func generateQuestionAndCorrectAnswer(_ filmRating: String) -> (String, Bool) {
        let filmRating = Float(filmRating) ?? 0
        let roundedRating = filmRating.rounded(.down)
        let isMore = Bool.random()

        var rating = [
            max(roundedRating - 1, 0),
            min(roundedRating + 1, 9)
        ].randomElement() ?? roundedRating
        if rating == filmRating { rating -= 1 }

        return (
            text: "Рейтинг этого фильма \(isMore ? "больше" : "меньше") чем \(Int(rating))?",
            correctAnswer: isMore ? filmRating > rating : filmRating < rating
        )
    }
}
