//
//  Chart.swift
//  Bill-Splitting
//
//  Created by 雷翎 on 2022/4/24.
//

import UIKit
import Charts

class PieChart: UIView {
 
    var chartView: PieChartView!
    var pieChartDataEntries = [PieChartDataEntry]()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
    }
 
    override func layoutSubviews() {
        super.layoutSubviews()
        setPieChart()
    }
    
    func setPieChart() {
        chartView = PieChartView()

        addSubview(chartView)
        chartView.translatesAutoresizingMaskIntoConstraints = false
        chartView.topAnchor.constraint(equalTo: self.topAnchor, constant: 0).isActive = true
        chartView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0).isActive = true
        chartView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 0).isActive = true
        chartView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0).isActive = true
        
        let set = PieChartDataSet(entries: pieChartDataEntries, label: "成員")
        set.colors = ChartColorTemplates.liberty()
        let data = PieChartData(dataSet: set)
        chartView.data = data
        chartView.rotationEnabled = false
        chartView.drawHoleEnabled = false
        chartView.animate(xAxisDuration: 2.0, yAxisDuration: 2.0)
        
        let formatter = NumberFormatter()
        formatter.positivePrefix = "$"
        data.setValueFormatter(DefaultValueFormatter(formatter: formatter))
        data.setValueTextColor(.systemGray)
    }
    
}
