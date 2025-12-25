<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\Experience;
use App\Models\Category;

class SearchController extends Controller
{
    public function index()
    {
        $categories = Category::orderBy('name')->get();
        $experiences = Experience::with(['category', 'vendor'])
            ->latest()
            ->take(12)
            ->get();

        return view('search.index', compact('categories', 'experiences'));
    }

    public function search(Request $request)
    {
        $query = Experience::with(['category', 'vendor']);

        // Filtro categoria
        if ($request->filled('category_id')) {
            $query->where('category_id', $request->category_id);
        }

        // Filtro prezzo
        if ($request->filled('max_price')) {
            $query->where('price_adult', '<=', $request->max_price);
        }

        // Filtro provincia/destinazione
        if ($request->filled('province')) {
            $query->whereJsonContains('destinations', $request->province);
        }

        // Ordinamento
        $sort = $request->get('sort', 'newest');
        switch ($sort) {
            case 'price_asc':
                $query->orderBy('price_adult', 'asc');
                break;
            case 'price_desc':
                $query->orderBy('price_adult', 'desc');
                break;
            default:
                $query->orderBy('created_at', 'desc');
        }

        $experiences = $query->paginate(12);
        $categories = Category::orderBy('name')->get();

        return view('search.results', compact('experiences', 'categories'));
    }

    public function catalog(Request $request)
    {
        // Catalogo curated per Reseller
        $query = Experience::with(['category', 'vendor']);

        if ($request->filled('search')) {
            $query->where('title', 'like', '%' . $request->search . '%');
        }

        $experiences = $query->latest()->paginate(20);

        return view('reseller.catalog', compact('experiences'));
    }
}
