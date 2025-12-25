<?php

namespace App\Http\Controllers;

use App\Models\Experience;
use App\Models\Category;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class ExperienceController extends Controller
{
    /**
     * Display a listing of the resource.
     */
    public function index()
    {
        $experiences = Experience::where('vendor_id', Auth::id())
            ->latest()
            ->paginate(10);

        return view('vendor.experiences.index', compact('experiences'));
    }

    /**
     * Show the form for creating a new resource.
     */
    public function create()
    {
        $categories = Category::orderBy('name')->get();
        return view('vendor.experiences.create', compact('categories'));
    }

    /**
     * Store a newly created resource in storage.
     */
    public function store(Request $request)
    {
        $validated = $request->validate([
            'title' => 'required|string|max:255',
            'category_id' => 'required|exists:categories,id',
            'short_description' => 'required|string|max:500',
            'full_description' => 'required|string',
            'price_adult' => 'required|numeric|min:0',
            'price_child' => 'nullable|numeric|min:0',
            'price_senior' => 'nullable|numeric|min:0',
            'duration' => 'required|in:up_to_1h,1-2h,2-3h,3-5h,5h_to_1day,1-3days,more_than_3days',
            'location_type' => 'required|in:borgo,campagna,citta,fiume_lago,mare,montagna',
            'province' => 'required|in:ascoli_piceno,fermo,macerata,ancona,pesaro_urbino',
            'min_participants' => 'required|integer|min:1',
            'max_participants' => 'nullable|integer|min:1',
            'meeting_point' => 'nullable|string|max:255',
            'languages' => 'nullable|array',
            'pets_allowed' => 'boolean',
            'free_cancellation' => 'boolean',
        ]);

        $validated['vendor_id'] = Auth::id();
        $validated['user_types'] = $request->input('user_types', []);
        $validated['age_groups'] = $request->input('age_groups', []);
        $validated['status'] = 'draft';
        $validated['pets_allowed'] = $request->has('pets_allowed');
        $validated['free_cancellation'] = $request->has('free_cancellation');

        $experience = Experience::create($validated);

        return redirect()->route('vendor.experiences.index')
            ->with('success', 'Esperienza creata con successo!');
    }

    /**
     * Display the specified resource.
     */
    public function show(Experience $experience)
    {
        $experience->load(['category', 'vendor', 'reviews']);
        return view('experiences.show', compact('experience'));
    }

    /**
     * Show the form for editing the specified resource.
     */
    public function edit(Experience $experience)
    {
        // Verifica che l'esperienza appartenga al vendor autenticato
        if ($experience->vendor_id !== Auth::id()) {
            abort(403);
        }

        $categories = Category::orderBy('name')->get();
        return view('vendor.experiences.edit', compact('experience', 'categories'));
    }

    /**
     * Update the specified resource in storage.
     */
    public function update(Request $request, Experience $experience)
    {
        // Verifica che l'esperienza appartenga al vendor autenticato
        if ($experience->vendor_id !== Auth::id()) {
            abort(403);
        }

        $validated = $request->validate([
            'title' => 'required|string|max:255',
            'category_id' => 'required|exists:categories,id',
            'short_description' => 'required|string|max:500',
            'full_description' => 'required|string',
            'price_adult' => 'required|numeric|min:0',
            'price_child' => 'nullable|numeric|min:0',
            'price_senior' => 'nullable|numeric|min:0',
            'duration' => 'required|in:up_to_1h,1-2h,2-3h,3-5h,5h_to_1day,1-3days,more_than_3days',
            'location_type' => 'required|in:borgo,campagna,citta,fiume_lago,mare,montagna',
            'province' => 'required|in:ascoli_piceno,fermo,macerata,ancona,pesaro_urbino',
            'min_participants' => 'required|integer|min:1',
            'max_participants' => 'nullable|integer|min:1',
            'meeting_point' => 'nullable|string|max:255',
            'languages' => 'nullable|array',
            'pets_allowed' => 'boolean',
            'free_cancellation' => 'boolean',
        ]);

        $validated['user_types'] = $request->input('user_types', []);
        $validated['age_groups'] = $request->input('age_groups', []);
        $validated['pets_allowed'] = $request->has('pets_allowed');
        $validated['free_cancellation'] = $request->has('free_cancellation');

        $experience->update($validated);

        return redirect()->route('vendor.experiences.index')
            ->with('success', 'Esperienza aggiornata con successo!');
    }

    /**
     * Remove the specified resource from storage.
     */
    public function destroy(Experience $experience)
    {
        // Verifica che l'esperienza appartenga al vendor autenticato
        if ($experience->vendor_id !== Auth::id()) {
            abort(403);
        }

        $experience->delete();

        return redirect()->route('vendor.experiences.index')
            ->with('success', 'Esperienza eliminata con successo!');
    }
}
