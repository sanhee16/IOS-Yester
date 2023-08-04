//
//  SelectLocationViewModel.swift
//  WeatherApp
//
//  Created by sandy on 2023/07/18.
//

import Foundation
import Combine
import Alamofire
import CoreLocation


typealias GeocodingItem = (idx: Int, item: Geocoding)

protocol SelectLocationViewModel: SelectLocationViewModelInput, SelectLocationViewModelOutput { }

protocol SelectLocationViewModelInput {
    var name: Observable<String> { get }
    var selectedItem: Observable<GeocodingItem?> { get }
    func viewWillAppear()
    func viewDidLoad()
    func onClickSearch()
    func onClickSearchMyLocation()
    func onClickAddLocation()
}

protocol SelectLocationViewModelOutput {
    var results: Observable<[Geocoding]> { get }
    var isSearching: Observable<Bool> { get }
}

class DefaultSelectLocationViewModel: BaseViewModel, SelectLocationViewModel {
    let weatherService: WeatherService
    let locationService: LocationService
    let locationRespository: AnyRepository<Location>
    
    var results: Observable<[Geocoding]> = Observable([])
    var name: Observable<String> = Observable("")
    var isSearching: Observable<Bool> = Observable(false)
    var selectedItem: Observable<GeocodingItem?> = Observable(nil)
    
    init(_ coordinator: AppCoordinator, locationRespository: AnyRepository<Location>, weatherService: WeatherService, locationService: LocationService) {
        self.locationRespository = locationRespository
        self.weatherService = weatherService
        self.locationService = locationService
        super.init(coordinator)
    }
    
    func viewWillAppear() {
        
    }
    
    func viewDidLoad() {
        
    }
    
    func onClickSearch() {
        self.isSearching.value = true
        self.selectedItem.value = nil
        self.weatherService.getGeocoding(name.value)
            .run(in: &self.subscription) {[weak self] response in
                guard let self = self else { return }
                self.results.value = response.value ?? []
//                print("success: \(response.value)")
//                print("error?: \(response.error)")
            } complete: {[weak self] in
                guard let self = self else { return }
                self.isSearching.value = false
                print("complete")
            }
    }
    
    func onClickSearchMyLocation() {
        self.isSearching.value = true
        self.selectedItem.value = nil
        self.results.value.removeAll()
        self.name.value.removeAll()
        
        self.locationService.requestLocation {[weak self] coordinate in
            guard let self = self else { return }
            
            self.weatherService.getReverseGeocoding(coordinate)
                .run(in: &self.subscription) { [weak self] response in
                    guard let self = self else { return }
                    self.results.value = response.value ?? []
                } complete: {[weak self] in
                    guard let self = self else { return }
                    self.isSearching.value = false
                }
        }
    }
    
    func onClickAddLocation() {
        guard let item = self.selectedItem.value?.item else { return }
        print(item)
        try? self.locationRespository.insert(item: Location(lat: item.lat, lon: item.lon, isStar: false, isCurrent: false, name: item.localName))
        self.coordinator.pop()
    }
}
