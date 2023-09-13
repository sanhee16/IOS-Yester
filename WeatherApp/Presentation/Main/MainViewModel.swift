//
//  MainView.swift
//  WeatherApp
//
//  Created by sandy on 2023/07/11.
//

import Foundation
import Alamofire
import Combine


enum UpdateStatus {
    case none
    case reload([WeatherCardItem])
    case load(Int, WeatherCardItem)
}

protocol MainViewModel: MainViewModelInput, MainViewModelOutput { }

protocol MainViewModelInput {
    func viewWillAppear()
    func viewDidLoad()
    func onClickAddLocation()
    func onClickManageLocation()
    func onClickSetting()
    func onChangePage(_ idx: Int, onDone: (()->())?)
}

protocol MainViewModelOutput {
    var isLoading: Observable<Bool> { get }
    var items: [WeatherCardItem] { get }
    var updateStatus: Observable<UpdateStatus> { get }
}

class DefaultMainViewModel: BaseViewModel {
    private let locationRespository: AnyRepository<Location>
    private let weatherService: `WeatherService`
    private let weatherServiceV2: WeatherServiceV2
    private let locationService: LocationService
    
    var isLoading: Observable<Bool> = Observable(false)
    var items: [WeatherCardItem] = []
    var isFirstLoad: Bool = true
    var updateStatus: Observable<UpdateStatus> = Observable(.none)
    
    init(_ coordinator: AppCoordinator, locationRespository: AnyRepository<Location>, weatherService: WeatherService, weatherServiceV2: WeatherServiceV2, locationService: LocationService) {
        print("init!")
        self.locationRespository = locationRespository
        self.weatherService = weatherService
        self.weatherServiceV2 = weatherServiceV2
        self.locationService = locationService
        super.init(coordinator)
    }
}

extension DefaultMainViewModel: MainViewModel {
    
    func viewDidLoad() {
        print("[LOCATION] VM viewDidLoad")
    }
    
    func viewWillAppear() {
        print("[LOCATION] VM viewWillAppear")
        self.isLoading.value = false
        self.isFirstLoad = true
        self.updateStatus.value = .none
        
        self.loadLocations()
        
        self.onChangePage(0) {[weak self] in
            self?.onChangePage(1, onDone: nil)
        }
    }
    
    func onClickAddLocation() {
        coordinator.presentSelectLocation()
    }
    
    func onChangePage(_ idx: Int, onDone: (()->())?) {
        if idx >= self.items.count {
            return
        }
        if self.items[idx].isLoaded {
            return
        }
        self.updateWeather(idx, onDone: onDone)
    }
    
    func updateWeather(_ idx: Int, onDone: (()->())? = nil) {
        if self.isLoading.value || self.items[idx].isLoaded {
            onDone?()
            return
        }
        
        self.isLoading.value = true
        print("[MainVC] updateWeather: \(idx)")
        
        let location = self.items[idx].location
        
        
        Publishers.Zip3 (
            self.weatherService.getOneCallWeather(location),
            self.weatherService.get3HourlyWeather(location),
            self.weatherServiceV2.getHistoryWeather(location)
        )
        .run(in: &self.subscription) {[weak self] (weather, threeHourWeather, historyWeather) in
            guard let self = self, let weather = weather.value, let threeHourWeather = threeHourWeather.value, let yesterday = historyWeather.value?.forecast.forecastday.first else {
                self?.items[idx] = WeatherCardItem(location: location, currentWeather: nil, daily: [], hourly: [], threeHourly: [], isLoaded: true, yesterday: nil)
                self?.isLoading.value = false
                onDone?()
                return
            }
            
            let current = weather.current
            let daily = weather.daily
            let hourly = weather.hourly
            
            self.items[idx] = WeatherCardItem(location: location, currentWeather: current, daily: daily, hourly: hourly, threeHourly: threeHourWeather.list, isLoaded: true, yesterday: yesterday)
            
            if self.isFirstLoad {
                self.updateStatus.value = .reload(self.items)
                self.isFirstLoad = false
            } else {
                self.updateStatus.value = .load(idx, self.items[idx])
            }
            
            self.isLoading.value = false
            onDone?()
        } complete: {
            
        }
    }
    
    func loadLocations() {
        if self.isLoading.value {
            return
        }
        self.isLoading.value = true
        let previousItems = self.items
        var newItems: [WeatherCardItem] = []
        
        Defaults.locations.forEach { location in
            if let idx = previousItems.firstIndex(where: { item in
                item.location == location
            }) {
                newItems.append(previousItems[idx])
            } else {
                newItems.append(WeatherCardItem(location: location, daily: [], hourly: [], threeHourly: [], isLoaded: false, yesterday: nil))
            }
        }
        self.items = newItems
        self.updateStatus.value = .reload(self.items)
        self.isLoading.value = false
    }
    
    func onClickManageLocation() {
        self.coordinator.presentManageLocation()
    }
    
    func onClickSetting() {
        self.coordinator.presentSetting()
    }
}
