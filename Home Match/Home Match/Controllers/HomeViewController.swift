//
//  HomeViewController.swift
//  Home Match
//
//  Created by Sterling Gamble on 4/4/21.
//

import UIKit
import AlamofireImage
import Lottie

class HomeViewController: UIViewController, UISearchResultsUpdating, UICollectionViewDelegate, UICollectionViewDataSource, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    let searchController = UISearchController()
    let imageButton = UIBarButtonItem()
    
    var tableView = UITableView()
    private let collectionView: UICollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewCompositionalLayout(sectionProvider: { (_, _) -> NSCollectionLayoutSection? in
        let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1)))
        
        item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 9.5, bottom: 0, trailing: 9.5)
        
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(164)), subitem: item, count: 2)
        
        group.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 4.5, bottom: 5, trailing: 4.5)
        
        return NSCollectionLayoutSection(group: group)
    }))
    
    var image: UIImageView?
    var animationView = AnimationView()

    let api = RealitorAPI()
    let matcher = Matcher()
    
    var searchResults = [Location]()
    var listings = [Home]()
    var location: Location?
    var imageURL: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let image = UIImage(systemName: "photo.fill")
        
        
        searchController.searchBar.delegate = self
        searchController.searchResultsUpdater = self
        searchController.searchBar.sizeToFit()
        searchController.searchBar.placeholder = "Enter a Location"
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.obscuresBackgroundDuringPresentation = false
        
        // filter button
//        searchController.searchBar.showsBookmarkButton = true
//        searchController.searchBar.setImage(UIImage(systemName: "slider.horizontal.3"), for: .bookmark, state: .normal)
        
        navigationItem.titleView = self.searchController.searchBar
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(openImagePicker))
        
        
        view.backgroundColor = .white
        
        // collection view of homes
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .white
        collectionView.register(HomeCell.self, forCellWithReuseIdentifier: "HomeCell")
        view.addSubview(collectionView)
        
        // table view for search results
        tableView = UITableView(frame: view.bounds, style: .plain)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = .white
        tableView.frame = view.bounds
        tableView.isHidden = true
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "resultCell")
        view.addSubview(tableView)
        
        // location presets
        searchResults.append(Location(city: "Alameda", state: "CA"))
        searchResults.append(Location(city: "Oakland", state: "CA"))
        searchResults.append(Location(city: "Los Angeles", state: "CA"))
        searchResults.append(Location(city: "San Francisco", state: "CA"))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // Nav Bar Appearance
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = false
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.frame = view.bounds
    }
    
    // MARK: Base Functions
    @objc func openImagePicker() {
        let imagePickerViewController = ImagePickerViewController()
        imagePickerViewController.title = "Image Picker"
        imagePickerViewController.selectionDelegate = self
        self.navigationController?.pushViewController(imagePickerViewController, animated: false)
    }
    
    // MARK: Animation
    func startAnimation() {
        animationView.animation = Animation.named("LottieHome")
        animationView.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height/1.5)
        animationView.backgroundColor = .white
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = .loop
        animationView.play()
        view.addSubview(animationView)
    }
    
    func stopAnimation() {
        animationView.stop()
        view.subviews.last?.removeFromSuperview()
    }
    
    // MARK: Search
    func updateSearchResults(for searchController: UISearchController) {
        guard let text = searchController.searchBar.text else {
            return
        }
        // commented out to reduce API calls
//        api.autoComplete(text: text) { (results) -> (Void) in
//            for result in results {
//                let city = result["city"] as! String
//                let state = result["state_code"] as! String
//                self.searchResults.append(Location(city: city, state: state))
//            }
//
//            DispatchQueue.main.async {
//                self.tableView.reloadData()
//            }
//
//        }
        
        print(text)
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        tableView.isHidden = false
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        tableView.isHidden = true
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        tableView.isHidden = false
    }
    
    // MARK: Matching
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        tableView.isHidden = true
        
        // a location object must chosen from the search results in order find homes
        if let location = location {
            self.startAnimation()
            print("Searching: \(location.city), \(location.state)")
            
            listings.removeAll()
            
            api.propertiesForSale(city: location.city, state: location.state) {  (properties) -> (Void) in
                // convert json to homes
                for property in properties {
                    guard let image = property["thumbnail"] as? String else {
                        continue
                    }
                    let address = property["address"] as! Dictionary<String, Any>
                    let line = address["line"] as! String
                    let city = address["city"] as! String
                    let state = address["state_code"] as! String
                    let price = property["price"] as! Int
                    let priceLine = "$\(price)"
                    
                    let addressLine = "\(line), \(city), \(state)"
                    self.listings.append(Home(imageURL: image, address: addressLine, price: priceLine))
                }
                
                // Match Listings
                guard let url = self.imageURL else {
                    return
                }
                
                let sourceImage = URL(string: url)
                let sortedListings = self.matcher.processImages(sourceImage: sourceImage, listings: self.listings)
                
                DispatchQueue.main.async { [weak self] in
                    self?.listings = sortedListings
                    self?.stopAnimation()
                    self?.collectionView.reloadData()
                }
            }
        }
        
    }
    
    // MARK: Listings Collection View
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return listings.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HomeCell", for: indexPath) as! HomeCell
        
        let home = listings[indexPath.row]
        cell.configure(with: home)
        cell.imageView.af.setImage(withURL: URL(string: home.imageURL!)!)
        
        return cell
    }
    
    // MARK: Search Results Table View
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "resultCell", for: indexPath)
        let location = searchResults[indexPath.row]
        
        cell.textLabel?.text = location.city + ", " + location.state
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedLocation = searchResults[indexPath.row]
        location = selectedLocation
        
        searchController.searchBar.text = selectedLocation.city + ", " + selectedLocation.state
        
        tableView.deselectRow(at: indexPath, animated: true)
        tableView.isHidden = true
    }
    
    
    
}


extension HomeViewController: ImageSelectionDelegate {
    func pickedImage(url: String) {
        imageURL = url
    }
}
