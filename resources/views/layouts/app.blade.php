<!DOCTYPE html>
<html lang="{{ str_replace('_', '-', app()->getLocale()) }}">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <meta name="csrf-token" content="{{ csrf_token() }}">
    <title>@yield('title', 'FUNTASTING - Marketplace Esperienziale')</title>
    
    <!-- Fonts -->
    <link rel="preconnect" href="https://fonts.bunny.net">
    <link href="https://fonts.bunny.net/css?family=inter:400,500,600,700" rel="stylesheet" />
    
    <!-- Styles -->
    @vite(['resources/css/app.css', 'resources/js/app.js'])
    @stack('styles')
</head>
<body class="font-sans antialiased bg-gray-50">
    <!-- Navigation -->
    <nav class="bg-white shadow-sm border-b border-gray-200">
        <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
            <div class="flex justify-between h-16">
                <div class="flex items-center">
                    <a href="{{ route('home') }}" class="flex items-center">
                        <span class="text-2xl font-bold text-orange-600">FUNTASTING</span>
                    </a>
                </div>
                
                <div class="flex items-center space-x-4">
                    @auth
                        <a href="{{ route(auth()->user()->role . '.dashboard') }}" 
                           class="text-gray-700 hover:text-orange-600 px-3 py-2 rounded-md text-sm font-medium">
                            Dashboard
                        </a>
                        <form method="POST" action="{{ route('logout') }}" class="inline">
                            @csrf
                            <button type="submit" class="text-gray-700 hover:text-orange-600 px-3 py-2 rounded-md text-sm font-medium">
                                Esci
                            </button>
                        </form>
                    @else
                        <a href="{{ route('login') }}" 
                           class="text-gray-700 hover:text-orange-600 px-3 py-2 rounded-md text-sm font-medium">
                            Login
                        </a>
                        <a href="{{ route('register', 'customer') }}" 
                           class="bg-orange-600 text-white hover:bg-orange-700 px-4 py-2 rounded-md text-sm font-medium">
                            Registrati
                        </a>
                    @endauth
                </div>
            </div>
        </div>
    </nav>

    <!-- Main Content -->
    <main>
        @yield('content')
    </main>

    <!-- Footer -->
    <footer class="bg-gray-800 text-white mt-12">
        <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
            <div class="grid grid-cols-1 md:grid-cols-3 gap-8">
                <div>
                    <h3 class="text-lg font-semibold mb-4">FUNTASTING</h3>
                    <p class="text-gray-400">Marketplace esperienziale per il turismo nelle Marche</p>
                </div>
                <div>
                    <h4 class="font-semibold mb-4">Link Utili</h4>
                    <ul class="space-y-2 text-gray-400">
                        <li><a href="#" class="hover:text-white">Chi Siamo</a></li>
                        <li><a href="#" class="hover:text-white">Contatti</a></li>
                        <li><a href="#" class="hover:text-white">Privacy Policy</a></li>
                    </ul>
                </div>
                <div>
                    <h4 class="font-semibold mb-4">Per Operatori</h4>
                    <ul class="space-y-2 text-gray-400">
                        <li><a href="{{ route('register', 'vendor') }}" class="hover:text-white">Diventa Fornitore</a></li>
                        <li><a href="{{ route('register', 'reseller') }}" class="hover:text-white">Diventa Partner</a></li>
                    </ul>
                </div>
            </div>
            <div class="mt-8 pt-8 border-t border-gray-700 text-center text-gray-400">
                <p>&copy; {{ date('Y') }} FUNTASTING. Tutti i diritti riservati.</p>
            </div>
        </div>
    </footer>

    @stack('scripts')
</body>
</html>

