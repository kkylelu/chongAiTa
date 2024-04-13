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
    @EnvironmentObject var journalData: JournalData
    
    @State var suggestionTitle: String? = nil
    @State var suggestionContent = [UIImageWrapper]()
    @State var suggestionLocations: [IdentifiableLocation] = []
    @State private var region = MKCoordinateRegion()
    
    var onCompletion: ((String) -> Void)?

    var body: some View {
           VStack {
               Spacer().frame(height: 25)
               
//               if journalData.showPicker {
                   JournalingSuggestionsPicker {
                       Text("Select Journaling Suggestion")
                   } onCompletion: { suggestion in
                       onCompletion?(suggestion.title ?? "No title")
                       suggestionTitle = suggestion.title
                       loadContent(suggestion: suggestion)
                       loadLocation(suggestion: suggestion)
//                       journalData.showPicker = false // 完成後關閉 picker
//                   }
               }
               
               Spacer().frame(height: 25)
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
    
    private func loadContent(suggestion: JournalingSuggestion) {
        Task {
            suggestionContent = await suggestion.content(forType: UIImage.self).map { UIImageWrapper(image: $0) }
        }
    }
    
    private func loadLocation(suggestion: JournalingSuggestion) {
        Task {
            if let locations = await suggestion.content(forType: JournalingSuggestion.Location.self).first {
                let identifiableLocation = IdentifiableLocation(location: locations)
                suggestionLocations = [identifiableLocation]
                if let coordinate = locations.location?.coordinate {
                    region = MKCoordinateRegion(center: coordinate, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
                }
            }
        }
    }
}

