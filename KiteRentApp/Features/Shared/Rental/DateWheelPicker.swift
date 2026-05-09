//
//  DateWheelPicker.swift
//  KiteRentApp
//
//  Created by Filip on 11/12/2025.
//

import SwiftUI

struct DateWheelPicker: View {
    @Binding var selectedDate: Date?
    
    private let today = Calendar.current.startOfDay(for: Date())
    
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(-90...0, id: \.self) { offset in
                        if let date = Calendar.current.date(byAdding: .day, value: offset, to: today) {
                            DatePillView(date: date, selectedDate: $selectedDate)
                                .id(date)
                        }
                    }
                    AllPillView(selectedDate: $selectedDate)
                }
                .padding(.horizontal)
                .padding(.vertical, 4)
            }
            .onAppear {
                if let date = selectedDate {
                    proxy.scrollTo(date, anchor: .center)
                }
            }
            .onChange(of: selectedDate) {_, newDate in
                if let date = newDate {
                    withAnimation {
                        proxy.scrollTo(Calendar.current.startOfDay(for: date), anchor: .center)
                    }
                }
            }
        }
    }
}

struct DatePillView: View {
    let date: Date
    @Binding var selectedDate: Date?
    
    private var isSelected: Bool {
        guard let selected = selectedDate else { return false }
        return Calendar.current.isDate(date, inSameDayAs: selected)
    }
    
    private var isToday: Bool {
        Calendar.current.isDateInToday(date)
    }
    
    var body: some View {
        Button {
            selectedDate = date
        } label: {
            VStack(spacing: 2) {
   
                Text(date.formatted(.dateTime.weekday(.abbreviated).locale(Locale(identifier: "pl_PL"))).uppercased())
                    .font(.caption2)
                    .fontWeight(.medium)
                
                Text("\(date.formatted(.dateTime.day())).\(Text(date.formatted(.dateTime.month(.twoDigits))))")
                    .font(.subheadline)
                    .fontWeight(.bold)
            }
            .padding(8)
            .frame(minWidth: 50)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(isSelected ? .blue : .gray.opacity(0.1))
            )
            .foregroundColor(isSelected ? .white : (isToday ? .blue : .primary))
        }
        .buttonStyle(.plain)
    }
}

struct AllPillView: View {
    @Binding var selectedDate: Date?
    
    private var isSelected: Bool { selectedDate == nil }
    
    var body: some View {
        Button {
            selectedDate = nil
        } label: {
            VStack(spacing: 2) {
                Text("ALL")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .padding(.vertical, 10)
            }
            .padding(.horizontal, 8)
            .frame(minWidth: 50)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(isSelected ? .blue : .gray.opacity(0.1))
            )
            .foregroundColor(isSelected ? .white : .primary)
        }
        .buttonStyle(.plain)
    }
}
