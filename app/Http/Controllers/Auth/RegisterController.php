<?php

namespace App\Http\Controllers\Auth;

use App\Http\Controllers\Controller;
use App\Models\User;
use App\Models\Vendor;
use App\Models\Reseller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Validation\Rules;

class RegisterController extends Controller
{
    public function showRegistrationForm($role = 'customer')
    {
        $allowedRoles = ['customer', 'vendor', 'reseller'];
        if (!in_array($role, $allowedRoles)) {
            $role = 'customer';
        }

        return view('auth.register', compact('role'));
    }

    public function register(Request $request)
    {
        $validated = $request->validate([
            'name' => ['required', 'string', 'max:255'],
            'email' => ['required', 'string', 'email', 'max:255', 'unique:users'],
            'password' => ['required', 'confirmed', Rules\Password::defaults()],
            'role' => ['required', 'in:customer,vendor,reseller'],
            'phone' => ['nullable', 'string', 'max:20'],
        ]);

        $user = User::create([
            'name' => $validated['name'],
            'email' => $validated['email'],
            'password' => Hash::make($validated['password']),
            'role' => $validated['role'],
            'phone' => $validated['phone'] ?? null,
        ]);

        // Crea profilo specifico in base al ruolo
        if ($user->role === 'vendor') {
            Vendor::create([
                'user_id' => $user->id,
                'company_name' => $request->company_name ?? $user->name,
                'email' => $user->email,
                'kyc_status' => 'pending',
            ]);
        } elseif ($user->role === 'reseller') {
            Reseller::create([
                'user_id' => $user->id,
                'company_name' => $request->company_name ?? $user->name,
                'email' => $user->email,
            ]);
        }

        auth()->login($user);

        return redirect()->route($user->role . '.dashboard')
            ->with('success', 'Registrazione completata con successo!');
    }
}
