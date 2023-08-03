//
//  SelectLocationViewController.swift
//  WeatherApp
//
//  Created by sandy on 2023/07/18.
//


import UIKit
import SwiftUI
import Combine
import SnapKit

class SelectLocationViewController: BaseViewController {
    typealias VM = SelectLocationViewModel
    
    private let vm: VM
    
    private let searchButton: UIButton = {
        let button = UIButton()
        
        button.setTitle("찾기", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.backgroundColor = UIColor.blue.withAlphaComponent(0.3)
        button.layer.cornerRadius = 10
        button.contentEdgeInsets = UIEdgeInsets(top: 8, left: 10, bottom: 8, right: 10)
        
        return button
    }()
    
    private let myLocationButton: UIButton = {
        let button = UIButton()
        
        button.setTitle("내 위치로 찾기", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.backgroundColor = UIColor.orange.withAlphaComponent(0.3)
        button.layer.cornerRadius = 10
        button.contentEdgeInsets = UIEdgeInsets(top: 8, left: 10, bottom: 8, right: 10)
        
        return button
    }()
    
    private let searchView: UIStackView = {
        let stackView = UIStackView()
        
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.spacing = 8
        return stackView
    }()
    
    private let searchingLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.textColor = .black
        return label
    }()
    
    private let searchController: UISearchController = {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.placeholder = "지역 이름"
        return searchController
    }()
    
    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.register(SelectLocationCell.self, forCellReuseIdentifier: SelectLocationCell.identifier)
        tableView.separatorStyle = .none
        tableView.backgroundColor = .clear
        
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0.1))
        
        return tableView
    }()
    
    private let selectButton: UIButton = {
        let button = UIButton()
        
        button.setTitle("추가하기", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.backgroundColor = UIColor.red
        button.layer.cornerRadius = 10
        button.contentEdgeInsets = UIEdgeInsets(top: 8, left: 10, bottom: 8, right: 10)
        
        return button
    }()
    
    
    init(vm: VM) {
        self.vm = vm
        super.init()
        self.bind(to: vm)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func bind(to vm: VM) {
        vm.results.observe(on: self) {[weak self] list in
            guard let self = self else { return }
            self.tableView.reloadData()
        }
        
        vm.isSearching.observe(on: self) {[weak self] isSearching in
            guard let self = self else { return }
            if isSearching {
                self.searchingLabel.text = ""
            } else {
                if !vm.name.value.isEmpty {
                    if vm.results.value.isEmpty {
                        self.searchingLabel.text = "\'\(vm.name.value)\'에 대한 결과가 없습니다."
                    } else {
                        self.searchingLabel.text = "\'\(vm.name.value)\'에 대한 검색 결과 입니다."
                    }
                }
            }
        }
        
        vm.selectedItem.observe(on: self) { [weak self] selectedItem in
            guard let self = self else { return }
            self.selectButton.isHidden = selectedItem == nil
        }
    }
    
    override func viewDidLoad() {
        print("viewDidLoad")
        super.viewDidLoad()
        vm.viewDidLoad()
        self.addSubViews()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        searchView.snp.makeConstraints { make in
            make.top.bottom.equalTo(self.view.safeAreaLayoutGuide)
            make.leading.trailing.equalTo(view.safeAreaLayoutGuide).inset(12)
        }
        
        selectButton.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide).inset(12)
        }
        
        searchButton.addTarget(self, action: #selector(self.onClickSearchLocation), for: .touchUpInside)
        myLocationButton.addTarget(self, action: #selector(self.onClickSearchMyLocation), for: .touchUpInside)
        selectButton.addTarget(self, action: #selector(self.onClickAddLocation), for: .touchUpInside)
        
        self.navigationItem.searchController = searchController
        searchController.searchResultsUpdater = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        vm.viewWillAppear()
    }
    
    private func addSubViews() {
        [searchView].forEach {
            self.view.addSubview($0)
        }
        [searchButton, myLocationButton, searchingLabel, tableView, selectButton].forEach {
            self.searchView.addArrangedSubview($0)
        }
    }
    
    @objc private func onClickSearchLocation() {
        print("onClickSearchLocation")
        vm.onClickSearch()
    }
    
    @objc private func onClickSearchMyLocation() {
        print("onClickSearchMyLocation")
        vm.onClickSearchMyLocation()
    }
    @objc private func onClickAddLocation() {
        print("onClickAddLocation")
        vm.onClickAddLocation()
    }
}

extension SelectLocationViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return vm.results.value.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SelectLocationCell.identifier, for: indexPath) as! SelectLocationCell
        cell.name.text = "\(self.vm.results.value[indexPath.row].localName)"
        cell.country.text = "\(self.vm.results.value[indexPath.row].country)"
        cell.value = (indexPath.row, vm.results.value[indexPath.row])
        cell.bind(vm: vm)
        let background = UIView()
        background.backgroundColor = .clear
        cell.selectedBackgroundView = background
        return cell
    }
}

extension SelectLocationViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let item = vm.selectedItem.value, item.1 == vm.results.value[indexPath.row] {
            print("DeSelect \(indexPath.row)")
            vm.selectedItem.value = nil
        } else {
            print("Select \(indexPath.row)")
            vm.selectedItem.value = (indexPath.row, vm.results.value[indexPath.row])
        }
    }
}

extension SelectLocationViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        vm.name.value = searchController.searchBar.text ?? ""
        //        print("updateSearchResults: \(vm.name.value)")
    }
}
