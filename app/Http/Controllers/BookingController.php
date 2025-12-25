<?php

namespace App\Http\Controllers;

use App\Models\Booking;
use App\Models\Experience;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Str;

class BookingController extends Controller
{
    /**
     * Display a listing of the resource.
     */
    public function index()
    {
        $user = Auth::user();
        
        // Se è un customer, mostra le sue prenotazioni
        if ($user->role === 'customer') {
            $bookings = $user->bookings()->with('experience')->latest()->get();
            return view('customer.bookings.index', compact('bookings'));
        }
        
        // Se è un vendor, mostra le prenotazioni delle sue esperienze
        if ($user->role === 'vendor') {
            return view('vendor.bookings.index');
        }
        
        abort(403);
    }

    /**
     * Store a newly created resource in storage.
     */
    public function store(Request $request)
    {
        $validated = $request->validate([
            'experience_id' => 'required|exists:experiences,id',
            'booking_date' => 'required|date|after_or_equal:today',
            'num_adults' => 'required|integer|min:1',
            'num_children' => 'nullable|integer|min:0',
            'num_seniors' => 'nullable|integer|min:0',
        ]);

        $experience = Experience::findOrFail($validated['experience_id']);
        
        // Calcola il totale
        $total = ($validated['num_adults'] * $experience->price_adult) +
                 (($validated['num_children'] ?? 0) * ($experience->price_child ?? $experience->price_adult)) +
                 (($validated['num_seniors'] ?? 0) * ($experience->price_senior ?? $experience->price_adult));
        
        $totalParticipants = $validated['num_adults'] + 
                            ($validated['num_children'] ?? 0) + 
                            ($validated['num_seniors'] ?? 0);

        // Verifica partecipanti minimi/massimi
        if ($totalParticipants < $experience->min_participants) {
            return back()->withErrors(['num_adults' => 'Numero minimo di partecipanti: ' . $experience->min_participants]);
        }
        
        if ($experience->max_participants && $totalParticipants > $experience->max_participants) {
            return back()->withErrors(['num_adults' => 'Numero massimo di partecipanti: ' . $experience->max_participants]);
        }

        $booking = Booking::create([
            'booking_code' => 'BK' . strtoupper(Str::random(8)),
            'experience_id' => $validated['experience_id'],
            'customer_id' => Auth::id(),
            'reseller_id' => Auth::user()->role === 'reseller' ? Auth::id() : null,
            'experience_date' => $validated['booking_date'],
            'adults' => $validated['num_adults'],
            'children' => $validated['num_children'] ?? 0,
            'seniors' => $validated['num_seniors'] ?? 0,
            'total_participants' => $totalParticipants,
            'total_amount' => $total,
            'commission_amount' => Auth::user()->role === 'reseller' && Auth::user()->reseller 
                ? $total * (Auth::user()->reseller->commission_rate ?? 0.10) 
                : 0,
            'status' => 'pending',
            'payment_status' => 'pending',
        ]);

        return redirect()->route('customer.bookings.show', $booking)
            ->with('success', 'Prenotazione creata con successo!');
    }

    /**
     * Display the specified resource.
     */
    public function show(Booking $booking)
    {
        // Verifica che l'utente possa vedere questa prenotazione
        if (Auth::user()->role === 'customer' && $booking->customer_id !== Auth::id()) {
            abort(403);
        }
        
        if (Auth::user()->role === 'vendor' && $booking->experience->vendor_id !== Auth::id()) {
            abort(403);
        }

        $booking->load(['experience', 'customer']);
        return view('customer.bookings.show', compact('booking'));
    }

    /**
     * Check-in per vendor
     */
    public function checkIn(Request $request, Booking $booking)
    {
        // Verifica che l'esperienza appartenga al vendor
        if ($booking->experience->vendor_id !== Auth::id()) {
            abort(403);
        }

        $booking->update([
            'checked_in' => true,
            'checked_in_at' => now(),
            'status' => 'completed',
        ]);

        return back()->with('success', 'Check-in effettuato con successo!');
    }
}
