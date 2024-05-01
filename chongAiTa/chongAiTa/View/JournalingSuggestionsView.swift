//
//  JournalingSuggestionsView.swift
//  chongAiTa
//
//  Created by Kyle Lu on 2024/4/13.
//

import SwiftUI
import JournalingSuggestions
import CoreLocation
import MapKit


struct ContentView: View {
    @EnvironmentObject var journalData: JournalPickerData
    
    @State var suggestionTitle: String? = nil
    @State var suggestionContent = [UIImageWrapper]()
    @State var suggestionLocations: [IdentifiableLocation] = []
    @State private var region = MKCoordinateRegion()
    
    var onCompletion: ((String, [UIImage], String?, String?) -> Void)?
    
    var body: some View {
        VStack {
            Spacer()
            
            JournalingSuggestionsPicker {
                    VStack {
                        Spacer()
                        HStack {
                            Image(systemName: "lightbulb")
                                .foregroundColor(.blue)
                            Text("點選匯入 AI 日記建議")
                        }
                    }
                } onCompletion: { suggestion in
                    // 印出 suggetionPicker 夾帶的所有資料
                    print("Suggestion: \(suggestion)")
                    suggestionTitle = suggestion.title
                    loadContent(suggestion: suggestion)
                    loadLocation(suggestion: suggestion)
                }
                        
                Spacer()
                        
                Text(suggestionTitle ?? "")
            
            List {
                ForEach(suggestionContent, id: \.image) { item in
                    Image(uiImage: item.image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxHeight: 200)
                }
            }
            
            
            if !suggestionLocations.isEmpty {
                let location = suggestionLocations[0].location
                VStack(alignment: .leading) {
                    Map(coordinateRegion: $region, annotationItems: suggestionLocations) { identifiableLocation in
                        MapMarker(coordinate: identifiableLocation.location.location?.coordinate ?? CLLocationCoordinate2D())
                    }
                    .frame(height: 300)
                    
                    Text("Place: \(location.place ?? "")")
                    Text("City: \(location.city ?? "")")
                    
                    if let date = location.date {
                        Text("Date: \(date)")
                    }
                }
            }
        }
    }
    
    func loadContent(suggestion: JournalingSuggestion) {
        Task {
            let images = await suggestion.content(forType: UIImage.self)
            suggestionContent = images.map { UIImageWrapper(image: $0) }
            journalData.selectedImages = images
            onCompletion?(suggestion.title, images, nil, nil)
        }
    }
    
    
    func loadLocation(suggestion: JournalingSuggestion) {
        Task {
            if let locations = await suggestion.content(forType: JournalingSuggestion.Location.self).first {
                print("Location Place: \(locations.place ?? "")")
                print("Location City: \(locations.city ?? "")")
                let identifiableLocation = IdentifiableLocation(location: locations)
                suggestionLocations = [identifiableLocation]
                if let coordinate = locations.location?.coordinate {
                    region = MKCoordinateRegion(center: coordinate, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
                }
                onCompletion?(suggestion.title, journalData.selectedImages, locations.place, locations.city)
            } else {
                onCompletion?(suggestion.title, journalData.selectedImages, nil, nil)
            }
        }
    }

}

