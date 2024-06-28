//
//  ViewController.swift
//  Movies Database
//
//  Created by Alwin on 28/06/24.
//

import UIKit

class ViewController: UIViewController, UISearchBarDelegate, UISearchResultsUpdating {
    
    @IBOutlet var tableView: UITableView!
    
    let options = ["Year", "Genre", "Directors", "Actors", "All Movies"]
    var expandedSections: Set<Int> = []
    var movies: [Movie] = []
    var filteredMovies: [Movie] = []
    var isSearching = false
    var uniqueYears: [Int] = []
    var uniqueGenres: [String] = []
    var uniqueDirectors: [String] = []
    var uniqueActors: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Movie Database"
        view.backgroundColor = .white
        
        movies = loadMoviesFromFile()
        
        setupTableView()
        setupSearchController()
    }
    
    func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "movieCell")
    }
    
    func setupSearchController() {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.delegate = self
        searchController.searchBar.placeholder = "Search Movies"
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text, !searchText.isEmpty else {
            isSearching = false
            tableView.reloadData()
            return
        }
        isSearching = true
        filteredMovies = movies.filter { movie in
            return movie.title.lowercased().contains(searchText.lowercased()) ||
            movie.genre.lowercased().contains(searchText.lowercased()) ||
            movie.actors.lowercased().contains(searchText.lowercased()) ||
            movie.director.lowercased().contains(searchText.lowercased())
        }
        tableView.reloadData()
    }
    
    func loadMoviesFromFile() -> [Movie] {
        guard let path = Bundle.main.path(forResource: "movies", ofType: "json") else {
            print("Failed to find JSON file.")
            return []
        }
        let url = URL(fileURLWithPath: path)
        do {
            let data = try Data(contentsOf: url)
            print(String(data: data, encoding: .utf8) ?? "Data is empty")
            let movies = try JSONDecoder().decode([Movie].self, from: data)
            print(movies)
            
            let years = movies.compactMap { Int($0.year) }
            uniqueYears = Array(Set(years)).sorted()
            print(uniqueYears)
            
            let genres = Array(Set(movies.map { $0.genre }))
            uniqueGenres = genres.sorted()
            
            // Populate uniqueDirectors with unique directors from the movies
            let directors = Array(Set(movies.map { $0.director }))
            uniqueDirectors = directors.sorted()
            
            // Populate uniqueActors with unique actors from the movies
            let actors = Array(Set(movies.flatMap { $0.actors.components(separatedBy: ", ") }))
            uniqueActors = actors.sorted()
            return movies
        } catch {
            print("Error loading movies: \(error)")
            return []
        }
    }
    
    func getValuesForSection(section: Int) -> [Movie] {
        switch section {
        case 0:
            return movies.sorted { $0.year < $1.year }
        case 1:
            return movies.sorted { $0.genre.localizedCompare($1.genre) == .orderedAscending }
        case 2:
            return movies.sorted { $0.director < $1.director }
        case 3:
            return movies.sorted { $0.actors.localizedCompare($1.actors) == .orderedAscending }
        case 4:
            return movies
        default:
            return []
        }
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return isSearching ? 1 : options.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isSearching {
            return filteredMovies.count
        }
        if expandedSections.contains(section) {
            switch section {
            case 0:
                return uniqueYears.count
            case 1:
                return uniqueGenres.count
            case 2:
                return uniqueDirectors.count
            case 3:
                return uniqueActors.count
            case 4:
                return getValuesForSection(section: section).count
            default:
                return 0
            }
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if isSearching {
            let cell = self.tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! TableViewCell
            let movie = filteredMovies[indexPath.row]
            cell.movieTitle.text = movie.title
            cell.movieYear.text = movie.year
            cell.movieLanguages.text = movie.language
            
            if let url = URL(string: movie.poster) {
                if let data = try? Data(contentsOf: url) {
                    cell.movieImage.image = UIImage(data: data)
                }
            }
            return cell
        }else {
            switch indexPath.section {
            case 0:
                let cell = self.tableView.dequeueReusableCell(withIdentifier: "movieCell", for: indexPath)
                cell.textLabel?.text = "\(uniqueYears[indexPath.row])"
                return cell
            case 1:
                let cell = self.tableView.dequeueReusableCell(withIdentifier: "movieCell", for: indexPath)
                cell.textLabel?.text = "\(uniqueGenres[indexPath.row])"
                return cell
            case 2:
                let cell = self.tableView.dequeueReusableCell(withIdentifier: "movieCell", for: indexPath)
                cell.textLabel?.text = "\(uniqueDirectors[indexPath.row])"
                return cell
            case 3:
                let cell = self.tableView.dequeueReusableCell(withIdentifier: "movieCell", for: indexPath)
                cell.textLabel?.text = "\(uniqueActors[indexPath.row])"
                return cell
            case 4:
                let cell = self.tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! TableViewCell
                let movie = getValuesForSection(section: indexPath.section)[indexPath.row]
                cell.movieTitle.text = movie.title
                cell.movieYear.text = movie.year
                cell.movieLanguages.text = movie.language
                
                if let url = URL(string: movie.poster) {
                    if let data = try? Data(contentsOf: url) {
                        cell.movieImage.image = UIImage(data: data)
                    }
                }
                return cell
            default:
                let cell = self.tableView.dequeueReusableCell(withIdentifier: "movieCell", for: indexPath)
                return cell
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if isSearching {
            return 150
        }else {
            if indexPath.section == 4 {
                return 150
            }else {
                return 44
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UITableViewHeaderFooterView(reuseIdentifier: "header")
        headerView.textLabel?.text = options[section]
        headerView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleSectionTap(_:))))
        headerView.tag = section
        return headerView
    }
    
    @objc func handleSectionTap(_ gestureRecognizer: UITapGestureRecognizer) {
        guard let section = gestureRecognizer.view?.tag else { return }
        if expandedSections.contains(section) {
            expandedSections.remove(section)
        } else {
            expandedSections.insert(section)
        }
        tableView.reloadSections(IndexSet(integer: section), with: .automatic)
    }
}

