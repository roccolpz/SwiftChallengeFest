//
//  SearchBar.swift
//  SwiftChallengeFestMaCabados
//
//  Created by Isaac Rojas on 07/06/25.
//
import SwiftUI

struct SearchBar: View {
    @Binding var text: String
    var placeholder: String = "Buscar alimentos..."
    var onSearchButtonClicked: (() -> Void)?
    var onCancelButtonClicked: (() -> Void)?
    
    @State private var isEditing = false
    @FocusState private var isFocused: Bool
    
    var body: some View {
        HStack {
            // Campo de búsqueda
            HStack {
                // Icono de búsqueda
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                    .font(.system(size: 16, weight: .medium))
                
                // TextField
                TextField(placeholder, text: $text)
                    .focused($isFocused)
                    .textFieldStyle(PlainTextFieldStyle())
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            isEditing = true
                        }
                    }
                    .onSubmit {
                        onSearchButtonClicked?()
                    }
                
                // Botón limpiar
                if !text.isEmpty {
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            text = ""
                        }
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                            .font(.system(size: 16))
                    }
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(.systemGray6))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(isEditing ? ColorHelper.Principal.primario : Color.clear, lineWidth: 1)
            )
            
            // Botón cancelar
            if isEditing {
                Button("Cancelar") {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        isEditing = false
                        text = ""
                        isFocused = false
                        onCancelButtonClicked?()
                    }
                }
                .font(.subheadline)
                .foregroundColor(ColorHelper.Principal.primario)
                .transition(.move(edge: .trailing).combined(with: .opacity))
            }
        }
        .onChange(of: isFocused) { focused in
            withAnimation(.easeInOut(duration: 0.2)) {
                if !focused && text.isEmpty {
                    isEditing = false
                }
            }
        }
    }
}

// MARK: - Búsqueda con Filtros
struct SearchBarWithFilters: View {
    @Binding var searchText: String
    @Binding var selectedCategory: CategoriaAlimento?
    var placeholder: String = "Buscar alimentos..."
    var onSearchChanged: ((String) -> Void)?
    var onCategoryChanged: ((CategoriaAlimento?) -> Void)?
    
    @State private var showingFilters = false
    
    var body: some View {
        VStack(spacing: 12) {
            // Barra de búsqueda principal
            HStack {
                SearchBar(
                    text: $searchText,
                    placeholder: placeholder,
                    onSearchButtonClicked: {
                        onSearchChanged?(searchText)
                    }
                )
                
                // Botón de filtros
                Button(action: {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                        showingFilters.toggle()
                    }
                }) {
                    Image(systemName: showingFilters ? "line.3.horizontal.decrease.circle.fill" : "line.3.horizontal.decrease.circle")
                        .font(.title3)
                        .foregroundColor(selectedCategory != nil ? ColorHelper.Principal.primario : .secondary)
                }
            }
            
            // Filtros de categoría
            if showingFilters {
                categoryFilters
                    .transition(.asymmetric(
                        insertion: .move(edge: .top).combined(with: .opacity),
                        removal: .move(edge: .top).combined(with: .opacity)
                    ))
            }
        }
        .onChange(of: searchText) { newValue in
            onSearchChanged?(newValue)
        }
        .onChange(of: selectedCategory) { newValue in
            onCategoryChanged?(newValue)
        }
    }
    
    private var categoryFilters: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                // Botón "Todos"
                CategoryFilterChip(
                    title: "Todos",
                    isSelected: selectedCategory == nil,
                    color: .gray
                ) {
                    selectedCategory = nil
                }
                
                // Categorías
                ForEach(CategoriaAlimento.allCases, id: \.self) { categoria in
                    CategoryFilterChip(
                        title: categoria.rawValue,
                        isSelected: selectedCategory == categoria,
                        color: ColorHelper.Categorias.colorPorCategoria(categoria)
                    ) {
                        selectedCategory = selectedCategory == categoria ? nil : categoria
                    }
                }
            }
            .padding(.horizontal, 16)
        }
    }
}

// MARK: - Chip de Filtro
struct CategoryFilterChip: View {
    let title: String
    let isSelected: Bool
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(isSelected ? .white : color)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(isSelected ? color : color.opacity(0.1))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(color, lineWidth: isSelected ? 0 : 1)
                )
        }
        .scaleEffect(isSelected ? 1.05 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
    }
}

// MARK: - Búsqueda con Sugerencias
struct SearchBarWithSuggestions: View {
    @Binding var searchText: String
    let suggestions: [String]
    var placeholder: String = "Buscar..."
    var onSuggestionSelected: ((String) -> Void)?
    var onSearchChanged: ((String) -> Void)?
    
    @State private var showingSuggestions = false
    @FocusState private var isSearchFocused: Bool
    
    var filteredSuggestions: [String] {
        if searchText.isEmpty {
            return suggestions.prefix(5).map { $0 }
        } else {
            return suggestions.filter {
                $0.localizedCaseInsensitiveContains(searchText)
            }.prefix(5).map { $0 }
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Barra de búsqueda
            SearchBar(
                text: $searchText,
                placeholder: placeholder,
                onSearchButtonClicked: {
                    showingSuggestions = false
                    onSearchChanged?(searchText)
                }
            )
            .focused($isSearchFocused)
            
            // Sugerencias
            if showingSuggestions && !filteredSuggestions.isEmpty {
                suggestionsList
                    .transition(.asymmetric(
                        insertion: .move(edge: .top).combined(with: .opacity),
                        removal: .move(edge: .top).combined(with: .opacity)
                    ))
            }
        }
        .onChange(of: isSearchFocused) { focused in
            withAnimation(.easeInOut(duration: 0.2)) {
                showingSuggestions = focused
            }
        }
        .onChange(of: searchText) { newValue in
            onSearchChanged?(newValue)
        }
    }
    
    private var suggestionsList: some View {
        VStack(spacing: 0) {
            ForEach(filteredSuggestions, id: \.self) { suggestion in
                Button(action: {
                    searchText = suggestion
                    showingSuggestions = false
                    isSearchFocused = false
                    onSuggestionSelected?(suggestion)
                }) {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.secondary)
                            .font(.system(size: 14))
                        
                        Text(suggestion)
                            .font(.subheadline)
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        Image(systemName: "arrow.up.left")
                            .foregroundColor(.secondary)
                            .font(.system(size: 12))
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(Color(.systemBackground))
                }
                
                if suggestion != filteredSuggestions.last {
                    Divider()
                        .padding(.leading, 48)
                }
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
        )
        .padding(.top, 4)
    }
}

// MARK: - Previews
#Preview("SearchBar Simple") {
    VStack(spacing: 20) {
        SearchBar(text: .constant(""))
        SearchBar(text: .constant("Arroz"))
    }
    .padding()
}

#Preview("SearchBar con Filtros") {
    SearchBarWithFilters(
        searchText: .constant(""),
        selectedCategory: .constant(nil)
    )
    .padding()
}

#Preview("SearchBar con Sugerencias") {
    SearchBarWithSuggestions(
        searchText: .constant(""),
        suggestions: ["Arroz blanco", "Arroz integral", "Pollo", "Brócoli", "Manzana"],
        placeholder: "Buscar alimentos..."
    )
    .padding()
}
