<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\ExperienceController;
use App\Http\Controllers\BookingController;
use App\Http\Controllers\SearchController;
use App\Http\Controllers\Auth\RegisterController;
use App\Http\Controllers\Auth\LoginController;

// Route pubbliche
Route::get('/', [SearchController::class, 'index'])->name('home');
Route::get('/search', [SearchController::class, 'search'])->name('search');
Route::get('/experiences/{experience}', [ExperienceController::class, 'show'])->name('experiences.show');

// Route autenticazione
Route::middleware('guest')->group(function () {
    Route::get('/login', [LoginController::class, 'showLoginForm'])->name('login');
    Route::post('/login', [LoginController::class, 'login']);
    Route::get('/register/{role?}', [RegisterController::class, 'showRegistrationForm'])->name('register');
    Route::post('/register', [RegisterController::class, 'register'])->name('register.submit');
});

Route::post('/logout', [LoginController::class, 'logout'])->name('logout')->middleware('auth');

// Route per clienti B2C
Route::middleware(['auth', 'role:customer'])->prefix('customer')->name('customer.')->group(function () {
    Route::get('/dashboard', function () {
        return view('customer.dashboard');
    })->name('dashboard');
    Route::get('/bookings', [BookingController::class, 'index'])->name('bookings');
    Route::post('/bookings', [BookingController::class, 'store'])->name('bookings.store');
    Route::get('/bookings/{booking}', [BookingController::class, 'show'])->name('bookings.show');
});

// Route per Vendor B2B
Route::middleware(['auth', 'role:vendor'])->prefix('vendor')->name('vendor.')->group(function () {
    Route::get('/dashboard', function () {
        return view('vendor.dashboard');
    })->name('dashboard');
    Route::resource('experiences', ExperienceController::class);
    Route::get('/bookings', [BookingController::class, 'index'])->name('bookings');
    Route::post('/bookings/{booking}/check-in', [BookingController::class, 'checkIn'])->name('bookings.check-in');
});

// Route per Reseller B2B
Route::middleware(['auth', 'role:reseller'])->prefix('reseller')->name('reseller.')->group(function () {
    Route::get('/dashboard', function () {
        return view('reseller.dashboard');
    })->name('dashboard');
    Route::get('/catalog', [SearchController::class, 'catalog'])->name('catalog');
    Route::post('/bookings', [BookingController::class, 'store'])->name('bookings.store');
    Route::get('/commissions', function () {
        return view('reseller.commissions');
    })->name('commissions');
});

// Route per Admin
Route::middleware(['auth', 'role:admin'])->prefix('admin')->name('admin.')->group(function () {
    Route::get('/dashboard', function () {
        return view('admin.dashboard');
    })->name('dashboard');
    Route::get('/vendors', function () {
        return view('admin.vendors');
    })->name('vendors');
    Route::get('/experiences', [ExperienceController::class, 'index'])->name('experiences');
});
